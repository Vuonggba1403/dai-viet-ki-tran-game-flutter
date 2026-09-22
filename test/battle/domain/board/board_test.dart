import 'package:ezwork/battle/domain/board/board.dart';
import 'package:ezwork/battle/domain/board/board_position.dart';
import 'package:ezwork/battle/domain/board/tile.dart';
import 'package:ezwork/battle/domain/board/tile_type.dart';
import 'package:flutter_test/flutter_test.dart';

Board _createSampleBoard() {
  final grid = List.generate(
    Board.rowCount,
    (r) => List.generate(
      Board.columnCount,
      (c) => Tile(
        id: r * Board.columnCount + c + 1,
        type: TileType.values[(r + c) % TileType.values.length],
      ),
    ),
  );
  return Board.fromGrid(grid);
}

void main() {
  group('Board', () {
    test('dimensions are exactly 7x7 (49 tiles)', () {
      expect(Board.rowCount, equals(7));
      expect(Board.columnCount, equals(7));
      expect(Board.totalTiles, equals(49));

      final board = _createSampleBoard();
      expect(board.toMap().length, equals(49));
    });

    test('getTile and getTileAt return correct tile or null on bounds', () {
      final board = _createSampleBoard();

      final tile00 = board.getTile(const BoardPosition(0, 0));
      expect(tile00, isNotNull);
      expect(tile00!.id, equals(1));

      final tileAt = board.getTileAt(6, 6);
      expect(tileAt, isNotNull);
      expect(tileAt!.id, equals(49));

      // Out of bounds
      expect(board.getTile(const BoardPosition(-1, 0)), isNull);
      expect(board.getTile(const BoardPosition(7, 7)), isNull);
      expect(board.getTileAt(10, 2), isNull);
    });

    test(
      'copyWithUpdatedTile returns a new immutable board without mutating original',
      () {
        final board = _createSampleBoard();
        const pos = BoardPosition(2, 3);
        const newTile = Tile(id: 999, type: TileType.heart);

        final updatedBoard = board.copyWithUpdatedTile(pos, newTile);

        expect(board.getTile(pos)?.id, isNot(equals(999)));
        expect(updatedBoard.getTile(pos)?.id, equals(999));
        expect(updatedBoard.getTile(pos)?.type, equals(TileType.heart));
      },
    );

    test('swapTiles swaps positions correctly and immutably', () {
      final board = _createSampleBoard();
      const posA = BoardPosition(1, 1);
      const posB = BoardPosition(1, 2);

      final tileA = board.getTile(posA);
      final tileB = board.getTile(posB);

      final swappedBoard = board.swapTiles(posA, posB);

      expect(swappedBoard.getTile(posA), equals(tileB));
      expect(swappedBoard.getTile(posB), equals(tileA));
      // Original remains unchanged
      expect(board.getTile(posA), equals(tileA));
      expect(board.getTile(posB), equals(tileB));
    });

    test('toMap and toGrid export correct unmodifiable views', () {
      final board = _createSampleBoard();
      final map = board.toMap();
      final grid = board.toGrid();

      expect(map.length, equals(49));
      expect(grid.length, equals(7));
      expect(grid[0].length, equals(7));

      expect(
        () => (map as dynamic)[const BoardPosition(0, 0)] = const Tile(
          id: 99,
          type: TileType.sword,
        ),
        throwsUnsupportedError,
      );
    });

    test('checksum is consistent for equal boards', () {
      final b1 = _createSampleBoard();
      final b2 = _createSampleBoard();

      expect(b1.checksum, equals(b2.checksum));
      expect(b1, equals(b2));

      final b3 = b1.copyWithUpdatedTile(
        const BoardPosition(0, 0),
        const Tile(id: 888, type: TileType.fire),
      );
      expect(b1.checksum, isNot(equals(b3.checksum)));
      expect(b1, isNot(equals(b3)));
    });
  });
}
