import 'dart:math' as math;
import 'package:ezwork/battle/data/models/enemy_definition.dart';
import 'package:ezwork/battle/domain/board/tile_type.dart';

/// Runtime combat state of an active enemy.
///
/// Pure Dart domain model — zero dependencies on Flutter, Flame, or GetIt.
class EnemyRuntime {
  EnemyRuntime({
    required this.id,
    required this.nameKey,
    required this.maxHp,
    required int currentHp,
    required this.attack,
    required this.defense,
    required this.initialTurnCounter,
    required this.resetTurnCounter,
    required int turnCounter,
    required this.targetRule,
    this.element,
    this.statusResistance = const [],
    this.phases,
    this.assetKey,
  }) : _currentHp = currentHp.clamp(0, maxHp),
       _turnCounter = math.max(0, turnCounter);

  factory EnemyRuntime.fromDefinition(
    EnemyDefinition def, {
    TileType? element,
  }) {
    return EnemyRuntime(
      id: def.id,
      nameKey: def.nameKey,
      maxHp: def.maxHp,
      currentHp: def.maxHp,
      attack: def.attack,
      defense: def.defense,
      initialTurnCounter: def.initialTurnCounter,
      resetTurnCounter: def.resetTurnCounter,
      turnCounter: def.initialTurnCounter,
      targetRule: def.targetRule,
      element: element,
      statusResistance: def.statusResistance,
      phases: def.phases,
      assetKey: def.assetKey,
    );
  }

  final String id;
  final String nameKey;
  final int maxHp;
  int _currentHp;
  final int attack;
  final int defense;
  final int initialTurnCounter;
  final int resetTurnCounter;
  int _turnCounter;
  final String targetRule;
  final TileType? element;
  final List<String> statusResistance;
  final List<EnemyPhaseDefinition>? phases;
  final String? assetKey;

  int get currentHp => _currentHp;
  int get turnCounter => _turnCounter;
  bool get isAlive => _currentHp > 0;
  double get hpRatio => maxHp > 0 ? _currentHp / maxHp : 0.0;

  /// Applies damage, reducing HP down to 0. Returns actual damage taken.
  int takeDamage(int amount) {
    if (amount <= 0 || !isAlive) return 0;
    final previousHp = _currentHp;
    _currentHp = math.max(0, _currentHp - amount);
    return previousHp - _currentHp;
  }

  /// Ticks turn counter down by 1. Returns remaining turns.
  int tickTurnCounter() {
    if (_turnCounter > 0) {
      _turnCounter--;
    }
    return _turnCounter;
  }

  /// Resets turn counter to [resetTurnCounter] after attacking.
  void resetCounter() {
    _turnCounter = resetTurnCounter;
  }

  EnemyRuntime copy() {
    return EnemyRuntime(
      id: id,
      nameKey: nameKey,
      maxHp: maxHp,
      currentHp: _currentHp,
      attack: attack,
      defense: defense,
      initialTurnCounter: initialTurnCounter,
      resetTurnCounter: resetTurnCounter,
      turnCounter: _turnCounter,
      targetRule: targetRule,
      element: element,
      statusResistance: statusResistance,
      phases: phases,
      assetKey: assetKey,
    );
  }
}
