import 'package:material_ui/material_ui.dart';

import 'walkthrough_metrics.dart';

/// Content of one walkthrough page.
@immutable
class WalkthroughPageData {
  const WalkthroughPageData({
    required this.imageAsset,
    required this.imageAlignment,
    required this.title,
    required this.subtitle,
    required this.imageSemanticLabel,
  });

  final String imageAsset;

  /// Focal point of the photo when cropped with `BoxFit.cover`.
  final Alignment imageAlignment;
  final String title;
  final String subtitle;

  /// Description of the photo for screen readers.
  final String imageSemanticLabel;

  /// The photo decoded at the physical screen height (plus the Ken Burns
  /// zoom) instead of its full resolution, which would take ~30–40 MB per
  /// photo. Use it both to precache and to paint, so they share the same
  /// cache entry.
  ///
  // DECISIÓN: resizing by height assumes every photo is proportionally wider
  // than the screen (true for the three photos), so `BoxFit.cover` fills the
  // height and crops the sides.
  ImageProvider imageProvider(BuildContext context) {
    final asset = AssetImage(imageAsset);
    final height =
        (MediaQuery.sizeOf(context).height *
                MediaQuery.devicePixelRatioOf(context) *
                (1 + WalkthroughMetrics.kenBurnsScale))
            .ceil();
    if (height <= 0) return asset;
    return ResizeImage(asset, height: height);
  }
}

/// The three walkthrough pages, in order.
///
/// The photos can be replaced by others with the same file names without
/// touching code; adjust [WalkthroughPageData.imageAlignment] if the subject
/// moves.
const List<WalkthroughPageData> walkthroughPages = [
  WalkthroughPageData(
    imageAsset: 'assets/images/onboarding/bog_1.jpg',
    imageAlignment: Alignment.center,
    title: 'Auditoría de gastos',
    subtitle: 'Registra cada salida en segundos.',
    imageSemanticLabel:
        'Vista aérea de Bogotá de día, con sus avenidas y los cerros '
        'orientales al fondo',
  ),
  WalkthroughPageData(
    imageAsset: 'assets/images/onboarding/bog_2.jpg',
    // Landscape photo: only ~30 % of its width is visible; keep the tall
    // tower and the avenue.
    imageAlignment: Alignment(-0.3, 0),
    title: 'Transparencia monetaria',
    subtitle: 'Asigna cada consumo justamente y a quien le corresponde.',
    imageSemanticLabel:
        'Avenida de Bogotá de noche, entre edificios iluminados y estelas '
        'de luz de los carros',
  ),
  WalkthroughPageData(
    imageAsset: 'assets/images/onboarding/bog_3.jpg',
    // Keep the Colpatria tower (right) in frame.
    imageAlignment: Alignment(0.6, 0),
    title: 'Flexibilidad económica',
    subtitle: 'Observa detalladamente el comportamiento de tus movimientos.',
    imageSemanticLabel:
        'Las luces de Bogotá de noche vistas desde lo alto, con la Torre '
        'Colpatria iluminada',
  ),
];

/// User-facing texts of the walkthrough chrome.
abstract final class WalkthroughCopy {
  static const String header = 'Bienvenido a FBU';
  static const String skip = 'Saltar';
  static const String next = 'Siguiente';
  static const String start = 'Empezar';

  /// Announced by the progress bar and the page dots.
  static String pageOf(int page, int count) => 'Página $page de $count';
}
