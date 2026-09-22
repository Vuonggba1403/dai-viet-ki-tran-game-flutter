import 'package:meta/meta.dart';

/// Configuration for Match-3 board layout and animations.
@immutable
class BattleGameConfig {
  const BattleGameConfig({
    this.rowCount = 7,
    this.columnCount = 7,
    this.boardPadding = 12.0,
    this.tileSpacing = 4.0,
    this.swapDuration = 0.18,
    this.rollbackDuration = 0.18,
    this.clearDuration = 0.20,
    this.dropDuration = 0.22,
    this.spawnDuration = 0.22,
    this.shuffleDuration = 0.35,
  });

  final int rowCount;
  final int columnCount;
  final double boardPadding;
  final double tileSpacing;

  /// Duration in seconds for swap animation.
  final double swapDuration;

  /// Duration in seconds for rollback animation on rejected swap.
  final double rollbackDuration;

  /// Duration in seconds for tile clear animation (scale/fade out).
  final double clearDuration;

  /// Duration in seconds for falling tiles.
  final double dropDuration;

  /// Duration in seconds for newly spawned tiles dropping in.
  final double spawnDuration;

  /// Duration in seconds for board shuffle animation.
  final double shuffleDuration;
}
