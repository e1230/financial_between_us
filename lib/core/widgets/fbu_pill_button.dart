import 'package:material_ui/material_ui.dart';

import '../theme/app_tokens.dart';
import '../utils/accent_color.dart';

/// Colors of a [FbuPillButton].
@immutable
class FbuPillButtonColors {
  const FbuPillButtonColors({
    required this.background,
    required this.pressedBackground,
    required this.disabledBackground,
    required this.foreground,
    required this.disabledForeground,
    required this.ripple,
  });

  /// Red pill of a destructive confirmation (sign out, leave a group).
  factory FbuPillButtonColors.destructive(AppTokens tokens) =>
      FbuPillButtonColors(
        background: tokens.negative,
        pressedBackground: AccentColor.pressed(tokens.negative),
        disabledBackground: tokens.surfaceVariant,
        foreground: tokens.onAccent,
        disabledForeground: tokens.textDisabled,
        ripple: tokens.onAccent.withValues(alpha: FbuPillButton.rippleOpacity),
      );

  final Color background;
  final Color pressedBackground;
  final Color disabledBackground;
  final Color foreground;
  final Color disabledForeground;
  final Color ripple;
}

/// Full-width 56 dp pill button shared by the primary and secondary buttons.
///
/// - Pressed: [FbuPillButtonColors.pressedBackground] and a 0.97 scale
///   (100 ms).
/// - Loading: the [child] cross-fades (150 ms) into a spinner. The button
///   keeps its size and colors and ignores taps.
///
/// Honors `MediaQuery.disableAnimations` (no scale, instant cross-fade).
class FbuPillButton extends StatefulWidget {
  const FbuPillButton({
    super.key,
    required this.onPressed,
    required this.colors,
    required this.child,
    this.isLoading = false,
    this.loadingSemanticsLabel,
  });

  final VoidCallback? onPressed;
  final FbuPillButtonColors colors;

  /// Usually a [Text]; styled with `labelLarge`.
  final Widget child;
  final bool isLoading;

  /// Announced by screen readers while [isLoading].
  final String? loadingSemanticsLabel;

  static const double height = 56;
  static const double pressedScale = 0.97;
  static const Duration pressDuration = Duration(milliseconds: 100);
  static const double rippleOpacity = 0.12;

  // Loading spinner: a quarter arc turning once every 0.8 s.
  static const double spinnerSize = 24;
  static const double spinnerStroke = 3;
  static const double spinnerArc = 0.25;
  static const double spinnerTrackOpacity = 0.25;
  static const Duration spinnerTurn = Duration(milliseconds: 800);

  @override
  State<FbuPillButton> createState() => _FbuPillButtonState();
}

class _FbuPillButtonState extends State<FbuPillButton> {
  final _states = WidgetStatesController();
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _states.addListener(_onStatesChanged);
  }

  void _onStatesChanged() {
    final pressed = _states.value.contains(WidgetState.pressed);
    if (pressed != _pressed) setState(() => _pressed = pressed);
  }

  @override
  void dispose() {
    _states
      ..removeListener(_onStatesChanged)
      ..dispose();
    super.dispose();
  }

  static void _ignore() {}

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = widget.colors;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final label = Theme.of(context).textTheme.labelLarge;
    final loading = widget.isLoading;

    return Semantics(
      label: loading ? widget.loadingSemanticsLabel : null,
      child: AnimatedScale(
        scale: _pressed && !reduceMotion && !loading
            ? FbuPillButton.pressedScale
            : 1,
        duration: reduceMotion ? Duration.zero : FbuPillButton.pressDuration,
        child: SizedBox(
          width: double.infinity,
          height: FbuPillButton.height,
          child: IgnorePointer(
            ignoring: loading,
            child: FilledButton(
              // While loading the button keeps its enabled colors.
              onPressed: loading ? _ignore : widget.onPressed,
              statesController: _states,
              style: ButtonStyle(
                elevation: const WidgetStatePropertyAll(0),
                shape: const WidgetStatePropertyAll(StadiumBorder()),
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.disabled)) {
                    return colors.disabledBackground;
                  }
                  return states.contains(WidgetState.pressed)
                      ? colors.pressedBackground
                      : colors.background;
                }),
                foregroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.disabled)
                      ? colors.disabledForeground
                      : colors.foreground,
                ),
                overlayColor: WidgetStatePropertyAll(colors.ripple),
                textStyle: WidgetStatePropertyAll(label),
                padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: tokens.space3),
                ),
              ),
              child: AnimatedSwitcher(
                duration: reduceMotion ? Duration.zero : tokens.motionFast,
                child: loading
                    ? _Spinner(
                        key: const ValueKey('spinner'),
                        color: colors.foreground,
                      )
                    : KeyedSubtree(
                        key: const ValueKey('label'),
                        child: widget.child,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A quarter arc on a faint track, turning linearly.
class _Spinner extends StatefulWidget {
  const _Spinner({super.key, required this.color});

  final Color color;

  @override
  State<_Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<_Spinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _turn = AnimationController(
    vsync: this,
    duration: FbuPillButton.spinnerTurn,
  )..repeat();

  @override
  void dispose() {
    _turn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: FbuPillButton.spinnerSize,
      child: RotationTransition(
        turns: _turn,
        child: CircularProgressIndicator(
          value: FbuPillButton.spinnerArc,
          strokeWidth: FbuPillButton.spinnerStroke,
          color: widget.color,
          backgroundColor: widget.color.withValues(
            alpha: FbuPillButton.spinnerTrackOpacity,
          ),
          strokeCap: StrokeCap.round,
        ),
      ),
    );
  }
}
