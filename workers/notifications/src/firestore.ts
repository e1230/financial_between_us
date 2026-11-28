/**
 * Minimal Firestore REST client authenticated as the service account (it
 * is not bound by the security rules).
 */
import {
  decodeFields,
  type Doc,
  encodeFields,
  type FsFields,
} from './firestore_value';

interface RawDoc {
  name: string;
  fields?: FsFields;
  updateTime: string;
}

function toDoc(raw: RawDoc): Doc {
  return {
    id: raw.name.slice(raw.name.lastIndexOf('/') + 1),
    data: decodeFields(raw.fields ?? {}),
    updateTime: raw.updateTime,
  };
}

export class Firestore {
  private readonly root: string;

  constructor(
    projectId: string,
    private readonly token: string,
  ) {
    this.root = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents`;
  }

  private request(url: string, init: RequestInit = {}): Promise<Response> {
    return fetch(url, {
      ...init,
      headers: {
        authorization: `Bearer ${this.token}`,
        'content-type': 'application/json',
      },
    });
  }

  private static async fail(response: Response, what: string): Promise<never> {
    throw new Error(`Firestore ${what} failed: ${response.status} ${await response.text()}`);
  }

  /** The document at [path], or `null` when it does not exist. */
  async get(path: string): Promise<Doc | null> {
    const response = await this.request(`${this.root}/${path}`);
    if (response.status === 404) return null;
    if (!response.ok) return Firestore.fail(response, `get ${path}`);
    return toDoc((await response.json()) as RawDoc);
  }

  /** Every document of the collection [path] (small collections only). */
  async list(path: string, pageSize = 50): Promise<Doc[]> {
    const response = await this.request(
      `${this.root}/${path}?pageSize=${pageSize}`,
    );
    if (!response.ok) return Firestore.fail(response, `list ${path}`);
    const body = (await response.json()) as { documents?: RawDoc[] };
    return (body.documents ?? []).map(toDoc);
  }

  /**
   * Creates `collection/id` only if it does not exist yet. Returns `false`
   * when it already did: the atomic check that sends each notification
   * once.
   */
  async createIfAbsent(
    collection: string,
    id: string,
    data: Record<string, unknown>,
  ): Promise<boolean> {
    const response = await this.request(
      `${this.root}/${collection}?documentId=${encodeURIComponent(id)}`,
      { method: 'POST', body: JSON.stringify({ fields: encodeFields(data) }) },
    );
    if (response.status === 409) return false;
    if (!response.ok) return Firestore.fail(response, `create ${collection}/${id}`);
    return true;
  }

  /** Sets [data] on the existing document [path] (only those fields). */
  async update(path: string, data: Record<string, unknown>): Promise<void> {
    const mask = Object.keys(data)
      .map((field) => `updateMask.fieldPaths=${encodeURIComponent(field)}`)
      .join('&');
    const response = await this.request(
      `${this.root}/${path}?${mask}&currentDocument.exists=true`,
      { method: 'PATCH', body: JSON.stringify({ fields: encodeFields(data) }) },
    );
    if (!response.ok) return Firestore.fail(response, `update ${path}`);
  }

  /**
   * Whether `parent/collection` has a document whose fields equal
   * [equals]. Equality filters only, so no composite index is needed.
   */
  async exists(
    parent: string,
    collection: string,
    equals: Record<string, { stringValue: string } | { timestampValue: string }>,
  ): Promise<boolean> {
    const response = await this.request(`${this.root}/${parent}:runQuery`, {
      method: 'POST',
      body: JSON.stringify({
        structuredQuery: {
          from: [{ collectionId: collection }],
          where: {
            compositeFilter: {
              op: 'AND',
              filters: Object.entries(equals).map(([field, value]) => ({
                fieldFilter: { field: { fieldPath: field }, op: 'EQUAL', value },
              })),
            },
          },
          limit: 1,
        },
      }),
    });
    if (!response.ok) return Firestore.fail(response, `query ${parent}/${collection}`);
    const rows = (await response.json()) as Array<{ document?: unknown }>;
    return rows.some((row) => row.document !== undefined);
  }
}
