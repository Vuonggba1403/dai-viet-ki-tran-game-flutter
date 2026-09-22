/// Identifies background music tracks available in the game.
enum BgmTrack {
  title,
  home,
  battle,
  boss,
}

extension BgmTrackX on BgmTrack {
  /// Relative asset path within the audio prefix (assets/audio/).
  String get filename => switch (this) {
    BgmTrack.title => 'bgm/title_intro.ogg',
    BgmTrack.home => 'bgm/home_loop.ogg',
    BgmTrack.battle => 'bgm/battle_loop.ogg',
    BgmTrack.boss => 'bgm/boss_loop.ogg',
  };

  /// Full bundle asset path.
  String get assetPath => 'assets/audio/$filename';
}

/// Identifies sound effect cues triggerable across UI, Match-3 board, and combat.
enum SfxCue {
  // UI
  buttonClick,
  panelOpen,

  // Match-3
  tileSwap,
  match3,
  combo2,
  combo3,
  combo4,
  comboMax,

  // Combat
  arrowShot,
  criticalHit,
  enemyHit,
  spearHit,
  swordSlash,

  // Magic
  fireCast,
  heal,
  lightning,
  shield,

  // Result
  victory,
  defeat,
}

extension SfxCueX on SfxCue {
  /// Relative asset path within the audio prefix (assets/audio/).
  String get filename => switch (this) {
    SfxCue.buttonClick => 'sfx/ui/button_click.ogg',
    SfxCue.panelOpen => 'sfx/ui/panel_open.ogg',
    SfxCue.tileSwap => 'sfx/match3/tile_swap.ogg',
    SfxCue.match3 => 'sfx/match3/match_3.ogg',
    SfxCue.combo2 => 'sfx/match3/combo_2.ogg',
    SfxCue.combo3 => 'sfx/match3/combo_3.ogg',
    SfxCue.combo4 => 'sfx/match3/combo_4.ogg',
    SfxCue.comboMax => 'sfx/match3/combo_max.ogg',
    SfxCue.arrowShot => 'sfx/combat/arrow_shot.ogg',
    SfxCue.criticalHit => 'sfx/combat/critical_hit.ogg',
    SfxCue.enemyHit => 'sfx/combat/enemy_hit.ogg',
    SfxCue.spearHit => 'sfx/combat/spear_hit.ogg',
    SfxCue.swordSlash => 'sfx/combat/sword_slash.ogg',
    SfxCue.fireCast => 'sfx/magic/fire_cast.ogg',
    SfxCue.heal => 'sfx/magic/heal.ogg',
    SfxCue.lightning => 'sfx/magic/lightning.ogg',
    SfxCue.shield => 'sfx/magic/shield.ogg',
    SfxCue.victory => 'sfx/result/victory.ogg',
    SfxCue.defeat => 'sfx/result/defeat.ogg',
  };

  /// Full bundle asset path.
  String get assetPath => 'assets/audio/$filename';

  /// Priority score used for concurrency limiting and mixing:
  /// Higher score means higher precedence when pool is full.
  /// Priority order: result/skill/critical > combo/match > UI click.
  int get priority => switch (this) {
    SfxCue.victory || SfxCue.defeat => 100,
    SfxCue.fireCast ||
    SfxCue.heal ||
    SfxCue.lightning ||
    SfxCue.shield ||
    SfxCue.swordSlash ||
    SfxCue.criticalHit => 80,
    SfxCue.arrowShot || SfxCue.spearHit || SfxCue.enemyHit => 60,
    SfxCue.comboMax ||
    SfxCue.combo4 ||
    SfxCue.combo3 ||
    SfxCue.combo2 ||
    SfxCue.match3 => 40,
    SfxCue.tileSwap => 30,
    SfxCue.panelOpen => 20,
    SfxCue.buttonClick => 10,
  };
}
