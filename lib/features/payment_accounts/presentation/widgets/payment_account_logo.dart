import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/dashed_rounded_border.dart';
import '../../domain/payment_account.dart';
import '../payment_accounts_metrics.dart';
import '../payment_accounts_strings.dart';

/// Size of a [PaymentAccountLogo].
enum PaymentAccountLogoSize {
  /// 32 dp tile with a 20 dp symbol: list rows, the "Tipo" field and the
  /// type tiles.
  small(
    PaymentAccountsMetrics.logoSmall,
    PaymentAccountsMetrics.logoSmallRadius,
    PaymentAccountsMetrics.logoSmallIcon,
  ),

  /// 56 dp tile with a 34 dp symbol: the detail sheet and the empty state.
  large(
    PaymentAccountsMetrics.logoLarge,
    PaymentAccountsMetrics.logoLargeRadius,
    PaymentAccountsMetrics.logoLargeIcon,
  );

  const PaymentAccountLogoSize(this.box, this.radius, this.symbol);

  final double box;
  final double radius;
  final double symbol;
}

/// Logo of a payment account type, wherever it shows up.
///
/// Brands (Nequi, Bre-B, Daviplata) sit on white and are never recolored;
/// cash and "other" use outline icons on `surfaceVariant`. Without a
/// [type] it is a dashed outline with a +. If a brand asset is missing it
/// shows a gray image placeholder instead of failing.
class PaymentAccountLogo extends StatelessWidget {
  const PaymentAccountLogo({
    super.key,
    required this.type,
    this.size = PaymentAccountLogoSize.small,
  });

  final PaymentAccountType? type;
  final PaymentAccountLogoSize size;

  /// Asset of each type.
  static String assetOf(PaymentAccountType type) => switch (type) {
    PaymentAccountType.nequi => 'assets/logos/nequi.svg',
    PaymentAccountType.breb => 'assets/logos/breb.svg',
    PaymentAccountType.daviplata => 'assets/logos/daviplata.svg',
    PaymentAccountType.cash => 'assets/logos/efectivo.svg',
    PaymentAccountType.other => 'assets/logos/otro.svg',
  };

  static bool _isBrand(PaymentAccountType type) =>
      type != PaymentAccountType.cash && type != PaymentAccountType.other;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final type = this.type;
    final radius = BorderRadius.circular(size.radius);

    if (type == null) {
      return ExcludeSemantics(
        child: CustomPaint(
          painter: DashedRoundedBorderPainter(
            color: tokens.outlineMuted,
            radius: size.radius,
            strokeWidth: PaymentAccountsMetrics.logoDashWidth,
          ),
          child: SizedBox.square(
            dimension: size.box,
            child: Icon(Icons.add, size: size.symbol, color: tokens.iconMuted),
          ),
        ),
      );
    }

    final brand = _isBrand(type);
    return Semantics(
      label: type.logoLabel,
      image: true,
      excludeSemantics: true,
      child: Container(
        width: size.box,
        height: size.box,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: brand ? tokens.logoBrandBackground : tokens.surfaceVariant,
          borderRadius: radius,
        ),
        child: SvgPicture.asset(
          assetOf(type),
          width: size.symbol,
          height: size.symbol,
          fit: BoxFit.contain,
          // A missing or broken asset must never break the screen.
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.image_outlined,
            size: size.symbol * PaymentAccountsMetrics.logoPlaceholderIcon,
            color: tokens.logoPlaceholder,
          ),
        ),
      ),
    );
  }
}
