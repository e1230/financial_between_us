/** Firebase Cloud Messaging HTTP v1. */

export type SendResult = 'sent' | 'unregistered' | 'failed';

/**
 * Sends a data-only message (the app builds the notification, with its
 * action buttons) with high priority so it wakes the app in background.
 */
export async function sendData(
  projectId: string,
  accessToken: string,
  deviceToken: string,
  data: Record<string, string>,
): Promise<SendResult> {
  const response = await fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: 'POST',
      headers: {
        authorization: `Bearer ${accessToken}`,
        'content-type': 'application/json',
      },
      body: JSON.stringify({
        message: {
          token: deviceToken,
          data,
          android: { priority: 'HIGH', ttl: '604800s' },
        },
      }),
    },
  );
  if (response.ok) return 'sent';
  const text = await response.text();
  // The app was uninstalled or the token expired: stop using it.
  if (
    response.status === 404 ||
    text.includes('UNREGISTERED') ||
    (response.status === 400 && text.includes('registration token'))
  ) {
    return 'unregistered';
  }
  console.error('FCM send failed', response.status, text);
  return 'failed';
}
