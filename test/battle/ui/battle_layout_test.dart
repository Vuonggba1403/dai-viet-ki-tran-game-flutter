import 'package:dai_viet_ki_tran_game/battle/data/models/enemy_definition.dart';
import 'package:dai_viet_ki_tran_game/battle/data/models/hero_definition.dart';
import 'package:dai_viet_ki_tran_game/battle/data/models/stage_definition.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/tile_type.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/combat/enemy_runtime.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/combat/hero_runtime.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/overlays/defeat_overlay.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/overlays/victory_overlay.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/widgets/battle_arena.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/widgets/battle_hero_dock.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/widgets/battle_top_bar.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/widgets/battle_versus_hud.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/widgets/match3_board_viewport.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Battle UI Layout Components', () {
    late List<HeroRuntime> heroes;
    late EnemyRuntime enemy;

    setUp(() {
      heroes = [
        HeroRuntime.fromDefinition(
          const HeroDefinition(
            id: 'dinh_bo_linh',
            nameKey: 'DBL',
            element: TileType.fire,
            heroClass: 'c',
            baseHp: 1000,
            baseAttack: 100,
            baseDefense: 50,
            maxMana: 100,
            startingMana: 100,
            activeSkillId: 's1',
          ),
        ),
        HeroRuntime.fromDefinition(
          const HeroDefinition(
            id: 'nguyen_bac',
            nameKey: 'NB',
            element: TileType.sword,
            heroClass: 'w',
            baseHp: 1200,
            baseAttack: 90,
            baseDefense: 70,
            maxMana: 80,
            startingMana: 20,
            activeSkillId: 's2',
          ),
        ),
      ];

      enemy = EnemyRuntime.fromDefinition(
        const EnemyDefinition(
          id: 'bandit',
          nameKey: 'enemy_bandit_name',
          maxHp: 800,
          attack: 50,
          defense: 25,
          initialTurnCounter: 3,
          resetTurnCounter: 3,
          targetRule: 'lowest_hp',
        ),
      );
    });

    testWidgets('Match3BoardViewport maintains 1:1 aspect ratio square', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              height: 600,
              child: Match3BoardViewport(
                gameWidget: SizedBox(
                  key: Key('mock_game_widget'),
                ),
              ),
            ),
          ),
        ),
      );

      final box = tester.renderObject<RenderBox>(
        find.byKey(const Key('match3_board_viewport')),
      );
      expect(box.size.width, equals(box.size.height));
      expect(box.size.width, isNonZero);
    });

    testWidgets(
      'BattleTopBar displays stage name, wave counter and pause button',
      (
        tester,
      ) async {
        var paused = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BattleTopBar(
                stageTitle: 'Hoa Lư Sơn',
                currentWave: 1,
                totalWaves: 3,
                remainingTurns: 25,
                onPause: () => paused = true,
              ),
            ),
          ),
        );

        expect(find.text('Hoa Lư Sơn • Đợt 1/3'), findsOneWidget);
        expect(find.text('Lượt: 25'), findsOneWidget);

        final pauseBtn = find.byKey(const Key('pause_button'));
        expect(pauseBtn, findsOneWidget);
        await tester.tap(pauseBtn);
        expect(paused, isTrue);
      },
    );

    testWidgets('BattleArena places player hero left and enemy right', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 390,
              height: 250,
              child: BattleArena(
                heroes: heroes,
                enemy: enemy,
              ),
            ),
          ),
        ),
      );

      final heroFinder = find.byKey(const Key('arena_player_hero'));
      final enemyFinder = find.byKey(const Key('arena_enemy'));

      expect(heroFinder, findsOneWidget);
      expect(enemyFinder, findsOneWidget);

      final heroPos = tester.getTopLeft(heroFinder);
      final enemyPos = tester.getTopLeft(enemyFinder);

      expect(heroPos.dx, lessThan(enemyPos.dx));
    });

    testWidgets('BattleVersusHud renders both sides and countdown badge', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BattleVersusHud(
              heroes: heroes,
              enemy: enemy,
              comboCount: 4,
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('enemy_hp_bar')), findsOneWidget);
      expect(find.byKey(const Key('enemy_turn_countdown')), findsOneWidget);
      expect(find.text('4 COMBO!'), findsOneWidget);
      expect(find.text('VS'), findsOneWidget);
    });

    testWidgets('BattleHeroDock renders hero cards and skill buttons', (
      tester,
    ) async {
      String? triggeredHeroId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BattleHeroDock(
              heroes: heroes,
              canCastSkill: (id) => id == 'dinh_bo_linh',
              onCastSkill: (id) => triggeredHeroId = id,
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('hero_card_dinh_bo_linh')), findsOneWidget);
      expect(find.byKey(const Key('hero_card_nguyen_bac')), findsOneWidget);

      // Both skill buttons are always rendered
      final disabledBtn = find.byKey(const Key('hero_skill_button_nguyen_bac'));
      expect(disabledBtn, findsOneWidget);
      await tester.tap(disabledBtn);
      expect(triggeredHeroId, isNull);

      // Only dinh_bo_linh is ready
      final skillBtn = find.byKey(const Key('hero_skill_button_dinh_bo_linh'));
      expect(skillBtn, findsOneWidget);

      await tester.tap(skillBtn);
      expect(triggeredHeroId, equals('dinh_bo_linh'));
    });

    testWidgets('VictoryOverlay renders banner, score, and handles buttons', (
      tester,
    ) async {
      var retried = false;
      var exited = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VictoryOverlay(
              stage: const StageDefinition(
                id: 'stage_1',
                displayNameKey: 'Hoa Lư Sơn',
                turnLimit: 30,
                waves: [],
              ),
              score: 2500,
              onRetry: () => retried = true,
              onExit: () => exited = true,
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('victory_view')), findsOneWidget);
      expect(find.text('CHIẾN THẮNG!'), findsOneWidget);
      expect(find.text('Hoa Lư Sơn'), findsOneWidget);
      expect(find.text('Điểm: 2500'), findsOneWidget);

      await tester.tap(find.byKey(const Key('victory_retry_button')));
      expect(retried, isTrue);

      await tester.tap(find.byKey(const Key('victory_exit_button')));
      expect(exited, isTrue);
    });

    testWidgets('DefeatOverlay renders banner, tips, and handles buttons', (
      tester,
    ) async {
      var retried = false;
      var exited = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DefeatOverlay(
              stage: const StageDefinition(
                id: 'stage_1',
                displayNameKey: 'Hoa Lư Sơn',
                turnLimit: 30,
                waves: [],
              ),
              onRetry: () => retried = true,
              onExit: () => exited = true,
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('defeat_view')), findsOneWidget);
      expect(find.text('THẤT BẠI'), findsOneWidget);
      expect(find.text('Hoa Lư Sơn'), findsOneWidget);

      await tester.tap(find.byKey(const Key('defeat_retry_button')));
      expect(retried, isTrue);

      await tester.tap(find.byKey(const Key('defeat_exit_button')));
      expect(exited, isTrue);
    });

    testWidgets(
      'Responsive widgets render cleanly across mobile screen widths',
      (
        tester,
      ) async {
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final testWidths = [320.0, 360.0, 390.0, 412.0];

        for (final width in testWidths) {
          tester.view.physicalSize = Size(width * 2.0, 700 * 2.0);
          tester.view.devicePixelRatio = 2.0;

          // Top Bar
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: BattleTopBar(
                  stageTitle: 'Chiến Trường',
                  currentWave: 1,
                  totalWaves: 2,
                  remainingTurns: 20,
                  onPause: () {},
                ),
              ),
            ),
          );
          expect(
            tester.takeException(),
            isNull,
            reason: 'TopBar failed on $width',
          );

          // Arena
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  height: 180,
                  child: BattleArena(heroes: heroes, enemy: enemy),
                ),
              ),
            ),
          );
          expect(
            tester.takeException(),
            isNull,
            reason: 'Arena failed on $width',
          );

          // Versus HUD
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: BattleVersusHud(
                  heroes: heroes,
                  enemy: enemy,
                  comboCount: 1,
                ),
              ),
            ),
          );
          expect(
            tester.takeException(),
            isNull,
            reason: 'VersusHud failed on $width',
          );

          // Hero Dock
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: BattleHeroDock(
                  heroes: heroes,
                  canCastSkill: (_) => false,
                  onCastSkill: (_) {},
                ),
              ),
            ),
          );
          expect(
            tester.takeException(),
            isNull,
            reason: 'HeroDock failed on $width',
          );
        }
      },
    );
  });
}
