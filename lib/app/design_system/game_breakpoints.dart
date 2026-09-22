/// Viewport breakpoints and game dimension constraints.
abstract final class GameBreakpoints {
  /// Screen width below 360px (e.g. iPhone SE 1st gen).
  static const double compact = 360;

  /// Standard mobile screen width (e.g. iPhone 13/14/15, Pixel).
  static const double standardMobile = 430;

  /// Maximum game content width when rendering on tablet, desktop, or web.
  static const double maxGameContentWidth = 460;

  /// Aspect ratio for hero cards in 2-column grid (~0.72-0.78).
  static const double heroCardAspectRatio = 0.74;

  /// Whether width is considered compact.
  static bool isCompact(double width) => width < compact;

  /// Whether width is considered wide or desktop.
  static bool isWide(double width) => width > standardMobile;
}
