import '../domain/activity_period.dart';
import '../domain/period_labels.dart';

/// Money activity of the user in a group over time: the Home chart. The
/// UI only depends on this interface. ("Últimos movimientos" comes from the
/// real movements, see `recentMovementsProvider`.)
abstract interface class HomeActivityRepository {
  /// What [uid] paid, is owed and owes in [groupId] along [period].
  Stream<ActivitySeries> watchSeries({
    required String groupId,
    required String uid,
    required ActivityPeriod period,
  });
}

/// In-memory chart series with the data of the design captures.
// TODO: derive the series from the group movements once events exist
// (balances are computed, never stored). If the volume grows, use
// aggregates.
// DECISIÓN: every group shows the same sample data until then.
class FakeHomeActivityRepository implements HomeActivityRepository {
  FakeHomeActivityRepository({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;

  static const int _thousand = 1000;

  @override
  Stream<ActivitySeries> watchSeries({
    required String groupId,
    required String uid,
    required ActivityPeriod period,
  }) {
    final labels = PeriodLabels.of(period, _clock());
    List<int> k(List<num> values) => [
      for (final v in values) (v * _thousand).round(),
    ];
    final (paid, owed, owe) = switch (period) {
      ActivityPeriod.sixMonths => (
        k([180, 240, 210, 320, 280, 412]),
        k([60, 95, 150, 130, 185, 162]),
        k([120, 90, 140, 60, 110, 86.5]),
      ),
      ActivityPeriod.month => (
        k([60, 140, 95, 117, 80]),
        k([120, 150, 140, 170, 162]),
        k([95, 70, 110, 92, 86.5]),
      ),
      ActivityPeriod.week => (
        k([0, 32, 0, 0, 248, 54, 78]),
        k([150, 150, 140, 140, 175, 170, 162]),
        k([60, 60, 60, 60, 100, 92, 86.5]),
      ),
    };
    final n = labels.length;
    List<int> fit(List<int> values) => [
      for (var i = 0; i < n; i++)
        values[i < values.length ? i : values.length - 1],
    ];
    final paidFit = fit(paid);
    return Stream.value(
      ActivitySeries(
        labels: labels,
        paid: paidFit,
        owedToYou: fit(owed),
        youOwe: fit(owe),
        paidTotal: paidFit.fold(0, (sum, v) => sum + v),
      ),
    );
  }
}
