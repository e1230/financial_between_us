import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../auth_metrics.dart';
import '../auth_text_styles.dart';

enum AuthBannerKind { error, success }

/// Inline notice of a form: red for errors, green for success.
///
/// Enters with a fade and an 8 dp rise (250 ms) and is announced by screen
/// readers. Give it a key per message to replay the entry.
class AuthBanner extends StatelessWidget {
  const AuthBanner({
    super.key,
    required this.message,
    this.kind = AuthBannerKind.error,
  });

  final String message;
  final AuthBannerKind kind;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = kind == AuthBannerKind.error
        ? tokens.negative
        : tokens.accent;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final banner = Container(
      padding: EdgeInsets.symmetric(
        vertical: AuthMetrics.bannerPaddingVertical,
        horizontal: tokens.space2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AuthMetrics.bannerFillOpacity),
        borderRadius: BorderRadius.circular(tokens.radiusInput),
        border: Border.all(
          color: color.withValues(alpha: AuthMetrics.bannerBorderOpacity),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            kind == AuthBannerKind.error
                ? Icons.error_outline
                : Icons.check_circle_outline,
            size: AuthMetrics.bannerIconSize,
            color: color,
          ),
          const SizedBox(width: AuthMetrics.bannerIconGap),
          Expanded(
            child: Text(message, style: AuthTextStyles.of(context).banner),
          ),
        ],
      ),
    );

    return Semantics(
      liveRegion: true,
      container: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: reduceMotion ? Duration.zero : AuthMetrics.bannerEntry,
        curve: Curves.easeOut,
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, AuthMetrics.bannerEntryOffset * (1 - value)),
            child: child,
          ),
        ),
        child: banner,
      ),
    );
  }
}
