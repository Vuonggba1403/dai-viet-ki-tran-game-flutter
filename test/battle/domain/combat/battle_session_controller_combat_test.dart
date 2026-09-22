import 'package:dai_viet_ki_tran_game/battle/data/models/enemy_definition.dart';
import 'package:dai_viet_ki_tran_game/battle/data/models/hero_definition.dart';
import 'package:dai_viet_ki_tran_game/battle/data/models/skill_definition.dart';
import 'package:dai_viet_ki_tran_game/battle/data/models/stage_definition.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/battle_session_controller.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/board_generator.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/legal_move_finder.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/tile_type.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/combat/battle_phase.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/combat/combat_event.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/random/seeded_random.dart';
import 'package:flutter_test/flutter_test.dart' hide MatchFinder;

void main() {
  group('BattleSessionController Combat Orchestration', () {
    late StageDefinition testStage;
    late List<HeroDefinition> heroes;
    late List<EnemyDefinition> enemies;
    late List<SkillDefinition> skills;

    setUp(() {
      testStage = const StageDefinition(
        id: 'stage_test',
        displayNameKey: 'Test Stage',
        turnLimit: 10,
        waves: [
          StageWaveDefinition(
            waveNumber: 1,
            enemyIds: ['enemy_easy'],
          ),
          StageWaveDefinition(
            waveNumber: 2,
            enemyIds: ['enemy_boss'],
          ),
        ],
      );

      heroes = const [
        HeroDefinition(
          id: 'hero_fire',
          nameKey: 'Fire Hero',
          element: TileType.fire,
          heroClass: 'c',
          baseHp: 1000,
          baseAttack: 150,
          baseDefense: 50,
          maxMana: 100,
          startingMana: 50,
          activeSkillId: 'skill_fire',
        ),
        HeroDefinition(
          id: 'hero_sword',
          nameKey: 'Sword Hero',
          element: TileType.sword,
          heroClass: 'w',
          baseHp: 1000,
          baseAttack: 120,
          baseDefense: 60,
          maxMana: 100,
          startingMana: 0,
          activeSkillId: 'skill_sword',
        ),
      ];

      enemies = const [
        EnemyDefinition(
          id: 'enemy_easy',
          nameKey: 'Easy Enemy',
          maxHp: 100, // dies quickly in 1 hit
          attack: 30,
          defense: 0,
          initialTurnCounter: 2,
          resetTurnCounter: 2,
          targetRule: 'lowest_hp',
        ),
        EnemyDefinition(
          id: 'enemy_boss',
          nameKey: 'Boss Enemy',
          maxHp: 200,
          attack: 80,
          defense: 10,
          initialTurnCounter: 1,
          resetTurnCounter: 2,
          targetRule: 'lowest_hp',
        ),
      ];

      skills = const [
        SkillDefinition(
          id: 'skill_fire',
          nameKey: 'Skill Fire',
          manaCost: 40,
          targetType: 'single_enemy',
          effects: [
            SkillEffectDefinition(
              type: 'damage',
              magnitude: 300,
              duration: 0,
              tileType: TileType.fire,
            ),
          ],
        ),
      ];
    });

    test(
      'initializes with 4-hero team, wave 1 enemy, and playerInput phase',
      () {
        final board = BoardGenerator.generate(SeededRandom(42));
        final controller = BattleSessionController(
          initialBoard: board,
          randomService: SeededRandom(42),
          stage: testStage,
          heroDefinitions: heroes,
          enemyDefinitions: enemies,
          skillDefinitions: skills,
        );

        expect(controller.heroes.length, equals(2));
        expect(controller.currentEnemy, isNotNull);
        expect(controller.currentEnemy!.id, equals('enemy_easy'));
        expect(controller.currentWaveNumber, equals(1));
        expect(controller.totalWaves, equals(2));
        expect(controller.currentPhase, equals(BattlePhase.playerInput));
        expect(controller.remainingTurns, equals(10));
      },
    );

    test(
      'valid swap advances wave when enemy is defeated and finishes in victory on wave 2',
      () {
        final board = BoardGenerator.generate(SeededRandom(42));
        final controller = BattleSessionController(
          initialBoard: board,
          randomService: SeededRandom(42),
          stage: testStage,
          heroDefinitions: heroes,
          enemyDefinitions: enemies,
          skillDefinitions: skills,
        );

        // Cast skill on wave 1 enemy (300 damage kills 100 HP enemy)
        expect(controller.canCastSkill('hero_fire'), isTrue);
        final skillEvents = controller.castSkill('hero_fire');
        expect(skillEvents.whereType<CombatWaveCleared>(), isNotEmpty);
        expect(skillEvents.whereType<CombatWaveStarted>(), isNotEmpty);

        // Now on wave 2
        expect(controller.currentWaveNumber, equals(2));
        expect(controller.currentEnemy!.id, equals('enemy_boss'));

        // Give fire hero 50 mana again and kill boss
        controller.heroes.first.gainMana(50);
        expect(controller.canCastSkill('hero_fire'), isTrue);
        final bossKillEvents = controller.castSkill('hero_fire');

        // Boss defeated on last wave -> Victory!
        expect(bossKillEvents.whereType<CombatVictorious>(), isNotEmpty);
        expect(controller.currentPhase, equals(BattlePhase.victory));
        expect(controller.totalScore, greaterThan(0));
      },
    );

    test(
      'enemy turn counter decrements on swap and attacks when reaching 0',
      () {
        final rng = SeededRandom(10);
        final board = BoardGenerator.generate(rng);
        final controller = BattleSessionController(
          initialBoard: board,
          randomService: rng,
          stage: testStage,
          heroDefinitions: heroes,
          enemyDefinitions: enemies,
          skillDefinitions: skills,
        );

        final moves = LegalMoveFinder.findLegalMoves(board);
        expect(moves, isNotEmpty);

        final prevTurns = controller.remainingTurns;
        controller.attemptSwap(moves.first);

        expect(controller.remainingTurns, equals(prevTurns - 1));
        expect(controller.lastCombatEvents, isNotEmpty);
      },
    );

    test('defeat triggers when all heroes perish', () {
      final board = BoardGenerator.generate(SeededRandom(42));
      final controller = BattleSessionController(
        initialBoard: board,
        randomService: SeededRandom(42),
        stage: testStage,
        heroDefinitions: heroes,
        enemyDefinitions: enemies,
        skillDefinitions: skills,
      );

      // Kill heroes
      for (final h in controller.heroes) {
        h.takeDamage(9999);
      }

      final moves = LegalMoveFinder.findLegalMoves(board);
      expect(moves, isNotEmpty);
      controller.attemptSwap(moves.first);

      expect(controller.currentPhase, equals(BattlePhase.defeat));
      expect(
        controller.lastCombatEvents.whereType<CombatDefeated>(),
        isNotEmpty,
      );
    });

    test('multi-enemy wave advances to next enemy without clearing wave', () {
      const multiStage = StageDefinition(
        id: 'stage_multi',
        displayNameKey: 'Multi Wave Stage',
        turnLimit: 20,
        waves: [
          StageWaveDefinition(
            waveNumber: 1,
            enemyIds: ['enemy_easy', 'enemy_boss'],
          ),
        ],
      );

      final rng = SeededRandom(42);
      final board = BoardGenerator.generate(rng);
      final controller = BattleSessionController(
        initialBoard: board,
        randomService: rng,
        stage: multiStage,
        heroDefinitions: heroes,
        enemyDefinitions: enemies,
        skillDefinitions: skills,
      );

      expect(controller.currentWaveNumber, equals(1));
      expect(controller.currentEnemyIndexInWave, equals(0));
      expect(controller.currentEnemy!.id, equals('enemy_easy'));

      // Kill first enemy with skill
      controller.heroes.first.gainMana(50);
      final killEvents = controller.castSkill('hero_fire');

      // First enemy dead, but wave has second enemy
      expect(killEvents.whereType<CombatWaveCleared>(), isEmpty);
      expect(controller.totalScore, equals(0)); // no 500 wave bonus
      expect(controller.currentWaveNumber, equals(1));
      expect(controller.currentEnemyIndexInWave, equals(1));
      expect(controller.currentEnemy!.id, equals('enemy_boss'));
      expect(controller.currentPhase, equals(BattlePhase.playerInput));

      // Kill second enemy (boss)
      controller.heroes.first.gainMana(50);
      final bossKillEvents = controller.castSkill('hero_fire');

      // Wave completed & Victory
      expect(bossKillEvents.whereType<CombatWaveCleared>(), isNotEmpty);
      expect(bossKillEvents.whereType<CombatVictorious>(), isNotEmpty);
      expect(controller.currentPhase, equals(BattlePhase.victory));
      expect(controller.totalScore, equals(500));
    });

    group('Turn limit enforcement (remainingTurns <= 0)', () {
      test('Edge 1: killing final enemy on last turn yields victory', () {
        const singleStage = StageDefinition(
          id: 'stage_last_turn_victory',
          displayNameKey: 'Last Turn Victory',
          turnLimit: 1,
          waves: [
            StageWaveDefinition(
              waveNumber: 1,
              enemyIds: ['enemy_easy'],
            ),
          ],
        );

        final rng = SeededRandom(42);
        final board = BoardGenerator.generate(rng);
        final controller = BattleSessionController(
          initialBoard: board,
          randomService: rng,
          stage: singleStage,
          heroDefinitions: heroes,
          enemyDefinitions: enemies,
          skillDefinitions: skills,
        );

        // Weaken enemy so swap kills it
        controller.currentEnemy!.takeDamage(99);
        expect(controller.currentEnemy!.currentHp, equals(1));

        final moves = LegalMoveFinder.findLegalMoves(board);
        controller.attemptSwap(moves.first);

        expect(controller.remainingTurns, equals(0));
        expect(controller.currentEnemy!.isAlive, isFalse);
        expect(controller.currentPhase, equals(BattlePhase.victory));
        expect(
          controller.lastCombatEvents.whereType<CombatVictorious>(),
          isNotEmpty,
        );
      });

      test(
        'Edge 2: killing first enemy in 2-enemy wave on last turn yields defeat',
        () {
          const multiStage = StageDefinition(
            id: 'stage_last_turn_multi',
            displayNameKey: 'Last Turn Multi',
            turnLimit: 1,
            waves: [
              StageWaveDefinition(
                waveNumber: 1,
                enemyIds: ['enemy_easy', 'enemy_boss'],
              ),
            ],
          );

          final rng = SeededRandom(42);
          final board = BoardGenerator.generate(rng);
          final controller = BattleSessionController(
            initialBoard: board,
            randomService: rng,
            stage: multiStage,
            heroDefinitions: heroes,
            enemyDefinitions: enemies,
            skillDefinitions: skills,
          );

          // Weaken first enemy so swap kills it
          controller.currentEnemy!.takeDamage(99);

          final moves = LegalMoveFinder.findLegalMoves(board);
          controller.attemptSwap(moves.first);

          expect(controller.remainingTurns, equals(0));
          // Second enemy spawned, but no turns remaining -> defeat
          expect(controller.currentEnemyIndexInWave, equals(1));
          expect(controller.currentEnemy!.id, equals('enemy_boss'));
          expect(controller.currentPhase, equals(BattlePhase.defeat));
          expect(
            controller.lastCombatEvents.whereType<CombatDefeated>(),
            isNotEmpty,
          );
        },
      );

      test(
        'Edge 3: clearing wave 1 on last turn with wave 2 remaining yields defeat',
        () {
          const multiWaveStage = StageDefinition(
            id: 'stage_last_turn_waves',
            displayNameKey: 'Last Turn Waves',
            turnLimit: 1,
            waves: [
              StageWaveDefinition(
                waveNumber: 1,
                enemyIds: ['enemy_easy'],
              ),
              StageWaveDefinition(
                waveNumber: 2,
                enemyIds: ['enemy_boss'],
              ),
            ],
          );

          final rng = SeededRandom(42);
          final board = BoardGenerator.generate(rng);
          final controller = BattleSessionController(
            initialBoard: board,
            randomService: rng,
            stage: multiWaveStage,
            heroDefinitions: heroes,
            enemyDefinitions: enemies,
            skillDefinitions: skills,
          );

          // Weaken wave 1 enemy so swap kills it
          controller.currentEnemy!.takeDamage(99);

          final moves = LegalMoveFinder.findLegalMoves(board);
          controller.attemptSwap(moves.first);

          expect(controller.remainingTurns, equals(0));
          // Wave 1 cleared, but wave 2 remains and turns <= 0 -> defeat
          expect(
            controller.lastCombatEvents.whereType<CombatWaveCleared>(),
            isNotEmpty,
          );
          expect(controller.currentPhase, equals(BattlePhase.defeat));
          expect(
            controller.lastCombatEvents.whereType<CombatDefeated>(),
            isNotEmpty,
          );
        },
      );

      test(
        'Edge 4: enemy surviving last turn yields defeat',
        () {
          const surviveStage = StageDefinition(
            id: 'stage_last_turn_survive',
            displayNameKey: 'Last Turn Survive',
            turnLimit: 1,
            waves: [
              StageWaveDefinition(
                waveNumber: 1,
                enemyIds: ['enemy_boss'], // 200 hp, won't die from 1 swap
              ),
            ],
          );

          final rng = SeededRandom(42);
          final board = BoardGenerator.generate(rng);
          final controller = BattleSessionController(
            initialBoard: board,
            randomService: rng,
            stage: surviveStage,
            heroDefinitions: heroes,
            enemyDefinitions: enemies,
            skillDefinitions: skills,
          );

          final moves = LegalMoveFinder.findLegalMoves(board);
          controller.attemptSwap(moves.first);

          expect(controller.remainingTurns, equals(0));
          expect(controller.currentEnemy!.isAlive, isTrue);
          expect(controller.currentPhase, equals(BattlePhase.defeat));
          expect(
            controller.lastCombatEvents.whereType<CombatDefeated>(),
            isNotEmpty,
          );
        },
      );
    });
  });
}
