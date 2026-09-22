import 'dart:math' as math;
import 'package:dai_viet_ki_tran_game/battle/data/models/enemy_definition.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/tile_type.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/combat/combat_event.dart';

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
    int currentPhase = 1,
    Set<int>? triggeredPhases,
  }) : _currentHp = currentHp.clamp(0, maxHp),
       _turnCounter = math.max(0, turnCounter),
       _currentPhase = currentPhase,
       _triggeredPhases = triggeredPhases != null
           ? Set<int>.from(triggeredPhases)
           : {1};

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

  int _currentPhase;
  final Set<int> _triggeredPhases;

  int get currentHp => _currentHp;
  int get turnCounter => _turnCounter;
  bool get isAlive => _currentHp > 0;
  double get hpRatio => maxHp > 0 ? _currentHp / maxHp : 0.0;
  int get currentPhase => _currentPhase;
  Set<int> get triggeredPhases => Set.unmodifiable(_triggeredPhases);

  /// Applies damage, reducing HP down to 0. Returns actual damage taken.
  int takeDamage(int amount) {
    if (amount <= 0 || !isAlive) return 0;
    final previousHp = _currentHp;
    _currentHp = math.max(0, _currentHp - amount);
    return previousHp - _currentHp;
  }

  /// Evaluates crossed boss phase thresholds and yields [CombatBossPhaseChanged] events.
  ///
  /// Supports multi-threshold skipping on high single-hit damage and guarantees
  /// each phase triggers at most once.
  List<CombatBossPhaseChanged> checkPhaseTransitions() {
    if (phases == null || phases!.isEmpty) return const [];

    final events = <CombatBossPhaseChanged>[];
    final currentPercent = maxHp > 0 ? (_currentHp * 100.0) / maxHp : 0.0;

    // Sort phases by phaseNumber ascending to preserve progression order
    final sortedPhases = List<EnemyPhaseDefinition>.from(phases!)
      ..sort((a, b) => a.phaseNumber.compareTo(b.phaseNumber));

    for (final phase in sortedPhases) {
      if (!_triggeredPhases.contains(phase.phaseNumber) &&
          currentPercent <= phase.hpThresholdPercent) {
        _triggeredPhases.add(phase.phaseNumber);
        _currentPhase = phase.phaseNumber;
        events.add(
          CombatBossPhaseChanged(
            enemyId: id,
            phaseNumber: phase.phaseNumber,
            hpThresholdPercent: phase.hpThresholdPercent,
          ),
        );
      }
    }

    return events;
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
      currentPhase: _currentPhase,
      triggeredPhases: Set<int>.from(_triggeredPhases),
    );
  }
}
