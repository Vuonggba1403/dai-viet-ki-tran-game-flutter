import 'package:ezwork/battle/domain/board/board.dart';
import 'package:ezwork/battle/domain/board/board_resolver.dart';
import 'package:ezwork/battle/domain/board/swap.dart';
import 'package:ezwork/battle/domain/random/random_service.dart';
import 'package:meta/meta.dart';

/// Pure Dart controller that maintains runtime state for an active battle session's board.
///
/// Encapsulates board mutation, RNG state, next tile ID allocation, and
/// resolution execution without any dependency on Flutter or Flame.
class BattleSessionController {
  BattleSessionController({
    required Board initialBoard,
    required RandomService randomService,
    int initialTileId = 10000,
  }) : _currentBoard = initialBoard,
       _randomService = randomService,
       _nextTileId = initialTileId {
    _advanceNextTileId();
  }

  Board _currentBoard;
  final RandomService _randomService;
  int _nextTileId;
  int _comboCount = 0;

  /// The current settled board state.
  Board get currentBoard => _currentBoard;

  /// The RNG service powering board generation and refills.
  RandomService get randomService => _randomService;

  /// The highest combo count achieved from the last resolved swap.
  int get comboCount => _comboCount;

  /// The next unique runtime ID to be allocated for newly spawned tiles.
  @visibleForTesting
  int get nextTileId => _nextTileId;

  /// Attempts to perform a swap on the current board.
  ///
  /// If valid, updates [currentBoard], advances [nextTileId], updates [comboCount],
  /// and returns the complete [BoardResolution].
  /// If invalid, leaves [currentBoard] untouched and returns the rejected resolution.
  BoardResolution attemptSwap(Swap swap) {
    final resolution = BoardResolver.resolveSwap(
      _currentBoard,
      swap,
      _randomService,
      nextTileId: _nextTileId,
    );

    if (resolution.isSuccess) {
      _currentBoard = resolution.finalBoard;
      _comboCount = resolution.comboCount;
      _advanceNextTileId();
    }

    return resolution;
  }

  /// Resets the controller with a newly generated board.
  void resetBoard(Board newBoard) {
    _currentBoard = newBoard;
    _comboCount = 0;
    _advanceNextTileId();
  }

  void _advanceNextTileId() {
    var maxId = _nextTileId;
    for (var r = 0; r < Board.rowCount; r++) {
      for (var c = 0; c < Board.columnCount; c++) {
        final tile = _currentBoard.getTileAt(r, c);
        if (tile != null && tile.id >= maxId) {
          maxId = tile.id + 1;
        }
      }
    }
    _nextTileId = maxId;
  }
}
