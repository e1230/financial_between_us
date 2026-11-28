/**
 * What each notification request means: whether the caller really did it
 * (checked against the documents, never against the request), who gets
 * it and the key that keeps it from being sent twice. Pure: the documents
 * are read by `index.ts`.
 */
import { type Doc, int, str, strings } from './firestore_value';

export const movementEventTypes = [
  'movement.created',
  'movement.rejected',
  'movement.deleted',
] as const;
export const selfMemberEventTypes = [
  'member.joined',
  'member.requested',
  'member.left',
] as const;
export const adminMemberEventTypes = [
  'member.approved',
  'member.removed',
] as const;

export type MovementEventType = (typeof movementEventTypes)[number];
export type SelfMemberEventType = (typeof selfMemberEventTypes)[number];
export type AdminMemberEventType = (typeof adminMemberEventTypes)[number];

export type NotifyRequest =
  | { type: MovementEventType; groupId: string; movementIds: string[] }
  | { type: SelfMemberEventType; groupId: string }
  | { type: AdminMemberEventType; groupId: string; memberUid: string };

/** One notification: the same data for every recipient. */
export interface Delivery {
  /** Id of its `notificationLog` document. */
  key: string;
  recipients: string[];
  data: Record<string, string>;
}

/** A request that must not send anything. */
export class EventError extends Error {
  constructor(
    readonly status: 400 | 403 | 404 | 409,
    message: string,
  ) {
    super(message);
  }
}

/** A movement payment from "Todos los grupos" writes one per group. */
export const maxMovementsPerRequest = 10;

const idPattern = /^[A-Za-z0-9_-]{1,128}$/;

function isId(value: unknown): value is string {
  return typeof value === 'string' && idPattern.test(value);
}

function isOneOf<T extends string>(
  values: readonly T[],
  value: unknown,
): value is T {
  return typeof value === 'string' && (values as readonly string[]).includes(value);
}

export function parseRequest(body: unknown): NotifyRequest {
  if (typeof body !== 'object' || body === null) {
    throw new EventError(400, 'body must be an object');
  }
  const { type, groupId, movementIds, memberUid } = body as Record<
    string,
    unknown
  >;
  if (!isId(groupId)) throw new EventError(400, 'invalid groupId');
  if (isOneOf(movementEventTypes, type)) {
    if (
      !Array.isArray(movementIds) ||
      movementIds.length === 0 ||
      movementIds.length > maxMovementsPerRequest ||
      !movementIds.every(isId)
    ) {
      throw new EventError(400, 'invalid movementIds');
    }
    return { type, groupId, movementIds: [...new Set(movementIds)] };
  }
  if (isOneOf(selfMemberEventTypes, type)) return { type, groupId };
  if (isOneOf(adminMemberEventTypes, type)) {
    if (!isId(memberUid)) throw new EventError(400, 'invalid memberUid');
    return { type, groupId, memberUid };
  }
  throw new EventError(400, 'unknown type');
}

/** "Santiago Ruiz", or the nickname when there is no name. */
export function displayName(profile: Doc | null): string {
  if (profile === null) return '';
  const name = str(profile.data, 'displayName')?.trim() ?? '';
  return name.length > 0 ? name : (str(profile.data, 'nickname') ?? '');
}

/** Admins in promotion order; older groups only have the owner. */
export function adminsOf(group: Doc): string[] {
  const admins = strings(group.data, 'admins');
  if (admins.length > 0) return admins;
  const owner = str(group.data, 'ownerUid');
  return owner === null ? [] : [owner];
}

/** A timestamp as a document id fragment (`20261127T101500123456Z`). */
export function stamp(timestamp: string | null): string {
  if (timestamp === null) throw new EventError(409, 'missing timestamp');
  return timestamp.replace(/[^0-9A-Za-z]/g, '');
}

function without(uids: string[], ...excluded: string[]): string[] {
  return [...new Set(uids)].filter((uid) => !excluded.includes(uid));
}

function baseData(
  type: string,
  group: Doc,
  actorUid: string,
  actorName: string,
): Record<string, string> {
  return {
    type,
    groupId: group.id,
    groupName: str(group.data, 'name') ?? '',
    actorUid,
    actorName,
  };
}

export interface MovementContext {
  caller: string;
  group: Doc;
  actor: Doc | null;
  movement: Doc;
}

export function movementDelivery(
  type: MovementEventType,
  { caller, group, actor, movement }: MovementContext,
): Delivery {
  const m = movement.data;
  const participants = strings(m, 'participants');
  const debtor = str(m, 'debtorUid');
  const creditor = str(m, 'creditorUid');
  const createdBy = str(m, 'createdBy');
  const status = str(m, 'status');
  const amount = int(m, 'amount');
  if (
    debtor === null ||
    creditor === null ||
    createdBy === null ||
    amount === null ||
    !participants.includes(caller)
  ) {
    throw new EventError(403, 'not a party of the movement');
  }
  const other = caller === debtor ? creditor : debtor;

  let recipient: string;
  let prefix: string;
  switch (type) {
    case 'movement.created':
      if (createdBy !== caller) throw new EventError(403, 'not its author');
      if (status !== 'active') throw new EventError(409, 'not active');
      recipient = other;
      prefix = 'mc';
      break;
    case 'movement.rejected':
      if (status !== 'rejected' || str(m, 'rejectedBy') !== caller) {
        throw new EventError(409, 'not rejected by the caller');
      }
      recipient = createdBy;
      prefix = 'mr';
      break;
    case 'movement.deleted':
      if (createdBy !== caller) throw new EventError(403, 'not its author');
      if (status !== 'deleted') throw new EventError(409, 'not deleted');
      recipient = other;
      prefix = 'md';
      break;
  }

  const data: Record<string, string> = {
    ...baseData(type, group, caller, displayName(actor)),
    movementId: movement.id,
    movementType: str(m, 'type') ?? '',
    debtorUid: debtor,
    creditorUid: creditor,
    amount: String(amount),
    concept: str(m, 'concept') ?? '',
  };
  if (type === 'movement.rejected') {
    data.rejectReason = str(m, 'rejectReason') ?? '';
  }
  return {
    key: `${prefix}_${group.id}_${movement.id}`,
    recipients: without([recipient], caller),
    data,
  };
}

/** The audit entry that tells a leave or a removal from a cancelled or
 * rejected request (both end with the same member document). */
export interface AuditCheck {
  entityId: string;
  action: string;
  timestamp: string;
}

export function auditCheckFor(
  request: NotifyRequest,
  caller: string,
  member: Doc | null,
): AuditCheck | null {
  if (member === null) return null;
  switch (request.type) {
    case 'member.left': {
      const leftAt = str(member.data, 'leftAt');
      return leftAt === null
        ? null
        : { entityId: caller, action: 'leave', timestamp: leftAt };
    }
    case 'member.removed': {
      const removedAt = str(member.data, 'removedAt');
      return removedAt === null
        ? null
        : { entityId: request.memberUid, action: 'remove', timestamp: removedAt };
    }
    default:
      return null;
  }
}

export interface MemberContext {
  caller: string;
  group: Doc;
  actor: Doc | null;
  /** `members/{uid}` of the caller, or of the target for admin events. */
  member: Doc | null;
  /** Profile of the target of an admin event. */
  target: Doc | null;
  /** The audit entry of [auditCheckFor] exists. */
  audited: boolean;
}

export function memberDelivery(
  request: Exclude<NotifyRequest, { type: MovementEventType }>,
  { caller, group, actor, member, target, audited }: MemberContext,
): Delivery {
  if (member === null) throw new EventError(404, 'member not found');
  const status = str(member.data, 'status');
  const members = strings(group.data, 'members');
  const actorName = displayName(actor);
  const gid = group.id;

  switch (request.type) {
    case 'member.joined': {
      if (status !== 'active' || !members.includes(caller)) {
        throw new EventError(409, 'not an active member');
      }
      return {
        // Shared with `member.approved`, so a member is announced once.
        key: `mj_${gid}_${caller}_${stamp(str(member.data, 'joinedAt'))}`,
        recipients: without(members, caller),
        data: {
          ...baseData(request.type, group, caller, actorName),
          memberUid: caller,
          memberName: actorName,
        },
      };
    }
    case 'member.requested': {
      if (
        status !== 'pending' ||
        !strings(group.data, 'pendingMembers').includes(caller)
      ) {
        throw new EventError(409, 'not a pending member');
      }
      return {
        key: `mq_${gid}_${caller}_${stamp(str(member.data, 'joinedAt'))}`,
        recipients: without(adminsOf(group), caller),
        data: {
          ...baseData(request.type, group, caller, actorName),
          memberUid: caller,
          memberName: actorName,
        },
      };
    }
    case 'member.left': {
      if (status !== 'left' || members.includes(caller) || !audited) {
        throw new EventError(409, 'did not leave as a member');
      }
      return {
        key: `ml_${gid}_${caller}_${stamp(str(member.data, 'leftAt'))}`,
        recipients: without(members, caller),
        data: {
          ...baseData(request.type, group, caller, actorName),
          memberUid: caller,
          memberName: actorName,
        },
      };
    }
    case 'member.approved':
    case 'member.removed':
      break;
  }

  const targetUid = request.memberUid;
  if (!adminsOf(group).includes(caller)) throw new EventError(403, 'not an admin');
  const data = {
    ...baseData(request.type, group, caller, actorName),
    memberUid: targetUid,
    memberName: displayName(target),
  };
  if (request.type === 'member.approved') {
    if (status !== 'active' || !members.includes(targetUid)) {
      throw new EventError(409, 'not approved');
    }
    return {
      key: `mj_${gid}_${targetUid}_${stamp(str(member.data, 'joinedAt'))}`,
      recipients: without(members, caller),
      data,
    };
  }
  if (
    status !== 'removed' ||
    str(member.data, 'removedBy') !== caller ||
    members.includes(targetUid) ||
    !audited
  ) {
    throw new EventError(409, 'not removed by the caller');
  }
  return {
    key: `mx_${gid}_${targetUid}_${stamp(str(member.data, 'removedAt'))}`,
    recipients: without([...members, targetUid], caller),
    data,
  };
}
