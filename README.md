# Financial Between Us

> Salen juntos. Las cuentas, claras.

App Android para que un grupo de amigos registre sus salidas a comer, asigne cada consumo a quien lo pidió y sepa con exactitud **quién debe, cuánto y a quién**, con historial auditable de cada cambio.

<!-- Reemplaza con tus capturas o un GIF de la app -->
<p align="center">
  <img src="docs/screenshots/onboarding.png" width="220" alt="Onboarding" />
  <img src="docs/screenshots/home.png" width="220" alt="Inicio" />
  <img src="docs/screenshots/outing.png" width="220" alt="Detalle de salida" />
</p>

## Funcionalidades

- Inicio y cierre de sesión con Firebase Auth.
- Grupos con invitación.
- Registro de salidas con foto del recibo (cámara o galería).
- Asignación de cada consumo a una o varias personas, con partes desiguales.
- Propina repartida de forma proporcional a lo que consumió cada uno.
- Saldos en tiempo real y **simplificación de deudas** (el mínimo de transferencias necesarias).
- Registro de abonos entre miembros.
- **Notificaciones push:** cuando alguien registra, rechaza o elimina un pago o una deuda contigo, y cuando alguien entra, pide entrar o sale de tus grupos. Desde la notificación puedes confirmar el movimiento o ir directo a rechazarlo.
- **Auditoría completa:** nada se borra, y cada cambio queda registrado con autor y fecha.
- Panel de análisis: gasto por mes, promedio por salida y quién paga más seguido.

## Stack

| Capa          | Tecnología                      |
| ------------- | ------------------------------- |
| App           | Flutter · Dart 3 (solo Android) |
| Estado        | Riverpod (con generador)        |
| Navegación    | go_router                       |
| Modelos       | freezed · json_serializable     |
| Autenticación | Firebase Auth                   |
| Base de datos | Cloud Firestore                 |
| Imágenes      | Cloudinary                      |
| Notificaciones | FCM + Cloudflare Worker (`workers/notifications`) |

## Arquitectura

Organización **feature-first**, con capas `data / domain / presentation` dentro de cada feature. La lógica de negocio (cálculo de saldos y simplificación de deudas) vive en `domain`, es Dart puro y tiene tests unitarios.

```
lib/
  core/        # tema, tokens de diseño, router, utilidades
  features/
    auth/
    onboarding/
    groups/
    outings/
    balances/
```

### Decisiones técnicas

- **Dinero en enteros (COP):** se evita `double` para no tener errores de redondeo.
- **Saldos calculados, no almacenados:** una sola fuente de verdad.
- **Soft delete + log de auditoría** protegido por Firestore Security Rules: solo los miembros del grupo leen, y nadie puede editar ni borrar el historial.
- **Push sin Cloud Functions:** un Cloudflare Worker gratuito envía los avisos con FCM HTTP v1. La app solo le cuenta qué pasó; el Worker lo verifica contra Firestore antes de avisar a nadie y cada aviso sale una sola vez.
- **Sistema de diseño propio** basado en `ThemeExtension`: ningún color ni tamaño está fijado a mano en los widgets.

## Cómo ejecutarlo

### Requisitos

- Flutter (canal stable) y Android SDK (`flutter doctor` sin errores).
- Un proyecto de Firebase propio con Authentication y Firestore activados.
- Una cuenta de Cloudinary con un *upload preset* sin firma.

### Pasos

```bash
git clone https://github.com/<tu-usuario>/financial_between_us.git
cd financial_between_us
flutter pub get

# Variables de entorno (Cloudinary)
cp .env.example .env   # y completa los valores

# Conecta tu propio proyecto de Firebase
dart pub global activate flutterfire_cli
flutterfire configure --platforms=android

# Genera el código de modelos y providers
dart run build_runner build --delete-conflicting-outputs

flutter run
```

> **Archivos que no están en el repositorio** y debes generar antes de compilar:
>
> | Archivo | Cómo se genera |
> | --- | --- |
> | `.env` | Copia de `.env.example` con tus valores de Cloudinary. Es obligatorio: está declarado como asset en `pubspec.yaml`, así que sin él la app no compila. |
> | `android/app/google-services.json` | `flutterfire configure` |
> | `lib/firebase_options.dart` | `flutterfire configure` |
>
> Las notificaciones push son opcionales: para activarlas despliega el Worker (`workers/notifications/README.md`) y pon su URL en `NOTIFICATIONS_WORKER_URL` del `.env`.
>
> El `.env` se empaqueta dentro del APK: pon ahí solo el nombre de la nube y el *upload preset* sin firma, **nunca** el API secret de Cloudinary.

### Tests

```bash
flutter test
cd workers/notifications && npm test   # Worker de notificaciones
```

## Roadmap

- [ ] Autenticación y onboarding
- [ ] Grupos e invitaciones
- [ ] Registro de salidas y consumos
- [ ] Saldos y simplificación de deudas
- [ ] Auditoría
- [ ] Panel de análisis
- [ ] Lectura automática del recibo (OCR en el dispositivo)

## Autor

**<Edgar Beltrán (E1230)>** · Desarrollador full stack · Bogotá, Colombia
