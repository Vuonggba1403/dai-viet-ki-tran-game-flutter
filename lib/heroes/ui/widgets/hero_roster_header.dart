import 'package:dai_viet_ki_tran_game/app/design_system/game_colors.dart';
import 'package:dai_viet_ki_tran_game/app/design_system/game_radius.dart';
import 'package:dai_viet_ki_tran_game/app/design_system/game_typography.dart';
import 'package:dai_viet_ki_tran_game/battle/battle.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Section header displaying hero capacity and a primary battle entry action.
class HeroRosterHeader extends StatelessWidget {
  const HeroRosterHeader({
    required this.currentCount,
    this.maxCapacity = 15,
    this.title = 'TƯỚNG',
    super.key,
  });

  final int currentCount;
  final int maxCapacity;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$title ($currentCount / $maxCapacity)',
            style: GameTypography.screenTitle.copyWith(
              color: GameColors.textSecondary,
              fontSize: 16,
            ),
          ),
          ElevatedButton.icon(
            key: const Key('enter_battle_button'),
            onPressed: () => context.pushNamed(BattlePage.routeName),
            icon: const Icon(
              Icons.sports_esports_rounded,
              size: 16,
              color: Colors.black,
            ),
            label: const Text(
              'Vào trận',
              style: TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: GameColors.goldPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: const RoundedRectangleBorder(
                borderRadius: GameRadius.borderSm,
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }
}
