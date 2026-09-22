import 'package:dai_viet_ki_tran_game/app/di/dependencies.dart';
import 'package:dai_viet_ki_tran_game/audio/application/audio_controller.dart';
import 'package:dai_viet_ki_tran_game/audio/application/audio_settings_cubit.dart';
import 'package:dai_viet_ki_tran_game/audio/data/audio_settings_repository.dart';
import 'package:dai_viet_ki_tran_game/audio/domain/audio_cue.dart';
import 'package:dai_viet_ki_tran_game/audio/domain/game_audio_service.dart';
import 'package:dai_viet_ki_tran_game/battle/data/data_sources/local_battle_content_data_source.dart';
import 'package:dai_viet_ki_tran_game/battle/data/repositories/battle_content_repository.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/cubit/battle_session_cubit.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/view/battle_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' hide MatchFinder;
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../../audio/audio_controller_test.dart';

class _MockBattleDataSource implements LocalBattleContentDataSource {
  const _MockBattleDataSource();

  @override
  Future<List<dynamic>> loadHeroesJson() async => [
    {
      'id': 'h1',
      'name_key': 'H1',
      'element': 'fire',
      'hero_class': 'warrior',
      'base_hp': 1000,
      'base_attack': 100,
      'base_defense': 50,
      'max_mana': 100,
      'starting_mana': 0,
      'active_skill_id': 'skill_hoa_long_quyet',
    },
    {
      'id': 'h2',
      'name_key': 'H2',
      'element': 'water',
      'hero_class': 'warrior',
      'base_hp': 1000,
      'base_attack': 100,
      'base_defense': 50,
      'max_mana': 100,
      'starting_mana': 0,
      'active_skill_id': 'skill_thuy_tran_thu',
    },
    {
      'id': 'h3',
      'name_key': 'H3',
      'element': 'lightning',
      'hero_class': 'warrior',
      'base_hp': 1000,
      'base_attack': 100,
      'base_defense': 50,
      'max_mana': 100,
      'starting_mana': 0,
      'active_skill_id': 'skill_loi_dinh_chuong',
    },
    {
      'id': 'h4',
      'name_key': 'H4',
      'element': 'sword',
      'hero_class': 'warrior',
      'base_hp': 1000,
      'base_attack': 100,
      'base_defense': 50,
      'max_mana': 100,
      'starting_mana': 0,
      'active_skill_id': 'skill_tram_long_kich',
    },
  ];

  @override
  Future<List<dynamic>> loadEnemiesJson() async => [
    {
      'id': 'normal_enemy',
      'name_key': 'Normal Enemy',
      'max_hp': 800,
      'attack': 80,
      'defense': 30,
      'initial_turn_counter': 3,
      'reset_turn_counter': 3,
      'target_rule': 'random',
      'status_resistance': <String>[],
    },
    {
      'id': 'boss_enemy',
      'name_key': 'Boss Enemy',
      'max_hp': 2500,
      'attack': 150,
      'defense': 60,
      'initial_turn_counter': 2,
      'reset_turn_counter': 2,
      'target_rule': 'lowest_hp',
      'status_resistance': <String>[],
      'phases': [
        {'phase_number': 1, 'hp_threshold_percent': 100},
        {'phase_number': 2, 'hp_threshold_percent': 50},
      ],
    },
  ];

  @override
  Future<List<dynamic>> loadSkillsJson() async => [
    {
      'id': 'skill_hoa_long_quyet',
      'name_key': 'Hỏa Long Quyết',
      'mana_cost': 40,
      'target_type': 'single_enemy',
      'effects': [
        {
          'type': 'damage',
          'magnitude': 100,
          'duration': 0,
        },
      ],
    },
    {
      'id': 'skill_thuy_tran_thu',
      'name_key': 'Thủy Trận Thủ',
      'mana_cost': 40,
      'target_type': 'all_allies',
      'effects': [
        {
          'type': 'heal',
          'magnitude': 100,
          'duration': 0,
        },
      ],
    },
    {
      'id': 'skill_loi_dinh_chuong',
      'name_key': 'Lôi Đình Chưởng',
      'mana_cost': 40,
      'target_type': 'single_enemy',
      'effects': [
        {
          'type': 'damage',
          'magnitude': 100,
          'duration': 0,
        },
      ],
    },
    {
      'id': 'skill_tram_long_kich',
      'name_key': 'Trảm Long Kích',
      'mana_cost': 40,
      'target_type': 'single_enemy',
      'effects': [
        {
          'type': 'damage',
          'magnitude': 100,
          'duration': 0,
        },
      ],
    },
  ];

  @override
  Future<List<dynamic>> loadStagesJson() async => [
    {
      'id': 'stage_normal',
      'display_name_key': 'Ải Thường',
      'waves': [
        {
          'wave_number': 1,
          'enemy_ids': ['normal_enemy'],
        },
      ],
      'turn_limit': 30,
    },
    {
      'id': 'stage_boss',
      'display_name_key': 'Ải Trùm',
      'waves': [
        {
          'wave_number': 1,
          'enemy_ids': ['boss_enemy'],
        },
      ],
      'turn_limit': 30,
    },
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BattlePage Audio Integration Widget Tests', () {
    late FakeGameAudioService fakeService;
    late AudioController audioController;
    late BattleContentRepository contentRepo;

    setUp(() {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();

      fakeService = FakeGameAudioService();
      audioController = AudioController(audioService: fakeService);
      contentRepo = BattleContentRepository(
        localDataSource: const _MockBattleDataSource(),
      );

      getIt
        ..registerSingleton<GameAudioService>(fakeService)
        ..registerSingleton<AudioSettingsRepository>(AudioSettingsRepository())
        ..registerSingleton<AudioController>(audioController)
        ..registerSingleton<AudioSettingsCubit>(
          AudioSettingsCubit(
            repository: getIt<AudioSettingsRepository>(),
            audioController: audioController,
          ),
        )
        ..registerSingleton<BattleContentRepository>(contentRepo)
        ..registerFactory(
          () => BattleSessionCubit(contentRepository: contentRepo),
        );
    });

    tearDown(() async {
      await getIt.reset();
    });

    testWidgets('BattlePage initializes regular battle BGM for normal stage', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BattlePage(stageId: 'stage_normal'),
        ),
      );
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        if (find.byKey(const Key('pause_button')).evaluate().isNotEmpty) break;
      }

      expect(fakeService.activeTrack, equals(BgmTrack.battle));
    });

    testWidgets('BattlePage initializes boss BGM for stage with phase metadata', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BattlePage(stageId: 'stage_boss'),
        ),
      );
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        if (find.byKey(const Key('pause_button')).evaluate().isNotEmpty) break;
      }

      expect(fakeService.activeTrack, equals(BgmTrack.boss));
    });

    testWidgets('Tapping pause ducks BGM and tapping resume restores BGM', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BattlePage(stageId: 'stage_normal'),
        ),
      );
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        if (find.byKey(const Key('pause_button')).evaluate().isNotEmpty) break;
      }

      expect(audioController.isPausedByGame, isFalse);

      // Tap pause button on HUD
      final pauseButtonFinder = find.byKey(const Key('pause_button'));
      expect(pauseButtonFinder, findsOneWidget);
      await tester.tap(pauseButtonFinder);
      await tester.pump(const Duration(milliseconds: 100));

      expect(audioController.isPausedByGame, isTrue);

      // Tap resume button on PauseOverlay
      final resumeButtonFinder = find.byKey(const Key('resume_button'));
      expect(resumeButtonFinder, findsOneWidget);
      await tester.tap(resumeButtonFinder);
      await tester.pump(const Duration(milliseconds: 100));

      expect(audioController.isPausedByGame, isFalse);
    });
  });
}
