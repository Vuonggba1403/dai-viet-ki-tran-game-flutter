import 'package:ezwork/battle/data/data_sources/local_battle_content_data_source.dart';
import 'package:ezwork/battle/data/repositories/battle_content_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDataSource implements LocalBattleContentDataSource {
  _FakeDataSource({
    required this.heroes,
    required this.skills,
    required this.enemies,
    required this.stages,
  });

  final List<dynamic> heroes;
  final List<dynamic> skills;
  final List<dynamic> enemies;
  final List<dynamic> stages;

  @override
  Future<List<dynamic>> loadHeroesJson() async => heroes;

  @override
  Future<List<dynamic>> loadSkillsJson() async => skills;

  @override
  Future<List<dynamic>> loadEnemiesJson() async => enemies;

  @override
  Future<List<dynamic>> loadStagesJson() async => stages;
}

void main() {
  group('BattleContentRepository', () {
    late List<Map<String, dynamic>> validHeroes;
    late List<Map<String, dynamic>> validSkills;
    late List<Map<String, dynamic>> validEnemies;
    late List<Map<String, dynamic>> validStages;

    setUp(() {
      validSkills = [
        {
          'id': 'skill_fire',
          'name_key': 'Fire Skill',
          'mana_cost': 50,
          'target_type': 'single_enemy',
          'effects': [
            {
              'type': 'damage',
              'magnitude': 100,
              'duration': 0,
              'tile_type': 'fire',
            },
          ],
        },
      ];

      validHeroes = [
        {
          'id': 'hero_1',
          'name_key': 'Hero 1',
          'element': 'fire',
          'hero_class': 'warrior',
          'base_hp': 1000,
          'base_attack': 100,
          'base_defense': 50,
          'max_mana': 100,
          'starting_mana': 0,
          'active_skill_id': 'skill_fire',
        },
      ];

      validEnemies = [
        {
          'id': 'enemy_1',
          'name_key': 'Enemy 1',
          'max_hp': 500,
          'attack': 40,
          'defense': 20,
          'initial_turn_counter': 3,
          'reset_turn_counter': 3,
          'target_rule': 'lowest_hp',
          'status_resistance': <String>[],
        },
      ];

      validStages = [
        {
          'id': 'stage_1',
          'display_name_key': 'Stage 1',
          'turn_limit': 30,
          'waves': [
            {
              'wave_number': 1,
              'enemy_ids': ['enemy_1'],
            },
          ],
        },
      ];
    });

    test('loads and caches valid content successfully', () async {
      final ds = _FakeDataSource(
        heroes: validHeroes,
        skills: validSkills,
        enemies: validEnemies,
        stages: validStages,
      );
      final repo = BattleContentRepository(localDataSource: ds);

      final content = await repo.getBattleContent();
      expect(content.heroes.length, equals(1));
      expect(content.skills.length, equals(1));
      expect(content.enemies.length, equals(1));
      expect(content.stages.length, equals(1));

      // Second call returns cached instance
      final cached = await repo.getBattleContent();
      expect(identical(content, cached), isTrue);
    });

    test('throws ContentValidationException when hero ID is duplicated', () {
      final duplicateHeroes = [
        ...validHeroes,
        {
          'id': 'hero_1',
          'name_key': 'Hero 1 Dup',
          'element': 'fire',
          'hero_class': 'warrior',
          'base_hp': 1000,
          'base_attack': 100,
          'base_defense': 50,
          'max_mana': 100,
          'starting_mana': 0,
          'active_skill_id': 'skill_fire',
        },
      ];

      final ds = _FakeDataSource(
        heroes: duplicateHeroes,
        skills: validSkills,
        enemies: validEnemies,
        stages: validStages,
      );
      final repo = BattleContentRepository(localDataSource: ds);

      expect(
        repo.getBattleContent,
        throwsA(isA<ContentValidationException>()),
      );
    });

    test('throws ContentValidationException when activeSkillId is missing', () {
      final invalidHero = [
        {
          ...validHeroes.first,
          'active_skill_id': 'non_existent_skill',
        },
      ];

      final ds = _FakeDataSource(
        heroes: invalidHero,
        skills: validSkills,
        enemies: validEnemies,
        stages: validStages,
      );
      final repo = BattleContentRepository(localDataSource: ds);

      expect(
        repo.getBattleContent,
        throwsA(isA<ContentValidationException>()),
      );
    });

    test('throws ContentValidationException when stage enemy ID is missing',
        () {
      final invalidStage = [
        {
          'id': 'stage_1',
          'display_name_key': 'Stage 1',
          'turn_limit': 30,
          'waves': [
            {
              'wave_number': 1,
              'enemy_ids': ['ghost_enemy'],
            },
          ],
        },
      ];

      final ds = _FakeDataSource(
        heroes: validHeroes,
        skills: validSkills,
        enemies: validEnemies,
        stages: invalidStage,
      );
      final repo = BattleContentRepository(localDataSource: ds);

      expect(
        repo.getBattleContent,
        throwsA(isA<ContentValidationException>()),
      );
    });

    test('throws ContentValidationException when hero stat is non-positive',
        () {
      final hero = [
        {
          ...validHeroes.first,
          'base_hp': 0,
        },
      ];

      final ds = _FakeDataSource(
        heroes: hero,
        skills: validSkills,
        enemies: validEnemies,
        stages: validStages,
      );
      final repo = BattleContentRepository(localDataSource: ds);

      expect(
        repo.getBattleContent,
        throwsA(isA<ContentValidationException>()),
      );
    });

    test('throws ContentValidationException when stage has empty waves', () {
      final stage = [
        {
          'id': 'stage_1',
          'display_name_key': 'Stage 1',
          'turn_limit': 30,
          'waves': <Map<String, dynamic>>[],
        },
      ];

      final ds = _FakeDataSource(
        heroes: validHeroes,
        skills: validSkills,
        enemies: validEnemies,
        stages: stage,
      );
      final repo = BattleContentRepository(localDataSource: ds);

      expect(
        repo.getBattleContent,
        throwsA(isA<ContentValidationException>()),
      );
    });

    test('production assets in assets/game_data/ pass all validation rules',
        () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      const ds = LocalBattleContentDataSource();
      final repo = BattleContentRepository(localDataSource: ds);
      final content = await repo.getBattleContent();
      expect(content.heroes.length, greaterThanOrEqualTo(4));
      expect(content.stages.length, greaterThanOrEqualTo(3));
      expect(content.skills, isNotEmpty);
      expect(content.enemies, isNotEmpty);
    });
  });
}
