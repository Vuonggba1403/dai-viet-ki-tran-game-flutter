// Remove json serialization warning
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'battle_balance_definition.freezed.dart';
part 'battle_balance_definition.g.dart';

/// Configuration definition for customizable game balance constants.
@freezed
abstract class BattleBalanceDefinition with _$BattleBalanceDefinition {
  const factory BattleBalanceDefinition({
    @JsonKey(name: 'base_heal') @Default(80) int baseHeal,
    @JsonKey(name: 'mana_per_tile') @Default(10) int manaPerTile,
    @JsonKey(name: 'score_per_combo') @Default(100) int scorePerCombo,
    @JsonKey(name: 'score_per_wave_clear') @Default(500) int scorePerWaveClear,
  }) = _BattleBalanceDefinition;

  factory BattleBalanceDefinition.fromJson(Map<String, dynamic> json) =>
      _$BattleBalanceDefinitionFromJson(json);
}
