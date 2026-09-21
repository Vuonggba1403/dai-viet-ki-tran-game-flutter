import 'package:ezwork/battle/domain/board/board_position.dart';
import 'package:ezwork/battle/domain/board/tile.dart';
import 'package:meta/meta.dart';

/// Represents the immutable 7x7 Match-3 board state.
///
/// Internal tile storage is encapsulated and never directly exposed
/// as a mutable list.
@immutable
class Board {
  const Board._(this._tiles);

  /// Creates a board from a 2D row-major list of tiles (must be 7x7).
  factory Board.fromGrid(List<List<Tile>> grid) {
    if (grid.length != rowCount) {
      throw ArgumentError(
        'Grid must have $rowCount rows, got ${grid.length}',
      );
    }
    final flattened = <Tile>[];
    for (var r = 0; r < rowCount; r++) {
      if (grid[r].length != columnCount) {
        throw ArgumentError(
          'Row $r must have $columnCount columns, got ${grid[r].length}',
        );
      }
      flattened.addAll(grid[r]);
    }
    return Board._(List<Tile>.unmodifiable(flattened));
  }

  /// Creates a board from a map of [BoardPosition] to [Tile].
  factory Board.fromMap(Map<BoardPosition, Tile> tileMap) {
    final flattened = List<Tile?>.filled(totalTiles, null);
    for (final entry in tileMap.entries) {
      final pos = entry.key;
      if (!pos.isValid()) {
        throw ArgumentError('Position $pos is outside 7x7 bounds');
      }
      final index = pos.row * columnCount + pos.column;
      flattened[index] = entry.value;
    }
    for (var i = 0; i < totalTiles; i++) {
      if (flattened[i] == null) {
        final r = i ~/ columnCount;
        final c = i % columnCount;
        throw ArgumentError('Missing tile at ($r, $c)');
      }
    }
    return Board._(List<Tile>.unmodifiable(flattened.cast<Tile>()));
  }

  /// Creates a board from a flat list of 49 tiles.
  factory Board.fromList(List<Tile> tiles) {
    if (tiles.length != totalTiles) {
      throw ArgumentError(
        'Board requires exactly $totalTiles tiles, got ${tiles.length}',
      );
    }
    return Board._(List<Tile>.unmodifiable(tiles));
  }

  /// Standard board dimension: 7 rows.
  static const int rowCount = 7;

  /// Standard board dimension: 7 columns.
  static const int columnCount = 7;

  /// Total number of tiles on the board (49).
  static const int totalTiles = rowCount * columnCount;

  final List<Tile> _tiles;

  /// Retrieves the tile at [pos], or null if out of bounds.
  Tile? getTile(BoardPosition pos) {
    if (!pos.isValid()) {
      return null;
    }
    return _tiles[pos.row * columnCount + pos.column];
  }

  /// Retrieves the tile at [row] and [column], or null if out of bounds.
  Tile? getTileAt(int row, int column) {
    if (row < 0 || row >= rowCount || column < 0 || column >= columnCount) {
      return null;
    }
    return _tiles[row * columnCount + column];
  }

  /// Returns a new [Board] with the tile at [pos] replaced by [tile].
  Board copyWithUpdatedTile(BoardPosition pos, Tile tile) {
    if (!pos.isValid()) {
      throw RangeError('Position $pos is out of board bounds');
    }
    final newTiles = List<Tile>.from(_tiles);
    newTiles[pos.row * columnCount + pos.column] = tile;
    return Board._(List<Tile>.unmodifiable(newTiles));
  }

  /// Returns a new [Board] with multiple tiles updated.
  Board copyWithUpdatedTiles(Map<BoardPosition, Tile> updates) {
    final newTiles = List<Tile>.from(_tiles);
    for (final entry in updates.entries) {
      final pos = entry.key;
      if (!pos.isValid()) {
        throw RangeError('Position $pos is out of board bounds');
      }
      newTiles[pos.row * columnCount + pos.column] = entry.value;
    }
    return Board._(List<Tile>.unmodifiable(newTiles));
  }

  /// Returns a new [Board] with tiles at [a] and [b] swapped.
  Board swapTiles(BoardPosition a, BoardPosition b) {
    if (!a.isValid() || !b.isValid()) {
      throw RangeError('Positions must be within board bounds: $a, $b');
    }
    final indexA = a.row * columnCount + a.column;
    final indexB = b.row * columnCount + b.column;
    final newTiles = List<Tile>.from(_tiles);
    final temp = newTiles[indexA];
    newTiles[indexA] = newTiles[indexB];
    newTiles[indexB] = temp;
    return Board._(List<Tile>.unmodifiable(newTiles));
  }

  /// Exports board to an unmodifiable map of [BoardPosition] to [Tile].
  Map<BoardPosition, Tile> toMap() {
    final map = <BoardPosition, Tile>{};
    for (var r = 0; r < rowCount; r++) {
      for (var c = 0; c < columnCount; c++) {
        map[BoardPosition(r, c)] = _tiles[r * columnCount + c];
      }
    }
    return Map.unmodifiable(map);
  }

  /// Exports board to a 2D row-major list.
  List<List<Tile>> toGrid() {
    return List.generate(
      rowCount,
      (r) => List.generate(
        columnCount,
        (c) => _tiles[r * columnCount + c],
        growable: false,
      ),
      growable: false,
    );
  }

  /// Generates a checksum integer for board equality and validation.
  int get checksum {
    var sum = 0;
    for (var i = 0; i < totalTiles; i++) {
      sum = 31 * sum + _tiles[i].hashCode;
    }
    return sum;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Board) return false;
    for (var i = 0; i < totalTiles; i++) {
      if (_tiles[i] != other._tiles[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    var result = 17;
    for (var i = 0; i < totalTiles; i++) {
      result = 37 * result + _tiles[i].hashCode;
    }
    return result;
  }
}
