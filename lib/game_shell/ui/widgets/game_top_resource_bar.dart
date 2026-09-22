import 'package:dai_viet_ki_tran_game/app/design_system/game_colors.dart';
import 'package:dai_viet_ki_tran_game/app/design_system/game_radius.dart';
import 'package:dai_viet_ki_tran_game/app/design_system/game_typography.dart';
import 'package:dai_viet_ki_tran_game/assets_gen/assets.gen.dart';
import 'package:flutter/material.dart';

/// Top resource bar displaying Level, Energy (9/9), Gold, and Gems.
class GameTopResourceBar extends StatelessWidget {
  const GameTopResourceBar({
    this.level = 15,
    this.currentEnergy = 9,
    this.maxEnergy = 9,
    this.gold = 999999,
    this.gem = 9999,
    this.onAddEnergy,
    this.onAddGold,
    this.onAddGem,
    super.key,
  });

  final int level;
  final int currentEnergy;
  final int maxEnergy;
  final int gold;
  final int gem;
  final VoidCallback? onAddEnergy;
  final VoidCallback? onAddGold;
  final VoidCallback? onAddGem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: const BoxDecoration(
        color: Color(0xFF1B1832),
        border: Border(
          bottom: BorderSide(color: Color(0xFF2C274D), width: 1.5),
        ),
      ),
      child: Row(
        children: [
          // 1. Player Level Badge
          _buildLevelBadge(level),
          const SizedBox(width: 6),

          // 2. Energy pill
          Expanded(
            child: _buildResourcePill(
              iconWidget: const Icon(
                Icons.shield_rounded,
                size: 16,
                color: Color(0xFF42A5F5),
              ),
              text: '$currentEnergy/$maxEnergy',
              onAdd: onAddEnergy,
            ),
          ),
          const SizedBox(width: 4),

          // 3. Gold pill
          Expanded(
            child: _buildResourcePill(
              iconWidget: Image.asset(
                Assets.images.game.items.currency.gold.path,
                width: 16,
                height: 16,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.monetization_on,
                  size: 16,
                  color: GameColors.goldPrimary,
                ),
              ),
              text: _formatCompact(gold),
              onAdd: onAddGold,
            ),
          ),
          const SizedBox(width: 4),

          // 4. Gem pill
          Expanded(
            child: _buildResourcePill(
              iconWidget: Image.asset(
                Assets.images.game.items.currency.gem.path,
                width: 16,
                height: 16,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.diamond_rounded,
                  size: 16,
                  color: Color(0xFF40C4FF),
                ),
              ),
              text: _formatCompact(gem),
              onAdd: onAddGem,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelBadge(int level) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF283593), Color(0xFF1E88E5)],
        ),
        borderRadius: GameRadius.borderSm,
        border: Border.all(color: const Color(0xFF64B5F6), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            size: 14,
            color: GameColors.goldPrimary,
          ),
          const SizedBox(width: 2),
          Text('$level', style: GameTypography.resourcePill),
        ],
      ),
    );
  }

  Widget _buildResourcePill({
    required Widget iconWidget,
    required String text,
    VoidCallback? onAdd,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF262142),
        borderRadius: GameRadius.borderFull,
        border: Border.all(color: const Color(0xFF3B3563)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconWidget,
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GameTypography.resourcePill,
            ),
          ),
          if (onAdd != null) ...[
            const SizedBox(width: 2),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: GameColors.goldPrimary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, size: 10, color: Colors.black),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatCompact(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 100000) {
      return '${(value / 1000).toStringAsFixed(0)}k';
    }
    return '$value';
  }
}
