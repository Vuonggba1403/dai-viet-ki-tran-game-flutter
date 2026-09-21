import 'package:ezwork/battle/domain/board/board.dart';
import 'package:ezwork/battle/domain/board/board_position.dart';
import 'package:ezwork/battle/domain/board/match_finder.dart';
import 'package:ezwork/battle/domain/board/special_tile_type.dart';
import 'package:ezwork/battle/domain/board/swap.dart';

/// Finds possible valid swaps on a [Board] that produce matches.
class LegalMoveFinder {
  const LegalMoveFinder();

  /// Returns true immediately if at least one legal move exists on the board.
  static bool hasLegalMove(Board board) {
    // Check horizontal swaps
    for (var r = 0; r < Board.rowCount; r++) {
      for (var c = 0; c < Board.columnCount - 1; c++) {
        final posA = BoardPosition(r, c);
        final posB = BoardPosition(r, c + 1);
        if (_isMoveLegal(board, posA, posB)) {
          return true;
        }
      }
    }

    // Check vertical swaps
    for (var r = 0; r < Board.rowCount - 1; r++) {
      for (var c = 0; c < Board.columnCount; c++) {
        final posA = BoardPosition(r, c);
        final posB = BoardPosition(r + 1, c);
        if (_isMoveLegal(board, posA, posB)) {
          return true;
        }
      }
    }

    return false;
  }

  /// Returns all distinct legal swaps available on the current board.
  static List<Swap> findLegalMoves(Board board) {
    final moves = <Swap>[];

    // Check horizontal swaps
    for (var r = 0; r < Board.rowCount; r++) {
      for (var c = 0; c < Board.columnCount - 1; c++) {
        final posA = BoardPosition(r, c);
        final posB = BoardPosition(r, c + 1);
        if (_isMoveLegal(board, posA, posB)) {
          moves.add(Swap(from: posA, to: posB));
        }
      }
    }

    // Check vertical swaps
    for (var r = 0; r < Board.rowCount - 1; r++) {
      for (var c = 0; c < Board.columnCount; c++) {
        final posA = BoardPosition(r, c);
        final posB = BoardPosition(r + 1, c);
        if (_isMoveLegal(board, posA, posB)) {
          moves.add(Swap(from: posA, to: posB));
        }
      }
    }

    return List<Swap>.unmodifiable(moves);
  }

  static bool _isMoveLegal(
    Board board,
    BoardPosition a,
    BoardPosition b,
  ) {
    final tileA = board.getTile(a);
    final tileB = board.getTile(b);
    if (tileA == null || tileB == null) return false;

    // If identical type and neither is special, swap is redundant
    if (tileA.type == tileB.type && !tileA.isSpecial && !tileB.isSpecial) {
      return false;
    }

    // Power Gem can swap with any tile
    if (tileA.specialType == SpecialTileType.powerGem ||
        tileB.specialType == SpecialTileType.powerGem) {
      return true;
    }

    // Two special tiles swapped together is always legal
    if (tileA.isSpecial && tileB.isSpecial) {
      return true;
    }

    // Perform virtual swap and check for matches
    final swapped = board.swapTiles(a, b);
    return MatchFinder.hasAnyMatch(swapped);
  }
}
