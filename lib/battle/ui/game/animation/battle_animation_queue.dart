import 'package:dai_viet_ki_tran_game/battle/domain/board/board_event.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/tile_type.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/game/battle_game_config.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/game/components/board_component.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/game/components/tile_component.dart';
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
    this.onBoardEvent,
  });

  final VoidCallback? onAnimationStart;
  final VoidCallback? onAnimationComplete;
  final ValueChanged<int>? onComboStep;
  final ValueChanged<BoardEvent>? onBoardEvent;

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
    onBoardEvent?.call(event);
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

        final futures = <Future<void>>[];
        if (fromTileComp != null) {
          futures.add(
            fromTileComp.moveTo(toPos, duration: config.swapDuration),
          );
        }
        if (toTileComp != null) {
          futures.add(
            toTileComp.moveTo(fromPos, duration: config.swapDuration),
          );
        }
        await Future.wait(futures);

      case SwapRejected(swap: final swap):
        final fromPos = board.positionFor(swap.from);
        final toPos = board.positionFor(swap.to);

        final fromTileComp = _findTileAt(board, fromPos);
        final toTileComp = _findTileAt(board, toPos);

        // Animate partially towards each other and then back (rollback)
        final midFrom = fromPos + (toPos - fromPos) * 0.4;
        final midTo = toPos + (fromPos - toPos) * 0.4;
        final halfDuration = config.rollbackDuration / 2;

        final step1 = <Future<void>>[];
        if (fromTileComp != null) {
          step1.add(fromTileComp.moveTo(midFrom, duration: halfDuration));
        }
        if (toTileComp != null) {
          step1.add(toTileComp.moveTo(midTo, duration: halfDuration));
        }
        await Future.wait(step1);

        final step2 = <Future<void>>[];
        if (fromTileComp != null) {
          step2.add(fromTileComp.moveTo(fromPos, duration: halfDuration));
        }
        if (toTileComp != null) {
          step2.add(toTileComp.moveTo(toPos, duration: halfDuration));
        }
        await Future.wait(step2);

      case CascadeStarted():
        // Cycle marker for cascade
        break;

      case TilesMatched():
        // Visual match highlight if desired
        break;

      case SpecialCreated(position: final pos, tile: final tile):
        final tilePos = board.positionFor(pos);
        final existing = _findTileAt(board, tilePos);
        if (existing != null) {
          board.remapTile(
            existing.tileId,
            tile,
            sprite: sprites?[tile.type],
          );
        }

      case SpecialTriggered():
        // Visual trigger effect
        break;

      case TilesCleared(positions: final positions):
        final compsToClear = <TileComponent>[];
        for (final pos in positions) {
          final targetPos = board.positionFor(pos);
          final tileComp = _findTileAt(board, targetPos);
          if (tileComp != null) {
            compsToClear.add(tileComp);
          }
        }

        final clearFutures = <Future<void>>[];
        for (final comp in compsToClear) {
          clearFutures.add(comp.animateClear(duration: config.clearDuration));
        }
        await Future.wait(clearFutures);

        for (final comp in compsToClear) {
          board.removeTile(comp.tileId);
        }

      case TilesDropped(drops: final drops):
        final dropFutures = <Future<void>>[];
        for (final drop in drops) {
          final comp = board.getTile(drop.tile.id);
          final targetPos = board.positionFor(drop.to);
          if (comp != null) {
            dropFutures.add(
              comp.moveTo(targetPos, duration: config.dropDuration),
            );
          }
        }
        await Future.wait(dropFutures);

      case TilesSpawned(spawns: final spawns):
        final spawnFutures = <Future<void>>[];
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
          spawnFutures.add(
            comp.moveTo(targetPos, duration: config.spawnDuration),
          );
        }
        await Future.wait(spawnFutures);

      case BoardShuffled(newPositions: final newPositions):
        final shuffleFutures = <Future<void>>[];
        for (final entry in newPositions.entries) {
          final tileId = entry.key;
          final newPos = entry.value;
          final comp = board.getTile(tileId);
          final targetPos = board.positionFor(newPos);
          if (comp != null) {
            shuffleFutures.add(
              comp.moveTo(targetPos, duration: config.shuffleDuration),
            );
          }
        }
        await Future.wait(shuffleFutures);

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
}
