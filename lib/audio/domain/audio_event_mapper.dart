import 'package:dai_viet_ki_tran_game/audio/domain/audio_cue.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/board_event.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/combat/combat_event.dart';

/// Pure domain mapper converting board and combat events into semantic [SfxCue]s.
class AudioEventMapper {
  const AudioEventMapper();

  /// Maps a pure Match-3 [BoardEvent] to an optional [SfxCue].
  ///
  /// Enforces:
  /// - One sound per cascade cycle.
  /// - TilesMatched triggers match3 on cycle 1, and combo2..max on cycle >= 2.
  /// - Cycle > 1 does NOT simultaneously play match3.
  /// - SwapStarted and SwapRejected trigger tileSwap.
  SfxCue? mapBoardEvent(BoardEvent event) {
    return switch (event) {
      SwapStarted() => SfxCue.tileSwap,
      SwapRejected() => SfxCue.tileSwap,
      TilesMatched(:final cycle) => switch (cycle) {
        <= 1 => SfxCue.match3,
        2 => SfxCue.combo2,
        3 => SfxCue.combo3,
        4 => SfxCue.combo4,
        _ => SfxCue.comboMax,
      },
      // Other board lifecycle events (CascadeStarted, CascadeCompleted, TilesDropped, etc.)
      // do not emit separate audio cues in this phase.
      _ => null,
    };
  }

  /// Maps a [CombatEvent] to an optional [SfxCue].
  ///
  /// Enforces:
  /// - Normal damage triggers enemyHit.
  /// - Critical or effective damage triggers criticalHit (never both together).
  /// - Victory / Defeat mapped to respective cues.
  /// - Multi-target hero heals do not trigger per-target cues here.
  SfxCue? mapCombatEvent(CombatEvent event) {
    return switch (event) {
      CombatEnemyDamaged(:final isCriticalOrEffective) =>
        isCriticalOrEffective ? SfxCue.criticalHit : SfxCue.enemyHit,
      CombatSkillExecuted(:final skillId) => mapSkillId(skillId),
      CombatVictorious() => SfxCue.victory,
      CombatDefeated() => SfxCue.defeat,
      _ => null,
    };
  }

  /// Maps a specific hero skill ID to its spell/attack sound cue.
  SfxCue? mapSkillId(String skillId) {
    return switch (skillId) {
      'skill_hoa_long_quyet' => SfxCue.fireCast,
      'skill_tram_long_kich' => SfxCue.swordSlash,
      'skill_loi_dinh_chuong' => SfxCue.lightning,
      'skill_thuy_tran_thu' => SfxCue.heal,
      _ => null,
    };
  }
}
