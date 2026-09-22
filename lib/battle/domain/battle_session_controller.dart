import 'package:ezwork/battle/data/models/enemy_definition.dart';
import 'package:ezwork/battle/data/models/hero_definition.dart';
import 'package:ezwork/battle/data/models/skill_definition.dart';
import 'package:ezwork/battle/data/models/stage_definition.dart';
import 'package:ezwork/battle/domain/board/board.dart';
import 'package:ezwork/battle/domain/board/board_resolver.dart';
import 'package:ezwork/battle/domain/board/swap.dart';
import 'package:ezwork/battle/domain/combat/battle_phase.dart';
import 'package:ezwork/battle/domain/combat/combat_event.dart';
import 'package:ezwork/battle/domain/combat/combat_resolver.dart';
import 'package:ezwork/battle/domain/combat/enemy_runtime.dart';
import 'package:ezwork/battle/domain/combat/hero_runtime.dart';
import 'package:ezwork/battle/domain/random/random_service.dart';
import 'package:meta/meta.dart';

/// Pure Dart controller that maintains runtime state for an active battle session's board
/// and combat turn lifecycle.
///
/// Encapsulates board mutation, RNG state, next tile ID allocation, 4-hero team state,
/// active wave enemy, combat event resolution, and phase state machine without any
/// dependency on Flutter, Flame, or GetIt.
class BattleSessionController {
  BattleSessionController({
    required Board initialBoard,
    required RandomService randomService,
    int initialTileId = 10000,
    StageDefinition? stage,
    List<HeroDefinition>? heroDefinitions,
    List<EnemyDefinition>? enemyDefinitions,
    List<SkillDefinition>? skillDefinitions,
    CombatResolver combatResolver = const CombatResolver(),
    void Function()? onStateChanged,
  }) : _currentBoard = initialBoard,
       _randomService = randomService,
       _nextTileId = initialTileId,
       _stage = stage,
       _enemyDefinitions = enemyDefinitions,
       _skillDefinitions = skillDefinitions,
       _combatResolver = combatResolver,
       _onStateChanged = onStateChanged {
    _advanceNextTileId();

    if (heroDefinitions != null && heroDefinitions.isNotEmpty) {
      _heroes = heroDefinitions
          .take(4)
          .map(HeroRuntime.fromDefinition)
          .toList();
    } else {
      _heroes = [];
    }

    if (_stage != null &&
        _enemyDefinitions != null &&
        _stage.waves.isNotEmpty) {
      _remainingTurns = _stage.turnLimit;
      _loadWave(0);
      _currentPhase = BattlePhase.playerInput;
    } else {
      _currentPhase = BattlePhase.playerInput;
    }
  }

  Board _currentBoard;
  final RandomService _randomService;
  int _nextTileId;
  int _comboCount = 0;

  final StageDefinition? _stage;
  final List<EnemyDefinition>? _enemyDefinitions;
  final List<SkillDefinition>? _skillDefinitions;
  final CombatResolver _combatResolver;
  final void Function()? _onStateChanged;

  late final List<HeroRuntime> _heroes;
  EnemyRuntime? _currentEnemy;
  int _currentWaveIndex = 0;
  int _remainingTurns = 30;
  int _totalScore = 0;
  BattlePhase _currentPhase = BattlePhase.setup;
  List<CombatEvent> _lastCombatEvents = const [];

  /// The current settled board state.
  Board get currentBoard => _currentBoard;

  /// The RNG service powering board generation and refills.
  RandomService get randomService => _randomService;

  /// The highest combo count achieved from the last resolved swap.
  int get comboCount => _comboCount;

  /// The active 4-hero team runtime instances.
  List<HeroRuntime> get heroes => List.unmodifiable(_heroes);

  /// The active wave enemy runtime instance, or null if board-only.
  EnemyRuntime? get currentEnemy => _currentEnemy;

  /// Current 1-based wave number.
  int get currentWaveNumber => _currentWaveIndex + 1;

  /// Total waves defined in the current stage.
  int get totalWaves => _stage?.waves.length ?? 1;

  /// Remaining turns before defeat by move limit.
  int get remainingTurns => _remainingTurns;

  /// Cumulative combat score for this battle session.
  int get totalScore => _totalScore;

  /// The current turn lifecycle phase.
  BattlePhase get currentPhase => _currentPhase;

  /// The combat events generated from the most recent resolution.
  List<CombatEvent> get lastCombatEvents => _lastCombatEvents;

  /// The next unique runtime ID to be allocated for newly spawned tiles.
  @visibleForTesting
  int get nextTileId => _nextTileId;

  void _loadWave(int waveIndex) {
    if (_stage == null || _enemyDefinitions == null) return;
    if (waveIndex >= _stage.waves.length) return;

    _currentWaveIndex = waveIndex;
    final wave = _stage.waves[waveIndex];
    if (wave.enemyIds.isEmpty) return;

    final enemyId = wave.enemyIds.first;
    final enemyDef = _enemyDefinitions.firstWhere(
      (e) => e.id == enemyId,
      orElse: () => _enemyDefinitions.first,
    );
    _currentEnemy = EnemyRuntime.fromDefinition(enemyDef);
  }

  /// Attempts to perform a swap on the current board.
  ///
  /// If valid, updates [currentBoard], advances [nextTileId], updates [comboCount],
  /// executes combat resolution against [currentEnemy], updates turn countdowns,
  /// and returns the complete [BoardResolution].
  /// If invalid, leaves [currentBoard] untouched and returns the rejected resolution.
  BoardResolution attemptSwap(Swap swap) {
    final resolution = BoardResolver.resolveSwap(
      _currentBoard,
      swap,
      _randomService,
      nextTileId: _nextTileId,
    );

    if (resolution.isSuccess) {
      _currentBoard = resolution.finalBoard;
      _comboCount = resolution.comboCount;
      _advanceNextTileId();

      // If active combat session is configured, resolve combat mechanics
      if (_currentEnemy != null && _heroes.isNotEmpty) {
        _executeCombatTurn(resolution);
      }
    }

    return resolution;
  }

  void _executeCombatTurn(BoardResolution resolution) {
    _remainingTurns--;
    _totalScore += _comboCount * 100;
    _currentPhase = BattlePhase.applyingCombat;

    final events = <CombatEvent>[];

    // 1. Resolve player tile matches (damage, team heal, mana gain)
    final matchEvents = _combatResolver.resolveBoardMatches(
      boardEvents: resolution.events,
      heroes: _heroes,
      enemy: _currentEnemy!,
    );
    events.addAll(matchEvents);

    // 2. Check if active enemy was defeated
    if (!_currentEnemy!.isAlive) {
      events.add(CombatWaveCleared(waveNumber: currentWaveNumber));
      _totalScore += 500;

      if (_currentWaveIndex + 1 < totalWaves) {
        _loadWave(_currentWaveIndex + 1);
        events.add(
          CombatWaveStarted(
            waveNumber: currentWaveNumber,
            totalWaves: totalWaves,
            enemy: _currentEnemy!,
          ),
        );
        _currentPhase = BattlePhase.playerInput;
      } else {
        // All waves cleared -> Victory!
        _currentPhase = BattlePhase.victory;
        events.add(CombatVictorious(finalScore: _totalScore));
      }
    } else {
      // 3. Enemy counter turn
      _currentPhase = BattlePhase.enemyTurn;
      final enemyEvents = _combatResolver.resolveEnemyTurn(
        enemy: _currentEnemy!,
        heroes: _heroes,
        nextInt: _randomService.nextInt,
      );
      events.addAll(enemyEvents);

      // 4. Check defeat conditions
      if (_heroes.every((h) => !h.isAlive)) {
        _currentPhase = BattlePhase.defeat;
        events.add(const CombatDefeated(reason: 'Tất cả anh hùng đã tử trận'));
      } else if (_remainingTurns <= 0) {
        _currentPhase = BattlePhase.defeat;
        events.add(const CombatDefeated(reason: 'Hết lượt đi'));
      } else {
        _currentPhase = BattlePhase.playerInput;
      }
    }

    _lastCombatEvents = List.unmodifiable(events);
    _onStateChanged?.call();
  }

  /// Whether the hero with [heroId] is alive and has sufficient mana to cast skill.
  bool canCastSkill(String heroId) {
    if (_currentPhase != BattlePhase.playerInput) return false;
    final hero = _heroes.where((h) => h.id == heroId).firstOrNull;
    if (hero == null || !hero.isAlive) return false;

    final skill = _skillDefinitions
        ?.where((s) => s.id == hero.activeSkillId)
        .firstOrNull;
    if (skill == null) return false;

    return hero.currentMana >= skill.manaCost;
  }

  /// Casts the active skill for the hero with [heroId].
  List<CombatEvent> castSkill(String heroId) {
    if (!canCastSkill(heroId) || _currentEnemy == null) return const [];

    final hero = _heroes.firstWhere((h) => h.id == heroId);
    final skill = _skillDefinitions!.firstWhere(
      (s) => s.id == hero.activeSkillId,
    );

    final events = <CombatEvent>[];
    final skillEvents = _combatResolver.resolveSkillCast(
      hero: hero,
      skill: skill,
      enemy: _currentEnemy!,
      heroes: _heroes,
    );
    events.addAll(skillEvents);

    if (!_currentEnemy!.isAlive) {
      events.add(CombatWaveCleared(waveNumber: currentWaveNumber));
      _totalScore += 500;

      if (_currentWaveIndex + 1 < totalWaves) {
        _loadWave(_currentWaveIndex + 1);
        events.add(
          CombatWaveStarted(
            waveNumber: currentWaveNumber,
            totalWaves: totalWaves,
            enemy: _currentEnemy!,
          ),
        );
        _currentPhase = BattlePhase.playerInput;
      } else {
        _currentPhase = BattlePhase.victory;
        events.add(CombatVictorious(finalScore: _totalScore));
      }
    }

    _lastCombatEvents = List.unmodifiable(events);
    _onStateChanged?.call();
    return events;
  }

  /// Resets the controller with a newly generated board.
  void resetBoard(Board newBoard) {
    _currentBoard = newBoard;
    _comboCount = 0;
    _advanceNextTileId();
  }

  void _advanceNextTileId() {
    var maxId = _nextTileId;
    for (var r = 0; r < Board.rowCount; r++) {
      for (var c = 0; c < Board.columnCount; c++) {
        final tile = _currentBoard.getTileAt(r, c);
        if (tile != null && tile.id >= maxId) {
          maxId = tile.id + 1;
        }
      }
    }
    _nextTileId = maxId;
  }
}
