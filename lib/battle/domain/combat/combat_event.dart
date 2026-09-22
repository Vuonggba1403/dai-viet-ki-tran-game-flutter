import 'package:meta/meta.dart';

/// Sealed hierarchy of immutable combat events produced during battle resolution.
///
/// Stores scalar snapshots and entity IDs rather than mutable references to
/// domain entities, ensuring event immutability across subsequent turn mutations.
@immutable
sealed class CombatEvent {
  const CombatEvent();
}

class CombatHeroDamaged extends CombatEvent {
  const CombatHeroDamaged({
    required this.heroId,
    required this.damage,
    required this.remainingHp,
  });
  final String heroId;
  final int damage;
  final int remainingHp;

  @override
  String toString() => 'CombatHeroDamaged($heroId, -$damage, HP: $remainingHp)';
}

class CombatHeroHealed extends CombatEvent {
  const CombatHeroHealed({
    required this.heroId,
    required this.amount,
    required this.currentHp,
  });
  final String heroId;
  final int amount;
  final int currentHp;

  @override
  String toString() => 'CombatHeroHealed($heroId, +$amount, HP: $currentHp)';
}

class CombatHeroManaGained extends CombatEvent {
  const CombatHeroManaGained({
    required this.heroId,
    required this.amount,
    required this.currentMana,
  });
  final String heroId;
  final int amount;
  final int currentMana;

  @override
  String toString() =>
      'CombatHeroManaGained($heroId, +$amount, MP: $currentMana)';
}

class CombatEnemyDamaged extends CombatEvent {
  const CombatEnemyDamaged({
    required this.enemyId,
    required this.damage,
    required this.remainingHp,
    required this.isCriticalOrEffective,
  });
  final String enemyId;
  final int damage;
  final int remainingHp;
  final bool isCriticalOrEffective;

  @override
  String toString() =>
      'CombatEnemyDamaged($enemyId, -$damage, HP: $remainingHp)';
}

class CombatEnemyTurnTicked extends CombatEvent {
  const CombatEnemyTurnTicked({
    required this.enemyId,
    required this.remainingTurns,
  });
  final String enemyId;
  final int remainingTurns;

  @override
  String toString() =>
      'CombatEnemyTurnTicked($enemyId, turns: $remainingTurns)';
}

class CombatEnemyAttacked extends CombatEvent {
  const CombatEnemyAttacked({
    required this.enemyId,
    required this.targetHeroId,
    required this.damage,
  });
  final String enemyId;
  final String targetHeroId;
  final int damage;

  @override
  String toString() =>
      'CombatEnemyAttacked($enemyId -> $targetHeroId, dmg: $damage)';
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
    required this.enemyId,
  });
  final int waveNumber;
  final int totalWaves;
  final String enemyId;

  @override
  String toString() =>
      'CombatWaveStarted(wave: $waveNumber/$totalWaves, enemy: $enemyId)';
}

class CombatSkillExecuted extends CombatEvent {
  const CombatSkillExecuted({
    required this.heroId,
    required this.skillId,
    required this.manaSpent,
  });
  final String heroId;
  final String skillId;
  final int manaSpent;

  @override
  String toString() =>
      'CombatSkillExecuted($heroId cast $skillId, -$manaSpent MP)';
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

class CombatBossPhaseChanged extends CombatEvent {
  const CombatBossPhaseChanged({
    required this.enemyId,
    required this.phaseNumber,
    required this.hpThresholdPercent,
  });
  final String enemyId;
  final int phaseNumber;
  final int hpThresholdPercent;

  @override
  String toString() =>
      'CombatBossPhaseChanged($enemyId, phase: $phaseNumber, threshold: $hpThresholdPercent%)';
}
