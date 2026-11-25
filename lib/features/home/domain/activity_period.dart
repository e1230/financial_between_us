/// Period of the Home chart.
enum ActivityPeriod {
  week,
  month,
  sixMonths;

  /// Default period of the chart.
  static const ActivityPeriod initial = ActivityPeriod.sixMonths;
}

/// Money of the user in a group along a period, one point per slot (day,
/// week or month). Whole pesos.
class ActivitySeries {
  ActivitySeries({
    required this.labels,
    required this.paid,
    required this.owedToYou,
    required this.youOwe,
    required this.paidTotal,
  }) : assert(
         paid.length == labels.length &&
             owedToYou.length == labels.length &&
             youOwe.length == labels.length,
         'Every series needs one value per label',
       );

  /// X axis labels ("Jun", "S1", "L").
  final List<String> labels;

  /// What the user paid in each slot.
  final List<int> paid;

  /// What others owed the user at the end of each slot.
  final List<int> owedToYou;

  /// What the user owed at the end of each slot.
  final List<int> youOwe;

  /// What the user paid in the whole period.
  final int paidTotal;

  /// Current balance in favor (last slot).
  int get owedToYouNow => owedToYou.isEmpty ? 0 : owedToYou.last;

  /// Current balance against (last slot).
  int get youOweNow => youOwe.isEmpty ? 0 : youOwe.last;

  /// Highest value of the three series (0 when empty).
  int get maxValue =>
      [...paid, ...owedToYou, ...youOwe].fold(0, (max, v) => v > max ? v : max);
}
