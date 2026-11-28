/**
 * `POST /v1/notify` with `Authorization: Bearer <Firebase ID token>`.
 *
 * The app calls it right after a write to Firestore succeeds. The request
 * only says what happened; the Worker reads the documents to check that
 * the caller really did it, picks the recipients and sends each
 * notification once (see `events.ts`).
 */
import {
  auditCheckFor,
  type Delivery,
  EventError,
  memberDelivery,
  movementDelivery,
  type NotifyRequest,
  parseRequest,
} from './events';
import { sendData } from './fcm';
import { Firestore } from './firestore';
import { str } from './firestore_value';
import { accessToken, verifyIdToken } from './google';

export interface Env {
  FIREBASE_PROJECT_ID: string;
  /** Whole JSON key of the service account (a Wrangler secret). */
  FIREBASE_SERVICE_ACCOUNT: string;
}

const json = (status: number, body: Record<string, unknown>) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { 'content-type': 'application/json' },
  });

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    if (url.pathname !== '/v1/notify') return json(404, { error: 'not found' });
    if (request.method !== 'POST') return json(405, { error: 'method not allowed' });

    const header = request.headers.get('authorization') ?? '';
    const idToken = header.startsWith('Bearer ') ? header.slice(7) : '';
    let caller: string;
    try {
      caller = await verifyIdToken(idToken, env.FIREBASE_PROJECT_ID);
    } catch {
      return json(401, { error: 'invalid token' });
    }

    try {
      const notify = parseRequest(await request.json().catch(() => null));
      const db = new Firestore(
        env.FIREBASE_PROJECT_ID,
        await accessToken(env.FIREBASE_SERVICE_ACCOUNT),
      );
      const deliveries = await resolve(db, notify, caller);
      const sent = await Promise.all(
        deliveries.map((delivery) => deliver(db, env, notify, caller, delivery)),
      );
      return json(200, { sent: sent.reduce((a, b) => a + b, 0) });
    } catch (error) {
      if (error instanceof EventError) {
        return json(error.status, { error: error.message });
      }
      console.error('notify failed', error);
      return json(500, { error: 'internal error' });
    }
  },
} satisfies ExportedHandler<Env>;

/** Reads what the request refers to and turns it into deliveries. */
async function resolve(
  db: Firestore,
  notify: NotifyRequest,
  caller: string,
): Promise<Delivery[]> {
  const groupPath = `groups/${notify.groupId}`;
  const [group, actor] = await Promise.all([
    db.get(groupPath),
    db.get(`users/${caller}`),
  ]);
  if (group === null) throw new EventError(404, 'group not found');

  if ('movementIds' in notify) {
    const movements = await Promise.all(
      notify.movementIds.map((id) => db.get(`${groupPath}/movements/${id}`)),
    );
    return movements.map((movement) => {
      if (movement === null) throw new EventError(404, 'movement not found');
      return movementDelivery(notify.type, { caller, group, actor, movement });
    });
  }

  const subject = 'memberUid' in notify ? notify.memberUid : caller;
  const [member, target] = await Promise.all([
    db.get(`${groupPath}/members/${subject}`),
    subject === caller ? Promise.resolve(actor) : db.get(`users/${subject}`),
  ]);
  const check = auditCheckFor(notify, caller, member);
  const audited =
    check !== null &&
    (await db.exists(groupPath, 'auditLog', {
      entityId: { stringValue: check.entityId },
      action: { stringValue: check.action },
      uid: { stringValue: caller },
      timestamp: { timestampValue: check.timestamp },
    }));
  return [
    memberDelivery(notify, { caller, group, actor, member, target, audited }),
  ];
}

/** Sends [delivery] unless it was sent before; returns the messages sent. */
async function deliver(
  db: Firestore,
  env: Env,
  notify: NotifyRequest,
  caller: string,
  delivery: Delivery,
): Promise<number> {
  if (delivery.recipients.length === 0) return 0;
  const first = await db.createIfAbsent('notificationLog', delivery.key, {
    type: delivery.data.type,
    groupId: notify.groupId,
    actorUid: caller,
    recipients: delivery.recipients,
    sentAt: new Date(),
  });
  if (!first) return 0;

  const token = await accessToken(env.FIREBASE_SERVICE_ACCOUNT);
  const counts = await Promise.all(
    delivery.recipients.map(async (uid) => {
      const devices = (await db.list(`users/${uid}/fcmTokens`)).filter(
        (device) => device.data.deletedAt == null,
      );
      const results = await Promise.all(
        devices.map(async (device) => {
          const deviceToken = str(device.data, 'token') ?? device.id;
          const result = await sendData(env.FIREBASE_PROJECT_ID, token, deviceToken, {
            ...delivery.data,
            recipientUid: uid,
          });
          if (result === 'unregistered') {
            // Soft delete, like everything else.
            await db.update(`users/${uid}/fcmTokens/${device.id}`, {
              deletedAt: new Date(),
            });
          }
          return result === 'sent' ? 1 : 0;
        }),
      );
      return results.reduce<number>((a, b) => a + b, 0);
    }),
  );
  return counts.reduce((a, b) => a + b, 0);
}
