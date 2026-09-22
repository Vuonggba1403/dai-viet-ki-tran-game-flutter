import 'package:dai_viet_ki_tran_game/battle/domain/combat/enemy_runtime.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/combat/hero_runtime.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/widgets/battle_top_bar.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/widgets/battle_versus_hud.dart';
import 'package:flutter/material.dart';

/// Top overlay HUD combining top status bar, arena combatants, and versus HUD.
class BattleHud extends StatelessWidget {
  const BattleHud({
    required this.stageTitle,
    required this.comboCount,
    required this.onPause,
    this.enemy,
    this.heroes = const [],
    this.remainingTurns = 30,
    this.currentWave = 1,
    this.totalWaves = 1,
    this.arena,
    super.key,
  });

  final String stageTitle;
  final int comboCount;
  final VoidCallback onPause;
  final EnemyRuntime? enemy;
  final List<HeroRuntime> heroes;
  final int remainingTurns;
  final int currentWave;
  final int totalWaves;
  final Widget? arena;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Top status bar with stage title, turns, and pause button
        BattleTopBar(
          stageTitle: stageTitle,
          currentWave: currentWave,
          totalWaves: totalWaves,
          remainingTurns: remainingTurns,
          onPause: onPause,
        ),

        // 2. Battlefield arena (heroes vs enemies facing each other)
        if (arena != null) arena!,

        // 3. Versus combat card HUD (player vs enemy)
        BattleVersusHud(
          heroes: heroes,
          enemy: enemy,
          comboCount: comboCount,
          remainingTurns: remainingTurns,
        ),
      ],
    );
  }
}
