import 'package:dai_viet_ki_tran_game/app/design_system/game_colors.dart';
import 'package:flutter/material.dart';

/// Typography styles tailored for game screens and badges.
abstract final class GameTypography {
  static const TextStyle screenTitle = TextStyle(
    color: GameColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.2,
  );

  static const TextStyle sectionHeader = TextStyle(
    color: GameColors.textSecondary,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 1,
  );

  static const TextStyle heroCardName = TextStyle(
    color: GameColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w800,
    shadows: [
      Shadow(
        offset: Offset(1, 1),
        blurRadius: 3,
      ),
    ],
  );

  static const TextStyle rankBadge = TextStyle(
    color: Colors.white,
    fontSize: 13,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle resourcePill = TextStyle(
    color: GameColors.textPrimary,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle navLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle hudStat = TextStyle(
    color: Colors.white,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    shadows: [
      Shadow(
        offset: Offset(1, 1),
        blurRadius: 2,
      ),
    ],
  );
}
