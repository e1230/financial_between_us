import 'package:material_ui/material_ui.dart';

import '../theme/app_tokens.dart';

/// Shows a popup with the app style: a 60 % black barrier and an entry
/// with a fade and a 0.92 → 1 scale (250 ms, ease-out cubic). With
/// `MediaQuery.disableAnimations` it only fades, in 150 ms.
///
/// [builder] usually returns a [FbuDialog].
Future<T?> showFbuDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  final reduceMotion = MediaQuery.disableAnimationsOf(context);
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: context.tokens.brandBackground.withValues(
      alpha: FbuDialog.barrierOpacity,
    ),
    transitionDuration: reduceMotion
        ? FbuDialog.reducedMotionDuration
        : FbuDialog.entryDuration,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: reduceMotion
            ? child
            : ScaleTransition(
                scale: Tween(
                  begin: FbuDialog.startScale,
                  end: 1.0,
                ).animate(curved),
                child: child,
              ),
      );
    },
  );
}

/// Frame of every popup: 16 dp from the screen sides, `surface` fill,
/// 1 dp border, radius 24 and 24 dp of padding. Scrolls when the content
/// (or the keyboard) does not leave room.
class FbuDialog extends StatelessWidget {
  const FbuDialog({super.key, required this.child, this.semanticsLabel});

  final Widget child;

  /// Announced by screen readers when the popup opens (usually its title).
  final String? semanticsLabel;

  static const double barrierOpacity = 0.6;
  static const double startScale = 0.92;
  static const Duration entryDuration = Duration(milliseconds: 250);
  static const Duration reducedMotionDuration = Duration(milliseconds: 150);

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: keyboard),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(tokens.space2),
            child: Semantics(
              scopesRoute: true,
              namesRoute: true,
              explicitChildNodes: true,
              label: semanticsLabel,
              child: Material(
                color: tokens.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(tokens.radiusDialog),
                  side: BorderSide(color: tokens.border),
                ),
                child: Padding(
                  padding: EdgeInsets.all(tokens.space3),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
