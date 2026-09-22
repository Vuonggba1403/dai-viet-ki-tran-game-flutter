import 'package:dai_viet_ki_tran_game/battle/domain/board/special_tile_type.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/tile.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/tile_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Tile', () {
    test('instantiates with default specialType none', () {
      const tile = Tile(id: 42, type: TileType.sword);
      expect(tile.id, equals(42));
      expect(tile.type, equals(TileType.sword));
      expect(tile.specialType, equals(SpecialTileType.none));
      expect(tile.isSpecial, isFalse);
    });

    test('special tile returns isSpecial true', () {
      const tile = Tile(
        id: 1,
        type: TileType.fire,
        specialType: SpecialTileType.bomb,
      );
      expect(tile.isSpecial, isTrue);
    });

    test('copyWith updates properties correctly', () {
      const tile = Tile(id: 1, type: TileType.water);
      final updated = tile.copyWith(
        type: TileType.lightning,
        specialType: SpecialTileType.lineHorizontal,
      );

      expect(updated.id, equals(1));
      expect(updated.type, equals(TileType.lightning));
      expect(updated.specialType, equals(SpecialTileType.lineHorizontal));
    });

    test('equality and hashCode match identical values', () {
      const tile1 = Tile(id: 5, type: TileType.heart);
      const tile2 = Tile(id: 5, type: TileType.heart);
      const tile3 = Tile(id: 6, type: TileType.heart);

      expect(tile1, equals(tile2));
      expect(tile1.hashCode, equals(tile2.hashCode));
      expect(tile1, isNot(equals(tile3)));
    });
  });

  group('TileType', () {
    test('5 standard types are present', () {
      expect(
        TileType.values,
        containsAll([
          TileType.sword,
          TileType.fire,
          TileType.water,
          TileType.lightning,
          TileType.heart,
        ]),
      );
      expect(TileType.values.length, equals(5));
    });

    test('elemental relations: Fire > Lightning > Water > Fire', () {
      // Advantage (1.5)
      expect(
        TileType.fire.getElementMultiplier(TileType.lightning),
        equals(1.5),
      );
      expect(
        TileType.lightning.getElementMultiplier(TileType.water),
        equals(1.5),
      );
      expect(TileType.water.getElementMultiplier(TileType.fire), equals(1.5));

      // Disadvantage (0.75)
      expect(
        TileType.lightning.getElementMultiplier(TileType.fire),
        equals(0.75),
      );
      expect(
        TileType.water.getElementMultiplier(TileType.lightning),
        equals(0.75),
      );
      expect(TileType.fire.getElementMultiplier(TileType.water), equals(0.75));

      // Neutral (1.0)
      expect(TileType.fire.getElementMultiplier(TileType.fire), equals(1.0));
      expect(TileType.sword.getElementMultiplier(TileType.fire), equals(1.0));
      expect(TileType.heart.getElementMultiplier(TileType.water), equals(1.0));
      expect(TileType.fire.getElementMultiplier(TileType.sword), equals(1.0));
    });
  });
}
