import 'package:ezwork/battle/domain/board/board_position.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BoardPosition', () {
    test('equality and hashCode', () {
      const pos1 = BoardPosition(2, 3);
      const pos2 = BoardPosition(2, 3);
      const pos3 = BoardPosition(3, 2);

      expect(pos1, equals(pos2));
      expect(pos1.hashCode, equals(pos2.hashCode));
      expect(pos1, isNot(equals(pos3)));
    });

    test('isValid within default 7x7 bounds', () {
      expect(const BoardPosition(0, 0).isValid(), isTrue);
      expect(const BoardPosition(6, 6).isValid(), isTrue);
      expect(const BoardPosition(3, 4).isValid(), isTrue);

      expect(const BoardPosition(-1, 0).isValid(), isFalse);
      expect(const BoardPosition(0, -1).isValid(), isFalse);
      expect(const BoardPosition(7, 0).isValid(), isFalse);
      expect(const BoardPosition(0, 7).isValid(), isFalse);
    });

    test('isAdjacent only for orthogonal neighbors', () {
      const center = BoardPosition(3, 3);

      // Orthogonal neighbors
      expect(center.isAdjacent(const BoardPosition(2, 3)), isTrue); // up
      expect(center.isAdjacent(const BoardPosition(4, 3)), isTrue); // down
      expect(center.isAdjacent(const BoardPosition(3, 2)), isTrue); // left
      expect(center.isAdjacent(const BoardPosition(3, 4)), isTrue); // right

      // Diagonals are NOT adjacent
      expect(center.isAdjacent(const BoardPosition(2, 2)), isFalse);
      expect(center.isAdjacent(const BoardPosition(2, 4)), isFalse);
      expect(center.isAdjacent(const BoardPosition(4, 2)), isFalse);
      expect(center.isAdjacent(const BoardPosition(4, 4)), isFalse);

      // Same position is NOT adjacent
      expect(center.isAdjacent(const BoardPosition(3, 3)), isFalse);

      // Distant positions
      expect(center.isAdjacent(const BoardPosition(1, 3)), isFalse);
      expect(center.isAdjacent(const BoardPosition(3, 5)), isFalse);
    });

    test('orthogonalNeighbors returns only bounded neighbors', () {
      const corner = BoardPosition(0, 0);
      final cornerNeighbors = corner.orthogonalNeighbors();
      expect(
        cornerNeighbors,
        containsAll([
          const BoardPosition(1, 0),
          const BoardPosition(0, 1),
        ]),
      );
      expect(cornerNeighbors.length, equals(2));

      const center = BoardPosition(3, 3);
      final centerNeighbors = center.orthogonalNeighbors();
      expect(
        centerNeighbors,
        containsAll([
          const BoardPosition(2, 3),
          const BoardPosition(4, 3),
          const BoardPosition(3, 2),
          const BoardPosition(3, 4),
        ]),
      );
      expect(centerNeighbors.length, equals(4));
    });

    test('compareTo orders row-first then column', () {
      const p1 = BoardPosition(0, 1);
      const p2 = BoardPosition(0, 2);
      const p3 = BoardPosition(1, 0);

      final list = [p3, p2, p1]..sort();
      expect(list, equals([p1, p2, p3]));
    });
  });
}
