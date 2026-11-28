# Worker de notificaciones

Cloudflare Worker (plan gratuito) que envía las notificaciones push de Financial Between Us con **FCM HTTP v1**. Existe porque el plan Spark de Firebase no incluye Cloud Functions.

## Cómo funciona

1. La app escribe en Firestore como siempre (un pago, una deuda, un rechazo, alguien que entra o sale de un grupo).
2. Si la escritura funcionó, la app llama a `POST /v1/notify` con el ID token de Firebase del usuario y un cuerpo que solo dice qué pasó:

   ```json
   { "type": "movement.created", "groupId": "g1", "movementIds": ["m1"] }
   { "type": "member.left", "groupId": "g1" }
   { "type": "member.removed", "groupId": "g1", "memberUid": "u2" }
   ```

3. El Worker **no le cree al cliente**:
   - verifica el ID token;
   - lee los documentos reales con una service account;
   - comprueba que quien llama sea de verdad el autor (o el admin) y que el estado coincida;
   - decide los destinatarios (`src/events.ts`).
4. Crea `notificationLog/{clave}` solo si no existe. Así, cada aviso sale **una sola vez** aunque la app repita la llamada.
5. Envía un mensaje **solo de datos** y de prioridad alta a cada token de `users/{uid}/fcmTokens` (los que no tienen `deletedAt`). La app arma la notificación: textos en español y los botones "Confirmar" y "Rechazar". Si FCM dice que un token ya no existe, el Worker lo marca con `deletedAt`.

| Tipo | Quién lo envía | Lo reciben |
| --- | --- | --- |
| `movement.created` | el autor del movimiento | la otra parte |
| `movement.rejected` | quien lo rechazó | el autor |
| `movement.deleted` | el autor | la otra parte |
| `member.joined` | quien entró sin aprobación | los demás miembros |
| `member.requested` | quien pidió entrar | los admins |
| `member.left` | quien salió (no cuenta cancelar una solicitud) | los miembros que quedan |
| `member.approved` | el admin que aprobó | la persona aprobada y los demás miembros |
| `member.removed` | el admin que eliminó | la persona eliminada y los demás miembros |

## Puesta en marcha

1. **Service account.** En Google Cloud Console → IAM → Cuentas de servicio del proyecto `financial-between-us`, crea una cuenta con los roles *Firebase Cloud Messaging API Admin* y *Cloud Datastore User*, y descarga una clave JSON. Esa clave nunca va al repositorio.
2. **Dependencias y secreto:**

   ```bash
   cd workers/notifications
   npm install
   npx wrangler login
   npx wrangler secret put FIREBASE_SERVICE_ACCOUNT   # pega el JSON completo
   ```

3. **Despliegue:** `npm run deploy`. Copia la URL que imprime (por ejemplo, `https://fbu-notifications.<tu-subdominio>.workers.dev`) en el `.env` de la app como `NOTIFICATIONS_WORKER_URL`.
4. **Reglas e índices:** publica `firestore.rules` (incluye `fcmTokens` y `notificationLog`). El Worker no necesita índices compuestos.

Si `NOTIFICATIONS_WORKER_URL` no está definida, la app funciona igual pero no envía avisos.

## Desarrollo

```bash
npm test            # vitest: reglas de cada evento y codificación de Firestore
npm run typecheck   # tsc --noEmit
npm run dev         # wrangler dev (pon el secreto en .dev.vars, ignorado por git)
```

## Costos

En el plan gratuito de Workers caben 100.000 solicitudes al día, y FCM no tiene costo. Cada aviso hace entre 3 y 6 lecturas de Firestore y 1 escritura (`notificationLog`), muy por debajo de la cuota diaria de Spark para un grupo de 10 personas.
