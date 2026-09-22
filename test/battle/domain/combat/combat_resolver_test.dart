import 'package:ezwork/battle/data/models/enemy_definition.dart';
import 'package:ezwork/battle/data/models/hero_definition.dart';
import 'package:ezwork/battle/data/models/skill_definition.dart';
import 'package:ezwork/battle/domain/board/board_event.dart';
import 'package:ezwork/battle/domain/board/board_position.dart';
import 'package:ezwork/battle/domain/board/match_group.dart';
import 'package:ezwork/battle/domain/board/tile_type.dart';
import 'package:ezwork/battle/domain/combat/combat_event.dart';
import 'package:ezwork/battle/domain/combat/combat_resolver.dart';
import 'package:ezwork/battle/domain/combat/enemy_runtime.dart';
import 'package:ezwork/battle/domain/combat/hero_runtime.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CombatResolver', () {
    const resolver = CombatResolver();

    group('Combo multiplier', () {
      test('scales according to GDD combo progression and caps at 2.30', () {
        expect(CombatResolver.calculateComboMultiplier(0), equals(1.0));
        expect(CombatResolver.calculateComboMultiplier(1), equals(1.0));
        expect(CombatResolver.calculateComboMultiplier(2), equals(1.20));
        expect(CombatResolver.calculateComboMultiplier(3), equals(1.45));
        expect(CombatResolver.calculateComboMultiplier(4), equals(1.70));
        expect(
          CombatResolver.calculateComboMultiplier(5),
          closeTo(1.85, 0.001),
        );
        expect(
          CombatResolver.calculateComboMultiplier(6),
          closeTo(2.00, 0.001),
        );
        expect(
          CombatResolver.calculateComboMultiplier(7),
          closeTo(2.15, 0.001),
        );
        expect(CombatResolver.calculateComboMultiplier(8), equals(2.30));
        expect(CombatResolver.calculateComboMultiplier(15), equals(2.30));
      });
    });

    group('Damage formula and defense mitigation', () {
      test(
        'mitigates raw damage with formula max(1, (raw * 100 / (100 + def)).round())',
        () {
          // raw 100, def 0 => 100
          expect(CombatResolver.calculateMitigatedDamage(100, 0), equals(100));

          // raw 100, def 100 => 50
          expect(CombatResolver.calculateMitigatedDamage(100, 100), equals(50));

          // raw 100, def 50 => round(100 * 100 / 150) = round(66.666) = 67
          expect(CombatResolver.calculateMitigatedDamage(100, 50), equals(67));

          // minimum damage is always 1 for non-zero raw damage
          expect(CombatResolver.calculateMitigatedDamage(1, 9999), equals(1));
          expect(CombatResolver.calculateMitigatedDamage(0, 100), equals(0));
        },
      );
    });

    group('resolveBoardMatches', () {
      late HeroRuntime fireHero;
      late HeroRuntime swordHero;
      late HeroRuntime waterHero;
      late HeroRuntime lightningHero;
      late List<HeroRuntime> heroes;
      late EnemyRuntime enemy;

      setUp(() {
        fireHero = HeroRuntime.fromDefinition(
          const HeroDefinition(
            id: 'h_fire',
            nameKey: 'H Fire',
            element: TileType.fire,
            heroClass: 'c',
            baseHp: 1000,
            baseAttack: 150,
            baseDefense: 50,
            maxMana: 100,
            startingMana: 0,
            activeSkillId: 's1',
          ),
        );
        swordHero = HeroRuntime.fromDefinition(
          const HeroDefinition(
            id: 'h_sword',
            nameKey: 'H Sword',
            element: TileType.sword,
            heroClass: 'w',
            baseHp: 1200,
            baseAttack: 120,
            baseDefense: 80,
            maxMana: 100,
            startingMana: 0,
            activeSkillId: 's1',
          ),
        );
        waterHero = HeroRuntime.fromDefinition(
          const HeroDefinition(
            id: 'h_water',
            nameKey: 'H Water',
            element: TileType.water,
            heroClass: 's',
            baseHp: 900,
            baseAttack: 100,
            baseDefense: 60,
            maxMana: 100,
            startingMana: 0,
            activeSkillId: 's1',
          ),
        );
        lightningHero = HeroRuntime.fromDefinition(
          const HeroDefinition(
            id: 'h_lightning',
            nameKey: 'H Lightning',
            element: TileType.lightning,
            heroClass: 'b',
            baseHp: 1100,
            baseAttack: 160,
            baseDefense: 40,
            maxMana: 100,
            startingMana: 0,
            activeSkillId: 's1',
          ),
        );
        heroes = [fireHero, swordHero, waterHero, lightningHero];

        enemy = EnemyRuntime.fromDefinition(
          const EnemyDefinition(
            id: 'bandit',
            nameKey: 'Bandit',
            maxHp: 500,
            attack: 50,
            defense: 25,
            initialTurnCounter: 3,
            resetTurnCounter: 3,
            targetRule: 'lowest_hp',
          ),
        );
      });

      test('sword match damages enemy and gains mana for sword hero', () {
        final matchGroup = MatchGroup(
          tileType: TileType.sword,
          positions: {
            const BoardPosition(0, 0),
            const BoardPosition(0, 1),
            const BoardPosition(0, 2),
          },
        );
        final events = [
          TilesMatched(cycle: 1, matches: [matchGroup]),
        ];

        final combatEvents = resolver.resolveBoardMatches(
          boardEvents: events,
          heroes: heroes,
          enemy: enemy,
        );

        // Raw: 120 * (3/3) * 1.0 * 1.0 = 120
        // Mitigated: round(120 * 100 / 125) = 96
        expect(enemy.currentHp, equals(500 - 96));
        expect(swordHero.currentMana, equals(30)); // 3 tiles * 10

        expect(combatEvents.whereType<CombatEnemyDamaged>(), isNotEmpty);
        expect(combatEvents.whereType<CombatHeroManaGained>(), isNotEmpty);
      });

      test(
        'elemental match applies advantage multiplier against enemy element',
        () {
          // Enemy is lightning; fire hero has advantage (1.5x)
          final lightningEnemy = EnemyRuntime.fromDefinition(
            const EnemyDefinition(
              id: 'e_lightning',
              nameKey: 'E Lightning',
              maxHp: 500,
              attack: 40,
              defense: 0,
              initialTurnCounter: 2,
              resetTurnCounter: 2,
              targetRule: 'random',
            ),
            element: TileType.lightning,
          );

          final matchGroup = MatchGroup(
            tileType: TileType.fire,
            positions: {
              const BoardPosition(0, 0),
              const BoardPosition(0, 1),
              const BoardPosition(0, 2),
            },
          );

          final combatEvents = resolver.resolveBoardMatches(
            boardEvents: [
              TilesMatched(cycle: 1, matches: [matchGroup]),
            ],
            heroes: heroes,
            enemy: lightningEnemy,
          );

          // 150 attack * 1.0 combo * 1.5 advantage = 225 damage
          expect(lightningEnemy.currentHp, equals(500 - 225));
          expect(fireHero.currentMana, equals(30));

          final damageEvent = combatEvents
              .whereType<CombatEnemyDamaged>()
              .first;
          expect(damageEvent.isCriticalOrEffective, isTrue);
        },
      );

      test('heart match heals all living heroes', () {
        fireHero.takeDamage(200);
        waterHero.takeDamage(300);

        final heartGroup = MatchGroup(
          tileType: TileType.heart,
          positions: {
            const BoardPosition(1, 0),
            const BoardPosition(1, 1),
            const BoardPosition(1, 2),
          },
        );

        final combatEvents = resolver.resolveBoardMatches(
          boardEvents: [
            TilesMatched(cycle: 1, matches: [heartGroup]),
          ],
          heroes: heroes,
          enemy: enemy,
        );

        // Base heal: 80 HP
        expect(fireHero.currentHp, equals(880));
        expect(waterHero.currentHp, equals(680));
        expect(combatEvents.whereType<CombatHeroHealed>().length, equals(2));
      });

      test('Heart match healing is order-independent when enemy dies', () {
        final lethalSwordGroup = MatchGroup(
          tileType: TileType.sword,
          positions: {
            const BoardPosition(0, 0),
            const BoardPosition(0, 1),
            const BoardPosition(0, 2),
          },
        );
        final heartGroup = MatchGroup(
          tileType: TileType.heart,
          positions: {
            const BoardPosition(1, 0),
            const BoardPosition(1, 1),
            const BoardPosition(1, 2),
          },
        );

        // Case A: [lethalSword, heart]
        final enemyA = EnemyRuntime.fromDefinition(
          const EnemyDefinition(
            id: 'weak_enemy',
            nameKey: 'Weak',
            maxHp: 50,
            attack: 10,
            defense: 0,
            initialTurnCounter: 1,
            resetTurnCounter: 1,
            targetRule: 'lowest_hp',
          ),
        );
        final heroA = HeroRuntime.fromDefinition(
          const HeroDefinition(
            id: 'h_sword',
            nameKey: 'H Sword',
            element: TileType.sword,
            heroClass: 'w',
            baseHp: 1000,
            baseAttack: 120,
            baseDefense: 50,
            maxMana: 100,
            startingMana: 0,
            activeSkillId: 's1',
          ),
        )..takeDamage(300);

        final eventsA = resolver.resolveBoardMatches(
          boardEvents: [
            TilesMatched(cycle: 1, matches: [lethalSwordGroup, heartGroup]),
          ],
          heroes: [heroA],
          enemy: enemyA,
        );

        // Case B: [heart, lethalSword]
        final enemyB = EnemyRuntime.fromDefinition(
          const EnemyDefinition(
            id: 'weak_enemy',
            nameKey: 'Weak',
            maxHp: 50,
            attack: 10,
            defense: 0,
            initialTurnCounter: 1,
            resetTurnCounter: 1,
            targetRule: 'lowest_hp',
          ),
        );
        final heroB = HeroRuntime.fromDefinition(
          const HeroDefinition(
            id: 'h_sword',
            nameKey: 'H Sword',
            element: TileType.sword,
            heroClass: 'w',
            baseHp: 1000,
            baseAttack: 120,
            baseDefense: 50,
            maxMana: 100,
            startingMana: 0,
            activeSkillId: 's1',
          ),
        )..takeDamage(300);

        final eventsB = resolver.resolveBoardMatches(
          boardEvents: [
            TilesMatched(cycle: 1, matches: [heartGroup, lethalSwordGroup]),
          ],
          heroes: [heroB],
          enemy: enemyB,
        );

        expect(enemyA.isAlive, isFalse);
        expect(enemyB.isAlive, isFalse);
        expect(heroA.currentHp, equals(heroB.currentHp));
        expect(
          eventsA.whereType<CombatHeroHealed>().length,
          equals(eventsB.whereType<CombatHeroHealed>().length),
        );
      });
    });

    group('Enemy turn resolution', () {
      test('ticks counter down and executes attack on turn 0', () {
        final hero = HeroRuntime.fromDefinition(
          const HeroDefinition(
            id: 'h1',
            nameKey: 'H1',
            element: TileType.sword,
            heroClass: 'w',
            baseHp: 500,
            baseAttack: 100,
            baseDefense: 50,
            maxMana: 100,
            startingMana: 0,
            activeSkillId: 's1',
          ),
        );
        final enemy = EnemyRuntime.fromDefinition(
          const EnemyDefinition(
            id: 'bandit',
            nameKey: 'Bandit',
            maxHp: 300,
            attack: 60,
            defense: 20,
            initialTurnCounter: 1,
            resetTurnCounter: 2,
            targetRule: 'lowest_hp',
          ),
        );

        // First tick brings counter from 1 to 0 -> attacks!
        final events = resolver.resolveEnemyTurn(
          enemy: enemy,
          heroes: [hero],
        );

        expect(events.whereType<CombatEnemyTurnTicked>(), isNotEmpty);
        expect(events.whereType<CombatEnemyAttacked>(), isNotEmpty);
        expect(events.whereType<CombatHeroDamaged>(), isNotEmpty);

        // Damage: round(60 * 100 / 150) = 40
        expect(hero.currentHp, equals(460));
        expect(enemy.turnCounter, equals(2)); // counter reset
      });
    });

    group('resolveSkillCast', () {
      test('executes damage and heal skills with mana deduction', () {
        final hero = HeroRuntime.fromDefinition(
          const HeroDefinition(
            id: 'h_fire',
            nameKey: 'H Fire',
            element: TileType.fire,
            heroClass: 'c',
            baseHp: 1000,
            baseAttack: 100,
            baseDefense: 50,
            maxMana: 100,
            startingMana: 60,
            activeSkillId: 'skill_fire_nuke',
          ),
        );
        final enemy = EnemyRuntime.fromDefinition(
          const EnemyDefinition(
            id: 'e1',
            nameKey: 'E1',
            maxHp: 500,
            attack: 40,
            defense: 25,
            initialTurnCounter: 3,
            resetTurnCounter: 3,
            targetRule: 'lowest_hp',
          ),
        );
        const skill = SkillDefinition(
          id: 'skill_fire_nuke',
          nameKey: 'Fire Nuke',
          manaCost: 50,
          targetType: 'single_enemy',
          effects: [
            SkillEffectDefinition(
              type: 'damage',
              magnitude: 250,
              duration: 0,
              tileType: TileType.fire,
            ),
          ],
        );

        final events = resolver.resolveSkillCast(
          hero: hero,
          skill: skill,
          enemy: enemy,
          heroes: [hero],
        );

        expect(hero.currentMana, equals(10)); // 60 - 50
        // Damage: round(250 * 100 / 125) = 200
        expect(enemy.currentHp, equals(300));
        expect(events.whereType<CombatSkillExecuted>(), isNotEmpty);
        expect(events.whereType<CombatEnemyDamaged>(), isNotEmpty);
      });
    });
  });
}
