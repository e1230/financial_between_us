import '../../profile/domain/user_profile.dart';

/// Where a signed-in user goes.
enum SessionDestination {
  /// Signed in (e.g. with Google) but `users/{uid}` does not exist yet: the
  /// user still has to choose a nickname.
  chooseNickname,

  /// The profile exists but "Completa tu perfil" was not finished.
  completeProfile,

  /// Everything set up.
  home,
}

/// Decides the [SessionDestination] of a signed-in user from their
/// [profile] (`null` when `users/{uid}` does not exist).
SessionDestination sessionDestinationFor(UserProfile? profile) {
  if (profile == null) return SessionDestination.chooseNickname;
  if (!profile.profileCompleted) return SessionDestination.completeProfile;
  return SessionDestination.home;
}
