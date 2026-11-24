import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_tokens.dart';
import 'auth_metrics.dart';

/// Text styles of the auth module, derived from the app [TextTheme].
@immutable
class AuthTextStyles {
  const AuthTextStyles._({
    required this.title,
    required this.subtitle,
    required this.fieldLabel,
    required this.fieldValue,
    required this.helper,
    required this.link,
    required this.footer,
    required this.divider,
    required this.banner,
  });

  factory AuthTextStyles.of(BuildContext context) {
    final tokens = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final title = textTheme.displaySmall!;
    final bodyLarge = textTheme.bodyLarge!;
    final bodyMedium = textTheme.bodyMedium!;
    final bodySmall = textTheme.bodySmall!;
    return AuthTextStyles._(
      // Satoshi Bold 32/38, −0.02 em.
      title: title.copyWith(
        height: AuthMetrics.titleLineHeight / title.fontSize!,
        letterSpacing: AuthMetrics.titleLetterSpacing,
        color: tokens.textPrimary,
      ),
      // Inter 16/24 at 60 %.
      subtitle: bodyLarge.copyWith(
        height: tokens.space3 / bodyLarge.fontSize!,
        color: tokens.textSecondary,
      ),
      // Inter 12/16 at 60 % (green on focus, red on error).
      fieldLabel: bodySmall.copyWith(
        height: AuthMetrics.fieldLabelLineHeight / bodySmall.fontSize!,
        color: tokens.textSecondary,
      ),
      // Inter 16/22.
      fieldValue: bodyLarge.copyWith(
        height: AuthMetrics.fieldValueLineHeight / bodyLarge.fontSize!,
        color: tokens.textPrimary,
      ),
      // Inter 12/16 at 60 % (red for errors).
      helper: bodySmall.copyWith(
        height: AuthMetrics.fieldLabelLineHeight / bodySmall.fontSize!,
        color: tokens.textSecondary,
      ),
      // Inter 14 w600 green.
      link: textTheme.titleSmall!.copyWith(color: tokens.accent),
      // Inter 14 at 60 %.
      footer: bodyMedium.copyWith(color: tokens.textSecondary),
      // Inter 13 at 60 %.
      divider: bodyMedium.copyWith(
        fontSize: AuthMetrics.dividerFontSize,
        color: tokens.textSecondary,
      ),
      // Inter 14/20.
      banner: bodyMedium.copyWith(
        height: AuthMetrics.bannerLineHeight / bodyMedium.fontSize!,
        color: tokens.textPrimary,
      ),
    );
  }

  final TextStyle title;
  final TextStyle subtitle;
  final TextStyle fieldLabel;
  final TextStyle fieldValue;
  final TextStyle helper;
  final TextStyle link;
  final TextStyle footer;
  final TextStyle divider;
  final TextStyle banner;
}
