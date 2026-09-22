import 'package:dai_viet_ki_tran_game/battle/domain/battle_session_controller.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/board.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/board_generator.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/board_position.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/legal_move_finder.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/swap.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/tile.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/tile_type.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/random/seeded_random.dart';
import 'package:flutter_test/flutter_test.dart' hide MatchFinder;

void main() {
  group('BattleSessionController', () {
    late SeededRandom rng;
    late Board initialBoard;

    setUp(() {
      rng = SeededRandom(42);
      initialBoard = BoardGenerator.generate(rng);
    });

    test(
      'initializes with given board and advances nextTileId beyond board max id',
      () {
        final controller = BattleSessionController(
          initialBoard: initialBoard,
          randomService: rng,
          initialTileId: 10,
        );

        expect(controller.currentBoard, equals(initialBoard));
        expect(controller.comboCount, equals(0));
        // Board generator creates 49 tiles with IDs 1..49, so nextTileId should be at least 50
        expect(controller.nextTileId, greaterThan(49));
      },
    );

    test('attemptSwap preserves board state when swap is rejected', () {
      // Create a board with known tiles where swap (0,0) and (0,1) produces no match
      final grid = List.generate(
        7,
        (r) => List.generate(
          7,
          (c) => Tile(
            id: r * 7 + c + 1,
            type: TileType.values[(r * 2 + c) % 5],
          ),
        ),
      );
      final board = Board.fromGrid(grid);
      final controller = BattleSessionController(
        initialBoard: board,
        randomService: rng,
      );

      final initialChecksum = controller.currentBoard.checksum;
      final resolution = controller.attemptSwap(
        const Swap(from: BoardPosition(0, 0), to: BoardPosition(0, 1)),
      );

      expect(resolution.isSuccess, isFalse);
      expect(controller.currentBoard.checksum, equals(initialChecksum));
      expect(controller.comboCount, equals(0));
    });

    test('attemptSwap updates board and comboCount when swap is accepted', () {
      // Find a guaranteed legal move on the initialBoard
      final moves = LegalMoveFinder.findLegalMoves(initialBoard);
      expect(moves, isNotEmpty);
      final validMove = moves.first;

      final controller = BattleSessionController(
        initialBoard: initialBoard,
        randomService: rng,
      );

      final prevNextTileId = controller.nextTileId;
      final resolution = controller.attemptSwap(validMove);

      expect(resolution.isSuccess, isTrue);
      expect(controller.currentBoard, equals(resolution.finalBoard));
      expect(controller.comboCount, equals(resolution.comboCount));
      expect(controller.nextTileId, greaterThanOrEqualTo(prevNextTileId));
    });

    test('resetBoard updates board and resets comboCount', () {
      final controller = BattleSessionController(
        initialBoard: initialBoard,
        randomService: rng,
      );

      final moves = LegalMoveFinder.findLegalMoves(initialBoard);
      controller.attemptSwap(moves.first);

      final newBoard = BoardGenerator.generate(SeededRandom(999));
      controller.resetBoard(newBoard);

      expect(controller.currentBoard, equals(newBoard));
      expect(controller.comboCount, equals(0));
    });
  });
}
