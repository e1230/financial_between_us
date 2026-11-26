import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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

/// Cloudinary uploader configured from `.env` (loaded by app startup).
@Riverpod(keepAlive: true)
AvatarUploader avatarUploader(Ref ref) => CloudinaryAvatarUploader(
  cloudName: dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '',
  uploadPreset: dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '',
);

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
