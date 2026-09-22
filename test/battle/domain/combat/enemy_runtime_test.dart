import 'package:dai_viet_ki_tran_game/battle/data/models/enemy_definition.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/combat/enemy_runtime.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EnemyRuntime', () {
    const def = EnemyDefinition(
      id: 'bandit',
      nameKey: 'enemy_bandit_name',
      maxHp: 500,
      attack: 40,
      defense: 20,
      initialTurnCounter: 3,
      resetTurnCounter: 3,
      targetRule: 'lowest_hp',
    );

    test('initializes from definition with full HP and initial counter', () {
      final enemy = EnemyRuntime.fromDefinition(def);
      expect(enemy.id, equals('bandit'));
      expect(enemy.maxHp, equals(500));
      expect(enemy.currentHp, equals(500));
      expect(enemy.attack, equals(40));
      expect(enemy.defense, equals(20));
      expect(enemy.turnCounter, equals(3));
      expect(enemy.isAlive, isTrue);
      expect(enemy.hpRatio, equals(1.0));
    });

    test('takeDamage reduces HP and clamps to 0', () {
      final enemy = EnemyRuntime.fromDefinition(def);
      final taken1 = enemy.takeDamage(200);
      expect(taken1, equals(200));
      expect(enemy.currentHp, equals(300));
      expect(enemy.isAlive, isTrue);

      final taken2 = enemy.takeDamage(400);
      expect(taken2, equals(300));
      expect(enemy.currentHp, equals(0));
      expect(enemy.isAlive, isFalse);

      final taken3 = enemy.takeDamage(100);
      expect(taken3, equals(0));
    });

    test(
      'tickTurnCounter decrements to 0 and resetCounter restores resetTurnCounter',
      () {
        final enemy = EnemyRuntime.fromDefinition(def);
        expect(enemy.turnCounter, equals(3));

        expect(enemy.tickTurnCounter(), equals(2));
        expect(enemy.tickTurnCounter(), equals(1));
        expect(enemy.tickTurnCounter(), equals(0));
        expect(enemy.tickTurnCounter(), equals(0)); // does not go below 0

        enemy.resetCounter();
        expect(enemy.turnCounter, equals(3));
      },
    );

    test('copy creates an exact clone with current HP and counter', () {
      final enemy = EnemyRuntime.fromDefinition(def)
        ..takeDamage(150)
        ..tickTurnCounter();

      final clone = enemy.copy();
      expect(clone.currentHp, equals(350));
      expect(clone.turnCounter, equals(2));
      expect(clone.id, equals(enemy.id));
    });

    group('Boss phase transitions', () {
      const bossDef = EnemyDefinition(
        id: 'boss_ki_tran',
        nameKey: 'Boss Ki Tran',
        maxHp: 1000,
        attack: 100,
        defense: 50,
        initialTurnCounter: 3,
        resetTurnCounter: 3,
        targetRule: 'lowest_hp',
        phases: [
          EnemyPhaseDefinition(
            phaseNumber: 2,
            hpThresholdPercent: 75,
            descriptionKey: 'Phase 2: Enraged',
          ),
          EnemyPhaseDefinition(
            phaseNumber: 3,
            hpThresholdPercent: 50,
            descriptionKey: 'Phase 3: Desperation',
          ),
          EnemyPhaseDefinition(
            phaseNumber: 4,
            hpThresholdPercent: 25,
            descriptionKey: 'Phase 4: Final Stand',
          ),
        ],
      );

      test('initializes with currentPhase 1 and phase 1 triggered', () {
        final boss = EnemyRuntime.fromDefinition(bossDef);
        expect(boss.currentPhase, equals(1));
        expect(boss.triggeredPhases, equals({1}));
      });

      test('triggers phase 2 when HP drops to or below 75%', () {
        // Deal 200 damage -> 800 HP (80%), no transition
        final boss = EnemyRuntime.fromDefinition(bossDef)..takeDamage(200);
        expect(boss.checkPhaseTransitions(), isEmpty);
        expect(boss.currentPhase, equals(1));

        // Deal 50 damage -> 750 HP (75%), triggers Phase 2
        final events = (boss..takeDamage(50)).checkPhaseTransitions();
        expect(events.length, equals(1));
        expect(events.first.phaseNumber, equals(2));
        expect(events.first.hpThresholdPercent, equals(75));
        expect(events.first.enemyId, equals('boss_ki_tran'));
        expect(boss.currentPhase, equals(2));
        expect(boss.triggeredPhases, containsAll([1, 2]));
      });

      test(
        'does not re-trigger already triggered phase on subsequent damage',
        () {
          final boss = EnemyRuntime.fromDefinition(bossDef);
          final events1 = (boss..takeDamage(300)).checkPhaseTransitions();
          expect(events1.length, equals(1));
          expect(events1.first.phaseNumber, equals(2));

          // More damage while still in phase 2 range
          final events2 = (boss..takeDamage(100)).checkPhaseTransitions();
          expect(events2, isEmpty); // no duplicate trigger!
          expect(boss.currentPhase, equals(2));
        },
      );

      test(
        'multi-threshold skip: triggers all crossed phases in ascending order',
        () {
          final boss = EnemyRuntime.fromDefinition(bossDef);

          // Massive hit: 1000 HP down to 200 HP (20%)
          // Crosses Phase 2 (75%), Phase 3 (50%), and Phase 4 (25%)
          final events = (boss..takeDamage(800)).checkPhaseTransitions();

          expect(events.length, equals(3));
          expect(events[0].phaseNumber, equals(2));
          expect(events[0].hpThresholdPercent, equals(75));
          expect(events[1].phaseNumber, equals(3));
          expect(events[1].hpThresholdPercent, equals(50));
          expect(events[2].phaseNumber, equals(4));
          expect(events[2].hpThresholdPercent, equals(25));

          expect(boss.currentPhase, equals(4));
          expect(boss.triggeredPhases, equals({1, 2, 3, 4}));

          // Subsequent damage to 0 HP yields no more transitions
          final eventsAfter = (boss..takeDamage(200)).checkPhaseTransitions();
          expect(eventsAfter, isEmpty);
        },
      );

      test('copy preserves currentPhase and triggeredPhases', () {
        final boss = EnemyRuntime.fromDefinition(bossDef)
          ..takeDamage(550)
          ..checkPhaseTransitions();
        expect(boss.currentPhase, equals(3));

        final copy = boss.copy();
        expect(copy.currentPhase, equals(3));
        expect(copy.triggeredPhases, equals({1, 2, 3}));
        expect(copy.checkPhaseTransitions(), isEmpty);
      });
    });
  });
}
