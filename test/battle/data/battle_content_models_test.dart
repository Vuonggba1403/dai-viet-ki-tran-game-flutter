import 'dart:convert';

import 'package:ezwork/battle/data/models/battle_content.dart';
import 'package:ezwork/battle/data/models/enemy_definition.dart';
import 'package:ezwork/battle/data/models/hero_definition.dart';
import 'package:ezwork/battle/data/models/skill_definition.dart';
import 'package:ezwork/battle/data/models/stage_definition.dart';
import 'package:ezwork/battle/domain/board/tile_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Battle Content Models', () {
    test('HeroDefinition serializes and deserializes correctly', () {
      const hero = HeroDefinition(
        id: 'dinh_bo_linh',
        nameKey: 'hero_dinh_bo_linh',
        element: TileType.fire,
        heroClass: 'commander',
        baseHp: 1200,
        baseAttack: 150,
        baseDefense: 80,
        maxMana: 100,
        startingMana: 20,
        activeSkillId: 'skill_hoa_long',
      );

      final json = hero.toJson();
      expect(json['id'], equals('dinh_bo_linh'));
      expect(json['element'], equals('fire'));

      final fromJson = HeroDefinition.fromJson(json);
      expect(fromJson, equals(hero));
    });

    test('SkillDefinition and SkillEffectDefinition serialize correctly', () {
      const skill = SkillDefinition(
        id: 'skill_hoa_long',
        nameKey: 'skill_hoa_long_name',
        manaCost: 50,
        targetType: 'single_enemy',
        effects: [
          SkillEffectDefinition(
            type: 'damage',
            magnitude: 250,
            duration: 0,
            tileType: TileType.fire,
          ),
        ],
      );

      final jsonString = jsonEncode(skill.toJson());
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      final fromJson = SkillDefinition.fromJson(decoded);
      expect(fromJson, equals(skill));
    });

    test('EnemyDefinition and EnemyPhaseDefinition serialize correctly', () {
      const enemy = EnemyDefinition(
        id: 'necromancer',
        nameKey: 'enemy_necromancer_name',
        maxHp: 1200,
        attack: 85,
        defense: 40,
        initialTurnCounter: 3,
        resetTurnCounter: 3,
        targetRule: 'random',
        statusResistance: ['stun'],
        phases: [
          EnemyPhaseDefinition(
            phaseNumber: 1,
            hpThresholdPercent: 100,
            descriptionKey: 'phase_1',
          ),
        ],
      );

      final jsonString = jsonEncode(enemy.toJson());
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      final fromJson = EnemyDefinition.fromJson(decoded);
      expect(fromJson, equals(enemy));
    });

    test('StageDefinition and StageWaveDefinition serialize correctly', () {
      const stage = StageDefinition(
        id: 'stage_1',
        displayNameKey: 'stage_1_name',
        turnLimit: 30,
        firstClearReward: {'gold': 100},
        repeatReward: {'gold': 30},
        waves: [
          StageWaveDefinition(waveNumber: 1, enemyIds: ['bandit']),
        ],
      );

      final jsonString = jsonEncode(stage.toJson());
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      final fromJson = StageDefinition.fromJson(decoded);
      expect(fromJson, equals(stage));
    });

    test('BattleContent wraps all definitions', () {
      const content = BattleContent(
        heroes: [],
        skills: [],
        enemies: [],
        stages: [],
      );

      final jsonString = jsonEncode(content.toJson());
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      final fromJson = BattleContent.fromJson(decoded);
      expect(fromJson, equals(content));
    });
  });
}
