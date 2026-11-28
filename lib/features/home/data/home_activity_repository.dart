import '../../balances/data/movements_repository.dart';
import '../domain/activity_period.dart';
import '../domain/activity_series_builder.dart';

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

/// The chart computed from the live active movements of the group (the
/// same stream the balances use), recomputed on every change: balances are
/// computed, never stored.
// TODO: add what the user paid for the bills of events once the Eventos
// module exists. If the volume grows, use aggregates.
class MovementsHomeActivityRepository implements HomeActivityRepository {
  MovementsHomeActivityRepository(this._movements, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final MovementsRepository _movements;
  final DateTime Function() _clock;

  @override
  Stream<ActivitySeries> watchSeries({
    required String groupId,
    required String uid,
    required ActivityPeriod period,
  }) => _movements
      .watchGroup(groupId)
      .map(
        (movements) => activitySeriesOf(
          uid: uid,
          movements: movements,
          period: period,
          now: _clock(),
        ),
      );
}
