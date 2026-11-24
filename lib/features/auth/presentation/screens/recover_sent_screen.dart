import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/fbu_primary_button.dart';
import '../../../../core/widgets/fbu_secondary_button.dart';
import '../../domain/mask_email.dart';
import '../auth_form.dart';
import '../auth_metrics.dart';
import '../auth_strings.dart';
import '../auth_text_styles.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/success_check.dart';

/// Confirmation after requesting a password reset, with a 45 s cooldown
/// before the email can be sent again.
class RecoverSentScreen extends StatefulWidget {
  const RecoverSentScreen({super.key, required this.email});

  /// Address the link was sent to; shown masked.
  final String email;

  @override
  State<RecoverSentScreen> createState() => _RecoverSentScreenState();
}

class _RecoverSentScreenState extends State<RecoverSentScreen> {
  static const _tick = Duration(seconds: 1);

  Timer? _timer;
  Duration _left = AuthMetrics.resendCooldown;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  void _startCooldown() {
    _timer?.cancel();
    _left = AuthMetrics.resendCooldown;
    _timer = Timer.periodic(_tick, (timer) {
      setState(() => _left -= _tick);
      if (_left <= Duration.zero) timer.cancel();
    });
  }

  Future<void> _resend() async {
    if (_resending) return;
    setState(() => _resending = true);
    // TODO: send the reset email again (handoff section 6.5).
    await simulateAuthRequest();
    if (!mounted) return;
    setState(() {
      _resending = false;
      _startCooldown();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = AuthTextStyles.of(context);
    final canResend = _left <= Duration.zero;
    return AuthScaffold(
      busy: _resending,
      children: [
        const Align(alignment: Alignment.centerLeft, child: SuccessCheck()),
        SizedBox(height: tokens.space3),
        Text(AuthStrings.sentTitle, style: styles.title),
        SizedBox(height: tokens.space1),
        Text(
          AuthStrings.sentBody(maskEmail(widget.email)),
          style: styles.subtitle,
        ),
        SizedBox(height: tokens.space4),
        FbuPrimaryButton(
          onPressed: () => context.go(AppRoutes.login),
          child: const Text(AuthStrings.backToSignIn),
        ),
        const SizedBox(height: AuthMetrics.buttonGap),
        FbuSecondaryButton(
          onPressed: canResend ? _resend : null,
          isLoading: _resending,
          loadingSemanticsLabel: AuthStrings.sending,
          child: Text(
            canResend ? AuthStrings.resend : AuthStrings.resendIn(_left),
          ),
        ),
        SizedBox(height: tokens.space1),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AuthMetrics.touchTarget),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(AuthStrings.spamNote, style: styles.footer),
          ),
        ),
      ],
    );
  }
}
