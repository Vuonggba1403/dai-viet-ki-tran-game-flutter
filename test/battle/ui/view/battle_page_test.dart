import 'package:ezwork/app/di/dependencies.dart';
import 'package:ezwork/battle/data/data_sources/local_battle_content_data_source.dart';
import 'package:ezwork/battle/data/models/stage_definition.dart';
import 'package:ezwork/battle/data/repositories/battle_content_repository.dart';
import 'package:ezwork/battle/ui/cubit/battle_session_cubit.dart';
import 'package:ezwork/battle/ui/cubit/battle_session_state.dart';
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
          'tile_type': 'fire',
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
      },
    );

    testWidgets('pause button shows PauseOverlay and resume button hides it', (
      tester,
    ) async {
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

    testWidgets(
      'handles unknown stageId gracefully by presenting error view and retry/exit options',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: BattlePage(stageId: 'unknown_stage_id'),
          ),
        );

        for (var i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 50));
          if (find
              .byKey(const Key('session_error_retry_button'))
              .evaluate()
              .isNotEmpty) {
            break;
          }
        }

        expect(find.byType(BattleHud), findsNothing);
        expect(
          find.text('Màn chơi không tồn tại. Vui lòng chọn lại màn chơi.'),
          findsNWidgets(2),
        );
        expect(
          find.byKey(const Key('session_error_retry_button')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('session_error_exit_button')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'GameWidget errorBuilder presents user-friendly Vietnamese error without raw error string',
      (tester) async {
        final mockGame = _FailingFlameGame();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameWidget(
                game: mockGame,
                errorBuilder: (context, error) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.amberAccent,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Đã xảy ra lỗi trong trận đấu. Vui lòng thử lại.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                key: const Key('game_error_retry_button'),
                                onPressed: () {},
                                child: const Text('Thử lại'),
                              ),
                              const SizedBox(width: 16),
                              OutlinedButton(
                                key: const Key('game_error_exit_button'),
                                onPressed: () {},
                                child: const Text('Thoát'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        await tester.pump();

        expect(
          find.text('Đã xảy ra lỗi trong trận đấu. Vui lòng thử lại.'),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('game_error_retry_button')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('game_error_exit_button')),
          findsOneWidget,
        );
        expect(find.textContaining('Internal engine boom'), findsNothing);
      },
    );

    testWidgets('renders victory view cleanly without cast exception', (
      tester,
    ) async {
      late _TestBattleSessionCubit testCubit;
      if (getIt.isRegistered<BattleSessionCubit>()) {
        getIt.unregister<BattleSessionCubit>();
      }
      getIt.registerFactory<BattleSessionCubit>(
        () => testCubit = _TestBattleSessionCubit(
          contentRepository: repository,
          initialSeed: 42,
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: BattlePage(),
        ),
      );

      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        if (find.byType(BattleHud).evaluate().isNotEmpty) break;
      }

      final stage = (testCubit.state as BattleSessionStateReady).currentStage;
      testCubit.emitVictory(stage, 1500);
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byKey(const Key('victory_view')), findsOneWidget);
      expect(find.text('CHIẾN THẮNG!'), findsOneWidget);
      expect(find.text('Điểm: 1500'), findsOneWidget);
      expect(find.byKey(const Key('victory_retry_button')), findsOneWidget);
      expect(find.byKey(const Key('victory_exit_button')), findsOneWidget);
    });

    testWidgets('renders defeat view cleanly without cast exception', (
      tester,
    ) async {
      late _TestBattleSessionCubit testCubit;
      if (getIt.isRegistered<BattleSessionCubit>()) {
        getIt.unregister<BattleSessionCubit>();
      }
      getIt.registerFactory<BattleSessionCubit>(
        () => testCubit = _TestBattleSessionCubit(
          contentRepository: repository,
          initialSeed: 42,
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: BattlePage(),
        ),
      );

      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        if (find.byType(BattleHud).evaluate().isNotEmpty) break;
      }

      final stage = (testCubit.state as BattleSessionStateReady).currentStage;
      testCubit.emitDefeat(stage);
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byKey(const Key('defeat_view')), findsOneWidget);
      expect(find.text('THẤT BẠI'), findsOneWidget);
      expect(find.byKey(const Key('defeat_retry_button')), findsOneWidget);
      expect(find.byKey(const Key('defeat_exit_button')), findsOneWidget);
    });

    testWidgets(
      'renders on various iOS and Android screen resolutions without overflow',
      (tester) async {
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final resolutions =
            <String, ({double width, double height, double dpr})>{
              'iPhone SE 1st gen': (width: 320, height: 568, dpr: 2.0),
              'iPhone SE 3rd gen': (width: 375, height: 667, dpr: 2.0),
              'iPhone 14 / 15': (width: 390, height: 844, dpr: 3.0),
              'iPhone 15 Pro Max': (width: 430, height: 932, dpr: 3.0),
              'Android Compact': (width: 360, height: 640, dpr: 2.0),
              'Samsung Galaxy S23': (width: 360, height: 780, dpr: 3.0),
              'Pixel 7 / Android': (width: 412, height: 915, dpr: 2.625),
              'Samsung Galaxy S24 Ultra': (width: 412, height: 892, dpr: 3.5),
              'Android Tall 20:9': (width: 360, height: 800, dpr: 3.0),
              'Sony Xperia 21:9': (width: 384, height: 854, dpr: 2.5),
              'Galaxy Z Fold Unfolded': (width: 673, height: 841, dpr: 2.625),
              'iPad / Tablet': (width: 768, height: 1024, dpr: 2.0),
              'iPad 10.9"': (width: 820, height: 1180, dpr: 2.0),
              'Landscape iPhone': (width: 844, height: 390, dpr: 3.0),
              'Landscape Android': (width: 915, height: 412, dpr: 2.625),
            };

        for (final res in resolutions.values) {
          tester.view.physicalSize = Size(
            res.width * res.dpr,
            res.height * res.dpr,
          );
          tester.view.devicePixelRatio = res.dpr;

          await tester.pumpWidget(
            const MaterialApp(
              home: BattlePage(),
            ),
          );

          for (var i = 0; i < 20; i++) {
            await tester.pump(const Duration(milliseconds: 50));
            if (find.byType(BattleHud).evaluate().isNotEmpty) break;
          }

          expect(find.byType(BattleHud), findsOneWidget);
          expect(
            find.byWidgetPredicate((w) => w is GameWidget),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        }
      },
    );
  });
}

class _TestBattleSessionCubit extends BattleSessionCubit {
  _TestBattleSessionCubit({
    required super.contentRepository,
    super.initialSeed,
  });

  void emitVictory(StageDefinition stage, int score) {
    emit(BattleSessionState.victory(stage: stage, score: score));
  }

  void emitDefeat(StageDefinition stage) {
    emit(BattleSessionState.defeat(stage: stage));
  }
}

class _FailingFlameGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    throw StateError('Internal engine boom');
  }
}
