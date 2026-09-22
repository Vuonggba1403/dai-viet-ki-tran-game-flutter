import 'package:ezwork/battle/domain/board/board.dart';
import 'package:ezwork/battle/domain/board/board_generator.dart';
import 'package:ezwork/battle/domain/board/legal_move_finder.dart';
import 'package:ezwork/battle/domain/board/match_finder.dart';
import 'package:ezwork/battle/domain/board/tile.dart';
import 'package:ezwork/battle/domain/board/tile_type.dart';
import 'package:ezwork/battle/domain/random/seeded_random.dart';
import 'package:flutter_test/flutter_test.dart' hide MatchFinder;

void main() {
  group('BoardGenerator', () {
    test('same seed generates identical board deterministically', () {
      final board1 = BoardGenerator.generate(SeededRandom(42));
      final board2 = BoardGenerator.generate(SeededRandom(42));

      expect(board1, equals(board2));
      expect(board1.checksum, equals(board2.checksum));
    });

    test(
      'validates 10,000 seeds: 49 tiles, no prematches, always has legal moves',
      () {
        const seedCount = 10000;

        for (var seed = 1; seed <= seedCount; seed++) {
          final rng = SeededRandom(seed);
          final board = BoardGenerator.generate(rng);

          // 1. Total 49 tiles
          expect(board.toMap().length, equals(Board.totalTiles));

          // 2. Zero prematches
          expect(
            MatchFinder.hasAnyMatch(board),
            isFalse,
            reason: 'Seed $seed generated a board with prematches!',
          );

          // 3. At least one legal move exists
          expect(
            LegalMoveFinder.hasLegalMove(board),
            isTrue,
            reason: 'Seed $seed generated a board without legal moves!',
          );
        }
      },
    );

    test(
      'shuffle preserves tiles while eliminating prematches and ensuring moves',
      () {
        final rng = SeededRandom(777);
        final initialBoard = BoardGenerator.generate(rng);

        final shuffledBoard = BoardGenerator.shuffle(initialBoard, rng);

        expect(shuffledBoard.toMap().length, equals(Board.totalTiles));
        expect(MatchFinder.hasAnyMatch(shuffledBoard), isFalse);
        expect(LegalMoveFinder.hasLegalMove(shuffledBoard), isTrue);

        // Verify multiset of tile IDs is preserved
        final initialIds = initialBoard.toMap().values.map((t) => t.id).toList()
          ..sort();
        final shuffledIds =
            shuffledBoard.toMap().values.map((t) => t.id).toList()..sort();
        expect(shuffledIds, equals(initialIds));
      },
    );

    test('shuffle never replaces an impossible tile distribution', () {
      final uniformBoard = Board.fromList(
        List.generate(
          Board.totalTiles,
          (index) => Tile(id: index + 1, type: TileType.fire),
        ),
      );

      expect(
        () => BoardGenerator.shuffle(uniformBoard, SeededRandom(1)),
        throwsStateError,
      );
    });
  });
}
