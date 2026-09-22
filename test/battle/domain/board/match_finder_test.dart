import 'package:dai_viet_ki_tran_game/battle/domain/board/board.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/board_position.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/match_finder.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/match_group.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/special_tile_type.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/tile.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/tile_type.dart';
import 'package:flutter_test/flutter_test.dart' hide MatchFinder;

Board _createEmptyGrid({Set<TileType>? excluded}) {
  final excludedTypes = excluded ?? {TileType.fire};
  final availableTypes = TileType.values
      .where((t) => !excludedTypes.contains(t))
      .toList();

  final grid = List.generate(
    Board.rowCount,
    (r) => List.generate(
      Board.columnCount,
      (c) => Tile(
        id: r * Board.columnCount + c + 1,
        type: availableTypes[(r * 2 + c) % availableTypes.length],
      ),
    ),
  );
  return Board.fromGrid(grid);
}

void main() {
  group('MatchFinder', () {
    test('finds single horizontal 3-match with no special created', () {
      var board = _createEmptyGrid(excluded: {TileType.fire});
      board = board
          .copyWithUpdatedTile(
            const BoardPosition(3, 2),
            const Tile(id: 100, type: TileType.fire),
          )
          .copyWithUpdatedTile(
            const BoardPosition(3, 3),
            const Tile(id: 101, type: TileType.fire),
          )
          .copyWithUpdatedTile(
            const BoardPosition(3, 4),
            const Tile(id: 102, type: TileType.fire),
          );

      final matches = MatchFinder.find(board);

      expect(matches.length, equals(1));
      expect(matches.first.tileType, equals(TileType.fire));
      expect(matches.first.positions.length, equals(3));
      expect(matches.first.specialCreated, equals(SpecialTileType.none));
      expect(
        matches.first.positions,
        containsAll([
          const BoardPosition(3, 2),
          const BoardPosition(3, 3),
          const BoardPosition(3, 4),
        ]),
      );
    });

    test('finds vertical 3-match with no special created', () {
      var board = _createEmptyGrid(excluded: {TileType.fire});
      board = board
          .copyWithUpdatedTile(
            const BoardPosition(1, 5),
            const Tile(id: 100, type: TileType.fire),
          )
          .copyWithUpdatedTile(
            const BoardPosition(2, 5),
            const Tile(id: 101, type: TileType.fire),
          )
          .copyWithUpdatedTile(
            const BoardPosition(3, 5),
            const Tile(id: 102, type: TileType.fire),
          );

      final matches = MatchFinder.find(board);

      expect(matches.length, equals(1));
      expect(matches.first.tileType, equals(TileType.fire));
      expect(matches.first.positions.length, equals(3));
      expect(matches.first.specialCreated, equals(SpecialTileType.none));
    });

    test('finds horizontal 4-match and creates lineHorizontal special', () {
      var board = _createEmptyGrid(excluded: {TileType.water});
      for (var c = 1; c <= 4; c++) {
        board = board.copyWithUpdatedTile(
          BoardPosition(2, c),
          Tile(id: 100 + c, type: TileType.water),
        );
      }

      final matches = MatchFinder.find(board);

      expect(matches.length, equals(1));
      expect(matches.first.tileType, equals(TileType.water));
      expect(matches.first.positions.length, equals(4));
      expect(
        matches.first.specialCreated,
        equals(SpecialTileType.lineHorizontal),
      );
      expect(matches.first.specialSpawnPosition, isNotNull);
    });

    test('finds vertical 4-match and creates lineVertical special', () {
      var board = _createEmptyGrid(excluded: {TileType.lightning});
      for (var r = 2; r <= 5; r++) {
        board = board.copyWithUpdatedTile(
          BoardPosition(r, 4),
          Tile(id: 100 + r, type: TileType.lightning),
        );
      }

      final matches = MatchFinder.find(board);

      expect(matches.length, equals(1));
      expect(matches.first.tileType, equals(TileType.lightning));
      expect(matches.first.positions.length, equals(4));
      expect(
        matches.first.specialCreated,
        equals(SpecialTileType.lineVertical),
      );
    });

    test('finds 5-in-a-line and creates powerGem special', () {
      var board = _createEmptyGrid(excluded: {TileType.heart});
      for (var c = 1; c <= 5; c++) {
        board = board.copyWithUpdatedTile(
          BoardPosition(0, c),
          Tile(id: 100 + c, type: TileType.heart),
        );
      }

      final matches = MatchFinder.find(board);

      expect(matches.length, equals(1));
      expect(matches.first.tileType, equals(TileType.heart));
      expect(matches.first.positions.length, equals(5));
      expect(matches.first.specialCreated, equals(SpecialTileType.powerGem));
      expect(
        matches.first.specialSpawnPosition,
        equals(const BoardPosition(0, 3)),
      );
    });

    test('finds T-shape match and creates bomb special', () {
      var board = _createEmptyGrid(excluded: {TileType.fire});
      // Horizontal row 3, cols 1, 2, 3
      // Vertical col 2, rows 1, 2, 3
      final positions = [
        const BoardPosition(3, 1),
        const BoardPosition(3, 2),
        const BoardPosition(3, 3),
        const BoardPosition(1, 2),
        const BoardPosition(2, 2),
      ];
      for (final p in positions) {
        board = board.copyWithUpdatedTile(
          p,
          Tile(id: p.row * 10 + p.column, type: TileType.fire),
        );
      }

      final matches = MatchFinder.find(board);

      expect(matches.length, equals(1));
      expect(matches.first.tileType, equals(TileType.fire));
      expect(matches.first.positions.length, equals(5));
      expect(matches.first.specialCreated, equals(SpecialTileType.bomb));
      expect(
        matches.first.specialSpawnPosition,
        equals(const BoardPosition(3, 2)),
      );
    });

    test('finds L-shape match and creates bomb special', () {
      var board = _createEmptyGrid(excluded: {TileType.sword});
      // Horizontal: (2, 2), (2, 3), (2, 4)
      // Vertical: (2, 2), (3, 2), (4, 2)
      final positions = [
        const BoardPosition(2, 2),
        const BoardPosition(2, 3),
        const BoardPosition(2, 4),
        const BoardPosition(3, 2),
        const BoardPosition(4, 2),
      ];
      for (final p in positions) {
        board = board.copyWithUpdatedTile(
          p,
          Tile(id: p.row * 10 + p.column, type: TileType.sword),
        );
      }

      final matches = MatchFinder.find(board);

      expect(matches.length, equals(1));
      expect(matches.first.tileType, equals(TileType.sword));
      expect(matches.first.positions.length, equals(5));
      expect(matches.first.specialCreated, equals(SpecialTileType.bomb));
      expect(
        matches.first.specialSpawnPosition,
        equals(const BoardPosition(2, 2)),
      );
    });

    test('prioritizes swap target as special spawn position when provided', () {
      var board = _createEmptyGrid(excluded: {TileType.water});
      for (var c = 0; c < 4; c++) {
        board = board.copyWithUpdatedTile(
          BoardPosition(0, c),
          Tile(id: 100 + c, type: TileType.water),
        );
      }

      const swapTarget = BoardPosition(0, 3);
      final matches = MatchFinder.find(
        board,
        preferredSpawnPosition: swapTarget,
      );

      expect(
        matches.first.specialCreated,
        equals(SpecialTileType.lineHorizontal),
      );
      expect(matches.first.specialSpawnPosition, equals(swapTarget));
    });

    test('finds multiple distinct match groups independently', () {
      var board = _createEmptyGrid(excluded: {TileType.sword, TileType.fire});
      // Match group 1: sword at row 0, cols 0, 1, 2
      for (var c = 0; c < 3; c++) {
        board = board.copyWithUpdatedTile(
          BoardPosition(0, c),
          Tile(id: 10 + c, type: TileType.sword),
        );
      }
      // Match group 2: fire at row 6, cols 4, 5, 6
      for (var c = 4; c < 7; c++) {
        board = board.copyWithUpdatedTile(
          BoardPosition(6, c),
          Tile(id: 60 + c, type: TileType.fire),
        );
      }

      final matches = MatchFinder.find(board);

      expect(matches.length, equals(2));
      final types = matches.map((m) => m.tileType).toSet();
      expect(types, containsAll([TileType.sword, TileType.fire]));
    });

    test('equal groups keep the hash contract regardless of set order', () {
      const first = BoardPosition(1, 1);
      const second = BoardPosition(1, 2);
      const third = BoardPosition(1, 3);
      final a = MatchGroup(
        tileType: TileType.fire,
        positions: {first, second, third},
      );
      final b = MatchGroup(
        tileType: TileType.fire,
        positions: {third, first, second},
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect({a, b}, hasLength(1));
    });
  });
}
