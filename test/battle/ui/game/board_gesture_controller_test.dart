import 'package:dai_viet_ki_tran_game/battle/domain/battle_session_controller.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/board_generator.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/board_position.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/swap.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/random/seeded_random.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/game/battle_game_config.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/game/components/board_component.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/game/input/board_gesture_controller.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/game/match3_battle_game.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' hide MatchFinder;

void main() {
  group('BoardGestureController', () {
    test(
      'targetPositionForDelta returns null when delta length is below threshold',
      () {
        const from = BoardPosition(2, 2);
        final target = BoardGestureController.targetPositionForDelta(
          from,
          Vector2(5, 5),
          threshold: 20,
        );
        expect(target, isNull);
      },
    );

    test('targetPositionForDelta detects right swipe when +X is dominant', () {
      const from = BoardPosition(2, 2);
      final target = BoardGestureController.targetPositionForDelta(
        from,
        Vector2(25, 5),
        threshold: 20,
      );
      expect(target, equals(const BoardPosition(2, 3)));
    });

    test('targetPositionForDelta detects left swipe when -X is dominant', () {
      const from = BoardPosition(2, 2);
      final target = BoardGestureController.targetPositionForDelta(
        from,
        Vector2(-25, 5),
        threshold: 20,
      );
      expect(target, equals(const BoardPosition(2, 1)));
    });

    test('targetPositionForDelta detects down swipe when +Y is dominant', () {
      const from = BoardPosition(2, 2);
      final target = BoardGestureController.targetPositionForDelta(
        from,
        Vector2(5, 25),
        threshold: 20,
      );
      expect(target, equals(const BoardPosition(3, 2)));
    });

    test('targetPositionForDelta detects up swipe when -Y is dominant', () {
      const from = BoardPosition(2, 2);
      final target = BoardGestureController.targetPositionForDelta(
        from,
        Vector2(5, -25),
        threshold: 20,
      );
      expect(target, equals(const BoardPosition(1, 2)));
    });

    test(
      'targetPositionForDelta returns null when target is outside board bounds',
      () {
        const topEdge = BoardPosition(0, 2);
        final targetUp = BoardGestureController.targetPositionForDelta(
          topEdge,
          Vector2(0, -30),
          threshold: 20,
        );
        expect(targetUp, isNull);

        const leftEdge = BoardPosition(2, 0);
        final targetLeft = BoardGestureController.targetPositionForDelta(
          leftEdge,
          Vector2(-30, 0),
          threshold: 20,
        );
        expect(targetLeft, isNull);
      },
    );

    test('isLocked resets drag state and locks input', () {
      final board = BoardComponent(
        config: const BattleGameConfig(),
        size: Vector2(350, 350),
      )..onGameResize(Vector2(350, 350));

      final controller = BoardGestureController(
        boardComponent: board,
        onSwapRequested: (_) {},
        swipeThreshold: 10,
      );

      expect(controller.isLocked, isFalse);
      controller.isLocked = true;
      expect(controller.isLocked, isTrue);

      controller.isLocked = false;
      expect(controller.isLocked, isFalse);
    });

    test('containsLocalPoint returns true only inside board slots', () {
      final board = BoardComponent(
        config: const BattleGameConfig(),
        size: Vector2(350, 350),
      )..onGameResize(Vector2(350, 350));

      final controller = BoardGestureController(
        boardComponent: board,
        onSwapRequested: (_) {},
        size: board.size,
      );

      final validTilePos = board.positionFor(const BoardPosition(0, 0));
      expect(controller.containsLocalPoint(validTilePos), isTrue);

      expect(controller.containsLocalPoint(Vector2(-10, -10)), isFalse);
      expect(controller.containsLocalPoint(Vector2(999, 999)), isFalse);
    });

    testWidgets('real pointer drag on GameWidget dispatches onSwapRequested', (
      tester,
    ) async {
      final rng = SeededRandom(42);
      final board = BoardGenerator.generate(rng);
      final sessionController = BattleSessionController(
        initialBoard: board,
        randomService: rng,
      );

      Swap? dispatchedSwap;
      final game = Match3BattleGame(
        sessionController: sessionController,
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 400,
                  height: 400,
                  child: GameWidget(game: game),
                ),
              ),
            ),
          ),
        );

        for (var i = 0; i < 40; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          await tester.pump();
          if (game.isLoaded) break;
        }
      });
      expect(game.isLoaded, isTrue);

      game.gestureController.onSwapRequested = (swap) {
        dispatchedSwap = swap;
      };

      final tilePos = game.boardComponent.positionFor(
        const BoardPosition(2, 2),
      );
      final screenCenter = tester.getCenter(
        find.byType(GameWidget<Match3BattleGame>),
      );
      final gameTopLeft = screenCenter - const Offset(200, 200);
      final startOffset = gameTopLeft + Offset(tilePos.x, tilePos.y);

      await tester.timedDragFrom(
        startOffset,
        const Offset(40, 0),
        const Duration(milliseconds: 150),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(dispatchedSwap, isNotNull);
      expect(dispatchedSwap!.from, equals(const BoardPosition(2, 2)));
      expect(dispatchedSwap!.to, equals(const BoardPosition(2, 3)));
    });
  });
}
