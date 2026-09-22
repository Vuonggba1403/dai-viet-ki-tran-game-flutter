import 'package:ezwork/battle/data/data_sources/local_battle_content_data_source.dart';
import 'package:ezwork/battle/data/models/battle_balance_definition.dart';
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

    test(
      'throws ContentValidationException when stage enemy ID is missing',
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
      },
    );

    test(
      'throws ContentValidationException when hero stat is non-positive',
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
      },
    );

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

    test('throws ContentValidationException when ID format is invalid', () {
      final invalidHero = [
        {
          ...validHeroes.first,
          'id': 'Hero-1 Invalid',
        },
      ];
      final ds = _FakeDataSource(
        heroes: invalidHero,
        skills: validSkills,
        enemies: validEnemies,
        stages: validStages,
      );
      final repo = BattleContentRepository(localDataSource: ds);

      expect(repo.getBattleContent, throwsA(isA<ContentValidationException>()));
    });

    test('throws ContentValidationException when startingMana > maxMana', () {
      final invalidHero = [
        {
          ...validHeroes.first,
          'starting_mana': 150,
          'max_mana': 100,
        },
      ];
      final ds = _FakeDataSource(
        heroes: invalidHero,
        skills: validSkills,
        enemies: validEnemies,
        stages: validStages,
      );
      final repo = BattleContentRepository(localDataSource: ds);

      expect(repo.getBattleContent, throwsA(isA<ContentValidationException>()));
    });

    test('throws ContentValidationException when skill effects are empty', () {
      final invalidSkill = [
        {
          ...validSkills.first,
          'effects': <Map<String, dynamic>>[],
        },
      ];
      final ds = _FakeDataSource(
        heroes: validHeroes,
        skills: invalidSkill,
        enemies: validEnemies,
        stages: validStages,
      );
      final repo = BattleContentRepository(localDataSource: ds);

      expect(repo.getBattleContent, throwsA(isA<ContentValidationException>()));
    });

    test(
      'throws ContentValidationException when boss phases are out of order',
      () {
        final invalidEnemy = [
          {
            ...validEnemies.first,
            'phases': [
              {'phase_number': 2, 'hp_threshold_percent': 50},
            ],
          },
        ];
        final ds = _FakeDataSource(
          heroes: validHeroes,
          skills: validSkills,
          enemies: invalidEnemy,
          stages: validStages,
        );
        final repo = BattleContentRepository(localDataSource: ds);

        expect(
          repo.getBattleContent,
          throwsA(isA<ContentValidationException>()),
        );
      },
    );

    test(
      'throws ContentValidationException when wave numbers are not sequential',
      () {
        final invalidStage = [
          {
            ...validStages.first,
            'waves': [
              {
                'wave_number': 2,
                'enemy_ids': ['enemy_1'],
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
      },
    );

    test(
      'throws ContentValidationException when stage rewards contain negative values',
      () {
        final invalidStage = [
          {
            ...validStages.first,
            'first_clear_reward': {'gold': -10},
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
      },
    );

    test(
      'production assets in assets/game_data/ pass all validation rules',
      () async {
        TestWidgetsFlutterBinding.ensureInitialized();
        const ds = LocalBattleContentDataSource();
        final repo = BattleContentRepository(localDataSource: ds);
        final content = await repo.getBattleContent();
        expect(content.heroes.length, greaterThanOrEqualTo(4));
        expect(content.stages.length, greaterThanOrEqualTo(3));
        expect(content.skills, isNotEmpty);
        expect(content.enemies, isNotEmpty);
        expect(content.balance.baseHeal, equals(80));
        expect(content.balance.manaPerTile, equals(10));
        expect(content.balance.scorePerCombo, equals(100));
        expect(content.balance.scorePerWaveClear, equals(500));
      },
    );

    test(
      'validates and accepts custom non-negative balance parameters',
      () async {
        final ds = _FakeDataSource(
          heroes: validHeroes,
          skills: validSkills,
          enemies: validEnemies,
          stages: validStages,
        );
        final repo = BattleContentRepository(localDataSource: ds);
        const customBalance = BattleBalanceDefinition(
          baseHeal: 120,
          manaPerTile: 15,
          scorePerCombo: 200,
          scorePerWaveClear: 1000,
        );
        final content = await repo.getBattleContent(
          customBalance: customBalance,
        );
        expect(content.balance.baseHeal, equals(120));
        expect(content.balance.manaPerTile, equals(15));
        expect(content.balance.scorePerCombo, equals(200));
        expect(content.balance.scorePerWaveClear, equals(1000));
      },
    );

    test(
      'throws ContentValidationException when balance values are negative',
      () {
        final ds = _FakeDataSource(
          heroes: validHeroes,
          skills: validSkills,
          enemies: validEnemies,
          stages: validStages,
        );
        final repo = BattleContentRepository(localDataSource: ds);

        for (final negBalance in [
          const BattleBalanceDefinition(baseHeal: -1),
          const BattleBalanceDefinition(manaPerTile: -5),
          const BattleBalanceDefinition(scorePerCombo: -10),
          const BattleBalanceDefinition(scorePerWaveClear: -50),
        ]) {
          expect(
            () => repo.getBattleContent(customBalance: negBalance),
            throwsA(isA<ContentValidationException>()),
          );
        }
      },
    );
  });
}
