import 'package:dai_viet_ki_tran_game/app/design_system/game_colors.dart';
import 'package:dai_viet_ki_tran_game/app/design_system/game_radius.dart';
import 'package:dai_viet_ki_tran_game/app/design_system/game_shadows.dart';
import 'package:dai_viet_ki_tran_game/battle/data/models/stage_definition.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/assets/battle_asset_catalog.dart';
import 'package:flutter/material.dart';

/// Modal dialog presented upon stage victory.
class VictoryOverlay extends StatelessWidget {
  const VictoryOverlay({
    required this.stage,
    required this.score,
    required this.onRetry,
    required this.onExit,
    super.key,
  });

  final StageDefinition stage;
  final int score;
  final VoidCallback onRetry;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.82),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Container(
            key: const Key('victory_view'),
            constraints: const BoxConstraints(maxWidth: 340),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1A33),
              borderRadius: GameRadius.borderLg,
              border: Border.all(color: GameColors.goldPrimary, width: 2),
              boxShadow: const [
                GameShadows.goldGlow,
                BoxShadow(
                  color: Colors.black87,
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Victory Banner image
                Image.asset(
                  BattleAssetCatalog.victoryBannerPath,
                  height: 64,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.emoji_events_rounded,
                    color: GameColors.goldPrimary,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 6),

                // 2. Main Title Text (Required by contract & test)
                const Text(
                  'CHIẾN THẮNG!',
                  style: TextStyle(
                    color: GameColors.goldPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),

                // 3. Stage Title
                Text(
                  stage.displayNameKey,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // 4. Star Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        Icons.star_rounded,
                        color: GameColors.goldPrimary,
                        size: 32,
                        shadows: [
                          Shadow(
                            color: Color(0xFFC9972C),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),

                // 5. Score Display (Required by test)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF282247),
                    borderRadius: GameRadius.borderSm,
                    border: Border.all(color: const Color(0xFF453D6E)),
                  ),
                  child: Text(
                    'Điểm: $score',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 6. Rewards Panel
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161226),
                    borderRadius: GameRadius.borderMd,
                    border: Border.all(color: const Color(0xFF38315A)),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'PHẦN THƯỞNG',
                        style: TextStyle(
                          color: Color(0xFFFFE082),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _RewardBadge(
                            icon: Icons.monetization_on_rounded,
                            iconColor: Color(0xFFFFD54F),
                            label: '+150',
                          ),
                          _RewardBadge(
                            icon: Icons.diamond_rounded,
                            iconColor: Color(0xFF4DD0E1),
                            label: '+10',
                          ),
                          _RewardBadge(
                            icon: Icons.military_tech_rounded,
                            iconColor: Color(0xFFFF8A65),
                            label: '+250 EXP',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 7. Replay Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    key: const Key('victory_retry_button'),
                    onPressed: onRetry,
                    icon: const Icon(Icons.replay_rounded, color: Colors.black),
                    label: const Text('Chơi lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GameColors.goldPrimary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: GameRadius.borderMd,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 8. Exit / Home Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    key: const Key('victory_exit_button'),
                    onPressed: onExit,
                    icon: const Icon(
                      Icons.home_outlined,
                      color: Colors.white70,
                    ),
                    label: const Text('Về trang chủ'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(
                        color: Color(0xFF4A4274),
                        width: 1.5,
                      ),
                      backgroundColor: const Color(0xFF262040),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: GameRadius.borderMd,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RewardBadge extends StatelessWidget {
  const _RewardBadge({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
