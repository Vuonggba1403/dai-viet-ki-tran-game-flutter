import 'package:ezwork/battle/data/models/hero_definition.dart';
import 'package:ezwork/battle/domain/board/tile_type.dart';
import 'package:ezwork/battle/domain/combat/hero_runtime.dart';
import 'package:ezwork/battle/ui/overlays/hero_team_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HeroTeamRow', () {
    late List<HeroRuntime> heroes;

    setUp(() {
      heroes = [
        HeroRuntime.fromDefinition(
          const HeroDefinition(
            id: 'dinh_bo_linh',
            nameKey: 'DBL',
            element: TileType.fire,
            heroClass: 'c',
            baseHp: 1000,
            baseAttack: 100,
            baseDefense: 50,
            maxMana: 100,
            startingMana: 80,
            activeSkillId: 's1',
          ),
        ),
        HeroRuntime.fromDefinition(
          const HeroDefinition(
            id: 'nguyen_bac',
            nameKey: 'NB',
            element: TileType.sword,
            heroClass: 'w',
            baseHp: 1200,
            baseAttack: 90,
            baseDefense: 70,
            maxMana: 80,
            startingMana: 10,
            activeSkillId: 's2',
          ),
        ),
      ];
    });

    testWidgets('renders hero cards with HP and Mana bars', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeroTeamRow(
              heroes: heroes,
              canCastSkill: (id) => id == 'dinh_bo_linh',
              onCastSkill: (_) {},
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('hero_card_dinh_bo_linh')), findsOneWidget);
      expect(find.byKey(const Key('hero_card_nguyen_bac')), findsOneWidget);

      expect(find.text('1000/1000'), findsOneWidget);
      expect(find.text('1200/1200'), findsOneWidget);
      expect(find.text('80/100'), findsOneWidget);
      expect(find.text('10/80'), findsOneWidget);

      // Skill button ready for dinh_bo_linh only
      expect(
        find.byKey(const Key('hero_skill_button_dinh_bo_linh')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('hero_skill_button_nguyen_bac')),
        findsNothing,
      );
    });

    testWidgets('tapping skill button triggers onCastSkill callback', (
      tester,
    ) async {
      String? castHeroId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeroTeamRow(
              heroes: heroes,
              canCastSkill: (id) => true,
              onCastSkill: (id) => castHeroId = id,
            ),
          ),
        ),
      );

      final skillBtn = find.byKey(const Key('hero_skill_button_dinh_bo_linh'));
      expect(skillBtn, findsOneWidget);

      await tester.tap(skillBtn);
      await tester.pump();

      expect(castHeroId, equals('dinh_bo_linh'));
    });
  });
}
