import 'package:dai_viet_ki_tran_game/app/design_system/game_colors.dart';
import 'package:dai_viet_ki_tran_game/app/design_system/game_radius.dart';
import 'package:dai_viet_ki_tran_game/app/design_system/game_shadows.dart';
import 'package:flutter/material.dart';

/// Skill button inside hero dock card that glows with gold when mana is 100%.
class HeroSkillButton extends StatelessWidget {
  const HeroSkillButton({
    required this.heroId,
    required this.isReady,
    required this.onPressed,
    this.label = 'CHIÊU',
    super.key,
  });

  final String heroId;
  final bool isReady;
  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key('hero_skill_button_$heroId'),
      onTap: isReady ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        decoration: BoxDecoration(
          color: isReady ? GameColors.goldPrimary : const Color(0xFF2C274D),
          borderRadius: GameRadius.borderXs,
          border: Border.all(
            color: isReady ? Colors.white : Colors.white24,
          ),
          boxShadow: isReady ? [GameShadows.goldGlow] : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isReady ? Colors.black : Colors.white38,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
