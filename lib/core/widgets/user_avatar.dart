import 'package:material_ui/material_ui.dart';

import '../theme/app_tokens.dart';

/// Round avatar of a user: their photo or, without one (or while it loads,
/// or if it fails), their initial over their color.
///
/// The letter is [AppTokens.onAccent]: user colors are always readable with
/// it (see `AccentColor`).
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.initial,
    required this.color,
    required this.size,
    this.image,
    this.semanticsLabel,
  });

  /// Letter shown without a photo.
  final String initial;

  /// Background of the letter.
  final Color color;
  final double size;

  /// The photo: a `NetworkImage` (Cloudinary) or a local preview.
  final ImageProvider? image;
  final String? semanticsLabel;

  /// Letter height relative to [size].
  static const double initialScale = 0.42;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final style = Theme.of(context).textTheme.headlineSmall!.copyWith(
      color: tokens.onAccent,
      fontSize: size * initialScale,
      height: 1,
    );
    final letter = Center(
      child: Text(initial, style: style, textScaler: TextScaler.noScaling),
    );
    final photo = image;

    return Semantics(
      label: semanticsLabel,
      image: true,
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: size,
          child: ClipOval(
            child: DecoratedBox(
              decoration: BoxDecoration(color: color),
              child: photo == null
                  ? letter
                  : Image(
                      image: photo,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                      frameBuilder: (context, child, frame, wasSync) =>
                          wasSync || frame != null ? child : letter,
                      errorBuilder: (context, error, stackTrace) => letter,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
