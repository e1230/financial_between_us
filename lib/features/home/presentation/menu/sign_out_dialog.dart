import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/accent_color.dart';
import '../../../../core/widgets/fbu_dialog.dart';
import '../../../../core/widgets/fbu_pill_button.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../auth/presentation/widgets/auth_banner.dart';
import '../dialogs/dialog_parts.dart';
import '../home_strings.dart';

/// Asks before signing out. On confirm it signs out of Firebase (and
/// Google) and goes to the welcome screen, replacing the whole stack.
Future<void> showSignOutDialog(BuildContext context) => showFbuDialog<void>(
  context: context,
  builder: (_) => const SignOutDialog(),
);

class SignOutDialog extends ConsumerStatefulWidget {
  const SignOutDialog({super.key});

  @override
  ConsumerState<SignOutDialog> createState() => _SignOutDialogState();
}

class _SignOutDialogState extends ConsumerState<SignOutDialog> {
  bool _busy = false;
  bool _failed = false;

  Future<void> _signOut() async {
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      await ref.read(authRepositoryProvider).signOut();
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _failed = true;
        });
      }
      return;
    }
    if (!mounted) return;
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.go(AppRoutes.welcome);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return FbuDialog(
      semanticsLabel: HomeStrings.signOutTitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DialogHeading(
            title: HomeStrings.signOutTitle,
            subtitle: HomeStrings.signOutText,
          ),
          if (_failed) ...[
            SizedBox(height: tokens.space2),
            const AuthBanner(message: HomeStrings.signOutError),
          ],
          SizedBox(height: tokens.space3),
          FbuPillButton(
            onPressed: _signOut,
            isLoading: _busy,
            loadingSemanticsLabel: HomeStrings.signingOut,
            colors: FbuPillButtonColors(
              background: tokens.negative,
              pressedBackground: AccentColor.pressed(tokens.negative),
              disabledBackground: tokens.surfaceVariant,
              foreground: tokens.onAccent,
              disabledForeground: tokens.textDisabled,
              ripple: tokens.onAccent.withValues(
                alpha: FbuPillButton.rippleOpacity,
              ),
            ),
            child: const Text(HomeStrings.signOut),
          ),
          SizedBox(height: tokens.space1),
          DialogCancelButton(
            onPressed: _busy ? null : Navigator.of(context).pop,
          ),
        ],
      ),
    );
  }
}
