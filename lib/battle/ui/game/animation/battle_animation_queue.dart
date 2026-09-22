import 'package:ezwork/battle/domain/board/board_event.dart';
import 'package:ezwork/battle/domain/board/tile_type.dart';
import 'package:ezwork/battle/ui/game/battle_game_config.dart';
import 'package:ezwork/battle/ui/game/components/board_component.dart';
import 'package:ezwork/battle/ui/game/components/tile_component.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

/// Sequentially executes visual animations corresponding to ordered [BoardEvent]s.
///
/// Flame rendering components consume events from pure Dart domain resolutions
/// without calculating any match, gravity, or cascade rules.
class BattleAnimationQueue {
  BattleAnimationQueue({
    this.onAnimationStart,
    this.onAnimationComplete,
    this.onComboStep,
  });

  final VoidCallback? onAnimationStart;
  final VoidCallback? onAnimationComplete;
  final ValueChanged<int>? onComboStep;

  bool _isBusy = false;

  /// Whether the queue is currently running an animation sequence.
  bool get isBusy => _isBusy;

  /// Executes all events in [events] sequentially on [boardComponent].
  Future<void> run({
    required List<BoardEvent> events,
    required BoardComponent boardComponent,
    required BattleGameConfig config,
    Map<TileType, Sprite>? sprites,
  }) async {
    if (events.isEmpty) return;

    _isBusy = true;
    onAnimationStart?.call();

    try {
      for (final event in events) {
        await _processEvent(
          event: event,
          board: boardComponent,
          config: config,
          sprites: sprites,
        );
      }
    } finally {
      _isBusy = false;
      onAnimationComplete?.call();
    }
  }

  Future<void> _processEvent({
    required BoardEvent event,
    required BoardComponent board,
    required BattleGameConfig config,
    Map<TileType, Sprite>? sprites,
  }) async {
    switch (event) {
      case SwapStarted():
        // Swap visual movement starts on Accepted or Rejected
        break;

      case SwapAccepted(swap: final swap):
        final fromPos = board.positionFor(swap.from);
        final toPos = board.positionFor(swap.to);

        // Find tiles currently at from and to
        final fromTileComp = _findTileAt(board, fromPos);
        final toTileComp = _findTileAt(board, toPos);

        fromTileComp?.moveTo(toPos, duration: config.swapDuration);
        toTileComp?.moveTo(fromPos, duration: config.swapDuration);

        await _wait(config.swapDuration);

      case SwapRejected(swap: final swap):
        final fromPos = board.positionFor(swap.from);
        final toPos = board.positionFor(swap.to);

        final fromTileComp = _findTileAt(board, fromPos);
        final toTileComp = _findTileAt(board, toPos);

        // Animate partially towards each other and then back (rollback)
        final midFrom = fromPos + (toPos - fromPos) * 0.4;
        final midTo = toPos + (fromPos - toPos) * 0.4;

        final halfDuration = config.rollbackDuration / 2;
        fromTileComp?.moveTo(midFrom, duration: halfDuration);
        toTileComp?.moveTo(midTo, duration: halfDuration);
        await _wait(halfDuration);

        fromTileComp?.moveTo(fromPos, duration: halfDuration);
        toTileComp?.moveTo(toPos, duration: halfDuration);
        await _wait(halfDuration);

      case CascadeStarted():
        // Cycle marker for cascade
        break;

      case TilesMatched():
        // Visual match highlight if desired
        break;

      case SpecialCreated(position: final pos, tile: final tile):
        final tilePos = board.positionFor(pos);
        final existing = _findTileAt(board, tilePos);
        existing?.tile = tile;

      case SpecialTriggered():
        // Visual trigger effect
        break;

      case TilesCleared(positions: final positions):
        for (final pos in positions) {
          final targetPos = board.positionFor(pos);
          final tileComp = _findTileAt(board, targetPos);
          if (tileComp != null) {
            tileComp.animateClear(duration: config.clearDuration);
          }
        }
        await _wait(config.clearDuration);

        for (final pos in positions) {
          final targetPos = board.positionFor(pos);
          final tileComp = _findTileAt(board, targetPos);
          if (tileComp != null) {
            board.removeTile(tileComp.tileId);
          }
        }

      case TilesDropped(drops: final drops):
        for (final drop in drops) {
          final comp = board.getTile(drop.tile.id);
          final targetPos = board.positionFor(drop.to);
          comp?.moveTo(targetPos, duration: config.dropDuration);
        }
        await _wait(config.dropDuration);

      case TilesSpawned(spawns: final spawns):
        for (final spawn in spawns) {
          final targetPos = board.positionFor(spawn.position);
          // Spawn starting slightly above the board
          final startPos = Vector2(
            targetPos.x,
            targetPos.y - (board.tileSize * 1.5),
          );

          final comp = TileComponent(
            tileId: spawn.tile.id,
            initialTile: spawn.tile,
            position: startPos,
            size: Vector2.all(board.tileSize),
            sprite: sprites?[spawn.tile.type],
          );
          board.addTile(comp);
          comp.moveTo(targetPos, duration: config.spawnDuration);
        }
        await _wait(config.spawnDuration);

      case BoardShuffled(newPositions: final newPositions):
        for (final entry in newPositions.entries) {
          final tileId = entry.key;
          final newPos = entry.value;
          final comp = board.getTile(tileId);
          final targetPos = board.positionFor(newPos);
          comp?.moveTo(targetPos, duration: config.shuffleDuration);
        }
        await _wait(config.shuffleDuration);

      case CascadeCompleted(cycle: final cycle):
        onComboStep?.call(cycle);
    }
  }

  TileComponent? _findTileAt(BoardComponent board, Vector2 position) {
    const tolerance = 4.0;
    for (final comp in board.tilesById.values) {
      if ((comp.position - position).length <= tolerance) {
        return comp;
      }
    }
    return null;
  }

  Future<void> _wait(double durationSeconds) async {
    if (durationSeconds <= 0) return;
    await Future<void>.delayed(
      Duration(milliseconds: (durationSeconds * 1000).round()),
    );
  }
}
