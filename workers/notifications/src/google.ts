/**
 * Google credentials: verifies the Firebase ID token of the caller and
 * gets an OAuth access token for the service account.
 */
import { createRemoteJWKSet, importPKCS8, jwtVerify, SignJWT } from 'jose';

/** Public keys of Firebase Auth ID tokens (cached by `jose`). */
const firebaseKeys = createRemoteJWKSet(
  new URL(
    'https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com',
  ),
);

/** Uid of the signed-in user who sent [idToken]; throws when invalid. */
export async function verifyIdToken(
  idToken: string,
  projectId: string,
): Promise<string> {
  const { payload } = await jwtVerify(idToken, firebaseKeys, {
    issuer: `https://securetoken.google.com/${projectId}`,
    audience: projectId,
    algorithms: ['RS256'],
  });
  if (typeof payload.sub !== 'string' || payload.sub.length === 0) {
    throw new Error('ID token without subject');
  }
  return payload.sub;
}

interface ServiceAccount {
  client_email: string;
  private_key: string;
  private_key_id?: string;
  token_uri?: string;
}

const scopes = [
  'https://www.googleapis.com/auth/firebase.messaging',
  'https://www.googleapis.com/auth/datastore',
].join(' ');

const defaultTokenUri = 'https://oauth2.googleapis.com/token';

// Lives as long as the isolate does; renewed a minute before it expires.
let cached: { token: string; expiresAt: number } | null = null;

export async function accessToken(serviceAccountJson: string): Promise<string> {
  const now = Date.now();
  if (cached !== null && cached.expiresAt - 60_000 > now) return cached.token;

  const account = JSON.parse(serviceAccountJson) as ServiceAccount;
  const tokenUri = account.token_uri ?? defaultTokenUri;
  const key = await importPKCS8(account.private_key, 'RS256');
  const assertion = await new SignJWT({ scope: scopes })
    .setProtectedHeader({ alg: 'RS256', typ: 'JWT', kid: account.private_key_id })
    .setIssuer(account.client_email)
    .setSubject(account.client_email)
    .setAudience(tokenUri)
    .setIssuedAt()
    .setExpirationTime('1h')
    .sign(key);

  const response = await fetch(tokenUri, {
    method: 'POST',
    headers: { 'content-type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion,
    }),
  });
  if (!response.ok) {
    throw new Error(`OAuth token request failed: ${response.status}`);
  }
  const body = (await response.json()) as {
    access_token: string;
    expires_in: number;
  };
  cached = {
    token: body.access_token,
    expiresAt: now + body.expires_in * 1000,
  };
  return body.access_token;
}
