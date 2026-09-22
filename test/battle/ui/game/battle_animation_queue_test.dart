import 'dart:async';

import 'package:ezwork/battle/domain/board/board_event.dart';
import 'package:ezwork/battle/domain/board/board_generator.dart';
import 'package:ezwork/battle/domain/board/board_position.dart';
import 'package:ezwork/battle/domain/board/special_tile_type.dart';
import 'package:ezwork/battle/domain/board/swap.dart';
import 'package:ezwork/battle/domain/board/tile.dart';
import 'package:ezwork/battle/domain/board/tile_type.dart';
import 'package:ezwork/battle/domain/random/seeded_random.dart';
import 'package:ezwork/battle/ui/game/animation/battle_animation_queue.dart';
import 'package:ezwork/battle/ui/game/battle_game_config.dart';
import 'package:ezwork/battle/ui/game/components/board_component.dart';
import 'package:ezwork/battle/ui/game/components/tile_component.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
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

      final tileAt00 = board.boardPositionFor(
        board.positionFor(const BoardPosition(0, 0)),
      );
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

    test(
      'SpecialCreated remaps component tileId and handles subsequent drops and clears',
      () async {
        final queue = BattleAnimationQueue();
        final oldTileComp = board.tilesById.values.first;
        final oldId = oldTileComp.tileId;
        final initialPos = board.boardPositionFor(oldTileComp.position)!;

        const specialTile = Tile(
          id: 77777,
          type: TileType.fire,
          specialType: SpecialTileType.bomb,
        );

        final events = [
          SpecialCreated(
            position: initialPos,
            specialType: SpecialTileType.bomb,
            tile: specialTile,
          ),
          // Next cascade: the special tile drops to another row
          TilesDropped(
            cycle: 2,
            drops: [
              TileDrop(
                tile: specialTile,
                from: initialPos,
                to: const BoardPosition(6, 6),
              ),
            ],
          ),
        ];

        await queue.run(
          events: events,
          boardComponent: board,
          config: config,
        );

        // Old ID must be removed, new ID must exist
        expect(board.getTile(oldId), isNull);
        final newComp = board.getTile(77777);
        expect(newComp, isNotNull);
        expect(newComp!.tileId, equals(77777));
        expect(newComp.tile.specialType, equals(SpecialTileType.bomb));

        // Its position must match drop destination (6, 6)
        final expectedPos = board.positionFor(const BoardPosition(6, 6));
        expect(newComp.position.x, closeTo(expectedPos.x, 0.01));
        expect(newComp.position.y, closeTo(expectedPos.y, 0.01));
      },
    );

    testWithFlameGame(
      'tile effects pause and resume in sync with Flame engine',
      (game) async {
        final comp = TileComponent(
          tileId: 101,
          initialTile: const Tile(id: 101, type: TileType.water),
          position: Vector2.zero(),
          size: Vector2.all(40),
        );
        await game.add(comp);
        await game.ready();

        var completed = false;
        unawaited(
          comp.moveTo(
            Vector2(100, 100),
            duration: 0.2,
            onComplete: () => completed = true,
          ),
        );
        await game.ready();

        // Advance 0.1s: effect is half-way, not completed
        game.update(0.1);
        expect(completed, isFalse);

        // Pause engine: even if time passes, effect does not advance
        game.pauseEngine();
        expect(completed, isFalse);

        // Resume engine and tick remaining 0.1s
        game
          ..resumeEngine()
          ..update(0.11);
        expect(completed, isTrue);
        expect(comp.position, equals(Vector2(100, 100)));
      },
    );
  });
}
