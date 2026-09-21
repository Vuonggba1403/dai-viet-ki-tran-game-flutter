import 'package:ezwork/battle/domain/board/board.dart';
import 'package:ezwork/battle/domain/board/board_position.dart';
import 'package:ezwork/battle/domain/board/match_group.dart';
import 'package:ezwork/battle/domain/board/special_tile_type.dart';
import 'package:ezwork/battle/domain/board/tile_type.dart';

class _RawRun {
  const _RawRun({
    required this.isHorizontal,
    required this.type,
    required this.positions,
  });

  final bool isHorizontal;
  final TileType type;
  final List<BoardPosition> positions;
}

/// Finds and classifies match groups (3, 4, 5, T/L) on a [Board].
class MatchFinder {
  const MatchFinder();

  /// Scans the entire board for valid match runs and groups overlapping runs.
  ///
  /// [preferredSpawnPosition] (typically the destination of the user's swap)
  /// is prioritized as the spawn coordinate if a special tile is generated.
  static List<MatchGroup> find(
    Board board, {
    BoardPosition? preferredSpawnPosition,
  }) {
    final rawRuns = <_RawRun>[];

    // 1. Horizontal scan (row-by-row)
    for (var r = 0; r < Board.rowCount; r++) {
      var matchStart = 0;
      while (matchStart < Board.columnCount) {
        final startTile = board.getTileAt(r, matchStart);
        if (startTile == null) {
          matchStart++;
          continue;
        }
        var matchEnd = matchStart + 1;
        while (matchEnd < Board.columnCount) {
          final nextTile = board.getTileAt(r, matchEnd);
          if (nextTile == null || nextTile.type != startTile.type) {
            break;
          }
          matchEnd++;
        }
        final length = matchEnd - matchStart;
        if (length >= 3) {
          final positions = <BoardPosition>[];
          for (var c = matchStart; c < matchEnd; c++) {
            positions.add(BoardPosition(r, c));
          }
          rawRuns.add(
            _RawRun(
              isHorizontal: true,
              type: startTile.type,
              positions: positions,
            ),
          );
        }
        matchStart = matchEnd;
      }
    }

    // 2. Vertical scan (column-by-column)
    for (var c = 0; c < Board.columnCount; c++) {
      var matchStart = 0;
      while (matchStart < Board.rowCount) {
        final startTile = board.getTileAt(matchStart, c);
        if (startTile == null) {
          matchStart++;
          continue;
        }
        var matchEnd = matchStart + 1;
        while (matchEnd < Board.rowCount) {
          final nextTile = board.getTileAt(matchEnd, c);
          if (nextTile == null || nextTile.type != startTile.type) {
            break;
          }
          matchEnd++;
        }
        final length = matchEnd - matchStart;
        if (length >= 3) {
          final positions = <BoardPosition>[];
          for (var r = matchStart; r < matchEnd; r++) {
            positions.add(BoardPosition(r, c));
          }
          rawRuns.add(
            _RawRun(
              isHorizontal: false,
              type: startTile.type,
              positions: positions,
            ),
          );
        }
        matchStart = matchEnd;
      }
    }

    if (rawRuns.isEmpty) {
      return const [];
    }

    // 3. Cluster overlapping runs of the same TileType using connected components
    final runCount = rawRuns.length;
    final parent = List.generate(runCount, (i) => i);

    int findRoot(int i) {
      var root = i;
      while (root != parent[root]) {
        root = parent[root];
      }
      var curr = i;
      while (curr != root) {
        final next = parent[curr];
        parent[curr] = root;
        curr = next;
      }
      return root;
    }

    void unionRuns(int i, int j) {
      final rootI = findRoot(i);
      final rootJ = findRoot(j);
      if (rootI != rootJ) {
        parent[rootI] = rootJ;
      }
    }

    for (var i = 0; i < runCount; i++) {
      for (var j = i + 1; j < runCount; j++) {
        if (rawRuns[i].type == rawRuns[j].type) {
          // Check if they share any tile position
          final setI = rawRuns[i].positions.toSet();
          final sharesPosition = rawRuns[j].positions.any(setI.contains);
          if (sharesPosition) {
            unionRuns(i, j);
          }
        }
      }
    }

    // Group runs by their root representative
    final clusters = <int, List<_RawRun>>{};
    for (var i = 0; i < runCount; i++) {
      final root = findRoot(i);
      clusters.putIfAbsent(root, () => []).add(rawRuns[i]);
    }

    final matchGroups = <MatchGroup>[];

    for (final cluster in clusters.values) {
      final tileType = cluster.first.type;
      final allPositions = <BoardPosition>{};
      var maxStraightLength = 0;
      var hasStraight5 = false;
      var hasHorizontal4 = false;
      var hasVertical4 = false;
      var hasHorizontalRun = false;
      var hasVerticalRun = false;
      BoardPosition? straight5Center;
      BoardPosition? line4Position;
      BoardPosition? intersectionPoint;

      for (final run in cluster) {
        allPositions.addAll(run.positions);
        if (run.isHorizontal) {
          hasHorizontalRun = true;
          if (run.positions.length >= 5) {
            hasStraight5 = true;
            straight5Center = run.positions[run.positions.length ~/ 2];
          } else if (run.positions.length == 4) {
            hasHorizontal4 = true;
            line4Position = run.positions[1];
          }
        } else {
          hasVerticalRun = true;
          if (run.positions.length >= 5) {
            hasStraight5 = true;
            straight5Center = run.positions[run.positions.length ~/ 2];
          } else if (run.positions.length == 4) {
            hasVertical4 = true;
            line4Position = run.positions[1];
          }
        }
        if (run.positions.length > maxStraightLength) {
          maxStraightLength = run.positions.length;
        }
      }

      // Check for T/L/Cross intersection
      final isTLOrCross = hasHorizontalRun && hasVerticalRun;
      if (isTLOrCross) {
        // Find intersection tile between horizontal and vertical runs
        final hPositions = <BoardPosition>{};
        final vPositions = <BoardPosition>{};
        for (final run in cluster) {
          if (run.isHorizontal) {
            hPositions.addAll(run.positions);
          } else {
            vPositions.addAll(run.positions);
          }
        }
        final intersections = hPositions.intersection(vPositions).toList()
          ..sort();
        if (intersections.isNotEmpty) {
          intersectionPoint = intersections.first;
        }
      }

      // Determine special tile type according to Section 8.3 priority:
      // 1. Match 5 thẳng -> Power Gem
      // 2. T/L -> Bomb
      // 3. Match 4 -> Line (horizontal or vertical based on run direction)
      // 4. Match 3 -> none
      var specialType = SpecialTileType.none;
      BoardPosition? specialSpawn;

      if (hasStraight5) {
        specialType = SpecialTileType.powerGem;
        specialSpawn = straight5Center;
      } else if (isTLOrCross) {
        specialType = SpecialTileType.bomb;
        specialSpawn = intersectionPoint;
      } else if (hasHorizontal4) {
        specialType = SpecialTileType.lineHorizontal;
        specialSpawn = line4Position;
      } else if (hasVertical4) {
        specialType = SpecialTileType.lineVertical;
        specialSpawn = line4Position;
      }

      // If user provided a preferred spawn position (the swap target)
      // and it belongs to this match group, override default spawn position.
      if (specialType != SpecialTileType.none) {
        if (preferredSpawnPosition != null &&
            allPositions.contains(preferredSpawnPosition)) {
          specialSpawn = preferredSpawnPosition;
        } else if (specialSpawn == null ||
            !allPositions.contains(specialSpawn)) {
          // Fallback to deterministic minimum position
          final sorted = allPositions.toList()..sort();
          specialSpawn = sorted.first;
        }
      }

      matchGroups.add(
        MatchGroup(
          tileType: tileType,
          positions: Set<BoardPosition>.unmodifiable(allPositions),
          specialCreated: specialType,
          specialSpawnPosition: specialSpawn,
        ),
      );
    }

    return List<MatchGroup>.unmodifiable(matchGroups);
  }

  /// Quick check whether any 3-in-a-row/column exists on the board.
  static bool hasAnyMatch(Board board) {
    // Check horizontal
    for (var r = 0; r < Board.rowCount; r++) {
      for (var c = 0; c < Board.columnCount - 2; c++) {
        final t1 = board.getTileAt(r, c);
        final t2 = board.getTileAt(r, c + 1);
        final t3 = board.getTileAt(r, c + 2);
        if (t1 != null && t2 != null && t3 != null) {
          if (t1.type == t2.type && t2.type == t3.type) {
            return true;
          }
        }
      }
    }
    // Check vertical
    for (var c = 0; c < Board.columnCount; c++) {
      for (var r = 0; r < Board.rowCount - 2; r++) {
        final t1 = board.getTileAt(r, c);
        final t2 = board.getTileAt(r + 1, c);
        final t3 = board.getTileAt(r + 2, c);
        if (t1 != null && t2 != null && t3 != null) {
          if (t1.type == t2.type && t2.type == t3.type) {
            return true;
          }
        }
      }
    }
    return false;
  }
}
