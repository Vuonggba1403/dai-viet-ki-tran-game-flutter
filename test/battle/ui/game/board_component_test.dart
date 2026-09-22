import 'package:ezwork/battle/domain/board/board_generator.dart';
import 'package:ezwork/battle/domain/board/board_position.dart';
import 'package:ezwork/battle/domain/board/tile.dart';
import 'package:ezwork/battle/domain/board/tile_type.dart';
import 'package:ezwork/battle/domain/random/seeded_random.dart';
import 'package:ezwork/battle/ui/game/battle_game_config.dart';
import 'package:ezwork/battle/ui/game/components/board_component.dart';
import 'package:ezwork/battle/ui/game/components/tile_component.dart';
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
      expect(component.boardPositionFor(center34),
          equals(const BoardPosition(3, 4)));
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
  });
}
