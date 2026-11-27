import 'package:material_ui/material_ui.dart';

import '../balances_metrics.dart';

/// An amount that counts to its new [value] (tabular figures, so the width
/// does not jump): from 0 the first time, in [firstDuration], and from the
/// previous value afterwards, in [duration]. With
/// `MediaQuery.disableAnimations` it changes right away.
class CountingAmount extends StatefulWidget {
  const CountingAmount({
    super.key,
    required this.value,
    required this.format,
    required this.style,
    this.firstDuration = BalancesMetrics.netCount,
    this.duration = BalancesMetrics.netRecount,
  });

  /// Whole pesos.
  final int value;
  final String Function(int value) format;
  final TextStyle style;
  final Duration firstDuration;
  final Duration duration;

  @override
  State<CountingAmount> createState() => _CountingAmountState();
}

class _CountingAmountState extends State<CountingAmount> {
  bool _first = true;

  @override
  void didUpdateWidget(covariant CountingAmount oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _first = false;
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final text = Semantics(
      label: widget.format(widget.value),
      child: ExcludeSemantics(child: _animated(reduceMotion)),
    );
    return text;
  }

  Widget _animated(bool reduceMotion) {
    if (reduceMotion) return _text(widget.value);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: widget.value.toDouble()),
      duration: _first ? widget.firstDuration : widget.duration,
      curve: BalancesMetrics.countCurve,
      builder: (context, value, _) => _text(value.round()),
    );
  }

  Widget _text(int value) => Text(
    widget.format(value),
    maxLines: 1,
    softWrap: false,
    overflow: TextOverflow.visible,
    style: widget.style,
  );
}
