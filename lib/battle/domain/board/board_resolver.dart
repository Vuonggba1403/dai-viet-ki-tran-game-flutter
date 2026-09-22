import 'package:ezwork/battle/domain/board/board.dart';
import 'package:ezwork/battle/domain/board/board_event.dart';
import 'package:ezwork/battle/domain/board/board_generator.dart';
import 'package:ezwork/battle/domain/board/board_position.dart';
import 'package:ezwork/battle/domain/board/legal_move_finder.dart';
import 'package:ezwork/battle/domain/board/match_finder.dart';
import 'package:ezwork/battle/domain/board/match_group.dart';
import 'package:ezwork/battle/domain/board/special_tile_type.dart';
import 'package:ezwork/battle/domain/board/swap.dart';
import 'package:ezwork/battle/domain/board/tile.dart';
import 'package:ezwork/battle/domain/board/tile_type.dart';
import 'package:ezwork/battle/domain/random/random_service.dart';
import 'package:meta/meta.dart';

class _PowerGemResolution {
  const _PowerGemResolution({required this.clears, required this.event});

  final Set<BoardPosition> clears;
  final SpecialTriggered event;
}

/// The complete output of a board resolution step.
@immutable
class BoardResolution {
  BoardResolution({
    required this.finalBoard,
    required List<BoardEvent> events,
    required this.comboCount,
    required Map<TileType, int> matchedTilesSummary,
    required this.isSuccess,
  }) : events = List<BoardEvent>.unmodifiable(events),
       matchedTilesSummary = Map<TileType, int>.unmodifiable(
         matchedTilesSummary,
       );

  final Board finalBoard;
  final List<BoardEvent> events;
  final int comboCount;
  final Map<TileType, int> matchedTilesSummary;
  final bool isSuccess;
}

/// Resolves swaps, gravity, refills, cascades, and shuffles on a [Board].
class BoardResolver {
  const BoardResolver();

  /// Maximum cascade cycles to prevent potential infinite loops.
  static const int maxCascadeCycles = 50;

  /// Resolves an attempted swap on the given [board].
  ///
  /// If the swap is invalid (not orthogonal, out of bounds, or creates no match),
  /// returns a resolution containing [SwapStarted] -> [SwapRejected] and leaves
  /// the board unchanged.
  static BoardResolution resolveSwap(
    Board board,
    Swap swap,
    RandomService random, {
    int nextTileId = 10000,
  }) {
    final events = <BoardEvent>[];
    final summary = <TileType, int>{
      for (final type in TileType.values) type: 0,
    };

    // 1. Orthogonal adjacency and bounds check
    if (!swap.isValidAdjacent()) {
      events
        ..add(SwapStarted(swap))
        ..add(SwapRejected(swap));
      return BoardResolution(
        finalBoard: board,
        events: List.unmodifiable(events),
        comboCount: 0,
        matchedTilesSummary: Map.unmodifiable(summary),
        isSuccess: false,
      );
    }

    final tileFrom = board.getTile(swap.from);
    final tileTo = board.getTile(swap.to);
    if (tileFrom == null || tileTo == null) {
      events
        ..add(SwapStarted(swap))
        ..add(SwapRejected(swap));
      return BoardResolution(
        finalBoard: board,
        events: List.unmodifiable(events),
        comboCount: 0,
        matchedTilesSummary: Map.unmodifiable(summary),
        isSuccess: false,
      );
    }

    // Check for special tile interactions before regular match finding
    final isPowerGemSwap =
        tileFrom.specialType == SpecialTileType.powerGem ||
        tileTo.specialType == SpecialTileType.powerGem;
    // Simulate swap
    var currentBoard = board.swapTiles(swap.from, swap.to);
    final initialMatches = MatchFinder.find(
      currentBoard,
      preferredSpawnPosition: swap.to,
    );

    final createsMatchAtSwap = initialMatches.any(
      (match) =>
          match.positions.contains(swap.from) ||
          match.positions.contains(swap.to),
    );
    final isValidMove = createsMatchAtSwap || isPowerGemSwap;

    if (!isValidMove) {
      events
        ..add(SwapStarted(swap))
        ..add(SwapRejected(swap));
      return BoardResolution(
        finalBoard: board,
        events: List.unmodifiable(events),
        comboCount: 0,
        matchedTilesSummary: Map.unmodifiable(summary),
        isSuccess: false,
      );
    }

    // Move is accepted!
    events
      ..add(SwapStarted(swap))
      ..add(SwapAccepted(swap));

    var cycle = 1;
    var comboCount = 0;
    final maxExistingTileId = board
        .toMap()
        .values
        .map((tile) => tile.id)
        .reduce((a, b) => a > b ? a : b);
    var idCounter = nextTileId > maxExistingTileId
        ? nextTileId
        : maxExistingTileId + 1;

    // Handle a direct Power Gem swap on cycle 1.
    Set<BoardPosition>? forcedInitialClears;
    SpecialTriggered? forcedSpecialEvent;
    final initiallyTriggeredSpecials = <BoardPosition>{};
    if (isPowerGemSwap) {
      final powerGemResolution = _resolvePowerGemSwap(
        currentBoard,
        swap,
        tileFrom,
        tileTo,
      );
      forcedInitialClears = powerGemResolution.clears;
      forcedSpecialEvent = powerGemResolution.event;
      if (tileFrom.specialType == SpecialTileType.powerGem) {
        initiallyTriggeredSpecials.add(swap.to);
      }
      if (tileTo.specialType == SpecialTileType.powerGem) {
        initiallyTriggeredSpecials.add(swap.from);
      }
    }

    while (cycle <= maxCascadeCycles) {
      final matches = (cycle == 1 && forcedInitialClears != null)
          ? <MatchGroup>[]
          : MatchFinder.find(
              currentBoard,
              preferredSpawnPosition: (cycle == 1) ? swap.to : null,
            );

      final hasForcedClears =
          cycle == 1 &&
          forcedInitialClears != null &&
          forcedInitialClears.isNotEmpty;

      if (matches.isEmpty && !hasForcedClears) {
        break;
      }

      events.add(CascadeStarted(cycle));
      if (cycle == 1 && forcedSpecialEvent != null) {
        events.add(forcedSpecialEvent);
      }
      comboCount++;

      final positionsToClear = <BoardPosition>{};
      final specialSpawns = <BoardPosition, Tile>{};

      if (hasForcedClears) {
        positionsToClear.addAll(forcedInitialClears);
      }

      // Process standard matches
      for (final match in matches) {
        positionsToClear.addAll(match.positions);
        summary[match.tileType] =
            (summary[match.tileType] ?? 0) + match.positions.length;

        if (match.createsSpecial && match.specialSpawnPosition != null) {
          final spawnPos = match.specialSpawnPosition!;
          final specialTile = Tile(
            id: idCounter++,
            type: match.tileType,
            specialType: match.specialCreated,
          );
          specialSpawns[spawnPos] = specialTile;
        }
      }

      if (matches.isNotEmpty) {
        events.add(TilesMatched(cycle: cycle, matches: matches));
      }

      // If a special tile was created in this match, it must NOT be cleared!
      for (final entry in specialSpawns.entries) {
        positionsToClear.remove(entry.key);
        currentBoard = currentBoard.copyWithUpdatedTile(entry.key, entry.value);
        events.add(
          SpecialCreated(
            position: entry.key,
            specialType: entry.value.specialType,
            tile: entry.value,
          ),
        );
      }

      // Expand clears through special tile triggers (chain reaction)
      final allClearedPositions = _expandSpecialTriggers(
        currentBoard,
        positionsToClear,
        events,
        initiallyTriggeredPositions: initiallyTriggeredSpecials,
      );

      // Record tile clear event
      final sortedClears = allClearedPositions.toList()..sort();
      events.add(TilesCleared(cycle: cycle, positions: sortedClears));

      // Apply Gravity (tiles fall down columns)
      final drops = <TileDrop>[];
      final newGrid = List.generate(
        Board.rowCount,
        (_) => List<Tile?>.filled(Board.columnCount, null),
      );

      for (var c = 0; c < Board.columnCount; c++) {
        var targetRow = Board.rowCount - 1;
        for (var r = Board.rowCount - 1; r >= 0; r--) {
          final pos = BoardPosition(r, c);
          if (!allClearedPositions.contains(pos)) {
            final tile = currentBoard.getTileAt(r, c)!;
            newGrid[targetRow][c] = tile;
            if (targetRow != r) {
              drops.add(
                TileDrop(
                  tile: tile,
                  from: pos,
                  to: BoardPosition(targetRow, c),
                ),
              );
            }
            targetRow--;
          }
        }
      }

      if (drops.isNotEmpty) {
        events.add(TilesDropped(cycle: cycle, drops: drops));
      }

      // Refill empty spaces at the top of each column
      final spawns = <TileSpawn>[];
      for (var c = 0; c < Board.columnCount; c++) {
        for (var r = 0; r < Board.rowCount; r++) {
          if (newGrid[r][c] == null) {
            final randomType =
                TileType.values[random.nextInt(TileType.values.length)];
            final spawnedTile = Tile(id: idCounter++, type: randomType);
            newGrid[r][c] = spawnedTile;
            spawns.add(
              TileSpawn(
                tile: spawnedTile,
                position: BoardPosition(r, c),
              ),
            );
          }
        }
      }

      events.add(TilesSpawned(cycle: cycle, spawns: spawns));
      currentBoard = Board.fromGrid(
        newGrid.map((row) => row.cast<Tile>()).toList(),
      );

      events.add(CascadeCompleted(cycle));
      cycle++;
    }

    if (cycle > maxCascadeCycles && MatchFinder.hasAnyMatch(currentBoard)) {
      throw StateError(
        'Board did not settle after $maxCascadeCycles cascade cycles.',
      );
    }

    // If no legal moves remain on board after cascade settles, shuffle
    if (!LegalMoveFinder.hasLegalMove(currentBoard)) {
      final shuffledBoard = BoardGenerator.shuffle(currentBoard, random);
      final newPositions = <int, BoardPosition>{};
      for (var r = 0; r < Board.rowCount; r++) {
        for (var c = 0; c < Board.columnCount; c++) {
          final tile = shuffledBoard.getTileAt(r, c)!;
          newPositions[tile.id] = BoardPosition(r, c);
        }
      }
      events.add(BoardShuffled(newPositions: newPositions));
      currentBoard = shuffledBoard;
    }

    return BoardResolution(
      finalBoard: currentBoard,
      events: List.unmodifiable(events),
      comboCount: comboCount,
      matchedTilesSummary: Map.unmodifiable(summary),
      isSuccess: true,
    );
  }

  /// Triggers special tile abilities and cascades chain reactions.
  static Set<BoardPosition> _expandSpecialTriggers(
    Board board,
    Set<BoardPosition> initialClears,
    List<BoardEvent> events, {
    Set<BoardPosition> initiallyTriggeredPositions = const {},
  }) {
    final allCleared = Set<BoardPosition>.from(initialClears);
    final queue = List<BoardPosition>.from(initialClears);
    final triggeredSpecialPositions = <BoardPosition>{
      ...initiallyTriggeredPositions,
    };

    while (queue.isNotEmpty) {
      final pos = queue.removeAt(0);
      final tile = board.getTile(pos);
      if (tile == null || !tile.isSpecial) continue;
      if (triggeredSpecialPositions.contains(pos)) continue;

      triggeredSpecialPositions.add(pos);
      final affected = <BoardPosition>[];

      switch (tile.specialType) {
        case SpecialTileType.lineHorizontal:
          for (var c = 0; c < Board.columnCount; c++) {
            affected.add(BoardPosition(pos.row, c));
          }
        case SpecialTileType.lineVertical:
          for (var r = 0; r < Board.rowCount; r++) {
            affected.add(BoardPosition(r, pos.column));
          }
        case SpecialTileType.bomb:
          for (var r = pos.row - 1; r <= pos.row + 1; r++) {
            for (var c = pos.column - 1; c <= pos.column + 1; c++) {
              final target = BoardPosition(r, c);
              if (target.isValid()) {
                affected.add(target);
              }
            }
          }
        case SpecialTileType.powerGem:
          // If triggered naturally by explosion, clear random or surrounding
          for (var r = 0; r < Board.rowCount; r++) {
            for (var c = 0; c < Board.columnCount; c++) {
              final target = BoardPosition(r, c);
              final t = board.getTile(target);
              if (t != null && t.type == tile.type) {
                affected.add(target);
              }
            }
          }
        case SpecialTileType.none:
      }

      events.add(
        SpecialTriggered(
          position: pos,
          specialType: tile.specialType,
          affectedPositions: affected,
        ),
      );

      for (final p in affected) {
        if (allCleared.add(p)) {
          queue.add(p);
        }
      }
    }

    return allCleared;
  }

  static _PowerGemResolution _resolvePowerGemSwap(
    Board board,
    Swap swap,
    Tile tileFrom,
    Tile tileTo,
  ) {
    final clears = <BoardPosition>{};
    final isFromPowerGem = tileFrom.specialType == SpecialTileType.powerGem;
    final isToPowerGem = tileTo.specialType == SpecialTileType.powerGem;
    late final BoardPosition powerGemPosition;

    if (isFromPowerGem && isToPowerGem) {
      powerGemPosition = swap.to;
      // Both are Power Gems -> Clear entire board!
      for (var r = 0; r < Board.rowCount; r++) {
        for (var c = 0; c < Board.columnCount; c++) {
          clears.add(BoardPosition(r, c));
        }
      }
    } else {
      // One Power Gem swapped with normal/special tile
      powerGemPosition = isFromPowerGem ? swap.to : swap.from;
      final otherTile = isFromPowerGem ? tileTo : tileFrom;
      final targetType = otherTile.type;

      clears
        ..add(swap.from)
        ..add(swap.to);

      for (var r = 0; r < Board.rowCount; r++) {
        for (var c = 0; c < Board.columnCount; c++) {
          final p = BoardPosition(r, c);
          final t = board.getTile(p);
          if (t != null && t.type == targetType) {
            clears.add(p);
          }
        }
      }
    }

    return _PowerGemResolution(
      clears: clears,
      event: SpecialTriggered(
        position: powerGemPosition,
        specialType: SpecialTileType.powerGem,
        affectedPositions: clears.toList()..sort(),
      ),
    );
  }
}
