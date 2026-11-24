import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../auth_metrics.dart';
import '../auth_strings.dart';

/// Layout shared by the auth screens.
///
/// - Transparent, so the shell background shows through. It does not resize
///   with the keyboard: the content scrolls instead (`reverse: true`), which
///   keeps the focused field and the main button visible.
/// - Content anchored to the bottom, 24 dp side padding, at most 420 dp wide.
/// - Optional ← button at `top: padding.top + 4, left: 4`.
/// - While [busy], system back and ← are disabled.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.children,
    this.showBack = true,
    this.busy = false,
    this.bottomGap,
  });

  final List<Widget> children;
  final bool showBack;
  final bool busy;

  /// Space above the gesture bar. Defaults to 8 dp (16 dp on Welcome).
  final double? bottomGap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final padding = MediaQuery.paddingOf(context);
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final top =
        padding.top +
        (showBack
            ? AuthMetrics.backButtonInset + AuthMetrics.touchTarget
            : tokens.space1);
    final bottom = padding.bottom + keyboard + (bottomGap ?? tokens.space1);

    return PopScope(
      canPop: !busy,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  reverse: true,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    tokens.space3,
                    top,
                    tokens.space3,
                    bottom,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: (constraints.maxHeight - top - bottom).clamp(
                        0,
                        double.infinity,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: AuthMetrics.maxContentWidth,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: children,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (showBack)
              Positioned(
                top: padding.top + AuthMetrics.backButtonInset,
                left: AuthMetrics.backButtonInset,
                child: AuthBackButton(enabled: !busy),
              ),
          ],
        ),
      ),
    );
  }
}

/// 48×48 ← button with tooltip "Volver"; at 38 % while disabled.
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key, this.enabled = true});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return AnimatedOpacity(
      opacity: enabled ? 1 : AuthMetrics.busyOpacity,
      duration: reduceMotion ? Duration.zero : tokens.motionFast,
      child: IconButton(
        onPressed: enabled ? () => Navigator.maybePop(context) : null,
        tooltip: AuthStrings.back,
        constraints: const BoxConstraints.tightFor(
          width: AuthMetrics.touchTarget,
          height: AuthMetrics.touchTarget,
        ),
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.arrow_back, size: AuthMetrics.backIconSize),
        color: tokens.textPrimary,
        disabledColor: tokens.textPrimary,
      ),
    );
  }
}

/// Dims [child] to 38 % (150 ms) and blocks it while [busy].
class BusyFade extends StatelessWidget {
  const BusyFade({super.key, required this.busy, required this.child});

  final bool busy;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return IgnorePointer(
      ignoring: busy,
      child: AnimatedOpacity(
        opacity: busy ? AuthMetrics.busyOpacity : 1,
        duration: reduceMotion ? Duration.zero : context.tokens.motionFast,
        child: child,
      ),
    );
  }
}
