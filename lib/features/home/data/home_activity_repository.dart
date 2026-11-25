import '../domain/activity_period.dart';
import '../domain/movement.dart';
import '../domain/period_labels.dart';

/// Money activity of the user in a group: the Home chart and "Últimos
/// movimientos". The UI only depends on this interface.
abstract interface class HomeActivityRepository {
  /// The [limit] most recent movements of [groupId] that involve [uid],
  /// newest first.
  Stream<List<Movement>> watchRecentMovements({
    required String groupId,
    required String uid,
    int limit = recentLimit,
  });

  /// What [uid] paid, is owed and owes in [groupId] along [period].
  Stream<ActivitySeries> watchSeries({
    required String groupId,
    required String uid,
    required ActivityPeriod period,
  });

  /// Movements shown in the Home.
  static const int recentLimit = 5;
}

/// In-memory activity with the data of the design captures.
// TODO: replace with a Firestore implementation that derives movements and
// series from outings, payments and settlements (balances are computed,
// never stored). If the volume grows, use aggregates.
// DECISIÓN: every group shows the same sample data until then.
class FakeHomeActivityRepository implements HomeActivityRepository {
  FakeHomeActivityRepository({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;

  static const int _thousand = 1000;

  @override
  Stream<List<Movement>> watchRecentMovements({
    required String groupId,
    required String uid,
    int limit = HomeActivityRepository.recentLimit,
  }) {
    final now = _clock();
    final today = DateTime(now.year, now.month, now.day);
    final movements = [
      Movement(
        id: 'm1',
        type: MovementType.income,
        amount: 32 * _thousand,
        title: '@ana te pagó',
        place: 'Crepes & Waffles',
        createdAt: now.subtract(const Duration(minutes: 45)),
      ),
      Movement(
        id: 'm2',
        type: MovementType.payment,
        amount: 248 * _thousand,
        title: 'Pagaste la cuenta',
        place: 'Andrés Carne de Res',
        createdAt: today.subtract(const Duration(hours: 3)),
        participants: 6,
      ),
      Movement(
        id: 'm3',
        type: MovementType.debt,
        amount: 41500,
        title: 'Le debes a @pedro',
        place: 'Bogotá Beer Company',
        createdAt: today.subtract(const Duration(days: 3, hours: 2)),
      ),
    ];
    return Stream.value(movements.take(limit).toList());
  }

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
