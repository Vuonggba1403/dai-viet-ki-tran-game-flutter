import 'package:dai_viet_ki_tran_game/app/design_system/game_colors.dart';
import 'package:dai_viet_ki_tran_game/app/design_system/game_radius.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/assets/battle_asset_catalog.dart';
import 'package:flutter/material.dart';

/// Top utility bar for battle with stage title, turn counter, and pause button.
class BattleTopBar extends StatelessWidget {
  const BattleTopBar({
    required this.stageTitle,
    required this.currentWave,
    required this.totalWaves,
    required this.remainingTurns,
    required this.onPause,
    super.key,
  });

  final String stageTitle;
  final int currentWave;
  final int totalWaves;
  final int remainingTurns;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    final title = BattleAssetCatalog.localizedStageName(stageTitle);
    final waveText = totalWaves > 1
        ? '$title • Đợt $currentWave/$totalWaves'
        : title;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. Stage title and wave badge
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: GameRadius.borderSm,
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                waveText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // 2. Remaining turns badge
          Container(
            key: const Key('turn_counter_badge'),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: remainingTurns <= 5
                  ? GameColors.hpRed.withValues(alpha: 0.85)
                  : Colors.black.withValues(alpha: 0.65),
              borderRadius: GameRadius.borderSm,
              border: Border.all(
                color: remainingTurns <= 5 ? Colors.redAccent : Colors.white24,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.timer_outlined,
                  size: 14,
                  color: Colors.white70,
                ),
                const SizedBox(width: 4),
                Text(
                  'Lượt: $remainingTurns',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // 3. Pause button
          IconButton(
            key: const Key('pause_button'),
            icon: const Icon(
              Icons.pause_circle_outline_rounded,
              color: Colors.white,
              size: 26,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onPause,
          ),
        ],
      ),
    );
  }
}
