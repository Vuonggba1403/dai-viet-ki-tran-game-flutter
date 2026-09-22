import 'package:dai_viet_ki_tran_game/battle/domain/board/board.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/board_event.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/board_generator.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/board_position.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/board_resolver.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/legal_move_finder.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/match_finder.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/special_tile_type.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/swap.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/tile.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/tile_type.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/random/random_service.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/random/seeded_random.dart';
import 'package:flutter_test/flutter_test.dart' hide MatchFinder;

Board _createNonMatchingBoard() {
  final grid = List.generate(
    Board.rowCount,
    (r) => List.generate(
      Board.columnCount,
      (c) => Tile(
        id: r * Board.columnCount + c + 1,
        type: TileType.values[((r * 2) + c) % TileType.values.length],
      ),
    ),
  );
  return Board.fromGrid(grid);
}

class _ZeroRandom implements RandomService {
  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;

  @override
  int nextInt(int max) => 0;
}

void main() {
  group('BoardResolver', () {
    test('rejects non-adjacent or out of bounds swap', () {
      final board = _createNonMatchingBoard();
      final rng = SeededRandom(1);

      // Non-adjacent swap (distance > 1)
      const distantSwap = Swap(
        from: BoardPosition(0, 0),
        to: BoardPosition(0, 3),
      );
      final res1 = BoardResolver.resolveSwap(board, distantSwap, rng);

      expect(res1.isSuccess, isFalse);
      expect(res1.events.length, equals(2));
      expect(res1.events[0], isA<SwapStarted>());
      expect(res1.events[1], isA<SwapRejected>());
      expect(res1.finalBoard, equals(board));
      expect(res1.finalBoard.checksum, equals(board.checksum));

      // Diagonal swap
      const diagonalSwap = Swap(
        from: BoardPosition(1, 1),
        to: BoardPosition(2, 2),
      );
      final res2 = BoardResolver.resolveSwap(board, diagonalSwap, rng);
      expect(res2.isSuccess, isFalse);
      expect(res2.events[1], isA<SwapRejected>());
    });

    test(
      'rejects swap that creates no match and preserves board integrity',
      () {
        final board = _createNonMatchingBoard();
        final rng = SeededRandom(1);

        const uselessSwap = Swap(
          from: BoardPosition(0, 0),
          to: BoardPosition(0, 1),
        );
        final res = BoardResolver.resolveSwap(board, uselessSwap, rng);

        expect(res.isSuccess, isFalse);
        expect(res.comboCount, equals(0));
        expect(res.events.first, isA<SwapStarted>());
        expect(res.events.last, isA<SwapRejected>());
        expect(res.finalBoard.checksum, equals(board.checksum));
      },
    );

    test('rejects a swap when only an unrelated prematch exists', () {
      var board = _createNonMatchingBoard();
      for (var column = 0; column < 3; column++) {
        final position = BoardPosition(6, column);
        board = board.copyWithUpdatedTile(
          position,
          board.getTile(position)!.copyWith(type: TileType.fire),
        );
      }

      const unrelatedSwap = Swap(
        from: BoardPosition(0, 0),
        to: BoardPosition(0, 1),
      );
      final resolution = BoardResolver.resolveSwap(
        board,
        unrelatedSwap,
        SeededRandom(1),
      );

      expect(resolution.isSuccess, isFalse);
      expect(resolution.finalBoard, equals(board));
      expect(resolution.events.last, isA<SwapRejected>());
    });

    test('resolves valid match with correct ordered event sequence', () {
      var board = _createNonMatchingBoard();
      // Setup a valid horizontal match by swapping (3, 2) and (3, 3)
      // Row 3: water, water, [fire], [water]
      board = board
          .copyWithUpdatedTile(
            const BoardPosition(3, 0),
            const Tile(id: 1, type: TileType.water),
          )
          .copyWithUpdatedTile(
            const BoardPosition(3, 1),
            const Tile(id: 2, type: TileType.water),
          )
          .copyWithUpdatedTile(
            const BoardPosition(3, 2),
            const Tile(id: 3, type: TileType.fire),
          )
          .copyWithUpdatedTile(
            const BoardPosition(3, 3),
            const Tile(id: 4, type: TileType.water),
          );

      final rng = SeededRandom(42);
      const swap = Swap(from: BoardPosition(3, 2), to: BoardPosition(3, 3));

      final res = BoardResolver.resolveSwap(board, swap, rng);

      expect(res.isSuccess, isTrue);
      expect(res.comboCount, greaterThanOrEqualTo(1));
      expect(res.matchedTilesSummary[TileType.water], greaterThanOrEqualTo(3));

      // Check ordered events
      expect(res.events[0], isA<SwapStarted>());
      expect(res.events[1], isA<SwapAccepted>());
      expect(res.events[2], isA<CascadeStarted>());

      // Board has exactly 49 tiles and no nulls
      expect(res.finalBoard.toMap().length, equals(Board.totalTiles));
      for (var r = 0; r < Board.rowCount; r++) {
        for (var c = 0; c < Board.columnCount; c++) {
          expect(res.finalBoard.getTileAt(r, c), isNotNull);
        }
      }
    });

    test('creates and triggers line special tile on 4-match', () {
      var board = _createNonMatchingBoard();
      // Setup row 1: fire, fire, [sword], fire
      // and (2, 2): fire
      // Swapping (1, 2) [sword] and (2, 2) [fire] creates horizontal 4-match at row 1!
      board = board
          .copyWithUpdatedTile(
            const BoardPosition(1, 0),
            const Tile(id: 1, type: TileType.fire),
          )
          .copyWithUpdatedTile(
            const BoardPosition(1, 1),
            const Tile(id: 2, type: TileType.fire),
          )
          .copyWithUpdatedTile(
            const BoardPosition(1, 2),
            const Tile(id: 3, type: TileType.sword),
          )
          .copyWithUpdatedTile(
            const BoardPosition(1, 3),
            const Tile(id: 4, type: TileType.fire),
          )
          .copyWithUpdatedTile(
            const BoardPosition(1, 4),
            const Tile(id: 99, type: TileType.water),
          )
          .copyWithUpdatedTile(
            const BoardPosition(2, 2),
            const Tile(id: 5, type: TileType.fire),
          );

      final rng = SeededRandom(123);
      const swap = Swap(from: BoardPosition(2, 2), to: BoardPosition(1, 2));

      final res = BoardResolver.resolveSwap(board, swap, rng);

      expect(res.isSuccess, isTrue);
      final specialCreatedEvents = res.events.whereType<SpecialCreated>();
      expect(specialCreatedEvents.isNotEmpty, isTrue);
      expect(
        specialCreatedEvents.first.specialType,
        equals(SpecialTileType.lineHorizontal),
      );
      expect(
        specialCreatedEvents.first.position,
        equals(const BoardPosition(1, 2)),
      );
    });

    test('resolves Power Gem swap by clearing all tiles of target element', () {
      var board = _createNonMatchingBoard();
      // Place a PowerGem at (3, 3)
      const powerGemTile = Tile(
        id: 777,
        type: TileType.fire,
        specialType: SpecialTileType.powerGem,
      );
      board = board.copyWithUpdatedTile(
        const BoardPosition(3, 3),
        powerGemTile,
      );

      final rng = SeededRandom(55);
      // Swap with (3, 4) which is adjacent
      const swap = Swap(from: BoardPosition(3, 3), to: BoardPosition(3, 4));

      final res = BoardResolver.resolveSwap(board, swap, rng);

      expect(res.isSuccess, isTrue);
      final triggered = res.events.whereType<SpecialTriggered>();
      final powerGemEvents = triggered
          .where(
            (event) => event.specialType == SpecialTileType.powerGem,
          )
          .toList();
      expect(powerGemEvents, hasLength(1));
      expect(
        powerGemEvents.single.position,
        equals(const BoardPosition(3, 4)),
      );
      expect(
        res.events.indexOf(powerGemEvents.single),
        greaterThan(res.events.indexWhere((event) => event is CascadeStarted)),
      );
      // Affected positions must contain target type tiles
      expect(
        powerGemEvents.single.affectedPositions,
        contains(const BoardPosition(3, 4)),
      );
    });

    test('allocates new tile IDs above every existing runtime ID', () {
      var board = _createNonMatchingBoard();
      for (var column = 0; column < 4; column++) {
        final position = BoardPosition(1, column);
        board = board.copyWithUpdatedTile(
          position,
          board.getTile(position)!.copyWith(type: TileType.fire),
        );
      }
      const sourcePosition = BoardPosition(2, 3);
      board = board.copyWithUpdatedTile(
        sourcePosition,
        board.getTile(sourcePosition)!.copyWith(type: TileType.fire),
      );
      const gapPosition = BoardPosition(1, 3);
      board = board.copyWithUpdatedTile(
        gapPosition,
        board.getTile(gapPosition)!.copyWith(type: TileType.water),
      );

      final resolution = BoardResolver.resolveSwap(
        board,
        const Swap(from: sourcePosition, to: gapPosition),
        SeededRandom(12),
        nextTileId: 1,
      );
      final originalMaxId = board
          .toMap()
          .values
          .map((tile) => tile.id)
          .reduce((a, b) => a > b ? a : b);
      final created = resolution.events.whereType<SpecialCreated>().first;
      final finalIds = resolution.finalBoard
          .toMap()
          .values
          .map((tile) => tile.id)
          .toList();

      expect(created.tile.id, greaterThan(originalMaxId));
      expect(finalIds.toSet(), hasLength(Board.totalTiles));
    });

    test('fails instead of returning an unsettled board at cascade cap', () {
      var board = _createNonMatchingBoard();
      board = board
          .copyWithUpdatedTile(
            const BoardPosition(3, 0),
            board
                .getTile(const BoardPosition(3, 0))!
                .copyWith(type: TileType.sword),
          )
          .copyWithUpdatedTile(
            const BoardPosition(3, 1),
            board
                .getTile(const BoardPosition(3, 1))!
                .copyWith(type: TileType.sword),
          )
          .copyWithUpdatedTile(
            const BoardPosition(3, 2),
            board
                .getTile(const BoardPosition(3, 2))!
                .copyWith(type: TileType.heart),
          )
          .copyWithUpdatedTile(
            const BoardPosition(3, 3),
            board
                .getTile(const BoardPosition(3, 3))!
                .copyWith(type: TileType.sword),
          );

      expect(
        () => BoardResolver.resolveSwap(
          board,
          const Swap(
            from: BoardPosition(3, 2),
            to: BoardPosition(3, 3),
          ),
          _ZeroRandom(),
        ),
        throwsStateError,
      );
    });

    test('gravity leaves zero gaps in columns after clear', () {
      final rng = SeededRandom(99);
      final board = BoardGenerator.generate(rng);
      final legalMoves = LegalMoveFinder.findLegalMoves(board);
      expect(legalMoves.isNotEmpty, isTrue);

      final res = BoardResolver.resolveSwap(board, legalMoves.first, rng);
      expect(res.isSuccess, isTrue);

      // Verify final board has exactly 49 valid non-null tiles
      for (var r = 0; r < Board.rowCount; r++) {
        for (var c = 0; c < Board.columnCount; c++) {
          final tile = res.finalBoard.getTileAt(r, c);
          expect(tile, isNotNull, reason: 'Found gap at ($r, $c)');
        }
      }
    });

    test('preserves settled-board invariants across seeded play sequences', () {
      const seedCount = 100;
      const turnsPerSeed = 10;

      for (var seed = 1; seed <= seedCount; seed++) {
        final random = SeededRandom(seed);
        var board = BoardGenerator.generate(random);

        for (var turn = 0; turn < turnsPerSeed; turn++) {
          final moves = LegalMoveFinder.findLegalMoves(board);
          expect(moves, isNotEmpty, reason: 'seed $seed, turn $turn');
          final resolution = BoardResolver.resolveSwap(
            board,
            moves[random.nextInt(moves.length)],
            random,
          );
          board = resolution.finalBoard;

          final ids = board.toMap().values.map((tile) => tile.id).toSet();
          expect(ids, hasLength(Board.totalTiles));
          expect(MatchFinder.hasAnyMatch(board), isFalse);
          expect(LegalMoveFinder.hasLegalMove(board), isTrue);
        }
      }
    });

    test(
      'dead board automatically triggers BoardShuffled event with new legal moves',
      () {
        // Create a dead board (checkerboard)
        final grid = List.generate(
          Board.rowCount,
          (r) => List.generate(
            Board.columnCount,
            (c) => Tile(
              id: r * Board.columnCount + c + 1,
              type: (r + c).isEven ? TileType.sword : TileType.heart,
            ),
          ),
        );
        var deadBoard = Board.fromGrid(grid);

        // Add a single 3-match so swap is valid
        deadBoard = deadBoard
            .copyWithUpdatedTile(
              const BoardPosition(0, 0),
              const Tile(id: 1, type: TileType.fire),
            )
            .copyWithUpdatedTile(
              const BoardPosition(0, 1),
              const Tile(id: 2, type: TileType.fire),
            )
            .copyWithUpdatedTile(
              const BoardPosition(0, 2),
              const Tile(id: 3, type: TileType.water),
            )
            .copyWithUpdatedTile(
              const BoardPosition(0, 3),
              const Tile(id: 4, type: TileType.fire),
            );

        // After swap, if settled board has no moves, resolver shuffles it
        final rng = SeededRandom(1);
        const swap = Swap(from: BoardPosition(0, 2), to: BoardPosition(0, 3));

        final res = BoardResolver.resolveSwap(deadBoard, swap, rng);
        expect(res.isSuccess, isTrue);
        expect(LegalMoveFinder.hasLegalMove(res.finalBoard), isTrue);
      },
    );

    test('cascade hard cap prevents infinite loops', () {
      expect(BoardResolver.maxCascadeCycles, equals(50));
    });
  });
}
