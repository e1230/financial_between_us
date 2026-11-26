import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/fbu_primary_button.dart';
import '../payment_accounts_metrics.dart';
import '../payment_accounts_strings.dart';

/// Green "Copiar" of the detail. Copies [reference] (without format) and
/// turns into "Copiado" with a check for 1.5 s: the icon morphs (scale
/// 0.6 → 1 + fade, ease-out-back, 200 ms) and the text cross-fades
/// (150 ms). With `MediaQuery.disableAnimations` both only fade.
class CopyButton extends StatefulWidget {
  const CopyButton({super.key, required this.reference});

  final String reference;

  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  bool _copied = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.reference));
    if (!mounted) return;
    _timer?.cancel();
    setState(() => _copied = true);
    _timer = Timer(PaymentAccountsMetrics.copiedFor, () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final label = _copied
        ? PaymentAccountsStrings.copiedButton
        : PaymentAccountsStrings.copy;
    return Semantics(
      liveRegion: _copied,
      child: FbuPrimaryButton(
        onPressed: _copy,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: reduceMotion
                  ? PaymentAccountsMetrics.reducedFade
                  : PaymentAccountsMetrics.morph,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: reduceMotion
                    ? child
                    : ScaleTransition(
                        // Only the scale overshoots; the fade stays
                        // within 0–1.
                        scale:
                            Tween(
                                  begin: PaymentAccountsMetrics.morphStartScale,
                                  end: 1.0,
                                )
                                .chain(CurveTween(curve: Curves.easeOutBack))
                                .animate(animation),
                        child: child,
                      ),
              ),
              child: Icon(
                _copied ? Icons.check : Icons.copy_outlined,
                key: ValueKey(_copied),
                size: PaymentAccountsMetrics.buttonIconSize,
                color: tokens.onAccent,
              ),
            ),
            const SizedBox(width: PaymentAccountsMetrics.buttonIconGap),
            Flexible(
              child: AnimatedSwitcher(
                duration: PaymentAccountsMetrics.crossfade,
                child: Text(
                  label,
                  key: ValueKey(label),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
