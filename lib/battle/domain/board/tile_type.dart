/// 5 standard tile types in Loan 12 Su Quan prototype.
enum TileType {
  sword,
  fire,
  water,
  lightning,
  heart;

  /// Returns true if this tile type is one of the three elemental types.
  bool get isElemental => this == fire || this == water || this == lightning;

  /// Determines element multiplier against target element:
  /// Advantage (1.5): Fire > Lightning > Water > Fire.
  /// Disadvantage (0.75): Lightning < Fire < Water < Lightning.
  /// Neutral (1.0): same element, or if either side is sword or heart.
  double getElementMultiplier(TileType target) {
    if (!isElemental || !target.isElemental) {
      return 1;
    }
    if ((this == fire && target == lightning) ||
        (this == lightning && target == water) ||
        (this == water && target == fire)) {
      return 1.5;
    }
    if ((this == lightning && target == fire) ||
        (this == water && target == lightning) ||
        (this == fire && target == water)) {
      return 0.75;
    }
    return 1;
  }
}
