import 'package:dai_viet_ki_tran_game/app/design_system/game_colors.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/assets/battle_asset_catalog.dart';
import 'package:flutter/material.dart';

/// Full-screen scenic battle background with vignette gradient overlay.
class BattleBackground extends StatelessWidget {
  const BattleBackground({
    required this.stageId,
    super.key,
  });

  final String stageId;

  @override
  Widget build(BuildContext context) {
    final bgPath = BattleAssetCatalog.stageBackgroundPath(stageId);

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Scenic stage background image
        Image.asset(
          bgPath,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          errorBuilder: (context, error, stackTrace) => Container(
            color: GameColors.background,
          ),
        ),

        // 2. Vertical vignette gradient (clear in arena, darkens toward HUD and board)
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.28, 0.42, 1.0],
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.transparent,
                  GameColors.background.withValues(alpha: 0.70),
                  GameColors.background.withValues(alpha: 0.98),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
