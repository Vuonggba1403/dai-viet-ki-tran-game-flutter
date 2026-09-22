import 'package:freezed_annotation/freezed_annotation.dart';

part 'battle_session_effect.freezed.dart';

/// One-time UI side-effects dispatched by the battle session cubit.
@freezed
sealed class BattleSessionEffect with _$BattleSessionEffect {
  const factory BattleSessionEffect.exitToHome() =
      BattleSessionEffectExitToHome;
  const factory BattleSessionEffect.showError({required String message}) =
      BattleSessionEffectShowError;
}
