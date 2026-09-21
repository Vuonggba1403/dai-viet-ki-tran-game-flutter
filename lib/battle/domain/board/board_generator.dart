import 'package:ezwork/battle/domain/board/board.dart';
import 'package:ezwork/battle/domain/board/legal_move_finder.dart';
import 'package:ezwork/battle/domain/board/tile.dart';
import 'package:ezwork/battle/domain/board/tile_type.dart';
import 'package:ezwork/battle/domain/random/random_service.dart';

/// Generates valid 7x7 Match-3 boards with no pre-existing matches
/// and at least one legal move.
class BoardGenerator {
  const BoardGenerator();

  /// Maximum attempts to generate a board with legal moves before throwing or fallback.
  static const int maxGenerationAttempts = 200;

  /// Generates a valid 7x7 [Board] using [random].
  ///
  /// Guarantees:
  /// 1. Exactly 49 tiles.
  /// 2. No prematches (no 3 identical consecutive tiles horizontally or vertically).
  /// 3. At least one legal move exists.
  /// 4. Deterministic given the same [RandomService] state.
  static Board generate(
    RandomService random, {
    int startTileId = 1,
  }) {
    var nextId = startTileId;

    for (var attempt = 0; attempt < maxGenerationAttempts; attempt++) {
      final grid = List.generate(
        Board.rowCount,
        (_) => List<Tile?>.filled(Board.columnCount, null),
      );

      for (var r = 0; r < Board.rowCount; r++) {
        for (var c = 0; c < Board.columnCount; c++) {
          final prohibited = <TileType>{};

          // Check left 2 neighbors
          if (c >= 2) {
            final t1 = grid[r][c - 1];
            final t2 = grid[r][c - 2];
            if (t1 != null && t2 != null && t1.type == t2.type) {
              prohibited.add(t1.type);
            }
          }

          // Check top 2 neighbors
          if (r >= 2) {
            final t1 = grid[r - 1][c];
            final t2 = grid[r - 2][c];
            if (t1 != null && t2 != null && t1.type == t2.type) {
              prohibited.add(t1.type);
            }
          }

          final availableTypes = TileType.values
              .where((type) => !prohibited.contains(type))
              .toList();

          final chosenType =
              availableTypes[random.nextInt(availableTypes.length)];
          grid[r][c] = Tile(id: nextId++, type: chosenType);
        }
      }

      final board = Board.fromGrid(
        grid.map((row) => row.cast<Tile>()).toList(),
      );

      if (LegalMoveFinder.hasLegalMove(board)) {
        return board;
      }
    }

    throw StateError(
      'Failed to generate a valid board with legal moves after $maxGenerationAttempts attempts.',
    );
  }

  /// Shuffles existing tiles on the [board] to produce a new state with no
  /// prematches and at least one legal move, using [random].
  static Board shuffle(
    Board board,
    RandomService random,
  ) {
    final existingTiles = List<Tile>.from(board.toMap().values);

    for (var attempt = 0; attempt < maxGenerationAttempts; attempt++) {
      // Fisher-Yates shuffle
      for (var i = existingTiles.length - 1; i > 0; i--) {
        final j = random.nextInt(i + 1);
        final temp = existingTiles[i];
        existingTiles[i] = existingTiles[j];
        existingTiles[j] = temp;
      }

      // Check if grid has prematches
      var hasPrematch = false;
      for (var r = 0; r < Board.rowCount && !hasPrematch; r++) {
        for (var c = 0; c < Board.columnCount; c++) {
          final idx = r * Board.columnCount + c;
          final type = existingTiles[idx].type;

          if (c >= 2) {
            final idx1 = r * Board.columnCount + (c - 1);
            final idx2 = r * Board.columnCount + (c - 2);
            if (existingTiles[idx1].type == type &&
                existingTiles[idx2].type == type) {
              hasPrematch = true;
              break;
            }
          }
          if (r >= 2) {
            final idx1 = (r - 1) * Board.columnCount + c;
            final idx2 = (r - 2) * Board.columnCount + c;
            if (existingTiles[idx1].type == type &&
                existingTiles[idx2].type == type) {
              hasPrematch = true;
              break;
            }
          }
        }
      }

      if (hasPrematch) continue;

      final candidateBoard = Board.fromList(existingTiles);
      if (LegalMoveFinder.hasLegalMove(candidateBoard)) {
        return candidateBoard;
      }
    }

    throw StateError(
      'Failed to shuffle the existing tile distribution into a valid board '
      'after $maxGenerationAttempts attempts.',
    );
  }
}
