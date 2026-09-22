import 'package:dai_viet_ki_tran_game/battle/domain/board/board_position.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/match_group.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/special_tile_type.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/swap.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/tile.dart';
import 'package:meta/meta.dart';

/// Describes a tile dropping from one position to another down a column.
@immutable
class TileDrop {
  const TileDrop({
    required this.tile,
    required this.from,
    required this.to,
  });

  final Tile tile;
  final BoardPosition from;
  final BoardPosition to;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TileDrop &&
          other.tile == tile &&
          other.from == from &&
          other.to == to;

  @override
  int get hashCode => Object.hash(tile, from, to);

  @override
  String toString() => 'TileDrop(id: ${tile.id}, $from -> $to)';
}

/// Describes a newly spawned tile appearing at a position at top of board.
@immutable
class TileSpawn {
  const TileSpawn({
    required this.tile,
    required this.position,
  });

  final Tile tile;
  final BoardPosition position;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TileSpawn && other.tile == tile && other.position == position;

  @override
  int get hashCode => Object.hash(tile, position);

  @override
  String toString() => 'TileSpawn(id: ${tile.id} at $position)';
}

/// Base sealed class for all immutable Match-3 board events.
///
/// Flame visual rendering components consume these events in sequence
/// to drive sprite movements, particle effects, and sound triggers without
/// calculating game logic.
@immutable
sealed class BoardEvent {
  const BoardEvent();
}

/// Emitted when a swap is initiated between two positions.
class SwapStarted extends BoardEvent {
  const SwapStarted(this.swap);
  final Swap swap;

  @override
  String toString() => 'SwapStarted($swap)';
}

/// Emitted when an attempted swap is rejected (no match or invalid move).
class SwapRejected extends BoardEvent {
  const SwapRejected(this.swap);
  final Swap swap;

  @override
  String toString() => 'SwapRejected($swap)';
}

/// Emitted when an attempted swap is accepted as a valid move.
class SwapAccepted extends BoardEvent {
  const SwapAccepted(this.swap);
  final Swap swap;

  @override
  String toString() => 'SwapAccepted($swap)';
}

/// Emitted at the beginning of each cascade cycle (cycle starts at 1).
class CascadeStarted extends BoardEvent {
  const CascadeStarted(this.cycle);
  final int cycle;

  @override
  String toString() => 'CascadeStarted(cycle: $cycle)';
}

/// Emitted when matches are identified in the current cascade cycle.
class TilesMatched extends BoardEvent {
  TilesMatched({required this.cycle, required List<MatchGroup> matches})
    : matches = List<MatchGroup>.unmodifiable(matches);
  final int cycle;
  final List<MatchGroup> matches;

  @override
  String toString() => 'TilesMatched(cycle: $cycle, count: ${matches.length})';
}

/// Emitted when a special tile is created from a 4-match, T/L, or 5-match.
class SpecialCreated extends BoardEvent {
  const SpecialCreated({
    required this.position,
    required this.specialType,
    required this.tile,
  });
  final BoardPosition position;
  final SpecialTileType specialType;
  final Tile tile;

  @override
  String toString() =>
      'SpecialCreated($specialType at $position, id: ${tile.id})';
}

/// Emitted when a special tile's area effect is activated.
class SpecialTriggered extends BoardEvent {
  SpecialTriggered({
    required this.position,
    required this.specialType,
    required List<BoardPosition> affectedPositions,
  }) : affectedPositions = List<BoardPosition>.unmodifiable(affectedPositions);
  final BoardPosition position;
  final SpecialTileType specialType;
  final List<BoardPosition> affectedPositions;

  @override
  String toString() =>
      'SpecialTriggered($specialType at $position, affected: ${affectedPositions.length})';
}

/// Emitted when tiles are cleared from the board in the current cycle.
class TilesCleared extends BoardEvent {
  TilesCleared({required this.cycle, required List<BoardPosition> positions})
    : positions = List<BoardPosition>.unmodifiable(positions);
  final int cycle;
  final List<BoardPosition> positions;

  @override
  String toString() =>
      'TilesCleared(cycle: $cycle, count: ${positions.length})';
}

/// Emitted when surviving tiles fall down through gravity.
class TilesDropped extends BoardEvent {
  TilesDropped({required this.cycle, required List<TileDrop> drops})
    : drops = List<TileDrop>.unmodifiable(drops);
  final int cycle;
  final List<TileDrop> drops;

  @override
  String toString() => 'TilesDropped(cycle: $cycle, drops: ${drops.length})';
}

/// Emitted when empty top cells are refilled with new tiles.
class TilesSpawned extends BoardEvent {
  TilesSpawned({required this.cycle, required List<TileSpawn> spawns})
    : spawns = List<TileSpawn>.unmodifiable(spawns);
  final int cycle;
  final List<TileSpawn> spawns;

  @override
  String toString() => 'TilesSpawned(cycle: $cycle, spawns: ${spawns.length})';
}

/// Emitted when a cascade cycle finishes.
class CascadeCompleted extends BoardEvent {
  const CascadeCompleted(this.cycle);
  final int cycle;

  @override
  String toString() => 'CascadeCompleted(cycle: $cycle)';
}

/// Emitted when the board has no legal moves remaining and is shuffled.
class BoardShuffled extends BoardEvent {
  BoardShuffled({required Map<int, BoardPosition> newPositions})
    : newPositions = Map<int, BoardPosition>.unmodifiable(newPositions);

  /// Map of tile ID to new board position.
  final Map<int, BoardPosition> newPositions;

  @override
  String toString() => 'BoardShuffled(tiles: ${newPositions.length})';
}
