import 'dart:math' as math;
import 'package:ezwork/battle/data/models/battle_balance_definition.dart';
import 'package:ezwork/battle/data/models/skill_definition.dart';
import 'package:ezwork/battle/domain/board/board_event.dart';
import 'package:ezwork/battle/domain/board/tile_type.dart';
import 'package:ezwork/battle/domain/combat/combat_event.dart';
import 'package:ezwork/battle/domain/combat/enemy_runtime.dart';
import 'package:ezwork/battle/domain/combat/hero_runtime.dart';

/// Pure domain combat calculator and event generator.
///
/// Implements GDD damage formulas with defense mitigation, elemental advantage,
/// and combo scaling without any Flutter or Flame dependencies.
class CombatResolver {
  const CombatResolver({
    this.balance = const BattleBalanceDefinition(),
  });

  final BattleBalanceDefinition balance;

  /// Calculates combo damage multiplier based on cascade cycle count.
  ///
  /// - Cycle 1: 1.00x
  /// - Cycle 2: 1.20x
  /// - Cycle 3: 1.45x
  /// - Cycle 4: 1.70x
  /// - Cycle 5+: +0.15x per cycle, capped at 2.30x
  static double calculateComboMultiplier(int comboCycle) {
    if (comboCycle <= 1) return 1;
    if (comboCycle == 2) return 1.20;
    if (comboCycle == 3) return 1.45;
    if (comboCycle == 4) return 1.70;
    final bonus = (comboCycle - 4) * 0.15;
    return math.min(2.30, 1.70 + bonus);
  }

  /// Calculates mitigated damage according to standard GDD formula:
  /// `damage = math.max(1, (rawDamage * 100 / (100 + defense)).round())`
  static int calculateMitigatedDamage(double rawDamage, int defense) {
    if (rawDamage <= 0) return 0;
    final effectiveDefense = math.max(0, defense);
    final mitigated = (rawDamage * 100.0) / (100.0 + effectiveDefense);
    return math.max(1, mitigated.round());
  }

  /// Resolves all tile match groups produced from cascade resolution against
  /// current living heroes and active enemy.
  ///
  /// Returns ordered list of [CombatEvent]s.
  List<CombatEvent> resolveBoardMatches({
    required List<BoardEvent> boardEvents,
    required List<HeroRuntime> heroes,
    required EnemyRuntime enemy,
  }) {
    final combatEvents = <CombatEvent>[];

    final matchedEvents = boardEvents.whereType<TilesMatched>();
    for (final matched in matchedEvents) {
      final comboMult = calculateComboMultiplier(matched.cycle);

      for (final group in matched.matches) {
        if (group.tileType == TileType.heart) {
          // Team healing: externalized baseHeal HP scaled by match count and combo
          final healAmount =
              ((group.count / 3.0) * balance.baseHeal * comboMult).round();
          for (final hero in heroes) {
            if (hero.isAlive) {
              final actual = hero.heal(healAmount);
              if (actual > 0) {
                combatEvents.add(
                  CombatHeroHealed(
                    heroId: hero.id,
                    amount: actual,
                    currentHp: hero.currentHp,
                  ),
                );
              }
            }
          }
        } else {
          if (!enemy.isAlive) continue;

          // Offensive tiles (sword, fire, water, lightning)
          final matchingHeroes = heroes
              .where((h) => h.isAlive && h.element == group.tileType)
              .toList();

          for (final hero in matchingHeroes) {
            if (!enemy.isAlive) break;

            final elementMult = enemy.element != null
                ? hero.element.getElementMultiplier(enemy.element!)
                : 1.0;
            final isCriticalOrEffective = elementMult > 1.0;

            final rawDamage =
                hero.attack * (group.count / 3.0) * comboMult * elementMult;
            final damage = calculateMitigatedDamage(rawDamage, enemy.defense);

            final actualDamage = enemy.takeDamage(damage);
            combatEvents
              ..add(
                CombatEnemyDamaged(
                  enemyId: enemy.id,
                  damage: actualDamage,
                  remainingHp: enemy.currentHp,
                  isCriticalOrEffective: isCriticalOrEffective,
                ),
              )
              ..addAll(enemy.checkPhaseTransitions());

            // Mana generation: externalized manaPerTile per matched tile
            final manaGain = group.count * balance.manaPerTile;
            final actualMana = hero.gainMana(manaGain);
            if (actualMana > 0) {
              combatEvents.add(
                CombatHeroManaGained(
                  heroId: hero.id,
                  amount: actualMana,
                  currentMana: hero.currentMana,
                ),
              );
            }
          }
        }
      }
    }

    return combatEvents;
  }

  /// Selects a hero target from [heroes] according to [targetRule].
  static HeroRuntime? selectEnemyTarget({
    required List<HeroRuntime> heroes,
    required String targetRule,
    int Function(int max)? nextInt,
  }) {
    final livingHeroes = heroes.where((h) => h.isAlive).toList();
    if (livingHeroes.isEmpty) return null;

    switch (targetRule) {
      case 'lowest_hp':
        livingHeroes.sort((a, b) => a.currentHp.compareTo(b.currentHp));
        return livingHeroes.first;
      case 'highest_attack':
        livingHeroes.sort((a, b) => b.attack.compareTo(a.attack));
        return livingHeroes.first;
      case 'random':
      default:
        final index = nextInt != null ? nextInt(livingHeroes.length) : 0;
        return livingHeroes[index % livingHeroes.length];
    }
  }

  /// Resolves enemy action for the current turn.
  ///
  /// Ticks turn counter down. When counter hits 0, attacks a living hero
  /// selected by target rule and resets turn counter.
  List<CombatEvent> resolveEnemyTurn({
    required EnemyRuntime enemy,
    required List<HeroRuntime> heroes,
    int Function(int max)? nextInt,
  }) {
    if (!enemy.isAlive) return const [];

    final events = <CombatEvent>[];
    final remainingTurns = enemy.tickTurnCounter();

    events.add(
      CombatEnemyTurnTicked(
        enemyId: enemy.id,
        remainingTurns: remainingTurns,
      ),
    );

    if (remainingTurns <= 0) {
      final target = selectEnemyTarget(
        heroes: heroes,
        targetRule: enemy.targetRule,
        nextInt: nextInt,
      );

      if (target != null) {
        final damage = calculateMitigatedDamage(
          enemy.attack.toDouble(),
          target.defense,
        );
        final actual = target.takeDamage(damage);

        events
          ..add(
            CombatEnemyAttacked(
              enemyId: enemy.id,
              targetHeroId: target.id,
              damage: actual,
            ),
          )
          ..add(
            CombatHeroDamaged(
              heroId: target.id,
              damage: actual,
              remainingHp: target.currentHp,
            ),
          );
      }

      enemy.resetCounter();
    }

    return events;
  }

  /// Resolves execution of an active hero skill.
  List<CombatEvent> resolveSkillCast({
    required HeroRuntime hero,
    required SkillDefinition skill,
    required EnemyRuntime enemy,
    required List<HeroRuntime> heroes,
  }) {
    if (!hero.isAlive || hero.currentMana < skill.manaCost) return const [];

    hero.spendMana(skill.manaCost);
    final events = <CombatEvent>[
      CombatSkillExecuted(
        heroId: hero.id,
        skillId: skill.id,
        manaSpent: skill.manaCost,
      ),
    ];

    for (final effect in skill.effects) {
      if (effect.type == 'damage' && enemy.isAlive) {
        final elementMult = (effect.tileType != null && enemy.element != null)
            ? effect.tileType!.getElementMultiplier(enemy.element!)
            : 1.0;
        final rawDamage = effect.magnitude * elementMult;
        final damage = calculateMitigatedDamage(rawDamage, enemy.defense);
        final actual = enemy.takeDamage(damage);
        events
          ..add(
            CombatEnemyDamaged(
              enemyId: enemy.id,
              damage: actual,
              remainingHp: enemy.currentHp,
              isCriticalOrEffective: elementMult > 1.0,
            ),
          )
          ..addAll(enemy.checkPhaseTransitions());
      } else if (effect.type == 'heal') {
        for (final ally in heroes) {
          if (ally.isAlive) {
            final actual = ally.heal(effect.magnitude);
            if (actual > 0) {
              events.add(
                CombatHeroHealed(
                  heroId: ally.id,
                  amount: actual,
                  currentHp: ally.currentHp,
                ),
              );
            }
          }
        }
      }
    }

    return events;
  }
}
