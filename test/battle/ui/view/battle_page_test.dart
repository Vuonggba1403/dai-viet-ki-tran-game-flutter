import 'package:ezwork/app/di/dependencies.dart';
import 'package:ezwork/battle/data/data_sources/local_battle_content_data_source.dart';
import 'package:ezwork/battle/data/repositories/battle_content_repository.dart';
import 'package:ezwork/battle/ui/cubit/battle_session_cubit.dart';
import 'package:ezwork/battle/ui/overlays/battle_hud.dart';
import 'package:ezwork/battle/ui/view/battle_page.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' hide MatchFinder;

class _InMemoryBattleDataSource implements LocalBattleContentDataSource {
  const _InMemoryBattleDataSource();

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
          'active_skill_id': 's1',
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
          'active_skill_id': 's1',
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
          'active_skill_id': 's1',
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
          'active_skill_id': 's1',
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
              'tile_type': 'fire'
            },
          ],
        },
      ];

  @override
  Future<List<dynamic>> loadEnemiesJson() async => [
        {
          'id': 'e1',
          'name_key': 'E1',
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
              'enemy_ids': ['e1'],
            },
          ],
        },
      ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BattlePage', () {
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

    testWidgets(
        'renders loading indicator initially then transitions to battle board',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BattlePage(),
        ),
      );

      // Initially shows loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Settle loading and ready state
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        if (find.byType(BattleHud).evaluate().isNotEmpty) break;
      }

      expect(
        find.byWidgetPredicate((w) => w is GameWidget),
        findsOneWidget,
      );
      expect(find.byType(BattleHud), findsOneWidget);
      expect(find.byKey(const Key('pause_overlay')), findsNothing);
    });

    testWidgets('pause button shows PauseOverlay and resume button hides it',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BattlePage(),
        ),
      );
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        if (find.byKey(const Key('pause_button')).evaluate().isNotEmpty) break;
      }

      // Tap pause button
      final pauseBtn = find.byKey(const Key('pause_button'));
      expect(pauseBtn, findsOneWidget);
      await tester.tap(pauseBtn);
      await tester.pump(const Duration(milliseconds: 100));

      // Pause overlay should be visible
      expect(find.byKey(const Key('pause_overlay')), findsOneWidget);
      expect(find.text('TẠM DỪNG'), findsOneWidget);

      // Tap resume button
      final resumeBtn = find.byKey(const Key('resume_button'));
      expect(resumeBtn, findsOneWidget);
      await tester.tap(resumeBtn);
      await tester.pump(const Duration(milliseconds: 100));

      // Pause overlay should be dismissed
      expect(find.byKey(const Key('pause_overlay')), findsNothing);
    });

    testWidgets('properly disposes without errors when popped', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const BattlePage(),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      // Open battle page
      await tester.tap(find.text('Open'));
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        if (find.byType(BattlePage).evaluate().isNotEmpty) break;
      }
      expect(find.byType(BattlePage), findsOneWidget);

      // Pop battle page and wait for route transition to finish
      Navigator.of(tester.element(find.byType(BattlePage))).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(BattlePage), findsNothing);
    });
  });
}
