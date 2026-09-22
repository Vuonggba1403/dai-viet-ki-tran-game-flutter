import 'package:dai_viet_ki_tran_game/app/design_system/game_colors.dart';
import 'package:dai_viet_ki_tran_game/app/design_system/game_radius.dart';
import 'package:dai_viet_ki_tran_game/app/design_system/game_shadows.dart';
import 'package:dai_viet_ki_tran_game/app/design_system/game_typography.dart';
import 'package:flutter/material.dart';

/// Fixed bottom navigation bar with 5 game tabs and gold active highlighting.
class GameBottomNavigation extends StatelessWidget {
  const GameBottomNavigation({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1B1832),
        border: Border(
          top: BorderSide(color: Color(0xFF2C274D), width: 1.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            index: 0,
            icon: Icons.storefront_rounded,
            label: 'Cửa hàng',
            keyName: 'nav_shop',
          ),
          _buildNavItem(
            index: 1,
            icon: Icons.shield_outlined,
            label: 'Trang bị',
            keyName: 'nav_equipment',
          ),
          _buildNavItem(
            index: 2,
            icon: Icons.sports_martial_arts_rounded,
            label: 'Tướng',
            keyName: 'nav_heroes',
          ),
          _buildNavItem(
            index: 3,
            icon: Icons.military_tech_rounded,
            label: 'Chiến dịch',
            keyName: 'nav_campaign',
          ),
          _buildNavItem(
            index: 4,
            icon: Icons.settings_rounded,
            label: 'Cài đặt',
            keyName: 'nav_settings',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required String keyName,
  }) {
    final isActive = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        key: Key(keyName),
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2B264E) : Colors.transparent,
            borderRadius: GameRadius.borderMd,
            border: Border.all(
              color: isActive ? GameColors.goldPrimary : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: isActive ? [GameShadows.goldGlow] : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: isActive
                    ? GameColors.goldPrimary
                    : GameColors.textSecondary,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GameTypography.navLabel.copyWith(
                  color: isActive
                      ? GameColors.goldPrimary
                      : GameColors.textSecondary,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
