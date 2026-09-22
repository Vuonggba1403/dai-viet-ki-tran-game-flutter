import 'package:dai_viet_ki_tran_game/battle/data/models/enemy_definition.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/combat/enemy_runtime.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/overlays/battle_hud.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BattleHud Combat Elements', () {
    testWidgets(
      'renders enemy combat card with HP bar and turn countdown badge',
      (
        tester,
      ) async {
        final enemy = EnemyRuntime.fromDefinition(
          const EnemyDefinition(
            id: 'necromancer',
            nameKey: 'Necromancer',
            maxHp: 1200,
            attack: 85,
            defense: 40,
            initialTurnCounter: 3,
            resetTurnCounter: 3,
            targetRule: 'random',
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BattleHud(
                stageTitle: 'Hoa Lư Sơn',
                comboCount: 3,
                remainingTurns: 25,
                currentWave: 2,
                totalWaves: 3,
                enemy: enemy,
                onPause: () {},
              ),
            ),
          ),
        );

        expect(find.text('Hoa Lư Sơn • Đợt 2/3'), findsOneWidget);
        expect(find.text('Lượt: 25'), findsOneWidget);
        expect(find.byKey(const Key('combo_badge')), findsOneWidget);
        expect(find.text('3 COMBO!'), findsOneWidget);

        expect(find.byKey(const Key('enemy_combat_card')), findsOneWidget);
        expect(find.byKey(const Key('enemy_hp_bar')), findsOneWidget);
        expect(find.text('1200/1200'), findsOneWidget);
        expect(find.byKey(const Key('enemy_turn_countdown')), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
      },
    );
  });
}
