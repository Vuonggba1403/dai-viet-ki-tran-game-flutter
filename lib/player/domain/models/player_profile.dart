import 'package:flutter/foundation.dart';

/// Player profile model storing level, energy, gold, and gems.
@immutable
class PlayerProfile {
  const PlayerProfile({
    this.level = 1,
    this.currentEnergy = 9,
    this.maxEnergy = 9,
    this.gold = 5000,
    this.gem = 100,
  });

  final int level;
  final int currentEnergy;
  final int maxEnergy;
  final int gold;
  final int gem;

  PlayerProfile copyWith({
    int? level,
    int? currentEnergy,
    int? maxEnergy,
    int? gold,
    int? gem,
  }) {
    return PlayerProfile(
      level: level ?? this.level,
      currentEnergy: currentEnergy ?? this.currentEnergy,
      maxEnergy: maxEnergy ?? this.maxEnergy,
      gold: gold ?? this.gold,
      gem: gem ?? this.gem,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerProfile &&
          runtimeType == other.runtimeType &&
          level == other.level &&
          currentEnergy == other.currentEnergy &&
          maxEnergy == other.maxEnergy &&
          gold == other.gold &&
          gem == other.gem;

  @override
  int get hashCode => Object.hash(level, currentEnergy, maxEnergy, gold, gem);
}
