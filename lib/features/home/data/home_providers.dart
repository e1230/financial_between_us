import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../groups/data/groups_providers.dart';
import '../../profile/data/profile_providers.dart';
import '../domain/activity_period.dart';
import '../domain/movement.dart';
import 'home_activity_repository.dart';

part 'home_providers.g.dart';

@Riverpod(keepAlive: true)
HomeActivityRepository homeActivityRepository(Ref ref) =>
    FakeHomeActivityRepository();

/// Period of the Home chart; kept while the app is open.
@Riverpod(keepAlive: true)
class SelectedPeriod extends _$SelectedPeriod {
  @override
  ActivityPeriod build() => ActivityPeriod.initial;

  void select(ActivityPeriod period) => state = period;
}

/// Latest movements of the active group that involve the user.
@riverpod
Stream<List<Movement>> recentMovements(Ref ref) async* {
  final group = await ref.watch(activeGroupProvider.future);
  final profile = await ref.watch(currentUserProfileProvider.future);
  if (group == null || profile == null) {
    yield const [];
    return;
  }
  yield* ref
      .watch(homeActivityRepositoryProvider)
      .watchRecentMovements(groupId: group.id, uid: profile.uid);
}

/// Chart series of the active group in the selected period.
@riverpod
Stream<ActivitySeries?> activitySeries(Ref ref) async* {
  final period = ref.watch(selectedPeriodProvider);
  final group = await ref.watch(activeGroupProvider.future);
  final profile = await ref.watch(currentUserProfileProvider.future);
  if (group == null || profile == null) {
    yield null;
    return;
  }
  yield* ref
      .watch(homeActivityRepositoryProvider)
      .watchSeries(groupId: group.id, uid: profile.uid, period: period);
}

/// Version of the installed app, like "1.0.0".
@Riverpod(keepAlive: true)
Future<String> appVersion(Ref ref) async =>
    (await PackageInfo.fromPlatform()).version;
