import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/money_format.dart';
import '../../domain/balances_overview.dart';
import '../balances_metrics.dart';
import '../balances_strings.dart';
import '../balances_text_styles.dart';
import 'counting_amount.dart';

/// "Balance neto": the net amount (counting), a line about the scope, a
/// bar split green (owed to the user) / red (they owe) and the legend.
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.overview,
    required this.scopeName,
  });

  final BalancesOverview overview;

  /// "Low IQ Group" or "3 grupos".
  final String scopeName;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = BalancesTextStyles.of(context);
    final net = overview.net;
    final netColor = net > 0
        ? tokens.positive
        : net < 0
        ? tokens.negative
        : tokens.textPrimary;
    final line = net > 0
        ? BalancesStrings.inFavor(scopeName)
        : net < 0
        ? BalancesStrings.against(scopeName)
        : BalancesStrings.even(scopeName);

    return Container(
      padding: const EdgeInsets.all(BalancesMetrics.summaryPadding),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radiusPanel),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(BalancesStrings.netBalance, style: styles.label),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: CountingAmount(
              key: const ValueKey('net'),
              value: net,
              format: MoneyFormat.signed,
              style: styles.net.copyWith(color: netColor),
            ),
          ),
          Text(line, style: styles.label),
          const SizedBox(height: BalancesMetrics.barGap),
          _BalanceBar(owed: overview.owedToMeTotal, owe: overview.iOweTotal),
          const SizedBox(height: BalancesMetrics.legendGap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Legend(
                  color: tokens.positive,
                  label: BalancesStrings.owedToYou,
                  amount: overview.owedToMeTotal,
                  people: overview.owedToMe.length,
                ),
              ),
              SizedBox(width: tokens.space2),
              Expanded(
                child: _Legend(
                  color: tokens.negative,
                  label: BalancesStrings.youOwe,
                  amount: overview.iOweTotal,
                  people: overview.iOwe.length,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Two pills (green with flex = owed, red with flex = owe) that grow from
/// the left (500 ms; red 80 ms later). A single gray bar when both are 0.
class _BalanceBar extends StatefulWidget {
  const _BalanceBar({required this.owed, required this.owe});

  final int owed;
  final int owe;

  @override
  State<_BalanceBar> createState() => _BalanceBarState();
}

class _BalanceBarState extends State<_BalanceBar>
    with SingleTickerProviderStateMixin {
  static final int _total =
      (BalancesMetrics.barGrow + BalancesMetrics.barRedDelay).inMilliseconds;

  late final AnimationController _grow = AnimationController(
    vsync: this,
    duration: BalancesMetrics.barGrow + BalancesMetrics.barRedDelay,
  );
  late final CurvedAnimation _green = CurvedAnimation(
    parent: _grow,
    curve: Interval(
      0,
      BalancesMetrics.barGrow.inMilliseconds / _total,
      curve: Curves.easeOutCubic,
    ),
  );
  late final CurvedAnimation _red = CurvedAnimation(
    parent: _grow,
    curve: Interval(
      BalancesMetrics.barRedDelay.inMilliseconds / _total,
      1,
      curve: Curves.easeOutCubic,
    ),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _grow.value = 1;
    } else {
      _grow.forward();
    }
  }

  @override
  void dispose() {
    _green.dispose();
    _red.dispose();
    _grow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final green = _green;
    final red = _red;

    Widget segment(Color color, Animation<double> progress) => AnimatedBuilder(
      animation: progress,
      builder: (context, _) => FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.value,
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: color,
            shape: const StadiumBorder(),
          ),
        ),
      ),
    );

    final owed = widget.owed;
    final owe = widget.owe;
    return Semantics(
      label: BalancesStrings.barLabel(owed, owe),
      child: ExcludeSemantics(
        child: SizedBox(
          height: BalancesMetrics.barHeight,
          child: owed == 0 && owe == 0
              ? segment(tokens.border, green)
              : Row(
                  children: [
                    if (owed > 0)
                      Expanded(
                        flex: owed,
                        child: segment(tokens.positive, green),
                      ),
                    if (owed > 0 && owe > 0)
                      const SizedBox(width: BalancesMetrics.barSegmentGap),
                    if (owe > 0)
                      Expanded(flex: owe, child: segment(tokens.negative, red)),
                  ],
                ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.color,
    required this.label,
    required this.amount,
    required this.people,
  });

  final Color color;
  final String label;
  final int amount;
  final int people;

  @override
  Widget build(BuildContext context) {
    final styles = BalancesTextStyles.of(context);
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: BalancesMetrics.legendDot,
                height: BalancesMetrics.legendDot,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: BalancesMetrics.legendDotGap),
              Flexible(child: Text(label, style: styles.caption)),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              MoneyFormat.format(amount),
              maxLines: 1,
              softWrap: false,
              style: styles.legendAmount,
            ),
          ),
          Text(
            people == 0
                ? BalancesStrings.nobody
                : BalancesStrings.people(people),
            style: styles.caption,
          ),
        ],
      ),
    );
  }
}
