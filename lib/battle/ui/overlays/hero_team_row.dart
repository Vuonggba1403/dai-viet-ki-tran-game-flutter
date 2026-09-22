import 'package:dai_viet_ki_tran_game/battle/domain/combat/hero_runtime.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/widgets/battle_hero_dock.dart';
import 'package:flutter/material.dart';

/// Bottom overlay widget displaying the active 4-hero combat team status.
class HeroTeamRow extends StatelessWidget {
  const HeroTeamRow({
    required this.heroes,
    required this.canCastSkill,
    required this.onCastSkill,
    super.key,
  });

  final List<HeroRuntime> heroes;
  final bool Function(String heroId) canCastSkill;
  final ValueChanged<String> onCastSkill;

  @override
  Widget build(BuildContext context) {
    if (heroes.isEmpty) return const SizedBox.shrink();

    return BattleHeroDock(
      heroes: heroes,
      canCastSkill: canCastSkill,
      onCastSkill: onCastSkill,
    );
  }
}
