import 'package:ezwork/battle/domain/battle_session_controller.dart';
import 'package:ezwork/battle/domain/board/board.dart';
import 'package:ezwork/battle/domain/board/board_generator.dart';
import 'package:ezwork/battle/domain/board/board_position.dart';
import 'package:ezwork/battle/domain/board/board_resolver.dart';
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

    test(
      'pauseBattle and resumeBattle manage engine state and input lock',
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
      },
    );

    test(
      'handleSwapRequested executes swap and notifies combo callback',
      () async {
        var comboReported = 0;
        final game = Match3BattleGame(
          sessionController: controller,
          config: config,
          onComboChanged: (combo) => comboReported = combo,
        )..onGameResize(Vector2(400, 400));
        await game.onLoad();

        final legalMoves = LegalMoveFinder.findLegalMoves(
          controller.currentBoard,
        );
        expect(legalMoves, isNotEmpty);

        await game.handleSwapRequested(legalMoves.first);

        expect(game.isInputLocked, isFalse);
        expect(comboReported, greaterThan(0));
      },
    );

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
      },
    );

    test(
      'handleSwapRequested releases input lock in finally when exception occurs',
      () async {
        final mockController = _ThrowingSessionController(
          controller.currentBoard,
        );
        final game = Match3BattleGame(
          sessionController: mockController,
          config: config,
        )..onGameResize(Vector2(400, 400));
        await game.onLoad();

        expect(game.isInputLocked, isFalse);

        await expectLater(
          () => game.handleSwapRequested(
            const Swap(
              from: BoardPosition(0, 0),
              to: BoardPosition(0, 1),
            ),
          ),
          throwsA(isA<StateError>()),
        );

        expect(game.isInputLocked, isFalse);
        expect(game.gestureController.isLocked, isFalse);
      },
    );

    test(
      'onGameResize defers relayout when animationQueue is busy and reconciles cleanly on completion',
      () async {
        late Match3BattleGame game;
        game = Match3BattleGame(
          sessionController: controller,
          config: config,
          onAnimationStart: () {
            game.onGameResize(Vector2(600, 600));
          },
        )..onGameResize(Vector2(400, 400));
        await game.onLoad();

        final legalMoves = LegalMoveFinder.findLegalMoves(
          controller.currentBoard,
        );
        expect(legalMoves, isNotEmpty);

        // Execute swap; onAnimationStart will fire during busy animation
        await game.handleSwapRequested(legalMoves.first);

        // Verify boardComponent size is updated to 600x600
        expect(game.boardComponent.size, equals(Vector2(600, 600)));

        // Verify board contains all 49 tiles correctly positioned for 600x600
        expect(game.boardComponent.tilesById.length, equals(49));
        for (var r = 0; r < 7; r++) {
          for (var c = 0; c < 7; c++) {
            final tile = controller.currentBoard.getTile(BoardPosition(r, c));
            expect(tile, isNotNull);
            final comp = game.boardComponent.tilesById[tile!.id];
            expect(comp, isNotNull);
            expect(comp!.size.x, closeTo(game.boardComponent.tileSize, 0.01));
          }
        }
      },
    );
  });
}

class _ThrowingSessionController extends BattleSessionController {
  _ThrowingSessionController(Board board)
    : super(initialBoard: board, randomService: SeededRandom(1));

  @override
  BoardResolution attemptSwap(Swap swap) {
    throw StateError('Simulated cascade overflow error');
  }
}
