import 'package:ezwork/battle/domain/board/board_position.dart';
import 'package:meta/meta.dart';

/// Represents an attempted swap between two board positions.
@immutable
class Swap {
  const Swap({required this.from, required this.to});

  final BoardPosition from;
  final BoardPosition to;

  /// Checks whether both positions are valid board coordinates and
  /// orthogonally adjacent (Manhattan distance = 1).
  bool isValidAdjacent({int rowCount = 7, int columnCount = 7}) {
    if (!from.isValid(rowCount: rowCount, columnCount: columnCount) ||
        !to.isValid(rowCount: rowCount, columnCount: columnCount)) {
      return false;
    }
    return from.isAdjacent(to);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Swap &&
        ((other.from == from && other.to == to) ||
            (other.from == to && other.to == from));
  }

  @override
  int get hashCode => Object.hash(
        from.hashCode ^ to.hashCode,
        from.hashCode ^ to.hashCode,
      );

  @override
  String toString() => 'Swap($from <-> $to)';
}
