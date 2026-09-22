import 'package:dai_viet_ki_tran_game/app/design_system/game_colors.dart';
import 'package:dai_viet_ki_tran_game/app/design_system/game_radius.dart';
import 'package:dai_viet_ki_tran_game/battle/data/models/stage_definition.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/assets/battle_asset_catalog.dart';
import 'package:flutter/material.dart';

/// Modal dialog presented upon stage defeat.
class DefeatOverlay extends StatelessWidget {
  const DefeatOverlay({
    required this.stage,
    required this.onRetry,
    required this.onExit,
    super.key,
  });

  final StageDefinition stage;
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
            key: const Key('defeat_view'),
            constraints: const BoxConstraints(maxWidth: 340),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E141D),
              borderRadius: GameRadius.borderLg,
              border: Border.all(color: const Color(0xFFC62828), width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66C62828),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
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
                // 1. Defeat Banner Image
                Image.asset(
                  BattleAssetCatalog.defeatBannerPath,
                  height: 64,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.heart_broken_rounded,
                    color: Colors.redAccent,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 6),

                // 2. Title Text (Required by contract & test)
                const Text(
                  'THẤT BẠI',
                  style: TextStyle(
                    color: Color(0xFFFF5252),
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
                const SizedBox(height: 16),

                // 4. Tactical Advice Panel
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF281822),
                    borderRadius: GameRadius.borderMd,
                    border: Border.all(color: const Color(0xFF4E2637)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        color: GameColors.goldPrimary,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Mẹo: Tích lũy chuỗi combo ngũ hành và canh thời điểm dùng kỹ năng tướng để khắc chế kẻ địch.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 5. Retry Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    key: const Key('defeat_retry_button'),
                    onPressed: onRetry,
                    icon: const Icon(Icons.replay_rounded, color: Colors.white),
                    label: const Text('Thử lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      foregroundColor: Colors.white,
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

                // 6. Exit / Home Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    key: const Key('defeat_exit_button'),
                    onPressed: onExit,
                    icon: const Icon(
                      Icons.home_outlined,
                      color: Colors.white70,
                    ),
                    label: const Text('Về trang chủ'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(
                        color: Color(0xFF4A3442),
                        width: 1.5,
                      ),
                      backgroundColor: const Color(0xFF251A23),
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
