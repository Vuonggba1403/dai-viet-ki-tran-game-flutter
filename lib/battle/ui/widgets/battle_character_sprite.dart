import 'package:dai_viet_ki_tran_game/app/design_system/game_shadows.dart';
import 'package:flutter/material.dart';

/// Renders a combatant sprite standing on the ground with an elliptical shadow.
class BattleCharacterSprite extends StatelessWidget {
  const BattleCharacterSprite({
    required this.spritePath,
    this.scale = 1.0,
    this.fallbackColor = Colors.white54,
    super.key,
  });

  final String spritePath;
  final double scale;
  final Color fallbackColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // 1. Character Image
        Flexible(
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              spritePath,
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.person_rounded,
                size: 64,
                color: fallbackColor,
              ),
            ),
          ),
        ),

        // 2. Elliptical foot shadow on the ground
        Container(
          width: 72 * scale,
          height: 12 * scale,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.all(
              Radius.elliptical(72 * scale, 12 * scale),
            ),
            boxShadow: const [GameShadows.characterShadow],
          ),
        ),
      ],
    );
  }
}
