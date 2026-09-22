import 'package:dai_viet_ki_tran_game/battle/domain/board/board.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/board_event.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/board_position.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/board_resolver.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/match_group.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/tile.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/tile_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('immutable board outputs', () {
    test('MatchGroup copies its positions', () {
      final source = <BoardPosition>{const BoardPosition(0, 0)};
      final group = MatchGroup(tileType: TileType.fire, positions: source);

      source.add(const BoardPosition(0, 1));

      expect(group.positions, hasLength(1));
      expect(
        () => group.positions.add(const BoardPosition(0, 2)),
        throwsUnsupportedError,
      );
    });

    test('BoardEvent copies collection payloads', () {
      final positions = <BoardPosition>[const BoardPosition(0, 0)];
      final event = TilesCleared(cycle: 1, positions: positions);
      positions.add(const BoardPosition(0, 1));

      expect(event.positions, hasLength(1));
      expect(
        () => event.positions.add(const BoardPosition(0, 2)),
        throwsUnsupportedError,
      );
    });

    test('BoardResolution copies event and summary collections', () {
      final board = Board.fromList(
        List.generate(
          Board.totalTiles,
          (index) => Tile(
            id: index + 1,
            type: TileType.values[index % TileType.values.length],
          ),
        ),
      );
      final events = <BoardEvent>[];
      final summary = <TileType, int>{TileType.fire: 3};
      final resolution = BoardResolution(
        finalBoard: board,
        events: events,
        comboCount: 1,
        matchedTilesSummary: summary,
        isSuccess: true,
      );

      events.add(const CascadeStarted(1));
      summary[TileType.fire] = 99;

      expect(resolution.events, isEmpty);
      expect(resolution.matchedTilesSummary[TileType.fire], equals(3));
      expect(
        () => resolution.matchedTilesSummary[TileType.water] = 1,
        throwsUnsupportedError,
      );
    });
  });
}
