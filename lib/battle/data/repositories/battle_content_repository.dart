import 'package:ezwork/battle/data/data_sources/local_battle_content_data_source.dart';
import 'package:ezwork/battle/data/models/battle_balance_definition.dart';
import 'package:ezwork/battle/data/models/battle_content.dart';
import 'package:ezwork/battle/data/models/enemy_definition.dart';
import 'package:ezwork/battle/data/models/hero_definition.dart';
import 'package:ezwork/battle/data/models/skill_definition.dart';
import 'package:ezwork/battle/data/models/stage_definition.dart';

/// Exception thrown when game content validation fails.
class ContentValidationException implements Exception {
  const ContentValidationException(this.message);
  final String message;

  @override
  String toString() => 'ContentValidationException: $message';
}

/// Repository responsible for loading, parsing, validating, and caching [BattleContent].
class BattleContentRepository {
  BattleContentRepository({
    required LocalBattleContentDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final LocalBattleContentDataSource _localDataSource;
  BattleContent? _cachedContent;

  /// Loads and validates battle content from JSON. Caches results in-memory.
  Future<BattleContent> getBattleContent({
    bool forceRefresh = false,
    BattleBalanceDefinition? customBalance,
  }) async {
    if (_cachedContent != null && !forceRefresh && customBalance == null) {
      return _cachedContent!;
    }

    final rawHeroes = await _localDataSource.loadHeroesJson();
    final rawSkills = await _localDataSource.loadSkillsJson();
    final rawEnemies = await _localDataSource.loadEnemiesJson();
    final rawStages = await _localDataSource.loadStagesJson();

    final heroes = rawHeroes
        .map((e) => HeroDefinition.fromJson(e as Map<String, dynamic>))
        .toList();
    final skills = rawSkills
        .map((e) => SkillDefinition.fromJson(e as Map<String, dynamic>))
        .toList();
    final enemies = rawEnemies
        .map((e) => EnemyDefinition.fromJson(e as Map<String, dynamic>))
        .toList();
    final stages = rawStages
        .map((e) => StageDefinition.fromJson(e as Map<String, dynamic>))
        .toList();

    final balance = customBalance ?? const BattleBalanceDefinition();

    validateContent(
      heroes: heroes,
      skills: skills,
      enemies: enemies,
      stages: stages,
      balance: balance,
    );

    final content = BattleContent(
      heroes: List<HeroDefinition>.unmodifiable(heroes),
      skills: List<SkillDefinition>.unmodifiable(skills),
      enemies: List<EnemyDefinition>.unmodifiable(enemies),
      stages: List<StageDefinition>.unmodifiable(stages),
      balance: balance,
    );

    _cachedContent = content;
    return content;
  }

  static final _idRegex = RegExp(r'^[a-z0-9]+(_[a-z0-9]+)*$');

  /// Validates all content integrity constraints:
  /// - Unique IDs and snake_case format within each category
  /// - Reference integrity (hero -> skill, stage wave -> enemy)
  /// - Non-empty collections (heroes, skills, enemies, stages, effects, waves)
  /// - Positive stats (HP, attack, turn counter, turn limit)
  /// - Starting mana within bounds [0, maxMana]
  /// - Skill effect magnitudes and durations >= 0
  /// - Enemy boss phases sequential and hpThresholdPercent in [0, 100]
  /// - Stage wave numbers sequential and rewards non-negative
  /// - Non-negative battle balance parameters
  static void validateContent({
    required List<HeroDefinition> heroes,
    required List<SkillDefinition> skills,
    required List<EnemyDefinition> enemies,
    required List<StageDefinition> stages,
    BattleBalanceDefinition balance = const BattleBalanceDefinition(),
  }) {
    if (balance.baseHeal < 0 ||
        balance.manaPerTile < 0 ||
        balance.scorePerCombo < 0 ||
        balance.scorePerWaveClear < 0) {
      throw const ContentValidationException(
        'Battle balance values must not be negative',
      );
    }
    if (heroes.isEmpty) {
      throw const ContentValidationException('Heroes list must not be empty');
    }
    if (skills.isEmpty) {
      throw const ContentValidationException('Skills list must not be empty');
    }
    if (enemies.isEmpty) {
      throw const ContentValidationException('Enemies list must not be empty');
    }
    if (stages.isEmpty) {
      throw const ContentValidationException('Stages list must not be empty');
    }

    // 1. Validate Hero duplicate IDs and stats
    final heroIds = <String>{};
    for (final hero in heroes) {
      if (hero.id.isEmpty || !_idRegex.hasMatch(hero.id)) {
        throw ContentValidationException(
          'Hero has invalid ID format: "${hero.id}"',
        );
      }
      if (!heroIds.add(hero.id)) {
        throw ContentValidationException('Duplicate hero ID: "${hero.id}"');
      }
      if (hero.baseHp <= 0) {
        throw ContentValidationException(
          'Hero "${hero.id}" has non-positive baseHp: ${hero.baseHp}',
        );
      }
      if (hero.baseAttack <= 0) {
        throw ContentValidationException(
          'Hero "${hero.id}" has non-positive baseAttack: ${hero.baseAttack}',
        );
      }
      if (hero.baseDefense < 0) {
        throw ContentValidationException(
          'Hero "${hero.id}" has negative baseDefense: ${hero.baseDefense}',
        );
      }
      if (hero.maxMana <= 0) {
        throw ContentValidationException(
          'Hero "${hero.id}" has non-positive maxMana: ${hero.maxMana}',
        );
      }
      if (hero.startingMana < 0 || hero.startingMana > hero.maxMana) {
        throw ContentValidationException(
          'Hero "${hero.id}" has invalid startingMana: ${hero.startingMana} (maxMana: ${hero.maxMana})',
        );
      }
    }

    // 2. Validate Skill duplicate IDs and effects
    final skillIds = <String>{};
    for (final skill in skills) {
      if (skill.id.isEmpty || !_idRegex.hasMatch(skill.id)) {
        throw ContentValidationException(
          'Skill has invalid ID format: "${skill.id}"',
        );
      }
      if (!skillIds.add(skill.id)) {
        throw ContentValidationException('Duplicate skill ID: "${skill.id}"');
      }
      if (skill.manaCost < 0) {
        throw ContentValidationException(
          'Skill "${skill.id}" has negative manaCost: ${skill.manaCost}',
        );
      }
      if (skill.effects.isEmpty) {
        throw ContentValidationException(
          'Skill "${skill.id}" has no effects defined',
        );
      }
      for (final effect in skill.effects) {
        if (effect.magnitude < 0) {
          throw ContentValidationException(
            'Skill "${skill.id}" effect has negative magnitude: ${effect.magnitude}',
          );
        }
        if (effect.duration < 0) {
          throw ContentValidationException(
            'Skill "${skill.id}" effect has negative duration: ${effect.duration}',
          );
        }
        if (effect.count != null && effect.count! < 0) {
          throw ContentValidationException(
            'Skill "${skill.id}" effect has negative count: ${effect.count}',
          );
        }
      }
    }

    // Check hero -> skill reference integrity
    for (final hero in heroes) {
      if (!skillIds.contains(hero.activeSkillId)) {
        throw ContentValidationException(
          'Hero "${hero.id}" references non-existent activeSkillId: "${hero.activeSkillId}"',
        );
      }
    }

    // 3. Validate Enemy duplicate IDs and stats
    final enemyIds = <String>{};
    for (final enemy in enemies) {
      if (enemy.id.isEmpty || !_idRegex.hasMatch(enemy.id)) {
        throw ContentValidationException(
          'Enemy has invalid ID format: "${enemy.id}"',
        );
      }
      if (!enemyIds.add(enemy.id)) {
        throw ContentValidationException('Duplicate enemy ID: "${enemy.id}"');
      }
      if (enemy.maxHp <= 0) {
        throw ContentValidationException(
          'Enemy "${enemy.id}" has non-positive maxHp: ${enemy.maxHp}',
        );
      }
      if (enemy.attack <= 0) {
        throw ContentValidationException(
          'Enemy "${enemy.id}" has non-positive attack: ${enemy.attack}',
        );
      }
      if (enemy.defense < 0) {
        throw ContentValidationException(
          'Enemy "${enemy.id}" has negative defense: ${enemy.defense}',
        );
      }
      if (enemy.initialTurnCounter <= 0) {
        throw ContentValidationException(
          'Enemy "${enemy.id}" has non-positive initialTurnCounter: ${enemy.initialTurnCounter}',
        );
      }
      if (enemy.resetTurnCounter <= 0) {
        throw ContentValidationException(
          'Enemy "${enemy.id}" has non-positive resetTurnCounter: ${enemy.resetTurnCounter}',
        );
      }
      if (enemy.phases != null && enemy.phases!.isNotEmpty) {
        for (var i = 0; i < enemy.phases!.length; i++) {
          final phase = enemy.phases![i];
          if (phase.phaseNumber != i + 1) {
            throw ContentValidationException(
              'Enemy "${enemy.id}" phaseNumber must be ${i + 1}, got ${phase.phaseNumber}',
            );
          }
          if (phase.hpThresholdPercent < 0 || phase.hpThresholdPercent > 100) {
            throw ContentValidationException(
              'Enemy "${enemy.id}" phase ${phase.phaseNumber} hpThresholdPercent must be between 0 and 100: ${phase.hpThresholdPercent}',
            );
          }
        }
      }
    }

    // 4. Validate Stage duplicate IDs, non-empty waves, and enemy references
    final stageIds = <String>{};
    for (final stage in stages) {
      if (stage.id.isEmpty || !_idRegex.hasMatch(stage.id)) {
        throw ContentValidationException(
          'Stage has invalid ID format: "${stage.id}"',
        );
      }
      if (!stageIds.add(stage.id)) {
        throw ContentValidationException('Duplicate stage ID: "${stage.id}"');
      }
      if (stage.turnLimit <= 0) {
        throw ContentValidationException(
          'Stage "${stage.id}" has non-positive turnLimit: ${stage.turnLimit}',
        );
      }
      if (stage.waves.isEmpty) {
        throw ContentValidationException(
          'Stage "${stage.id}" has no waves defined',
        );
      }
      for (var i = 0; i < stage.waves.length; i++) {
        final wave = stage.waves[i];
        if (wave.waveNumber != i + 1) {
          throw ContentValidationException(
            'Stage "${stage.id}" wave number must be ${i + 1}, got ${wave.waveNumber}',
          );
        }
        if (wave.enemyIds.isEmpty) {
          throw ContentValidationException(
            'Stage "${stage.id}" wave ${wave.waveNumber} has no enemies',
          );
        }
        for (final eId in wave.enemyIds) {
          if (!enemyIds.contains(eId)) {
            throw ContentValidationException(
              'Stage "${stage.id}" wave ${wave.waveNumber} references non-existent enemy ID: "$eId"',
            );
          }
        }
      }
      if (stage.firstClearReward.values.any((v) => v < 0)) {
        throw ContentValidationException(
          'Stage "${stage.id}" has negative value in firstClearReward',
        );
      }
      if (stage.repeatReward.values.any((v) => v < 0)) {
        throw ContentValidationException(
          'Stage "${stage.id}" has negative value in repeatReward',
        );
      }
    }
  }
}
