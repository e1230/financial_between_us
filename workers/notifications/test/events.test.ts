import { describe, expect, it } from 'vitest';

import {
  auditCheckFor,
  EventError,
  memberDelivery,
  movementDelivery,
  parseRequest,
  stamp,
} from '../src/events';
import type { Doc } from '../src/firestore_value';

const doc = (id: string, data: Record<string, unknown>): Doc => ({
  id,
  data,
  updateTime: '2026-11-27T10:00:00.000000Z',
});

const group = doc('g1', {
  name: 'Viernes',
  ownerUid: 'ana',
  admins: ['ana'],
  members: ['ana', 'beto', 'caro'],
  pendingMembers: ['dani'],
});
const ana = doc('ana', { displayName: 'Ana Ruiz', nickname: 'anita' });
const beto = doc('beto', { displayName: ' ', nickname: 'beto' });

const movement = (data: Record<string, unknown>) =>
  doc('m1', {
    type: 'payment',
    debtorUid: 'ana',
    creditorUid: 'beto',
    participants: ['ana', 'beto'],
    amount: 48500,
    concept: '',
    createdBy: 'ana',
    status: 'active',
    ...data,
  });

function errorStatus(action: () => unknown): number | undefined {
  try {
    action();
  } catch (error) {
    if (error instanceof EventError) return error.status;
    throw error;
  }
  return undefined;
}

describe('parseRequest', () => {
  it('accepts a movement request and drops repeated ids', () => {
    expect(
      parseRequest({ type: 'movement.created', groupId: 'g1', movementIds: ['a', 'a', 'b'] }),
    ).toEqual({ type: 'movement.created', groupId: 'g1', movementIds: ['a', 'b'] });
  });

  it('rejects unknown types, bad ids and missing fields', () => {
    expect(errorStatus(() => parseRequest(null))).toBe(400);
    expect(errorStatus(() => parseRequest({ type: 'x', groupId: 'g1' }))).toBe(400);
    expect(errorStatus(() => parseRequest({ type: 'member.left', groupId: 'a/b' }))).toBe(400);
    expect(
      errorStatus(() => parseRequest({ type: 'movement.created', groupId: 'g1', movementIds: [] })),
    ).toBe(400);
    expect(
      errorStatus(() =>
        parseRequest({ type: 'movement.created', groupId: 'g1', movementIds: Array(11).fill('m') }),
      ),
    ).toBe(400);
    expect(errorStatus(() => parseRequest({ type: 'member.removed', groupId: 'g1' }))).toBe(400);
  });

  it('accepts member requests', () => {
    expect(parseRequest({ type: 'member.left', groupId: 'g1' })).toEqual({
      type: 'member.left',
      groupId: 'g1',
    });
    expect(parseRequest({ type: 'member.approved', groupId: 'g1', memberUid: 'dani' })).toEqual({
      type: 'member.approved',
      groupId: 'g1',
      memberUid: 'dani',
    });
  });
});

describe('movementDelivery', () => {
  it('sends a new movement to the other party', () => {
    const delivery = movementDelivery('movement.created', {
      caller: 'ana',
      group,
      actor: ana,
      movement: movement({}),
    });
    expect(delivery.key).toBe('mc_g1_m1');
    expect(delivery.recipients).toEqual(['beto']);
    expect(delivery.data).toMatchObject({
      type: 'movement.created',
      groupId: 'g1',
      groupName: 'Viernes',
      actorUid: 'ana',
      actorName: 'Ana Ruiz',
      movementId: 'm1',
      movementType: 'payment',
      debtorUid: 'ana',
      creditorUid: 'beto',
      amount: '48500',
    });
  });

  it('only lets the author announce a new movement', () => {
    expect(
      errorStatus(() =>
        movementDelivery('movement.created', {
          caller: 'beto',
          group,
          actor: beto,
          movement: movement({}),
        }),
      ),
    ).toBe(403);
    expect(
      errorStatus(() =>
        movementDelivery('movement.created', {
          caller: 'caro',
          group,
          actor: null,
          movement: movement({}),
        }),
      ),
    ).toBe(403);
  });

  it('sends a rejection to the author with its reason', () => {
    const delivery = movementDelivery('movement.rejected', {
      caller: 'beto',
      group,
      actor: beto,
      movement: movement({ status: 'rejected', rejectedBy: 'beto', rejectReason: 'not_received' }),
    });
    expect(delivery.key).toBe('mr_g1_m1');
    expect(delivery.recipients).toEqual(['ana']);
    expect(delivery.data.rejectReason).toBe('not_received');
    expect(delivery.data.actorName).toBe('beto');
  });

  it('needs the movement to really be rejected or deleted', () => {
    expect(
      errorStatus(() =>
        movementDelivery('movement.rejected', { caller: 'beto', group, actor: beto, movement: movement({}) }),
      ),
    ).toBe(409);
    expect(
      errorStatus(() =>
        movementDelivery('movement.deleted', { caller: 'ana', group, actor: ana, movement: movement({}) }),
      ),
    ).toBe(409);
  });

  it('sends a deletion to the other party', () => {
    const delivery = movementDelivery('movement.deleted', {
      caller: 'ana',
      group,
      actor: ana,
      movement: movement({ status: 'deleted' }),
    });
    expect(delivery.key).toBe('md_g1_m1');
    expect(delivery.recipients).toEqual(['beto']);
  });
});

describe('memberDelivery', () => {
  const joinedAt = '2026-11-27T10:15:00.123456Z';

  it('announces who joined to the other members', () => {
    const delivery = memberDelivery(
      { type: 'member.joined', groupId: 'g1' },
      {
        caller: 'caro',
        group,
        actor: doc('caro', { displayName: 'Caro' }),
        member: doc('caro', { status: 'active', joinedAt }),
        target: null,
        audited: false,
      },
    );
    expect(delivery.key).toBe(`mj_g1_caro_${stamp(joinedAt)}`);
    expect(delivery.recipients).toEqual(['ana', 'beto']);
    expect(delivery.data.memberName).toBe('Caro');
  });

  it('sends a request to join to the admins', () => {
    const delivery = memberDelivery(
      { type: 'member.requested', groupId: 'g1' },
      {
        caller: 'dani',
        group,
        actor: null,
        member: doc('dani', { status: 'pending', joinedAt }),
        target: null,
        audited: false,
      },
    );
    expect(delivery.recipients).toEqual(['ana']);
  });

  it('announces a leave only when the audit log says it was a leave', () => {
    const context = {
      caller: 'dani',
      group,
      actor: null,
      member: doc('dani', { status: 'left', leftAt: joinedAt }),
      target: null,
    };
    expect(
      errorStatus(() => memberDelivery({ type: 'member.left', groupId: 'g1' }, { ...context, audited: false })),
    ).toBe(409);
    const delivery = memberDelivery(
      { type: 'member.left', groupId: 'g1' },
      { ...context, audited: true },
    );
    expect(delivery.recipients).toEqual(['ana', 'beto', 'caro']);
    expect(auditCheckFor({ type: 'member.left', groupId: 'g1' }, 'dani', context.member)).toEqual({
      entityId: 'dani',
      action: 'leave',
      timestamp: joinedAt,
    });
  });

  it('shares the key of a direct join with an approval', () => {
    const approved = memberDelivery(
      { type: 'member.approved', groupId: 'g1', memberUid: 'caro' },
      {
        caller: 'ana',
        group,
        actor: ana,
        member: doc('caro', { status: 'active', joinedAt }),
        target: doc('caro', { displayName: 'Caro' }),
        audited: false,
      },
    );
    expect(approved.key).toBe(`mj_g1_caro_${stamp(joinedAt)}`);
    expect(approved.recipients).toEqual(['beto', 'caro']);
    expect(approved.data).toMatchObject({ type: 'member.approved', memberUid: 'caro', memberName: 'Caro' });
  });

  it('only lets admins announce approvals and removals', () => {
    expect(
      errorStatus(() =>
        memberDelivery(
          { type: 'member.approved', groupId: 'g1', memberUid: 'caro' },
          {
            caller: 'beto',
            group,
            actor: beto,
            member: doc('caro', { status: 'active', joinedAt }),
            target: null,
            audited: false,
          },
        ),
      ),
    ).toBe(403);
  });

  it('sends a removal to the removed member and the rest of the group', () => {
    const removedGroup = doc('g1', { ...group.data, members: ['ana', 'beto'] });
    const member = doc('caro', { status: 'removed', removedBy: 'ana', removedAt: joinedAt });
    const delivery = memberDelivery(
      { type: 'member.removed', groupId: 'g1', memberUid: 'caro' },
      { caller: 'ana', group: removedGroup, actor: ana, member, target: null, audited: true },
    );
    expect(delivery.key).toBe(`mx_g1_caro_${stamp(joinedAt)}`);
    expect(delivery.recipients).toEqual(['beto', 'caro']);
    expect(
      errorStatus(() =>
        memberDelivery(
          { type: 'member.removed', groupId: 'g1', memberUid: 'caro' },
          { caller: 'ana', group: removedGroup, actor: ana, member, target: null, audited: false },
        ),
      ),
    ).toBe(409);
  });
});
