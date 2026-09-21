import 'package:ezwork/battle/domain/board/board.dart';
import 'package:ezwork/battle/domain/board/board_position.dart';
import 'package:ezwork/battle/domain/board/legal_move_finder.dart';
import 'package:ezwork/battle/domain/board/special_tile_type.dart';
import 'package:ezwork/battle/domain/board/swap.dart';
import 'package:ezwork/battle/domain/board/tile.dart';
import 'package:ezwork/battle/domain/board/tile_type.dart';
import 'package:flutter_test/flutter_test.dart' hide MatchFinder;

Board _createDeadBoard() {
  // Cyclic pattern with step 2 row, step 1 col has 0 prematches and 0 legal moves
  final grid = List.generate(
    Board.rowCount,
    (r) => List.generate(
      Board.columnCount,
      (c) => Tile(
        id: r * Board.columnCount + c + 1,
        type: TileType.values[(r * 2 + c) % 5],
      ),
    ),
  );
  return Board.fromGrid(grid);
}

void main() {
  group('LegalMoveFinder', () {
    test('pure dead board has zero legal moves', () {
      final board = _createDeadBoard();
      expect(LegalMoveFinder.hasLegalMove(board), isFalse);
      expect(LegalMoveFinder.findLegalMoves(board), isEmpty);
    });

    test('detects horizontal swap creating a 3-match', () {
      var board = _createDeadBoard();
      // Setup row 0: sword, sword, heart, sword
      // Swapping (0, 2) [heart] and (0, 3) [sword] will make (0, 0), (0, 1), (0, 2) all swords!
      board = board
          .copyWithUpdatedTile(const BoardPosition(0, 0),
              const Tile(id: 1, type: TileType.sword))
          .copyWithUpdatedTile(const BoardPosition(0, 1),
              const Tile(id: 2, type: TileType.sword))
          .copyWithUpdatedTile(const BoardPosition(0, 2),
              const Tile(id: 3, type: TileType.heart))
          .copyWithUpdatedTile(const BoardPosition(0, 3),
              const Tile(id: 4, type: TileType.sword));

      expect(LegalMoveFinder.hasLegalMove(board), isTrue);

      final moves = LegalMoveFinder.findLegalMoves(board);
      expect(
        moves,
        contains(
            const Swap(from: BoardPosition(0, 2), to: BoardPosition(0, 3))),
      );
    });

    test('detects vertical swap creating a 3-match', () {
      var board = _createDeadBoard();
      // Setup col 0: fire, fire, water, fire
      // Swapping (2, 0) and (3, 0) will align 3 fires vertically
      board = board
          .copyWithUpdatedTile(
              const BoardPosition(0, 0), const Tile(id: 1, type: TileType.fire))
          .copyWithUpdatedTile(
              const BoardPosition(1, 0), const Tile(id: 2, type: TileType.fire))
          .copyWithUpdatedTile(const BoardPosition(2, 0),
              const Tile(id: 3, type: TileType.water))
          .copyWithUpdatedTile(const BoardPosition(3, 0),
              const Tile(id: 4, type: TileType.fire));

      expect(LegalMoveFinder.hasLegalMove(board), isTrue);

      final moves = LegalMoveFinder.findLegalMoves(board);
      expect(
        moves,
        contains(
            const Swap(from: BoardPosition(2, 0), to: BoardPosition(3, 0))),
      );
    });

    test('power gem tile always provides legal moves with adjacent tiles', () {
      var board = _createDeadBoard();
      board = board.copyWithUpdatedTile(
        const BoardPosition(3, 3),
        const Tile(
            id: 50, type: TileType.fire, specialType: SpecialTileType.powerGem),
      );

      expect(LegalMoveFinder.hasLegalMove(board), isTrue);
      final moves = LegalMoveFinder.findLegalMoves(board);
      expect(moves.isNotEmpty, isTrue);
    });

    test('does not accept a swap because of an unrelated existing match', () {
      var board = _createDeadBoard();
      board = board
          .copyWithUpdatedTile(
            const BoardPosition(6, 0),
            board
                .getTile(const BoardPosition(6, 0))!
                .copyWith(type: TileType.fire),
          )
          .copyWithUpdatedTile(
            const BoardPosition(6, 1),
            board
                .getTile(const BoardPosition(6, 1))!
                .copyWith(type: TileType.fire),
          )
          .copyWithUpdatedTile(
            const BoardPosition(6, 2),
            board
                .getTile(const BoardPosition(6, 2))!
                .copyWith(type: TileType.fire),
          );

      const unrelatedSwap = Swap(
        from: BoardPosition(0, 0),
        to: BoardPosition(0, 1),
      );

      expect(
        LegalMoveFinder.findLegalMoves(board),
        isNot(contains(unrelatedSwap)),
      );
    });

    test('does not invent a special-pair swap rule absent from the GDD', () {
      var board = _createDeadBoard();
      board = board
          .copyWithUpdatedTile(
            const BoardPosition(3, 3),
            board.getTile(const BoardPosition(3, 3))!.copyWith(
                  specialType: SpecialTileType.lineHorizontal,
                ),
          )
          .copyWithUpdatedTile(
            const BoardPosition(3, 4),
            board.getTile(const BoardPosition(3, 4))!.copyWith(
                  specialType: SpecialTileType.bomb,
                ),
          );

      const specialPairSwap = Swap(
        from: BoardPosition(3, 3),
        to: BoardPosition(3, 4),
      );

      expect(
        LegalMoveFinder.findLegalMoves(board),
        isNot(contains(specialPairSwap)),
      );
    });
  });
}
