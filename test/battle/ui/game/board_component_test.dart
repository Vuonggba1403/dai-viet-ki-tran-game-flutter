import 'package:dai_viet_ki_tran_game/battle/domain/board/board_generator.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/board_position.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/tile.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/tile_type.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/random/seeded_random.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/game/battle_game_config.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/game/components/board_component.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/game/components/tile_component.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart' hide MatchFinder;

void main() {
  group('BoardComponent', () {
    late BoardComponent component;
    const config = BattleGameConfig(
      boardPadding: 10,
    );

    setUp(() {
      component = BoardComponent(
        config: config,
        size: Vector2(350, 350),
      )..onGameResize(Vector2(350, 350));
    });

    test('calculates correct tileSize and centered offsets', () {
      expect(component.tileSize, greaterThan(0));
      const totalSpacing = 6 * 4.0;
      const expectedTileSize = (330.0 - totalSpacing) / 7;
      expect(component.tileSize, closeTo(expectedTileSize, 0.001));
    });

    test('positionFor returns distinct coordinates for adjacent positions', () {
      final pos00 = component.positionFor(const BoardPosition(0, 0));
      final pos01 = component.positionFor(const BoardPosition(0, 1));
      final pos10 = component.positionFor(const BoardPosition(1, 0));

      expect(pos01.x, greaterThan(pos00.x));
      expect(pos01.y, equals(pos00.y));

      expect(pos10.y, greaterThan(pos00.y));
      expect(pos10.x, equals(pos00.x));
    });

    test('boardPositionFor converts pixel position back to BoardPosition', () {
      final center00 = component.positionFor(const BoardPosition(0, 0));
      final boardPos = component.boardPositionFor(center00);
      expect(boardPos, equals(const BoardPosition(0, 0)));

      final center34 = component.positionFor(const BoardPosition(3, 4));
      expect(
        component.boardPositionFor(center34),
        equals(const BoardPosition(3, 4)),
      );
    });

    test('boardPositionFor returns null for out of bounds coordinates', () {
      expect(component.boardPositionFor(Vector2(-10, -10)), isNull);
      expect(component.boardPositionFor(Vector2(400, 400)), isNull);
    });

    test('initTiles populates all 49 tiles tracked by tileId', () {
      final board = BoardGenerator.generate(SeededRandom(123));
      component.initTiles(board);

      expect(component.tilesById.length, equals(49));
      for (var r = 0; r < 7; r++) {
        for (var c = 0; c < 7; c++) {
          final domainTile = board.getTileAt(r, c)!;
          final comp = component.getTile(domainTile.id);
          expect(comp, isNotNull);
          expect(comp!.tileId, equals(domainTile.id));
          expect(comp.tile, equals(domainTile));
        }
      }
    });

    test('addTile and removeTile manage tilesById dictionary', () {
      const tile = Tile(id: 999, type: TileType.fire);
      final tileComp = TileComponent(
        tileId: 999,
        initialTile: tile,
        position: Vector2.zero(),
        size: Vector2.all(40),
      );

      component.addTile(tileComp);
      expect(component.getTile(999), equals(tileComp));

      component.removeTile(999);
      expect(component.getTile(999), isNull);
    });

    test(
      'relayoutTiles updates position and size of all existing components',
      () {
        final domainBoard = BoardGenerator.generate(SeededRandom(123));
        component.initTiles(domainBoard);

        final initialTile = component.tilesById.values.first;
        final initialSize = initialTile.size.x;
        final initialPos = initialTile.position.clone();

        // Resize board to different aspect ratio
        component
          ..size = Vector2(500, 700)
          ..relayoutTiles(domainBoard);

        // Tile size and position must adapt to new board dimensions
        expect(initialTile.size.x, isNot(equals(initialSize)));
        expect(initialTile.position, isNot(equals(initialPos)));

        // Every tile must match its newly computed position
        for (var r = 0; r < 7; r++) {
          for (var c = 0; c < 7; c++) {
            final pos = BoardPosition(r, c);
            final tile = domainBoard.getTileAt(r, c)!;
            final comp = component.getTile(tile.id)!;
            final expectedPos = component.positionFor(pos);
            expect(comp.position.x, closeTo(expectedPos.x, 0.001));
            expect(comp.position.y, closeTo(expectedPos.y, 0.001));
            expect(comp.size.x, closeTo(component.tileSize, 0.001));
            expect(comp.size.y, closeTo(component.tileSize, 0.001));
          }
        }
      },
    );

    test(
      'maintains layout invariants across various iOS and Android screen resolutions',
      () {
        final domainBoard = BoardGenerator.generate(SeededRandom(999));
        final screenSizes = <String, Vector2>{
          'iPhone SE 1st gen (compact)': Vector2(320, 568),
          'iPhone SE 3rd gen (4.7")': Vector2(375, 667),
          'iPhone 13 / 14 / 15 (6.1")': Vector2(390, 844),
          'iPhone 15 Pro / 16 Pro': Vector2(393, 852),
          'iPhone 14 / 15 Plus (6.7")': Vector2(428, 926),
          'iPhone 15 / 16 Pro Max': Vector2(430, 932),
          'Android Budget (HD+)': Vector2(360, 640),
          'Android Galaxy S21/S22/S23': Vector2(360, 780),
          'Android Pixel 6/7/8': Vector2(412, 915),
          'Android Galaxy S24 Ultra': Vector2(412, 892),
          'Android Ultra-tall (21:9)': Vector2(384, 854),
          'Foldable (Galaxy Z Fold unfolded)': Vector2(673, 841),
          'Tablet iPad Mini': Vector2(744, 1133),
          'Tablet iPad 10.9"': Vector2(820, 1180),
          'Tablet iPad Pro 12.9"': Vector2(1024, 1366),
          'Landscape iPhone 14': Vector2(844, 390),
          'Landscape Android S24': Vector2(892, 412),
          'Landscape iPad': Vector2(1180, 820),
        };

        for (final entry in screenSizes.entries) {
          final label = entry.key;
          final size = entry.value;

          component
            ..size = size
            ..onGameResize(size)
            ..relayoutTiles(domainBoard);

          expect(
            component.tileSize,
            greaterThan(20.0),
            reason: 'Tile size too small on $label',
          );

          // All 49 board positions must stay strictly within bounds
          for (var r = 0; r < 7; r++) {
            for (var c = 0; c < 7; c++) {
              final pos = BoardPosition(r, c);
              final center = component.positionFor(pos);

              expect(
                center.x,
                greaterThan(0),
                reason: 'Tile ($r, $c) out of left bound on $label',
              );
              expect(
                center.x,
                lessThan(size.x),
                reason: 'Tile ($r, $c) out of right bound on $label',
              );
              expect(
                center.y,
                greaterThan(0),
                reason: 'Tile ($r, $c) out of top bound on $label',
              );
              expect(
                center.y,
                lessThan(size.y),
                reason: 'Tile ($r, $c) out of bottom bound on $label',
              );

              // 2-way coordinate mapping must be exact
              final mappedBack = component.boardPositionFor(center);
              expect(
                mappedBack,
                equals(pos),
                reason: 'Coordinate round-trip failed at ($r, $c) on $label',
              );
            }
          }
        }
      },
    );
  });
}
