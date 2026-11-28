/**
 * Typed values of the Firestore REST API and their plain JavaScript form.
 * Timestamps decode to their RFC 3339 string; integers to `number`.
 */
export interface FsValue {
  nullValue?: null;
  booleanValue?: boolean;
  integerValue?: string;
  doubleValue?: number;
  timestampValue?: string;
  stringValue?: string;
  referenceValue?: string;
  arrayValue?: { values?: FsValue[] };
  mapValue?: { fields?: Record<string, FsValue> };
}

export type FsFields = Record<string, FsValue>;

/** A Firestore document already decoded. */
export interface Doc {
  /** Last path segment. */
  id: string;
  data: Record<string, unknown>;
  /** RFC 3339 time of the last write. */
  updateTime: string;
}

export function decodeValue(value: FsValue): unknown {
  if ('stringValue' in value) return value.stringValue;
  if ('integerValue' in value) return Number(value.integerValue);
  if ('doubleValue' in value) return value.doubleValue;
  if ('booleanValue' in value) return value.booleanValue;
  if ('timestampValue' in value) return value.timestampValue;
  if ('referenceValue' in value) return value.referenceValue;
  if ('arrayValue' in value) {
    return (value.arrayValue?.values ?? []).map(decodeValue);
  }
  if ('mapValue' in value) return decodeFields(value.mapValue?.fields ?? {});
  return null;
}

export function decodeFields(fields: FsFields): Record<string, unknown> {
  const out: Record<string, unknown> = {};
  for (const [key, value] of Object.entries(fields)) {
    out[key] = decodeValue(value);
  }
  return out;
}

/** Encodes plain values for a write. `Date` becomes a timestamp. */
export function encodeValue(value: unknown): FsValue {
  if (value === null || value === undefined) return { nullValue: null };
  if (value instanceof Date) return { timestampValue: value.toISOString() };
  switch (typeof value) {
    case 'string':
      return { stringValue: value };
    case 'boolean':
      return { booleanValue: value };
    case 'number':
      return Number.isInteger(value)
        ? { integerValue: String(value) }
        : { doubleValue: value };
    default:
      break;
  }
  if (Array.isArray(value)) {
    return { arrayValue: { values: value.map(encodeValue) } };
  }
  if (typeof value === 'object') {
    return { mapValue: { fields: encodeFields(value as Record<string, unknown>) } };
  }
  throw new TypeError(`Unsupported Firestore value: ${String(value)}`);
}

export function encodeFields(data: Record<string, unknown>): FsFields {
  const out: FsFields = {};
  for (const [key, value] of Object.entries(data)) {
    out[key] = encodeValue(value);
  }
  return out;
}

// Readers of decoded data that tolerate missing or mistyped fields.

export function str(data: Record<string, unknown>, key: string): string | null {
  const value = data[key];
  return typeof value === 'string' ? value : null;
}

export function int(data: Record<string, unknown>, key: string): number | null {
  const value = data[key];
  return typeof value === 'number' && Number.isInteger(value) ? value : null;
}

export function strings(data: Record<string, unknown>, key: string): string[] {
  const value = data[key];
  return Array.isArray(value)
    ? value.filter((v): v is string => typeof v === 'string')
    : [];
}
