import 'package:ezwork/battle/data/data_sources/local_battle_content_data_source.dart';
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
  Future<BattleContent> getBattleContent({bool forceRefresh = false}) async {
    if (_cachedContent != null && !forceRefresh) {
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

    validateContent(
      heroes: heroes,
      skills: skills,
      enemies: enemies,
      stages: stages,
    );

    final content = BattleContent(
      heroes: List<HeroDefinition>.unmodifiable(heroes),
      skills: List<SkillDefinition>.unmodifiable(skills),
      enemies: List<EnemyDefinition>.unmodifiable(enemies),
      stages: List<StageDefinition>.unmodifiable(stages),
    );

    _cachedContent = content;
    return content;
  }

  /// Validates all content integrity constraints:
  /// - Unique IDs within each category
  /// - Reference integrity (hero -> skill, stage wave -> enemy)
  /// - Positive stats (HP, attack, turn counter, turn limit)
  /// - Non-empty stages and waves
  static void validateContent({
    required List<HeroDefinition> heroes,
    required List<SkillDefinition> skills,
    required List<EnemyDefinition> enemies,
    required List<StageDefinition> stages,
  }) {
    // 1. Validate Hero duplicate IDs and stats
    final heroIds = <String>{};
    for (final hero in heroes) {
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
    }

    // 2. Validate Skill duplicate IDs
    final skillIds = <String>{};
    for (final skill in skills) {
      if (!skillIds.add(skill.id)) {
        throw ContentValidationException('Duplicate skill ID: "${skill.id}"');
      }
      if (skill.manaCost < 0) {
        throw ContentValidationException(
          'Skill "${skill.id}" has negative manaCost: ${skill.manaCost}',
        );
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
    }

    // 4. Validate Stage duplicate IDs, non-empty waves, and enemy references
    if (stages.isEmpty) {
      throw const ContentValidationException('Stages list must not be empty');
    }

    final stageIds = <String>{};
    for (final stage in stages) {
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
      for (final wave in stage.waves) {
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
    }
  }
}
