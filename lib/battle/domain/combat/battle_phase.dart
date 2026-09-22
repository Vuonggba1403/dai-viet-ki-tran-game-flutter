/// Represents the current phase in the battle turn lifecycle.
///
/// Pure Dart domain model — zero dependencies on Flutter, Flame, or GetIt.
enum BattlePhase {
  /// Initial stage/wave setup before gameplay begins.
  setup,

  /// Waiting for player swap or skill input.
  playerInput,

  /// Match-3 board cascade is resolving animations.
  resolvingBoard,

  /// Applying tile matches (damage, heals, mana generation) to combatants.
  applyingCombat,

  /// Active enemy turn countdown ticks down and executes attack if 0.
  enemyTurn,

  /// All stage waves cleared successfully.
  victory,

  /// All heroes wiped out or turn limit reached.
  defeat,
}
