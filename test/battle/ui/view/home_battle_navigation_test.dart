import 'package:dai_viet_ki_tran_game/app/di/dependencies.dart';
import 'package:dai_viet_ki_tran_game/app/ui/view/navigation.dart';
import 'package:dai_viet_ki_tran_game/battle/data/data_sources/local_battle_content_data_source.dart';
import 'package:dai_viet_ki_tran_game/battle/data/repositories/battle_content_repository.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/cubit/battle_session_cubit.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/view/battle_page.dart';
import 'package:dai_viet_ki_tran_game/home/ui/view/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' hide MatchFinder;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Home to Battle Navigation', () {
    setUp(() {
      final repository = BattleContentRepository(
        localDataSource: const _InMemoryBattleDataSource(),
      );
      getIt
        ..registerSingleton<BattleContentRepository>(repository)
        ..registerFactory(
          () => BattleSessionCubit(
            contentRepository: repository,
            initialSeed: 42,
          ),
        );
    });

    tearDown(() async {
      await getIt.reset();
    });

    Future<void> pumpHome(WidgetTester tester) async {
      router.go('/home');
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        if (find
            .byKey(const Key('enter_battle_button'))
            .evaluate()
            .isNotEmpty) {
          break;
        }
      }
    }

    testWidgets(
      'starts on HomePage without authentication redirect and has /home URI',
      (
        tester,
      ) async {
        await pumpHome(tester);

        expect(find.byType(HomePage), findsOneWidget);
        expect(find.byKey(const Key('enter_battle_button')), findsOneWidget);
        expect(router.state.uri.toString(), equals('/home'));
      },
    );

    testWidgets(
      'router navigates to BattlePage via named route with queryParameters',
      (
        tester,
      ) async {
        await pumpHome(tester);
        router.goNamed(
          BattlePage.routeName,
          queryParameters: const {'stageId': 'stage_1'},
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        expect(find.byType(BattlePage), findsOneWidget);
        expect(router.state.uri.toString(), equals('/battle?stageId=stage_1'));
      },
    );

    testWidgets(
      'tapping enter battle button pushes BattlePage with URL /battle?stageId=stage_1',
      (
        tester,
      ) async {
        await pumpHome(tester);

        expect(find.byKey(const Key('enter_battle_button')), findsOneWidget);
        await tester.tap(find.byKey(const Key('enter_battle_button')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        expect(find.byType(BattlePage), findsOneWidget);
        expect(router.state.uri.toString(), equals('/battle?stageId=stage_1'));
      },
    );

    testWidgets(
      'reload / direct navigation to /battle?stageId=stage_2 restores BattlePage with correct stageId',
      (
        tester,
      ) async {
        router.go('/battle?stageId=stage_2');
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        for (var i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 50));
          if (find.byType(BattlePage).evaluate().isNotEmpty) {
            break;
          }
        }

        expect(find.byType(BattlePage), findsOneWidget);
        final battlePage = tester.widget<BattlePage>(find.byType(BattlePage));
        expect(battlePage.stageId, equals('stage_2'));
        expect(router.state.uri.toString(), equals('/battle?stageId=stage_2'));
      },
    );

    testWidgets('browser back returns from battle to previous home shell tab', (
      tester,
    ) async {
      await pumpHome(tester);

      expect(find.byKey(const Key('enter_battle_button')), findsOneWidget);
      // Enter battle via push
      await tester.tap(find.byKey(const Key('enter_battle_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(BattlePage), findsOneWidget);
      expect(router.state.uri.toString(), equals('/battle?stageId=stage_1'));

      // Pop / browser back
      router.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(HomePage), findsOneWidget);
      expect(router.state.uri.toString(), equals('/home'));
    });
  });
}

class _InMemoryBattleDataSource implements LocalBattleContentDataSource {
  const _InMemoryBattleDataSource();

  @override
  Future<List<dynamic>> loadHeroesJson() async => [
    {
      'id': 'dinh_bo_linh',
      'name_key': 'hero_dinh_bo_linh',
      'element': 'fire',
      'hero_class': 'commander',
      'base_hp': 1200,
      'base_attack': 150,
      'base_defense': 80,
      'max_mana': 100,
      'starting_mana': 20,
      'active_skill_id': 's1',
      'asset_key': 'heroes/assassin',
      'rank': 'S',
      'power': 1810,
    },
  ];

  @override
  Future<List<dynamic>> loadSkillsJson() async => [
    {
      'id': 's1',
      'name_key': 'S1',
      'mana_cost': 40,
      'target_type': 'single_enemy',
      'effects': [
        {
          'type': 'damage',
          'magnitude': 100,
          'duration': 0,
          'tile_type': 'fire',
        },
      ],
    },
  ];

  @override
  Future<List<dynamic>> loadEnemiesJson() async => [
    {
      'id': 'bandit',
      'name_key': 'Bandit',
      'max_hp': 500,
      'attack': 40,
      'defense': 20,
      'initial_turn_counter': 3,
      'reset_turn_counter': 3,
      'target_rule': 'lowest_hp',
      'status_resistance': <String>[],
    },
  ];

  @override
  Future<List<dynamic>> loadStagesJson() async => [
    {
      'id': 'stage_1',
      'display_name_key': 'Stage 1',
      'turn_limit': 30,
      'waves': [
        {
          'wave_number': 1,
          'enemy_ids': ['bandit'],
        },
      ],
    },
    {
      'id': 'stage_2',
      'display_name_key': 'Stage 2',
      'turn_limit': 30,
      'waves': [
        {
          'wave_number': 1,
          'enemy_ids': ['bandit'],
        },
      ],
    },
  ];
}
