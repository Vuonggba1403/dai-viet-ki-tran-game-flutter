import 'package:dai_viet_ki_tran_game/battle/data/models/battle_content.dart';
import 'package:dai_viet_ki_tran_game/battle/data/models/stage_definition.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/battle_session_controller.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'battle_session_state.freezed.dart';

/// Stable screen state for the active battle screen.
///
/// Per architecture rules, per-frame board mutations and tile animations
/// are never emitted into this state.
@freezed
sealed class BattleSessionState with _$BattleSessionState {
  const factory BattleSessionState.initial() = BattleSessionStateInitial;

  const factory BattleSessionState.loading() = BattleSessionStateLoading;

  const factory BattleSessionState.ready({
    required BattleContent content,
    required StageDefinition currentStage,
    required BattleSessionController sessionController,
    @Default(0) int comboCount,
    @Default(false) bool isPaused,
    @Default(0) int combatRevision,
  }) = BattleSessionStateReady;

  const factory BattleSessionState.error({
    required String errorMessage,
  }) = BattleSessionStateError;

  const factory BattleSessionState.victory({
    required StageDefinition stage,
    required int score,
  }) = BattleSessionStateVictory;

  const factory BattleSessionState.defeat({
    required StageDefinition stage,
  }) = BattleSessionStateDefeat;
}
