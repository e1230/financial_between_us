# Financial Between Us — íconos

Colores: negro `#111111` (fondo del ícono), verde `#28DE4B`, blanco `#F2F2F2`.

| Carpeta | Uso |
|---|---|
| `png/launcher/app_icon_1024.png` | Ícono del launcher (iOS y Android legacy). Cuadrado, sin transparencia: el sistema recorta las esquinas. |
| `png/launcher/adaptive_foreground_1024.png` | Primer plano del adaptive icon de Android (fondo transparente, dentro de la zona segura). |
| `png/icono/` | Ícono con borde verde y esquinas redondeadas (transparentes) para usar dentro de la app, el README o la web. |
| `png/pequeno/` + `favicon.ico` | Versión simplificada para 64 px o menos (favicon, pestañas). |
| `svg/` | Fuentes vectoriales de todo lo anterior. |

## Flutter (flutter_launcher_icons)

Copia `png/launcher/` a `assets/icon/` y agrega en `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.0

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon_1024.png"
  adaptive_icon_background: "#111111"
  adaptive_icon_foreground: "assets/icon/adaptive_foreground_1024.png"
  remove_alpha_ios: true
  web:
    generate: true
    image_path: "assets/icon/app_icon_1024.png"
    background_color: "#111111"
    theme_color: "#28DE4B"
```

Luego ejecuta:

```bash
dart run flutter_launcher_icons
```
