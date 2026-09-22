import 'package:dai_viet_ki_tran_game/app/di/dependencies.dart';
import 'package:dai_viet_ki_tran_game/battle/data/data_sources/local_battle_content_data_source.dart';
import 'package:dai_viet_ki_tran_game/battle/data/repositories/battle_content_repository.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/cubit/battle_session_cubit.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/view/battle_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
    },
    {
      'id': 'nguyen_bac',
      'name_key': 'hero_nguyen_bac',
      'element': 'sword',
      'hero_class': 'warrior',
      'base_hp': 1500,
      'base_attack': 130,
      'base_defense': 110,
      'max_mana': 80,
      'starting_mana': 0,
      'active_skill_id': 's1',
      'asset_key': 'heroes/swordsman',
    },
    {
      'id': 'dinh_dien',
      'name_key': 'hero_dinh_dien',
      'element': 'lightning',
      'hero_class': 'berserker',
      'base_hp': 1100,
      'base_attack': 170,
      'base_defense': 70,
      'max_mana': 90,
      'starting_mana': 0,
      'active_skill_id': 's1',
      'asset_key': 'heroes/monk',
    },
    {
      'id': 'luu_co',
      'name_key': 'hero_luu_co',
      'element': 'water',
      'hero_class': 'strategist',
      'base_hp': 1000,
      'base_attack': 120,
      'base_defense': 90,
      'max_mana': 120,
      'starting_mana': 30,
      'active_skill_id': 's1',
      'asset_key': 'heroes/strategist',
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
      'display_name_key': 'Chiến Dịch 1',
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

void main() {
  group('BattlePage Golden Tests', () {
    late BattleContentRepository repository;

    setUp(() {
      repository = BattleContentRepository(
        localDataSource: const _InMemoryBattleDataSource(),
      );

      if (!getIt.isRegistered<BattleSessionCubit>()) {
        getIt.registerFactory(
          () => BattleSessionCubit(
            contentRepository: repository,
            initialSeed: 42,
          ),
        );
      }
    });

    tearDown(() {
      if (getIt.isRegistered<BattleSessionCubit>()) {
        getIt.unregister<BattleSessionCubit>();
      }
    });

    Future<void> renderBattle(WidgetTester tester, Size size) async {
      tester.view.physicalSize = Size(size.width * 2.0, size.height * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: BattlePage(),
        ),
      );

      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        if (find
            .byKey(const Key('battle_flame_game_widget'))
            .evaluate()
            .isNotEmpty) {
          break;
        }
      }
      await tester.pump(const Duration(milliseconds: 50));
    }

    testWidgets('Battle Page matches golden at 320x568', (tester) async {
      await renderBattle(tester, const Size(320, 568));
      await expectLater(
        find.byType(BattlePage),
        matchesGoldenFile('goldens/battle_page_320x568.png'),
      );
    });

    testWidgets('Battle Page matches golden at 390x844', (tester) async {
      await renderBattle(tester, const Size(390, 844));
      await expectLater(
        find.byType(BattlePage),
        matchesGoldenFile('goldens/battle_page_390x844.png'),
      );
    });
  });
}
