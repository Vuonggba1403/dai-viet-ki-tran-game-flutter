import 'package:dai_viet_ki_tran_game/app/design_system/game_colors.dart';
import 'package:dai_viet_ki_tran_game/app/design_system/game_radius.dart';
import 'package:dai_viet_ki_tran_game/app/design_system/game_shadows.dart';
import 'package:flutter/material.dart';

/// Modal overlay presented when battle is paused.
class PauseOverlay extends StatelessWidget {
  const PauseOverlay({
    required this.onResume,
    required this.onRetry,
    required this.onExit,
    super.key,
  });

  final VoidCallback onResume;
  final VoidCallback onRetry;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: const Key('pause_overlay'),
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          width: 290,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1A33),
            borderRadius: GameRadius.borderLg,
            border: Border.all(color: GameColors.goldPrimary, width: 2),
            boxShadow: const [
              GameShadows.goldGlow,
              BoxShadow(
                color: Colors.black87,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gold banner title
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF533F1F), Color(0xFF2C2210)],
                  ),
                  borderRadius: GameRadius.borderSm,
                  border: Border.all(color: GameColors.goldPrimary),
                ),
                child: const Text(
                  'TẠM DỪNG',
                  style: TextStyle(
                    color: Color(0xFFFFE082),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Resume button (Gold primary)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  key: const Key('resume_button'),
                  onPressed: onResume,
                  icon: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.black,
                  ),
                  label: const Text('Tiếp tục'),
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
              const SizedBox(height: 12),

              // Retry button (Outlined wood)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('retry_button'),
                  onPressed: onRetry,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.white70,
                  ),
                  label: const Text('Chơi lại'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(
                      color: Color(0xFF5D5488),
                      width: 1.5,
                    ),
                    backgroundColor: const Color(0xFF2D274A),
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
              const SizedBox(height: 12),

              // Exit button
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  key: const Key('exit_button'),
                  onPressed: onExit,
                  icon: const Icon(
                    Icons.home_outlined,
                    color: Color(0xFFFF6E6E),
                  ),
                  label: const Text('Thoát ra ngoài'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFF6E6E),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
