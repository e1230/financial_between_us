# Splash animado — Financial Between Us

El splash tiene dos partes:

1. **Splash nativo** (mientras arranca el motor de Flutter): pantalla negra, generada con `flutter_native_splash`.
2. **Splash animado** (`FbuSplashScreen`): un widget en Flutter puro que dibuja el logo y la animación. No necesita paquetes extra.

Como la animación empieza sobre negro, el paso de uno al otro no se nota.

## 1. Copiar archivos

```
lib/splash/fbu_splash_screen.dart   → tu_proyecto/lib/splash/
assets/splash/splash_vacio.png      → tu_proyecto/assets/splash/
```

`lib/main_ejemplo.dart` es solo un ejemplo de cómo usarlo.

## 2. Fuente Space Grotesk

Descarga **Space Grotesk** de [fonts.google.com](https://fonts.google.com/specimen/Space+Grotesk). Copia `static/SpaceGrotesk-Bold.ttf` en `assets/fonts/` y agrega esto en `pubspec.yaml`:

```yaml
flutter:
  fonts:
    - family: SpaceGrotesk
      fonts:
        - asset: assets/fonts/SpaceGrotesk-Bold.ttf
          weight: 700
```

Si no la agregas, el texto curvo y "FBU" salen con la fuente por defecto.

## 3. Splash nativo negro

```yaml
dev_dependencies:
  flutter_native_splash: ^2.4.0

flutter_native_splash:
  color: "#000000"
  android_12:
    color: "#000000"
    # Android 12+ siempre muestra un ícono en su splash. Esta imagen es
    # transparente para que solo se vea negro antes de la animación.
    image: assets/splash/splash_vacio.png
    icon_background_color: "#000000"
```

```bash
dart run flutter_native_splash:create
```

Si prefieres que en Android 12+ se vea el logo desde el primer instante, cambia `image` por `adaptive_foreground_1024.png` del paquete de íconos.

## 4. Usarlo

```dart
FbuSplashScreen(
  waitFor: miArranque(),   // opcional: Firebase.initializeApp(), sesión, etc.
  onFinished: () {
    // navega al inicio (en main_ejemplo.dart hay un fade de 400 ms)
  },
)
```

- **`waitFor`**: la fase del `$` girando dura mínimo 2,2 s. Si el arranque tarda más, sigue en bucle hasta que termine, y después sale con la animación de "FBU".
- **`logoSize`**: tamaño del emblema; por defecto 260.

## Tiempos

| Tiempo | Animación |
|---|---|
| 0 – 0,6 s | ZoomIn del logo |
| 0,6 – 2,8 s (o hasta que termine `waitFor`) | `$` girando y flechas apareciendo y desvaneciéndose en bucle |
| +0 – 0,6 s | El logo sube |
| +0,4 – 1,0 s | "FBU" entra con slideInUp |
| +1,0 – 2,0 s | Quieto |
| +2,0 – 2,6 s | FadeOut de todo → `onFinished` |
