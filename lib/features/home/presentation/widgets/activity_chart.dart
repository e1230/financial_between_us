import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/user_palette.dart';
import '../../../../core/utils/money_format.dart';
import '../../domain/activity_period.dart';
import '../home_metrics.dart';
import '../home_strings.dart';
import '../home_text_styles.dart';

/// Line chart of the period: "Pagado", "Te deben" and "Debes".
///
/// Lines grow from zero when it appears and morph when the period changes
/// (600 ms, ease-out cubic). With `MediaQuery.disableAnimations` it is
/// drawn complete at once.
class ActivityChart extends StatefulWidget {
  const ActivityChart({super.key, required this.series});

  final ActivitySeries series;

  @override
  State<ActivityChart> createState() => _ActivityChartState();
}

class _ActivityChartState extends State<ActivityChart> {
  /// Whether the first frame (all lines at zero) was drawn.
  bool _entered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _entered = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = HomeTextStyles.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final series = widget.series;
    final grown = _entered || reduceMotion;

    final paidColor = context.userPalette.userSoft;
    final owedColor = tokens.positive;
    final oweColor = tokens.negative;
    final maxValue = series.maxValue;
    final maxY = maxValue == 0 ? 1.0 : maxValue * HomeMetrics.chartMaxFactor;
    final lastX = (series.labels.length - 1).toDouble();

    LineChartBarData line(List<int> values, Color color, {double? area}) {
      return LineChartBarData(
        spots: [
          for (final (i, v) in values.indexed)
            FlSpot(i.toDouble(), grown ? v.toDouble() : 0),
        ],
        color: color,
        isCurved: true,
        curveSmoothness: HomeMetrics.chartCurveSmoothness,
        preventCurveOverShooting: true,
        barWidth: HomeMetrics.chartLineWidth,
        isStrokeCapRound: true,
        dotData: FlDotData(
          checkToShowDot: (spot, _) => spot.x == lastX,
          getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
            radius: HomeMetrics.chartDotRadius,
            color: tokens.background,
            strokeWidth: HomeMetrics.chartDotStroke,
            strokeColor: color,
          ),
        ),
        belowBarData: BarAreaData(
          show: area != null,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: area ?? 0),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      );
    }

    final bars = [
      line(series.paid, paidColor, area: HomeMetrics.chartPaidAreaOpacity),
      line(series.owedToYou, owedColor),
      line(series.youOwe, oweColor, area: HomeMetrics.chartOweAreaOpacity),
    ];
    final names = [HomeStrings.paid, HomeStrings.owedToYou, HomeStrings.youOwe];
    final gridLine = FlLine(
      color: tokens.textPrimary.withValues(alpha: HomeMetrics.chartGridOpacity),
      strokeWidth: 1,
      dashArray: HomeMetrics.chartGridDash,
    );

    final data = LineChartData(
      minX: 0,
      maxX: lastX,
      minY: 0,
      maxY: maxY,
      lineBarsData: bars,
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        drawVerticalLine: false,
        horizontalInterval: maxY / HomeMetrics.chartGridLines,
        checkToShowHorizontalLine: (value) => value > 0,
        getDrawingHorizontalLine: (_) => gridLine,
      ),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(),
        rightTitles: const AxisTitles(),
        topTitles: const AxisTitles(),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            reservedSize: HomeMetrics.chartAxisHeight,
            getTitlesWidget: (value, meta) {
              final index = value.round();
              if (index != value || index < 0 || index > lastX) {
                return const SizedBox.shrink();
              }
              return SideTitleWidget(
                meta: meta,
                space: tokens.space1 / 2,
                fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                child: Text(series.labels[index], style: styles.axis),
              );
            },
          ),
        ),
      ),
      lineTouchData: LineTouchData(
        getTouchedSpotIndicator: (bar, indexes) => [
          for (final _ in indexes)
            TouchedSpotIndicatorData(
              FlLine(color: gridLine.color, strokeWidth: 1),
              const FlDotData(show: false),
            ),
        ],
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => tokens.surfaceVariant,
          tooltipBorderRadius: BorderRadius.circular(tokens.radiusCard),
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipItems: (spots) => [
            for (final spot in spots)
              LineTooltipItem(
                '${names[spot.barIndex]}  ',
                styles.tooltip.copyWith(color: tokens.textSecondary),
                textAlign: TextAlign.left,
                children: [
                  TextSpan(
                    text: MoneyFormat.format(spot.y.round()),
                    style: styles.tooltip.copyWith(color: spot.bar.color),
                  ),
                ],
              ),
          ],
        ),
      ),
    );

    return Semantics(
      label: HomeStrings.chartSemantics(
        paid: MoneyFormat.format(series.paidTotal),
        owedToYou: MoneyFormat.format(series.owedToYouNow),
        youOwe: MoneyFormat.format(series.youOweNow),
      ),
      image: true,
      excludeSemantics: true,
      child: SizedBox(
        height: HomeMetrics.chartHeight + HomeMetrics.chartAxisHeight,
        child: LineChart(
          data,
          duration: reduceMotion ? Duration.zero : HomeMetrics.chartAnimation,
          curve: HomeMetrics.easeOutCubic,
        ),
      ),
    );
  }
}
