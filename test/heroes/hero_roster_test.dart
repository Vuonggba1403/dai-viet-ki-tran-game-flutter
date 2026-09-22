import 'package:dai_viet_ki_tran_game/app/di/dependencies.dart';
import 'package:dai_viet_ki_tran_game/battle/data/data_sources/local_battle_content_data_source.dart';
import 'package:dai_viet_ki_tran_game/battle/data/models/battle_balance_definition.dart';
import 'package:dai_viet_ki_tran_game/battle/data/models/battle_content.dart';
import 'package:dai_viet_ki_tran_game/battle/data/models/hero_definition.dart';
import 'package:dai_viet_ki_tran_game/battle/data/repositories/battle_content_repository.dart';
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

    testWidgets(
      'shows roster error view with retry button on error and recovers on retry',
      (tester) async {
        final mockRepo = _FailingBattleContentRepository();
        if (getIt.isRegistered<BattleContentRepository>()) {
          getIt.unregister<BattleContentRepository>();
        }
        getIt.registerSingleton<BattleContentRepository>(mockRepo);
        addTearDown(() {
          if (getIt.isRegistered<BattleContentRepository>()) {
            getIt.unregister<BattleContentRepository>();
          }
        });

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: HeroesPage(),
            ),
          ),
        );
        await tester.pump();

        expect(find.byKey(const Key('roster_error_view')), findsOneWidget);
        expect(
          find.text('Không thể tải danh sách tướng. Vui lòng thử lại.'),
          findsOneWidget,
        );
        expect(find.byKey(const Key('roster_retry_button')), findsOneWidget);

        // Fix repository failure and tap retry
        mockRepo.shouldFail = false;
        await tester.tap(find.byKey(const Key('roster_retry_button')));
        await tester.pump();

        expect(find.byKey(const Key('roster_error_view')), findsNothing);
        expect(find.byType(HeroCard), findsOneWidget);
      },
    );
  });
}

class _FailingBattleContentRepository extends BattleContentRepository {
  _FailingBattleContentRepository()
    : super(localDataSource: _DummyDataSource());

  bool shouldFail = true;

  @override
  Future<BattleContent> getBattleContent({
    bool forceRefresh = false,
    BattleBalanceDefinition? customBalance,
  }) async {
    if (shouldFail) {
      throw StateError('Failed to fetch battle content');
    }
    return const BattleContent(
      heroes: [
        HeroDefinition(
          id: 'dinh_bo_linh',
          nameKey: 'hero_dinh_bo_linh',
          element: TileType.fire,
          heroClass: 'commander',
          baseHp: 1200,
          baseAttack: 150,
          baseDefense: 80,
          maxMana: 100,
          startingMana: 20,
          activeSkillId: 'skill_hoa_long_quyet',
          assetKey: 'heroes/assassin',
          rank: 'S',
          power: 1810,
        ),
      ],
      skills: [],
      enemies: [],
      stages: [],
    );
  }
}

class _DummyDataSource implements LocalBattleContentDataSource {
  @override
  Future<List<dynamic>> loadHeroesJson() async => [];
  @override
  Future<List<dynamic>> loadSkillsJson() async => [];
  @override
  Future<List<dynamic>> loadEnemiesJson() async => [];
  @override
  Future<List<dynamic>> loadStagesJson() async => [];
}
