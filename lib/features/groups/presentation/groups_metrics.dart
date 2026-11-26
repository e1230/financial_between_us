/// Sizes of the "Grupos" page that the theme tokens do not cover.
abstract final class GroupsMetrics {
  /// Gap between the screen top (below the status bar) and the back button.
  static const double backTop = 8;

  /// Left inset of the back button, so its icon lines up with the content.
  static const double backInset = 4;
  static const double backIconSize = 24;

  /// Minimum height of a group card.
  static const double cardMinHeight = 76;

  /// Size of the check of the group shown in the Home.
  static const double checkSize = 20;

  /// Size of the leave / cancel icon of a card.
  static const double actionIconSize = 22;

  /// Widths of the skeleton bars, relative to the free width.
  static const double skeletonTitleWidth = 0.55;
  static const double skeletonDetailWidth = 0.35;

  /// Avatar of a member row.
  static const double memberAvatar = 40;

  /// Minimum height of a member row.
  static const double memberMinHeight = 64;

  /// Horizontal and vertical padding of a tag of the info card.
  static const double tagPaddingH = 10;
  static const double tagPaddingV = 4;

  /// Height of the approve / reject buttons of a request.
  static const double requestButtonHeight = 36;

  /// Widest the balance of a member row gets ("Te debe / \$ 32.000").
  static const double balanceMaxWidth = 112;

  /// Stroke of the spinner of "Aprobar".
  static const double spinnerStroke = 2;
}
