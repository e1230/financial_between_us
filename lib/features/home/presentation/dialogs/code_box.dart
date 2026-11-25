import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../home_metrics.dart';
import '../home_strings.dart';
import '../home_text_styles.dart';

/// The join code of a new group with a "Copiar" button. After copying it
/// turns into "Copiado" (green) for 2 s and a line below confirms it.
class CodeBox extends StatefulWidget {
  const CodeBox({super.key, required this.code});

  final String code;

  @override
  State<CodeBox> createState() => _CodeBoxState();
}

class _CodeBoxState extends State<CodeBox> {
  bool _copied = false;
  Timer? _reset;

  @override
  void dispose() {
    _reset?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) return;
    setState(() => _copied = true);
    _reset?.cancel();
    _reset = Timer(HomeMetrics.copiedReset, () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = HomeTextStyles.of(context);
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : tokens.motionFast;
    final color = _copied ? tokens.positive : tokens.textPrimary;
    final background = _copied
        ? tokens.positive.withValues(alpha: HomeMetrics.semanticTintOpacity)
        : tokens.textPrimary.withValues(alpha: HomeMetrics.chipFillOpacity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: HomeMetrics.codeBoxHeight,
          padding: const EdgeInsetsDirectional.only(
            start: HomeMetrics.codeBoxPaddingStart,
            end: HomeMetrics.codeBoxPaddingEnd,
          ),
          decoration: BoxDecoration(
            color: tokens.surfaceVariant,
            borderRadius: BorderRadius.circular(tokens.radiusCard),
          ),
          child: Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: SelectableText(widget.code, style: styles.code),
                ),
              ),
              SizedBox(width: tokens.space1),
              Semantics(
                button: true,
                label: _copied ? HomeStrings.copied : HomeStrings.copyCode,
                excludeSemantics: true,
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: _copy,
                    customBorder: const StadiumBorder(),
                    child: AnimatedContainer(
                      duration: duration,
                      height: HomeMetrics.touchTarget,
                      padding: EdgeInsets.symmetric(horizontal: tokens.space2),
                      decoration: ShapeDecoration(
                        shape: const StadiumBorder(),
                        color: background,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _copied ? Icons.check : Icons.copy_outlined,
                            size: HomeMetrics.copyIconSize,
                            color: color,
                          ),
                          SizedBox(width: tokens.space1),
                          Text(
                            _copied ? HomeStrings.copied : HomeStrings.copy,
                            style: styles.chip.copyWith(color: color),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: duration,
          alignment: Alignment.topCenter,
          child: _copied
              ? Padding(
                  padding: EdgeInsets.only(
                    top: tokens.space1,
                    left: tokens.space1,
                  ),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      HomeStrings.codeCopied,
                      style: styles.small.copyWith(color: tokens.positive),
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
