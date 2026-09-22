import 'package:ezwork/battle/domain/combat/enemy_runtime.dart';
import 'package:ezwork/battle/domain/combat/hero_runtime.dart';
import 'package:meta/meta.dart';

/// Sealed hierarchy of combat events produced during battle resolution.
@immutable
sealed class CombatEvent {
  const CombatEvent();
}

class CombatHeroDamaged extends CombatEvent {
  const CombatHeroDamaged({
    required this.hero,
    required this.damage,
    required this.remainingHp,
  });
  final HeroRuntime hero;
  final int damage;
  final int remainingHp;

  @override
  String toString() =>
      'CombatHeroDamaged(${hero.id}, -$damage, HP: $remainingHp)';
}

class CombatHeroHealed extends CombatEvent {
  const CombatHeroHealed({
    required this.hero,
    required this.amount,
    required this.currentHp,
  });
  final HeroRuntime hero;
  final int amount;
  final int currentHp;

  @override
  String toString() => 'CombatHeroHealed(${hero.id}, +$amount, HP: $currentHp)';
}

class CombatHeroManaGained extends CombatEvent {
  const CombatHeroManaGained({
    required this.hero,
    required this.amount,
    required this.currentMana,
  });
  final HeroRuntime hero;
  final int amount;
  final int currentMana;

  @override
  String toString() =>
      'CombatHeroManaGained(${hero.id}, +$amount, MP: $currentMana)';
}

class CombatEnemyDamaged extends CombatEvent {
  const CombatEnemyDamaged({
    required this.enemy,
    required this.damage,
    required this.remainingHp,
    required this.isCriticalOrEffective,
  });
  final EnemyRuntime enemy;
  final int damage;
  final int remainingHp;
  final bool isCriticalOrEffective;

  @override
  String toString() =>
      'CombatEnemyDamaged(${enemy.id}, -$damage, HP: $remainingHp)';
}

class CombatEnemyTurnTicked extends CombatEvent {
  const CombatEnemyTurnTicked({
    required this.enemy,
    required this.remainingTurns,
  });
  final EnemyRuntime enemy;
  final int remainingTurns;

  @override
  String toString() =>
      'CombatEnemyTurnTicked(${enemy.id}, turns: $remainingTurns)';
}

class CombatEnemyAttacked extends CombatEvent {
  const CombatEnemyAttacked({
    required this.enemy,
    required this.targetHero,
    required this.damage,
  });
  final EnemyRuntime enemy;
  final HeroRuntime targetHero;
  final int damage;

  @override
  String toString() =>
      'CombatEnemyAttacked(${enemy.id} -> ${targetHero.id}, dmg: $damage)';
}

class CombatWaveCleared extends CombatEvent {
  const CombatWaveCleared({required this.waveNumber});
  final int waveNumber;

  @override
  String toString() => 'CombatWaveCleared(wave: $waveNumber)';
}

class CombatWaveStarted extends CombatEvent {
  const CombatWaveStarted({
    required this.waveNumber,
    required this.totalWaves,
    required this.enemy,
  });
  final int waveNumber;
  final int totalWaves;
  final EnemyRuntime enemy;

  @override
  String toString() =>
      'CombatWaveStarted(wave: $waveNumber/$totalWaves, enemy: ${enemy.id})';
}

class CombatSkillExecuted extends CombatEvent {
  const CombatSkillExecuted({
    required this.hero,
    required this.skillId,
    required this.manaSpent,
  });
  final HeroRuntime hero;
  final String skillId;
  final int manaSpent;

  @override
  String toString() =>
      'CombatSkillExecuted(${hero.id} cast $skillId, -$manaSpent MP)';
}

class CombatVictorious extends CombatEvent {
  const CombatVictorious({required this.finalScore});
  final int finalScore;

  @override
  String toString() => 'CombatVictorious(score: $finalScore)';
}

class CombatDefeated extends CombatEvent {
  const CombatDefeated({required this.reason});
  final String reason;

  @override
  String toString() => 'CombatDefeated(reason: $reason)';
}
