/// Types of special tiles created from 4-matches, T/L-matches, and 5-matches.
enum SpecialTileType {
  none,
  lineHorizontal,
  lineVertical,
  bomb,
  powerGem;

  /// Whether this is a special tile.
  bool get isSpecial => this != SpecialTileType.none;
}
