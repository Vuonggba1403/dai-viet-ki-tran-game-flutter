import 'package:meta/meta.dart';

/// Represents a discrete 2D coordinate on the Match-3 board.
///
/// Coordinates are 0-indexed:
/// - [row] from 0 (top) to rowCount - 1 (bottom).
/// - [column] from 0 (left) to columnCount - 1 (right).
@immutable
class BoardPosition implements Comparable<BoardPosition> {
  const BoardPosition(this.row, this.column);

  final int row;
  final int column;

  /// Validates whether this position is within board boundaries.
  bool isValid({int rowCount = 7, int columnCount = 7}) {
    return row >= 0 && row < rowCount && column >= 0 && column < columnCount;
  }

  /// Checks orthogonal adjacency (up, down, left, right).
  ///
  /// Diagonal tiles are NOT adjacent for standard match-3 swaps.
  bool isAdjacent(BoardPosition other) {
    final rowDiff = (row - other.row).abs();
    final colDiff = (column - other.column).abs();
    return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1);
  }

  /// Returns orthogonal neighbors that are within the specified board boundaries.
  List<BoardPosition> orthogonalNeighbors({
    int rowCount = 7,
    int columnCount = 7,
  }) {
    final neighbors = <BoardPosition>[];
    final candidates = [
      BoardPosition(row - 1, column),
      BoardPosition(row + 1, column),
      BoardPosition(row, column - 1),
      BoardPosition(row, column + 1),
    ];
    for (final candidate in candidates) {
      if (candidate.isValid(rowCount: rowCount, columnCount: columnCount)) {
        neighbors.add(candidate);
      }
    }
    return neighbors;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BoardPosition && other.row == row && other.column == column;
  }

  @override
  int get hashCode => Object.hash(row, column);

  @override
  int compareTo(BoardPosition other) {
    if (row != other.row) {
      return row.compareTo(other.row);
    }
    return column.compareTo(other.column);
  }

  @override
  String toString() => 'BoardPosition($row, $column)';
}
