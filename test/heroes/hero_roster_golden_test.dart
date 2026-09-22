import 'package:dai_viet_ki_tran_game/battle/domain/board/tile_type.dart';
import 'package:dai_viet_ki_tran_game/heroes/heroes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HeroRoster Golden Tests', () {
    final mockHeroes = [
      const HeroRosterItemViewModel(
        id: 'dinh_bo_linh',
        name: 'Đinh Bộ Lĩnh',
        rank: 'S',
        element: TileType.fire,
        heroClass: 'commander',
        assetKey: 'heroes/assassin',
        portraitPath: 'assets/images/heroes/assassin/idle_front.png',
        power: 1810,
      ),
      const HeroRosterItemViewModel(
        id: 'nguyen_bac',
        name: 'Nguyễn Bặc',
        rank: 'A',
        element: TileType.sword,
        heroClass: 'warrior',
        assetKey: 'heroes/swordsman',
        portraitPath: 'assets/images/heroes/swordsman/idle_front.png',
        power: 2110,
      ),
      const HeroRosterItemViewModel(
        id: 'dinh_dien',
        name: 'Đinh Điền',
        rank: 'B',
        element: TileType.lightning,
        heroClass: 'berserker',
        assetKey: 'heroes/monk',
        portraitPath: 'assets/images/heroes/monk/idle_front.png',
        power: 1750,
      ),
      const HeroRosterItemViewModel(
        id: 'luu_co',
        name: 'Lưu Cơ',
        rank: 'B',
        element: TileType.water,
        heroClass: 'strategist',
        assetKey: 'heroes/strategist',
        portraitPath: 'assets/images/heroes/strategist/idle_front.png',
        power: 1540,
      ),
    ];

    Future<void> renderRoster(WidgetTester tester, Size size) async {
      tester.view.physicalSize = Size(size.width * 2.0, size.height * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            backgroundColor: const Color(0xFF141224),
            body: SafeArea(
              child: HeroesPage(initialHeroes: mockHeroes),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('Hero Roster matches golden at 320x568', (tester) async {
      await renderRoster(tester, const Size(320, 568));
      await expectLater(
        find.byType(HeroesPage),
        matchesGoldenFile('goldens/hero_roster_320x568.png'),
      );
    });

    testWidgets('Hero Roster matches golden at 390x844', (tester) async {
      await renderRoster(tester, const Size(390, 844));
      await expectLater(
        find.byType(HeroesPage),
        matchesGoldenFile('goldens/hero_roster_390x844.png'),
      );
    });
  });
}
