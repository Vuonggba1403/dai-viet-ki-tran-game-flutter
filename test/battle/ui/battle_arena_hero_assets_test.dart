import 'package:dai_viet_ki_tran_game/battle/data/models/enemy_definition.dart';
import 'package:dai_viet_ki_tran_game/battle/data/models/hero_definition.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/tile_type.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/combat/enemy_runtime.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/combat/hero_runtime.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/widgets/battle_arena.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/widgets/battle_character_sprite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BattleArena Hero Assets Resolution', () {
    late EnemyRuntime enemy;

    setUp(() {
      enemy = EnemyRuntime.fromDefinition(
        const EnemyDefinition(
          id: 'bandit',
          nameKey: 'enemy_bandit_name',
          maxHp: 800,
          attack: 50,
          defense: 25,
          initialTurnCounter: 3,
          resetTurnCounter: 3,
          targetRule: 'lowest_hp',
        ),
      );
    });

    testWidgets(
      'two heroes with the same element render different asset paths based on assetKey',
      (tester) async {
        // Both heroes share the same fire element
        final heroFireAssassin = HeroRuntime.fromDefinition(
          const HeroDefinition(
            id: 'hero_fire_1',
            nameKey: 'Hero Fire 1',
            element: TileType.fire,
            heroClass: 'assassin',
            baseHp: 1000,
            baseAttack: 100,
            baseDefense: 50,
            maxMana: 100,
            startingMana: 0,
            activeSkillId: 's1',
            assetKey: 'heroes/assassin',
          ),
        );

        final heroFireLotusMage = HeroRuntime.fromDefinition(
          const HeroDefinition(
            id: 'hero_fire_2',
            nameKey: 'Hero Fire 2',
            element: TileType.fire,
            heroClass: 'mage',
            baseHp: 1000,
            baseAttack: 100,
            baseDefense: 50,
            maxMana: 100,
            startingMana: 0,
            activeSkillId: 's2',
            assetKey: 'heroes/lotus_mage',
          ),
        );

        // Render Hero 1 in BattleArena
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BattleArena(
                heroes: [heroFireAssassin],
                enemy: enemy,
                enableIdleAnimation: false,
              ),
            ),
          ),
        );

        final heroSpriteFinder1 = find.descendant(
          of: find.byKey(const Key('arena_player_hero')),
          matching: find.byType(BattleCharacterSprite),
        );
        expect(heroSpriteFinder1, findsOneWidget);
        final spriteWidget1 = tester.widget<BattleCharacterSprite>(
          heroSpriteFinder1,
        );
        final path1 = spriteWidget1.spritePath;

        expect(path1, contains('assassin/idle_right.png'));

        // Render Hero 2 in BattleArena
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BattleArena(
                heroes: [heroFireLotusMage],
                enemy: enemy,
                enableIdleAnimation: false,
              ),
            ),
          ),
        );

        final heroSpriteFinder2 = find.descendant(
          of: find.byKey(const Key('arena_player_hero')),
          matching: find.byType(BattleCharacterSprite),
        );
        expect(heroSpriteFinder2, findsOneWidget);
        final spriteWidget2 = tester.widget<BattleCharacterSprite>(
          heroSpriteFinder2,
        );
        final path2 = spriteWidget2.spritePath;

        expect(path2, contains('lotus_mage/idle_right.png'));

        // Paths must be different despite having identical TileType.fire element
        expect(path1, isNot(equals(path2)));
      },
    );

    testWidgets(
      'preserves hero RIGHT and enemy LEFT facing direction convention',
      (
        tester,
      ) async {
        final hero = HeroRuntime.fromDefinition(
          const HeroDefinition(
            id: 'hero_dbl',
            nameKey: 'DBL',
            element: TileType.fire,
            heroClass: 'commander',
            baseHp: 1200,
            baseAttack: 150,
            baseDefense: 80,
            maxMana: 100,
            startingMana: 20,
            activeSkillId: 's1',
            assetKey: 'heroes/assassin',
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 200,
                child: BattleArena(
                  heroes: [hero],
                  enemy: enemy,
                  enableIdleAnimation: false,
                ),
              ),
            ),
          ),
        );

        final heroFinder = find.byKey(const Key('arena_player_hero'));
        final enemyFinder = find.byKey(const Key('arena_enemy'));

        expect(heroFinder, findsOneWidget);
        expect(enemyFinder, findsOneWidget);

        final heroSprite = tester.widget<BattleCharacterSprite>(
          find.descendant(
            of: heroFinder,
            matching: find.byType(BattleCharacterSprite),
          ),
        );
        final enemySprite = tester.widget<BattleCharacterSprite>(
          find.descendant(
            of: enemyFinder,
            matching: find.byType(BattleCharacterSprite),
          ),
        );

        // Hero faces right
        expect(heroSprite.spritePath, contains('idle_right'));
        // Enemy faces left
        expect(enemySprite.spritePath, contains('idle_left'));

        // Player hero on the left, enemy on the right
        final heroOffset = tester.getTopLeft(heroFinder);
        final enemyOffset = tester.getTopLeft(enemyFinder);
        expect(heroOffset.dx, lessThan(enemyOffset.dx));
      },
    );
  });
}
