# Financial Between Us

App Android en Flutter para que un grupo pequeño de amigos (≤ 10 personas) registre las salidas a comer, asigne cada consumo a quien lo pidió y sepa con exactitud quién debe cuánto y a quién. Proyecto personal y de portafolio: el código debe verse profesional.

## Plataforma y stack

- **Solo Android.** No agregar código, configuración ni dependencias de iOS, web o escritorio.
- Flutter (canal stable) + Dart 3.
- Estado: **Riverpod** con generador (`@riverpod`).
- Navegación: **go_router**. Las pantallas de autenticación comparten un fondo animado mediante un `ShellRoute`.
- Modelos: **freezed** + **json_serializable**.
- Backend: **Firebase Auth** + **Cloud Firestore** (plan gratuito Spark).
- Fotos de recibos: **Cloudinary** (plan gratuito, upload preset sin firma). Nunca poner el API secret en la app.
- Preferencias locales: **shared_preferences** (`SharedPreferencesAsync`), excluidas de la copia de seguridad de Android.

## Carpeta `temp/`

- `temp/` es donde el usuario pega los recursos de los **próximos módulos y etapas**: handoffs, especificaciones, instrucciones para el agente, assets, íconos, capturas y HTML de referencia. Cada etapa suele traer su propia subcarpeta (ej.: `temp/fbu_walkthrough_handoff/`).
- **No se rastrea en git** (está en `.gitignore`) y puede borrarse al cerrar cada etapa.
- Es solo material de referencia: lo que se necesite se **copia** a `assets/`, `lib/` o `android/`. Nada en `lib/`, `test/` ni `pubspec.yaml` puede importar, leer ni declarar archivos de `temp/`.
- Las instrucciones de `temp/` se adaptan a este proyecto: si alguna choca con este `CLAUDE.md` (por ejemplo, agregar un paquete), manda `CLAUDE.md` y se le pregunta al usuario.

## Arquitectura

Feature-first, con capas dentro de cada feature:

```
lib/
  core/          # theme, tokens (AppTokens), router, utils, widgets compartidos
  features/
    auth/        # data / domain / presentation
    onboarding/
    groups/
    outings/
    balances/
```

- `domain`: entidades y lógica pura (sin Flutter ni Firebase). Aquí vive el cálculo de saldos.
- `data`: repositorios y acceso a Firestore.
- `presentation`: pantallas, widgets y providers.

## Modelo de datos (Firestore)

```
users/{uid}
groups/{groupId}                 members: [uid]
  outings/{outingId}             fecha, lugar, totalCOP, propinaPct, fotoUrl, createdBy
    items/{itemId}               descripción, valorCOP, consumidores {uid: partes}
    payments/{paymentId}         quién pagó y cuánto
  settlements/{id}               abonos entre miembros
  auditLog/{logId}               acción, entidad, antes/después, uid, timestamp
```

## Reglas de negocio (no negociables)

- **El dinero se maneja en enteros (pesos COP).** Nunca usar `double` para montos.
- Los saldos **se calculan**; no se guardan.
- La propina se reparte de forma proporcional a lo consumido por cada persona.
- **Nada se borra físicamente:** soft delete con `deletedAt`. Todo cambio deja un registro en `auditLog`, que es solo de escritura.
- El algoritmo de simplificación de deudas (minimizar transferencias) vive en `features/balances/domain` y debe tener tests unitarios.

## Sistema de diseño

- Referencia de estilo: Revolut (oscuro, sobrio, premium).
- Colores: fondo `#111111`, tarjetas `#1A1A1A`, inputs/chips `#242424`, bordes `#2E2E2E`, texto `#F2F2F2` (secundario al 60%, deshabilitado al 38%), acento `#28DE4B`, negativo `#FF5A5F`, advertencia `#FFB020`.
- **El texto sobre el acento verde siempre es `#111111`.**
- Tipografía: Satoshi (títulos, desde assets) + Inter (cuerpo y montos, con cifras tabulares).
  - Inter (licencia OFL) está en el repo: `assets/fonts/Inter-{Regular,Medium,SemiBold}.ttf`.
  - **Satoshi no se sube al repo**: su licencia (ITF Free Font License) prohíbe publicarla y el repo es público. Está en `.gitignore`. Para compilar desde un clon nuevo, descárgala de fontshare.com/fonts/satoshi y copia `Fonts/WEB/fonts/Satoshi-Bold.ttf` a `assets/fonts/Satoshi-Bold.ttf`.
- Espaciado en múltiplos de 8; radios de 12 (inputs y tarjetas) y pill (botones).
- **Prohibido hardcodear colores, tamaños o estilos de texto en los widgets:** todo sale de `AppTokens` (ThemeExtension) y del `ThemeData`.
- Diseño edge-to-edge; respetar la barra de navegación por gestos.
- Toda animación debe respetar `MediaQuery.disableAnimations`.

## Convenciones

- Código, nombres y comentarios en **inglés**. Textos visibles para el usuario en **español**.
- Montos formateados con `intl` en `es_CO` (ej.: `$ 48.500`).
- Widgets pequeños y en su propio archivo cuando pasen de ~150 líneas.
- No usar `print`; usar un logger.
- Cada pantalla contempla sus estados: cargando (skeleton), vacío, error y contenido.

## Comandos

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # tras cambiar modelos o providers
flutter analyze
flutter test
flutter run
```

## Reglas para Claude

- **No agregar paquetes nuevos sin preguntar primero.**
- No modificar `firebase_options.dart`, `google-services.json` ni las Security Rules sin que se pida.
- No cambiar el sistema de diseño ni los tokens por cuenta propia.
- Antes de dar una tarea por terminada, ejecutar `flutter analyze` y `flutter test` y corregir lo que falle.
- Nunca incluir secretos, claves ni datos reales de los amigos en el código o en los commits.
- Codigo en inglés
- Respuestas en chat en español