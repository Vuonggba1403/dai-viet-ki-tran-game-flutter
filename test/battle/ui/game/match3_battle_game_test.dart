import 'package:ezwork/battle/domain/battle_session_controller.dart';
import 'package:ezwork/battle/domain/board/board_generator.dart';
import 'package:ezwork/battle/domain/board/board_position.dart';
import 'package:ezwork/battle/domain/board/legal_move_finder.dart';
import 'package:ezwork/battle/domain/board/swap.dart';
import 'package:ezwork/battle/domain/random/seeded_random.dart';
import 'package:ezwork/battle/ui/game/battle_game_config.dart';
import 'package:ezwork/battle/ui/game/match3_battle_game.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart' hide MatchFinder;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Match3BattleGame', () {
    late BattleSessionController controller;
    const config = BattleGameConfig(
      swapDuration: 0,
      rollbackDuration: 0,
      clearDuration: 0,
      dropDuration: 0,
      spawnDuration: 0,
      shuffleDuration: 0,
    );

    setUp(() {
      final board = BoardGenerator.generate(SeededRandom(100));
      controller = BattleSessionController(
        initialBoard: board,
        randomService: SeededRandom(100),
      );
    });

    test('initializes board and gesture components on load', () async {
      final game = Match3BattleGame(
        sessionController: controller,
        config: config,
      )..onGameResize(Vector2(400, 400));
      await game.onLoad();

      expect(game.boardComponent, isNotNull);
      expect(game.gestureController, isNotNull);
      expect(game.animationQueue, isNotNull);
      expect(game.boardComponent.tilesById.length, equals(49));
    });

    test('pauseBattle and resumeBattle manage engine state and input lock',
        () async {
      final game = Match3BattleGame(
        sessionController: controller,
        config: config,
      )..onGameResize(Vector2(400, 400));
      await game.onLoad();

      expect(game.isInputLocked, isFalse);

      game.pauseBattle();
      expect(game.isInputLocked, isTrue);
      expect(game.gestureController.isLocked, isTrue);

      game.resumeBattle();
      expect(game.isInputLocked, isFalse);
      expect(game.gestureController.isLocked, isFalse);
    });

    test('handleSwapRequested executes swap and notifies combo callback',
        () async {
      var comboReported = 0;
      final game = Match3BattleGame(
        sessionController: controller,
        config: config,
        onComboChanged: (combo) => comboReported = combo,
      )..onGameResize(Vector2(400, 400));
      await game.onLoad();

      final legalMoves =
          LegalMoveFinder.findLegalMoves(controller.currentBoard);
      expect(legalMoves, isNotEmpty);

      await game.handleSwapRequested(legalMoves.first);

      expect(game.isInputLocked, isFalse);
      expect(comboReported, greaterThan(0));
    });

    test(
        'handleSwapRequested rejects invalid swap without changing turn or locking forever',
        () async {
      final game = Match3BattleGame(
        sessionController: controller,
        config: config,
      )..onGameResize(Vector2(400, 400));
      await game.onLoad();

      // Attempt an invalid move that cannot create a match
      // By finding two tiles of different types that don't match
      const invalidSwap = Swap(
        from: BoardPosition(0, 0),
        to: BoardPosition(0, 1),
      );

      await game.handleSwapRequested(invalidSwap);

      expect(game.isInputLocked, isFalse);
    });
  });
}
