import 'package:dai_viet_ki_tran_game/assets_gen/assets.gen.dart';

/// Centralized asset mapping for battle stages, backgrounds, and enemies.
abstract final class BattleAssetCatalog {
  /// Returns the background image path for a given stage.
  static String stageBackgroundPath(String stageId) {
    return switch (stageId) {
      'stage_1' => Assets.images.game.backgrounds.battle.grasslandPath.path,
      'stage_2' => Assets.images.game.backgrounds.battle.lakeside.path,
      'stage_3' => Assets.images.game.backgrounds.battle.enchantedForest.path,
      'stage_castle' =>
        Assets.images.game.backgrounds.battle.castleCourtyard.path,
      _ => Assets.images.game.backgrounds.battle.grasslandPath.path,
    };
  }

  /// Returns the left-facing idle sprite path for an enemy (facing towards player).
  static String enemyIdleLeftPath(String enemyId) {
    return switch (enemyId) {
      'bandit' => Assets.images.game.enemies.bandit.idleLeft.path,
      'skeleton_archer' =>
        Assets.images.game.enemies.skeletonArcher.idleLeft.path,
      'goblin_bomber' => Assets.images.game.enemies.goblinBomber.idleLeft.path,
      'necromancer' => Assets.images.game.enemies.necromancer.idleLeft.path,
      _ => Assets.images.game.enemies.bandit.idleLeft.path,
    };
  }

  /// Returns the right-facing idle sprite path for an enemy.
  static String enemyIdleRightPath(String enemyId) {
    return switch (enemyId) {
      'bandit' => Assets.images.game.enemies.bandit.idleRight.path,
      'skeleton_archer' =>
        Assets.images.game.enemies.skeletonArcher.idleRight.path,
      'goblin_bomber' => Assets.images.game.enemies.goblinBomber.idleRight.path,
      'necromancer' => Assets.images.game.enemies.necromancer.idleRight.path,
      _ => Assets.images.game.enemies.bandit.idleRight.path,
    };
  }

  /// Returns avatar / portrait path for enemy in HUD.
  static String enemyAvatarPath(String enemyId) => enemyIdleLeftPath(enemyId);

  /// Returns localized or formatted enemy name.
  static String localizedEnemyName(String nameKey) {
    return switch (nameKey) {
      'enemy_bandit_name' => 'Sơn Tặc',
      'enemy_skeleton_archer_name' => 'Cung Thủ Khô Lâu',
      'enemy_goblin_bomber_name' => 'Yêu Tinh Thuốc Nổ',
      'enemy_necromancer_name' => 'Đỗ Cảnh Thạc (Tà Thuật)',
      _ => nameKey,
    };
  }

  /// Returns display title for stage.
  static String localizedStageName(String stageTitleKey) {
    return switch (stageTitleKey) {
      'stage_1_name' => 'Hoa Lư Sơn',
      'stage_2_name' => 'Đỗ Động Giang',
      'stage_3_name' => 'Tây Phù Liệt',
      _ => stageTitleKey,
    };
  }
}
