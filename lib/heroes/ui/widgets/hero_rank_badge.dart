import 'package:dai_viet_ki_tran_game/app/design_system/game_typography.dart';
import 'package:flutter/material.dart';

/// Hexagonal or shield-shaped badge displaying hero tier rank (S, A, B, C).
class HeroRankBadge extends StatelessWidget {
  const HeroRankBadge({
    required this.rank,
    this.badgeColor,
    super.key,
  });

  final String rank;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    final color = badgeColor ?? _colorForRank(rank);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomRight: Radius.circular(8),
          topRight: Radius.circular(4),
          bottomLeft: Radius.circular(4),
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Text(
        rank,
        style: GameTypography.rankBadge,
      ),
    );
  }

  static Color _colorForRank(String rank) {
    return switch (rank.toUpperCase()) {
      'S' => const Color(0xFFD32F2F), // Red/Gold S
      'A' => const Color(0xFF8E24AA), // Purple A
      'B' => const Color(0xFF5E35B1), // Deep Violet B
      'C' => const Color(0xFF1E88E5), // Blue C
      _ => const Color(0xFF546E7A),
    };
  }
}
