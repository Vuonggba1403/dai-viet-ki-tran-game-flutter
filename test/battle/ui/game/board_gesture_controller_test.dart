import 'package:ezwork/battle/domain/board/board_position.dart';
import 'package:ezwork/battle/ui/game/battle_game_config.dart';
import 'package:ezwork/battle/ui/game/components/board_component.dart';
import 'package:ezwork/battle/ui/game/input/board_gesture_controller.dart';
import 'package:flame/components.dart';
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
    });

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
    });

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
  });
}
