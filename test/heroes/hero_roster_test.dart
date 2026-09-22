import 'package:dai_viet_ki_tran_game/battle/domain/board/tile_type.dart';
import 'package:dai_viet_ki_tran_game/heroes/heroes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HeroRoster', () {
    final mockHeroes = [
      const HeroRosterItemViewModel(
        id: 'dinh_bo_linh',
        name: 'Đinh Bộ Lĩnh',
        rank: 'S',
        element: TileType.fire,
        heroClass: 'commander',
        assetKey: 'heroes/assassin',
        portraitPath: 'assets/images/heroes/assassin/idle_front.png',
      ),
      const HeroRosterItemViewModel(
        id: 'nguyen_bac',
        name: 'Nguyễn Bặc',
        rank: 'A',
        element: TileType.sword,
        heroClass: 'warrior',
        assetKey: 'heroes/swordsman',
        portraitPath: 'assets/images/heroes/swordsman/idle_front.png',
      ),
      const HeroRosterItemViewModel(
        id: 'dinh_dien',
        name: 'Đinh Điền',
        rank: 'B',
        element: TileType.lightning,
        heroClass: 'berserker',
        assetKey: 'heroes/monk',
        portraitPath: 'assets/images/heroes/monk/idle_front.png',
      ),
      const HeroRosterItemViewModel(
        id: 'luu_co',
        name: 'Lưu Cơ',
        rank: 'B',
        element: TileType.water,
        heroClass: 'strategist',
        assetKey: 'heroes/strategist',
        portraitPath: 'assets/images/heroes/strategist/idle_front.png',
      ),
    ];

    testWidgets('renders 4 hero cards in 2-column grid with ranks and names', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeroesPage(initialHeroes: mockHeroes),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(HeroCard), findsNWidgets(4));
      expect(find.text('TƯỚNG (4 / 15)'), findsOneWidget);
      expect(find.text('Đinh Bộ Lĩnh'), findsOneWidget);
      expect(find.text('Nguyễn Bặc'), findsOneWidget);
      expect(find.text('Đinh Điền'), findsOneWidget);
      expect(find.text('Lưu Cơ'), findsOneWidget);
      expect(find.text('S'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('tapping hero card triggers selection state', (tester) async {
      HeroRosterItemViewModel? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeroesPage(
              initialHeroes: mockHeroes,
              onSelectHero: (h) => selected = h,
            ),
          ),
        ),
      );
      await tester.pump();

      final firstHeroCard = find.byKey(const Key('hero_card_dinh_bo_linh'));
      expect(firstHeroCard, findsOneWidget);

      await tester.tap(firstHeroCard);
      await tester.pump();

      expect(selected?.id, equals('dinh_bo_linh'));
    });

    testWidgets('renders fallback icon gracefully when portrait is missing', (
      tester,
    ) async {
      final invalidHero = [
        const HeroRosterItemViewModel(
          id: 'unknown',
          name: 'Ẩn Danh',
          rank: 'C',
          element: TileType.sword,
          heroClass: 'warrior',
          assetKey: 'unknown/path',
          portraitPath: 'assets/images/non_existent.png',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeroesPage(initialHeroes: invalidHero),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
      expect(find.text('Ẩn Danh'), findsOneWidget);
    });
  });
}
