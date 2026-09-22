import 'package:ezwork/battle/data/models/enemy_definition.dart';
import 'package:ezwork/battle/domain/combat/enemy_runtime.dart';
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
  });
}
