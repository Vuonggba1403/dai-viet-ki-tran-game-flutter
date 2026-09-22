import 'package:ezwork/battle/data/models/hero_definition.dart';
import 'package:ezwork/battle/domain/board/tile_type.dart';
import 'package:ezwork/battle/domain/combat/hero_runtime.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HeroRuntime', () {
    const def = HeroDefinition(
      id: 'dinh_bo_linh',
      nameKey: 'hero_dinh_bo_linh',
      element: TileType.fire,
      heroClass: 'commander',
      baseHp: 1000,
      baseAttack: 150,
      baseDefense: 80,
      maxMana: 100,
      startingMana: 20,
      activeSkillId: 'skill_hoa_long_quyet',
    );

    test('initializes from definition with full HP and starting mana', () {
      final hero = HeroRuntime.fromDefinition(def);
      expect(hero.id, equals('dinh_bo_linh'));
      expect(hero.element, equals(TileType.fire));
      expect(hero.maxHp, equals(1000));
      expect(hero.currentHp, equals(1000));
      expect(hero.attack, equals(150));
      expect(hero.defense, equals(80));
      expect(hero.maxMana, equals(100));
      expect(hero.currentMana, equals(20));
      expect(hero.isAlive, isTrue);
      expect(hero.hpRatio, equals(1.0));
      expect(hero.manaRatio, equals(0.2));
    });

    test('takeDamage reduces HP and clamps to 0', () {
      final hero = HeroRuntime.fromDefinition(def);
      final taken1 = hero.takeDamage(300);
      expect(taken1, equals(300));
      expect(hero.currentHp, equals(700));
      expect(hero.isAlive, isTrue);

      final taken2 = hero.takeDamage(800);
      expect(taken2, equals(700));
      expect(hero.currentHp, equals(0));
      expect(hero.isAlive, isFalse);

      // Dead hero cannot take more damage
      final taken3 = hero.takeDamage(100);
      expect(taken3, equals(0));
    });

    test('heal restores HP and clamps to maxHp', () {
      final hero = HeroRuntime.fromDefinition(def)..takeDamage(400);
      final healed1 = hero.heal(150);
      expect(healed1, equals(150));
      expect(hero.currentHp, equals(750));

      final healed2 = hero.heal(500);
      expect(healed2, equals(250));
      expect(hero.currentHp, equals(1000));
    });

    test('gainMana increases mana and clamps to maxMana', () {
      final hero = HeroRuntime.fromDefinition(def);
      expect(hero.currentMana, equals(20));

      final gained1 = hero.gainMana(50);
      expect(gained1, equals(50));
      expect(hero.currentMana, equals(70));

      final gained2 = hero.gainMana(50);
      expect(gained2, equals(30));
      expect(hero.currentMana, equals(100));
    });

    test('spendMana checks sufficiency and deducts correctly', () {
      final hero = HeroRuntime.fromDefinition(def); // 20 mana
      expect(hero.spendMana(50), isFalse);
      expect(hero.currentMana, equals(20));

      expect(hero.spendMana(15), isTrue);
      expect(hero.currentMana, equals(5));

      expect(hero.spendMana(0), isTrue);
    });

    test('copy creates an exact clone with current stats', () {
      final hero = HeroRuntime.fromDefinition(def)
        ..takeDamage(200)
        ..gainMana(30);

      final clone = hero.copy();
      expect(clone.currentHp, equals(800));
      expect(clone.currentMana, equals(50));
      expect(clone.id, equals(hero.id));
    });
  });
}
