import 'package:material_ui/material_ui.dart';

/// Fixed layout and motion values of the auth module (design 360×800).
/// Colors, the 8-based spacing scale and radii come from `AppTokens`; these
/// are the module-specific measurements.
abstract final class AuthMetrics {
  /// Content never grows wider than this (tablets, large phones).
  static const double maxContentWidth = 420;

  // Title (Satoshi Bold 32/38, −0.02 em).
  static const double titleLineHeight = 38;
  static const double titleLetterSpacing = -0.64;

  // Text field
  static const double fieldHeight = 56;
  static const double fieldBorderWidth = 1.5;
  static const double fieldVerticalPadding = 6;
  static const double fieldLabelGap = 2;
  static const double fieldGap = 12;
  static const double fieldLabelLineHeight = 16;
  static const double fieldValueLineHeight = 22;
  static const double helperGap = 4;
  static const double footerGap = 4;
  static const double helperEntryOffset = 4;

  // Icons and touch targets
  static const double touchTarget = 48;
  static const double eyeIconSize = 22;
  static const double backIconSize = 24;
  static const double backButtonInset = 4;

  // Buttons
  static const double buttonGap = 12;
  static const double googleLogoSize = 20;
  static const double googleLogoGap = 12;
  static const String googleLogoAsset = 'assets/icons/google_g.png';

  // "o" divider
  static const double dividerThickness = 1;
  static const double dividerGap = 12;
  static const double dividerFontSize = 13;

  // Banner (error / success)
  static const double bannerIconSize = 20;
  static const double bannerPaddingVertical = 12;
  static const double bannerIconGap = 12;
  static const double bannerLineHeight = 20;
  static const double bannerFillOpacity = 0.12;
  static const double bannerBorderOpacity = 0.4;
  static const double bannerEntryOffset = 8;
  static const Duration bannerEntry = Duration(milliseconds: 250);

  // Sent check
  static const double checkCircleSize = 64;
  static const double checkCircleOpacity = 0.12;
  static const double checkIconSize = 28;
  static const double checkStroke = 3;
  static const double checkCircleStartScale = 0.6;
  static const Duration checkCircleDuration = Duration(milliseconds: 400);
  static const Duration checkDrawDelay = Duration(milliseconds: 150);
  static const Duration checkDrawDuration = Duration(milliseconds: 300);

  /// Opacity of everything secondary while an action is loading.
  static const double busyOpacity = 0.38;

  // Shake on validation error: ±6 dp, 3 oscillations.
  static const double shakeOffset = 6;
  static const int shakeOscillations = 3;
  static const Duration shakeDuration = Duration(milliseconds: 300);

  // Screen transition inside the shell.
  static const Duration pageExit = Duration(milliseconds: 150);
  static const Duration pageEntryDelay = Duration(milliseconds: 200);
  static const Duration pageEntry = Duration(milliseconds: 400);
  static const double pageEntryOffset = 12;
  static const Curve pageEntryCurve = Curves.easeOutCubic;

  /// Countdown before the reset email can be sent again.
  static const Duration resendCooldown = Duration(seconds: 45);
}
