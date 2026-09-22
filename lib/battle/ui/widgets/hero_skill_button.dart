import 'package:dai_viet_ki_tran_game/app/design_system/game_colors.dart';
import 'package:dai_viet_ki_tran_game/app/design_system/game_radius.dart';
import 'package:dai_viet_ki_tran_game/app/design_system/game_shadows.dart';
import 'package:flutter/material.dart';

/// Skill button inside hero dock card that displays readiness, charging, or defeated states.
class HeroSkillButton extends StatelessWidget {
  const HeroSkillButton({
    required this.heroId,
    required this.isReady,
    required this.onPressed,
    this.isAlive = true,
    this.label = 'CHIÊU',
    super.key,
  });

  final String heroId;
  final bool isReady;
  final bool isAlive;
  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    final canTrigger = isReady && isAlive;

    final Color bgColor;
    final Color textColor;
    final Border border;
    final List<BoxShadow>? shadows;
    final String displayLabel;

    if (!isAlive) {
      bgColor = const Color(0xFF261820);
      textColor = const Color(0xFF755E68);
      border = Border.all(color: const Color(0xFF422834));
      shadows = null;
      displayLabel = 'TỬ TRẬN';
    } else if (isReady) {
      bgColor = GameColors.goldPrimary;
      textColor = Colors.black;
      border = Border.all(color: Colors.white);
      shadows = const [GameShadows.goldGlow];
      displayLabel = label;
    } else {
      bgColor = const Color(0xFF25213E);
      textColor = const Color(0xFF7E78A8);
      border = Border.all(color: const Color(0xFF38325C));
      shadows = null;
      displayLabel = label;
    }

    return GestureDetector(
      key: Key('hero_skill_button_$heroId'),
      onTap: canTrigger ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: GameRadius.borderXs,
          border: border,
          boxShadow: shadows,
        ),
        child: Center(
          child: Text(
            displayLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: !isAlive ? 7.5 : 8.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
