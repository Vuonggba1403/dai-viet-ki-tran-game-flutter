import 'package:ezwork/battle/domain/board/board_event.dart';
import 'package:ezwork/battle/domain/board/board_generator.dart';
import 'package:ezwork/battle/domain/board/board_position.dart';
import 'package:ezwork/battle/domain/board/swap.dart';
import 'package:ezwork/battle/domain/board/tile.dart';
import 'package:ezwork/battle/domain/board/tile_type.dart';
import 'package:ezwork/battle/domain/random/seeded_random.dart';
import 'package:ezwork/battle/ui/game/animation/battle_animation_queue.dart';
import 'package:ezwork/battle/ui/game/battle_game_config.dart';
import 'package:ezwork/battle/ui/game/components/board_component.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart' hide MatchFinder;

void main() {
  group('BattleAnimationQueue', () {
    late BoardComponent board;
    const config = BattleGameConfig(
      swapDuration: 0,
      rollbackDuration: 0,
      clearDuration: 0,
      dropDuration: 0,
      spawnDuration: 0,
      shuffleDuration: 0,
    );

    setUp(() {
      board = BoardComponent(
        config: config,
        size: Vector2(350, 350),
      )..onGameResize(Vector2(350, 350));
      final domainBoard = BoardGenerator.generate(SeededRandom(42));
      board.initTiles(domainBoard);
    });

    test('SwapRejected executes rollback and releases isBusy lock', () async {
      var started = false;
      var completed = false;

      final queue = BattleAnimationQueue(
        onAnimationStart: () => started = true,
        onAnimationComplete: () => completed = true,
      );

      const swap = Swap(from: BoardPosition(0, 0), to: BoardPosition(0, 1));
      final events = [
        const SwapStarted(swap),
        const SwapRejected(swap),
      ];

      expect(queue.isBusy, isFalse);
      await queue.run(
        events: events,
        boardComponent: board,
        config: config,
      );

      expect(started, isTrue);
      expect(completed, isTrue);
      expect(queue.isBusy, isFalse);
    });

    test('TilesCleared removes tile components from board', () async {
      final queue = BattleAnimationQueue();

      final tileAt00 =
          board.boardPositionFor(board.positionFor(const BoardPosition(0, 0)));
      expect(tileAt00, equals(const BoardPosition(0, 0)));

      final initialTile = board.tilesById.values.first;

      final events = [
        TilesCleared(
          cycle: 1,
          positions: const [BoardPosition(0, 0)],
        ),
      ];

      await queue.run(
        events: events,
        boardComponent: board,
        config: config,
      );

      expect(board.getTile(initialTile.tileId), isNull);
    });

    test('TilesSpawned adds new tile component to board', () async {
      final queue = BattleAnimationQueue();

      const newTile = Tile(id: 9999, type: TileType.lightning);
      final events = [
        TilesSpawned(
          cycle: 1,
          spawns: const [
            TileSpawn(tile: newTile, position: BoardPosition(0, 0)),
          ],
        ),
      ];

      await queue.run(
        events: events,
        boardComponent: board,
        config: config,
      );

      expect(board.getTile(9999), isNotNull);
      expect(board.getTile(9999)!.tile.type, equals(TileType.lightning));
    });

    test('CascadeCompleted notifies combo callback', () async {
      var reportedCombo = 0;
      final queue = BattleAnimationQueue(
        onComboStep: (combo) => reportedCombo = combo,
      );

      final events = [
        const CascadeCompleted(3),
      ];

      await queue.run(
        events: events,
        boardComponent: board,
        config: config,
      );

      expect(reportedCombo, equals(3));
    });
  });
}
