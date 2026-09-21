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

/// The complete output of a board resolution step.
@immutable
class BoardResolution {
  const BoardResolution({
    required this.finalBoard,
    required this.events,
    required this.comboCount,
    required this.matchedTilesSummary,
    required this.isSuccess,
  });

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
    final isPowerGemSwap = tileFrom.specialType == SpecialTileType.powerGem ||
        tileTo.specialType == SpecialTileType.powerGem;
    final isSpecialPairSwap = tileFrom.isSpecial && tileTo.isSpecial;

    // Simulate swap
    var currentBoard = board.swapTiles(swap.from, swap.to);
    final initialMatches = MatchFinder.find(
      currentBoard,
      preferredSpawnPosition: swap.to,
    );

    final isValidMove =
        initialMatches.isNotEmpty || isPowerGemSwap || isSpecialPairSwap;

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
    var idCounter = nextTileId;

    // Handle direct Power Gem or Special Pair swap on cycle 1
    Set<BoardPosition>? forcedInitialClears;
    if (isPowerGemSwap) {
      forcedInitialClears = _resolvePowerGemSwap(
        currentBoard,
        swap,
        tileFrom,
        tileTo,
        events,
      );
    } else if (isSpecialPairSwap && initialMatches.isEmpty) {
      forcedInitialClears = _resolveSpecialPairSwap(
        currentBoard,
        swap,
        tileFrom,
        tileTo,
        events,
      );
    }

    while (cycle <= maxCascadeCycles) {
      final matches = (cycle == 1 && forcedInitialClears != null)
          ? <MatchGroup>[]
          : MatchFinder.find(
              currentBoard,
              preferredSpawnPosition: (cycle == 1) ? swap.to : null,
            );

      final hasForcedClears = cycle == 1 &&
          forcedInitialClears != null &&
          forcedInitialClears.isNotEmpty;

      if (matches.isEmpty && !hasForcedClears) {
        break;
      }

      events.add(CascadeStarted(cycle));
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
    List<BoardEvent> events,
  ) {
    final allCleared = Set<BoardPosition>.from(initialClears);
    final queue = List<BoardPosition>.from(initialClears);
    final triggeredSpecialPositions = <BoardPosition>{};

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

  static Set<BoardPosition> _resolvePowerGemSwap(
    Board board,
    Swap swap,
    Tile tileFrom,
    Tile tileTo,
    List<BoardEvent> events,
  ) {
    final clears = <BoardPosition>{};
    final isFromPowerGem = tileFrom.specialType == SpecialTileType.powerGem;
    final isToPowerGem = tileTo.specialType == SpecialTileType.powerGem;

    if (isFromPowerGem && isToPowerGem) {
      // Both are Power Gems -> Clear entire board!
      for (var r = 0; r < Board.rowCount; r++) {
        for (var c = 0; c < Board.columnCount; c++) {
          clears.add(BoardPosition(r, c));
        }
      }
      events.add(
        SpecialTriggered(
          position: swap.to,
          specialType: SpecialTileType.powerGem,
          affectedPositions: clears.toList()..sort(),
        ),
      );
    } else {
      // One Power Gem swapped with normal/special tile
      final powerGemPos = isFromPowerGem ? swap.from : swap.to;
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

      events.add(
        SpecialTriggered(
          position: powerGemPos,
          specialType: SpecialTileType.powerGem,
          affectedPositions: clears.toList()..sort(),
        ),
      );
    }

    return clears;
  }

  static Set<BoardPosition> _resolveSpecialPairSwap(
    Board board,
    Swap swap,
    Tile tileFrom,
    Tile tileTo,
    List<BoardEvent> events,
  ) {
    final clears = <BoardPosition>{swap.from, swap.to};

    // Line + Line: Clears full row and full column (cross)
    final isFromLine = tileFrom.specialType == SpecialTileType.lineHorizontal ||
        tileFrom.specialType == SpecialTileType.lineVertical;
    final isToLine = tileTo.specialType == SpecialTileType.lineHorizontal ||
        tileTo.specialType == SpecialTileType.lineVertical;

    if (isFromLine && isToLine) {
      for (var c = 0; c < Board.columnCount; c++) {
        clears.add(BoardPosition(swap.to.row, c));
      }
      for (var r = 0; r < Board.rowCount; r++) {
        clears.add(BoardPosition(r, swap.to.column));
      }
    } else if ((isFromLine && tileTo.specialType == SpecialTileType.bomb) ||
        (isToLine && tileFrom.specialType == SpecialTileType.bomb)) {
      // Line + Bomb: Clears 3 rows and 3 columns!
      for (var r = swap.to.row - 1; r <= swap.to.row + 1; r++) {
        if (r >= 0 && r < Board.rowCount) {
          for (var c = 0; c < Board.columnCount; c++) {
            clears.add(BoardPosition(r, c));
          }
        }
      }
      for (var c = swap.to.column - 1; c <= swap.to.column + 1; c++) {
        if (c >= 0 && c < Board.columnCount) {
          for (var r = 0; r < Board.rowCount; r++) {
            clears.add(BoardPosition(r, c));
          }
        }
      }
    } else if (tileFrom.specialType == SpecialTileType.bomb &&
        tileTo.specialType == SpecialTileType.bomb) {
      // Bomb + Bomb: Clears large 5x5 area
      for (var r = swap.to.row - 2; r <= swap.to.row + 2; r++) {
        for (var c = swap.to.column - 2; c <= swap.to.column + 2; c++) {
          final p = BoardPosition(r, c);
          if (p.isValid()) {
            clears.add(p);
          }
        }
      }
    }

    events.add(
      SpecialTriggered(
        position: swap.to,
        specialType: tileTo.specialType,
        affectedPositions: clears.toList()..sort(),
      ),
    );

    return clears;
  }
}
