import { describe, expect, it } from 'vitest';

import { decodeFields, encodeFields, int, str, strings } from '../src/firestore_value';

describe('firestore values', () => {
  it('decodes the REST representation', () => {
    expect(
      decodeFields({
        name: { stringValue: 'Viernes' },
        amount: { integerValue: '48500' },
        done: { booleanValue: true },
        none: { nullValue: null },
        at: { timestampValue: '2026-11-27T10:00:00Z' },
        members: { arrayValue: { values: [{ stringValue: 'a' }, { stringValue: 'b' }] } },
        empty: { arrayValue: {} },
        account: { mapValue: { fields: { type: { stringValue: 'nequi' } } } },
      }),
    ).toEqual({
      name: 'Viernes',
      amount: 48500,
      done: true,
      none: null,
      at: '2026-11-27T10:00:00Z',
      members: ['a', 'b'],
      empty: [],
      account: { type: 'nequi' },
    });
  });

  it('encodes values for a write', () => {
    expect(
      encodeFields({
        type: 'movement.created',
        recipients: ['beto'],
        count: 2,
        sentAt: new Date('2026-11-27T10:00:00.000Z'),
        deletedAt: null,
      }),
    ).toEqual({
      type: { stringValue: 'movement.created' },
      recipients: { arrayValue: { values: [{ stringValue: 'beto' }] } },
      count: { integerValue: '2' },
      sentAt: { timestampValue: '2026-11-27T10:00:00.000Z' },
      deletedAt: { nullValue: null },
    });
  });

  it('reads fields defensively', () => {
    const data = { a: 'x', n: 3, f: 1.5, list: ['u', 2, 'v'] };
    expect(str(data, 'a')).toBe('x');
    expect(str(data, 'n')).toBeNull();
    expect(int(data, 'n')).toBe(3);
    expect(int(data, 'f')).toBeNull();
    expect(strings(data, 'list')).toEqual(['u', 'v']);
    expect(strings(data, 'missing')).toEqual([]);
  });
});
