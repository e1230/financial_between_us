/// Fixed layout values of the profile module. Colors, the 8-based spacing
/// scale and radii come from `AppTokens`.
abstract final class ProfileMetrics {
  // Avatar editor
  static const double avatarSize = 96;
  static const double avatarBadgeSize = 32;
  static const double avatarBadgeIconSize = 18;
  static const double avatarBadgeBorder = 3;

  // Color swatches
  static const double swatchSize = 40;

  /// Tap area of a swatch (48 dp); swatches look 12 dp apart.
  static const double swatchTouchTarget = 48;
  static const double swatchGap = 4;
  static const double swatchRingWidth = 2;
  static const double swatchRingGap = 3;
  static const double swatchCheckSize = 20;

  // Custom color area
  static const double shadeAreaHeight = 144;
  static const double hueBarHeight = 24;
  static const double thumbSize = 24;
  static const double thumbBorder = 3;

  /// Opacity of the cover over shades that are not readable.
  static const double unreadableCoverOpacity = 0.72;

  /// Columns sampled to draw the readable boundary.
  static const int boundarySamples = 48;

  /// Hue stops of the hue bar.
  static const int hueStops = 7;

  // Skeleton
  static const double skeletonLineHeight = 16;
  static const double skeletonTitleWidth = 0.7;
  static const double skeletonSubtitleWidth = 0.9;
}
