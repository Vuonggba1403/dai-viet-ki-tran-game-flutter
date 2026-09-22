import 'dart:ui';

import 'package:dai_viet_ki_tran_game/battle/domain/board/special_tile_type.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/tile.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/tile_type.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/game/components/tile_component.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart' hide MatchFinder;

void main() {
  group('TileComponent', () {
    test('initializes properties correctly', () {
      const tile = Tile(id: 42, type: TileType.fire);
      final comp = TileComponent(
        tileId: 42,
        initialTile: tile,
        position: Vector2(100, 100),
        size: Vector2(40, 40),
      );

      expect(comp.tileId, equals(42));
      expect(comp.tile, equals(tile));
      expect(comp.position, equals(Vector2(100, 100)));
      expect(comp.size, equals(Vector2(40, 40)));
    });

    test('updateTile updates domain tile and special status', () {
      const tile = Tile(id: 1, type: TileType.water);
      final comp = TileComponent(
        tileId: 1,
        initialTile: tile,
        position: Vector2.zero(),
        size: Vector2.all(30),
      );

      const specialTile = Tile(
        id: 1,
        type: TileType.water,
        specialType: SpecialTileType.bomb,
      );
      comp.tile = specialTile;

      expect(comp.tile.specialType, equals(SpecialTileType.bomb));
      expect(comp.tile.isSpecial, isTrue);
    });

    test('renders standard and special tiles without errors', () {
      for (final type in TileType.values) {
        final comp = TileComponent(
          tileId: 1,
          initialTile: Tile(id: 1, type: type),
          position: Vector2.zero(),
          size: Vector2.all(40),
        );
        final recorder = PictureRecorder();
        final canvas = Canvas(recorder);
        expect(() => comp.render(canvas), returnsNormally);
      }

      for (final special in SpecialTileType.values) {
        final comp = TileComponent(
          tileId: 2,
          initialTile: Tile(id: 2, type: TileType.fire, specialType: special),
          position: Vector2.zero(),
          size: Vector2.all(40),
        );
        final recorder = PictureRecorder();
        final canvas = Canvas(recorder);
        expect(() => comp.render(canvas), returnsNormally);
      }
    });

    test('moveTo moves immediately when duration is zero', () {
      const tile = Tile(id: 10, type: TileType.sword);
      final comp = TileComponent(
        tileId: 10,
        initialTile: tile,
        position: Vector2.zero(),
        size: Vector2.all(40),
      );

      var completed = false;
      comp.moveTo(
        Vector2(50, 50),
        duration: 0,
        onComplete: () => completed = true,
      );

      expect(comp.position, equals(Vector2(50, 50)));
      expect(completed, isTrue);
    });
  });
}
