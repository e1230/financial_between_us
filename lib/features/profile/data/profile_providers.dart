import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/data/cloudinary_providers.dart';
import '../../../core/data/firestore_providers.dart';
import '../../auth/data/auth_providers.dart';
import '../domain/user_profile.dart';
import 'avatar_picker.dart';
import 'avatar_uploader.dart';
import 'user_profile_repository.dart';

part 'profile_providers.g.dart';

@Riverpod(keepAlive: true)
UserProfileRepository userProfileRepository(Ref ref) =>
    FirestoreUserProfileRepository(ref.watch(firebaseFirestoreProvider));

@Riverpod(keepAlive: true)
AvatarUploader avatarUploader(Ref ref) =>
    CloudinaryAvatarUploader(ref.watch(cloudinaryImageUploaderProvider));

@Riverpod(keepAlive: true)
AvatarPicker avatarPicker(Ref ref) => DeviceAvatarPicker();

/// Live profile of the signed-in user; `null` when signed out or while
/// `users/{uid}` does not exist yet.
@Riverpod(keepAlive: true)
Stream<UserProfile?> currentUserProfile(Ref ref) async* {
  final user = await ref.watch(authStateChangesProvider.future);
  if (user == null) {
    yield null;
    return;
  }
  yield* ref.watch(userProfileRepositoryProvider).watch(user.uid);
}

/// Live profile of any user (friends see each other's name, nickname,
/// photo and color); `null` if it does not exist.
@riverpod
Stream<UserProfile?> userProfile(Ref ref, String uid) =>
    ref.watch(userProfileRepositoryProvider).watch(uid);
