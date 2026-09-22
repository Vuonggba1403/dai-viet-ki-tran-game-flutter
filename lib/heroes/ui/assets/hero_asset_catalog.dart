import 'package:dai_viet_ki_tran_game/app/design_system/game_colors.dart';
import 'package:dai_viet_ki_tran_game/assets_gen/assets.gen.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/tile_type.dart';
import 'package:flutter/material.dart';

/// Centralized asset and presentation catalog for heroes in Dai Viet Ki Tran.
abstract final class HeroAssetCatalog {
  /// Returns the standing portrait image path for cards and roster display.
  static String portraitPath(String assetKey) {
    return switch (assetKey) {
      'heroes/assassin' => Assets.images.heroes.assassin.idleFront.path,
      'heroes/swordsman' => Assets.images.heroes.swordsman.idleFront.path,
      'heroes/monk' => Assets.images.heroes.monk.idleFront.path,
      'heroes/strategist' => Assets.images.heroes.strategist.idleFront.path,
      'heroes/guardian' => Assets.images.heroes.guardian.idleFront.path,
      'heroes/lotus_mage' => Assets.images.heroes.lotusMage.idleFront.path,
      'heroes/ranger' => Assets.images.heroes.ranger.idleFront.path,
      'heroes/spear_guard' => Assets.images.heroes.spearGuard.idleFront.path,
      _ => Assets.images.heroes.swordsman.idleFront.path,
    };
  }

  /// Returns the right-facing idle sprite path (used by player hero in battle arena).
  static String idleRightPath(String assetKey) {
    return switch (assetKey) {
      'heroes/assassin' => Assets.images.heroes.assassin.idleRight.path,
      'heroes/swordsman' => Assets.images.heroes.swordsman.idleRight.path,
      'heroes/monk' => Assets.images.heroes.monk.idleRight.path,
      'heroes/strategist' => Assets.images.heroes.strategist.idleRight.path,
      'heroes/guardian' => Assets.images.heroes.guardian.idleRight.path,
      'heroes/lotus_mage' => Assets.images.heroes.lotusMage.idleRight.path,
      'heroes/ranger' => Assets.images.heroes.ranger.idleRight.path,
      'heroes/spear_guard' => Assets.images.heroes.spearGuard.idleRight.path,
      _ => Assets.images.heroes.swordsman.idleRight.path,
    };
  }

  /// Returns the left-facing idle sprite path.
  static String idleLeftPath(String assetKey) {
    return switch (assetKey) {
      'heroes/assassin' => Assets.images.heroes.assassin.idleLeft.path,
      'heroes/swordsman' => Assets.images.heroes.swordsman.idleLeft.path,
      'heroes/monk' => Assets.images.heroes.monk.idleLeft.path,
      'heroes/strategist' => Assets.images.heroes.strategist.idleLeft.path,
      'heroes/guardian' => Assets.images.heroes.guardian.idleLeft.path,
      'heroes/lotus_mage' => Assets.images.heroes.lotusMage.idleLeft.path,
      'heroes/ranger' => Assets.images.heroes.ranger.idleLeft.path,
      'heroes/spear_guard' => Assets.images.heroes.spearGuard.idleLeft.path,
      _ => Assets.images.heroes.swordsman.idleLeft.path,
    };
  }

  /// Returns attack right frames for combat animation.
  static List<String> attackRightFrames(String assetKey) {
    return switch (assetKey) {
      'heroes/assassin' => [
        Assets.images.heroes.assassin.attackRight01.path,
        Assets.images.heroes.assassin.attackRight02.path,
      ],
      'heroes/swordsman' => [
        Assets.images.heroes.swordsman.attackRight01.path,
      ],
      'heroes/monk' => [
        Assets.images.heroes.monk.attackRight01.path,
      ],
      'heroes/strategist' => [
        Assets.images.heroes.strategist.skillRight01.path,
        Assets.images.heroes.strategist.skillRight02.path,
      ],
      _ => [idleRightPath(assetKey)],
    };
  }

  /// Returns the primary color for a given tile element.
  static Color elementColor(TileType element) {
    return switch (element) {
      TileType.fire => GameColors.elementFire,
      TileType.water => GameColors.elementWater,
      TileType.lightning => GameColors.elementLightning,
      TileType.sword => GameColors.elementSword,
      TileType.heart => GameColors.elementHeart,
    };
  }

  /// Returns radial/linear gradient for hero roster card background.
  static LinearGradient cardGradient(TileType element) {
    final baseColor = elementColor(element);
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        baseColor.withValues(alpha: 0.85),
        baseColor.withValues(alpha: 0.50),
        GameColors.surface,
      ],
      stops: const [0.0, 0.55, 1.0],
    );
  }

  /// Returns appropriate class icon for hero card badge.
  static IconData classIcon(String heroClass) {
    return switch (heroClass.toLowerCase()) {
      'commander' || 'leader' => Icons.shield_rounded,
      'warrior' => Icons.sports_martial_arts_rounded,
      'berserker' => Icons.flash_on_rounded,
      'strategist' || 'mage' => Icons.auto_stories_rounded,
      'ranger' => Icons.gps_fixed_rounded,
      'guardian' => Icons.security_rounded,
      _ => Icons.military_tech_rounded,
    };
  }

  /// Returns display name for localized key fallback.
  static String localizedName(String nameKey) {
    return switch (nameKey) {
      'hero_dinh_bo_linh' => 'Đinh Bộ Lĩnh',
      'hero_nguyen_bac' => 'Nguyễn Bặc',
      'hero_dinh_dien' => 'Đinh Điền',
      'hero_luu_co' => 'Lưu Cơ',
      _ => nameKey,
    };
  }
}
