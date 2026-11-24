import 'package:material_ui/material_ui.dart';

import '../theme/app_tokens.dart';

/// Full-width green pill button used for the main action of a screen.
///
/// Pressed state: [AppTokens.accentPressed] background and a 0.97 scale.
/// Honors `MediaQuery.disableAnimations` (the scale is skipped).
class FbuPrimaryButton extends StatefulWidget {
  const FbuPrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  final VoidCallback? onPressed;

  /// Usually a [Text]; styled with `labelLarge` in [AppTokens.onAccent].
  final Widget child;

  /// Height of the button.
  static const double height = 56;

  /// Scale while pressed.
  static const double pressedScale = 0.97;

  /// Duration of the press feedback.
  static const Duration pressDuration = Duration(milliseconds: 100);

  /// Opacity of the ripple drawn in [AppTokens.onAccent].
  static const double rippleOpacity = 0.12;

  @override
  State<FbuPrimaryButton> createState() => _FbuPrimaryButtonState();
}

class _FbuPrimaryButtonState extends State<FbuPrimaryButton> {
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

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final label = Theme.of(context).textTheme.labelLarge;

    return AnimatedScale(
      scale: _pressed && !reduceMotion ? FbuPrimaryButton.pressedScale : 1,
      duration: reduceMotion ? Duration.zero : FbuPrimaryButton.pressDuration,
      child: SizedBox(
        width: double.infinity,
        height: FbuPrimaryButton.height,
        child: FilledButton(
          onPressed: widget.onPressed,
          statesController: _states,
          style: ButtonStyle(
            elevation: const WidgetStatePropertyAll(0),
            shape: const WidgetStatePropertyAll(StadiumBorder()),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return tokens.surfaceVariant;
              }
              return states.contains(WidgetState.pressed)
                  ? tokens.accentPressed
                  : tokens.accent;
            }),
            foregroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.disabled)
                  ? tokens.textDisabled
                  : tokens.onAccent,
            ),
            overlayColor: WidgetStatePropertyAll(
              tokens.onAccent.withValues(alpha: FbuPrimaryButton.rippleOpacity),
            ),
            textStyle: WidgetStatePropertyAll(label),
            padding: WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: tokens.space3),
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
