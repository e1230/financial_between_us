import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/profile/data/profile_providers.dart';
import '../theme/app_tokens.dart';
import '../widgets/fbu_secondary_button.dart';
import '../widgets/user_avatar.dart';
import 'app_router.dart';

// TODO: replace with the real home (groups and outings).
/// Temporary home: shows who is signed in and lets them sign out.
class HomePlaceholderScreen extends ConsumerStatefulWidget {
  const HomePlaceholderScreen({super.key});

  /// Avatar size of this placeholder.
  static const double avatarSize = 72;

  @override
  ConsumerState<HomePlaceholderScreen> createState() =>
      _HomePlaceholderScreenState();
}

class _HomePlaceholderScreenState extends ConsumerState<HomePlaceholderScreen> {
  bool _signingOut = false;

  Future<void> _signOut() async {
    setState(() => _signingOut = true);
    try {
      await ref.read(authRepositoryProvider).signOut();
      if (mounted) context.go(AppRoutes.welcome);
    } catch (_) {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final profile = ref.watch(currentUserProfileProvider).value;
    final photoUrl = profile?.photoUrl;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(tokens.space3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (profile != null) ...[
                  UserAvatar(
                    initial: profile.initial,
                    color: Color(profile.colorValue),
                    image: photoUrl == null ? null : NetworkImage(photoUrl),
                    size: HomePlaceholderScreen.avatarSize,
                  ),
                  SizedBox(height: tokens.space2),
                  Text(profile.displayName, style: textTheme.headlineSmall),
                  Text(
                    '@${profile.nickname}',
                    style: textTheme.bodyMedium?.copyWith(color: tokens.accent),
                  ),
                  SizedBox(height: tokens.space4),
                ],
                Text('Inicio (pendiente)', style: textTheme.titleMedium),
                SizedBox(height: tokens.space1),
                Text(
                  'Aquí irán tus grupos y salidas.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: tokens.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: tokens.space4),
                FbuSecondaryButton(
                  onPressed: _signingOut ? null : _signOut,
                  isLoading: _signingOut,
                  loadingSemanticsLabel: 'Cerrando sesión',
                  child: const Text('Cerrar sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
