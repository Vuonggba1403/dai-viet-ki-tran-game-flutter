// Remove json serialization warning
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'enemy_definition.freezed.dart';
part 'enemy_definition.g.dart';

@freezed
abstract class EnemyPhaseDefinition with _$EnemyPhaseDefinition {
  const factory EnemyPhaseDefinition({
    @JsonKey(name: 'phase_number') required int phaseNumber,
    @JsonKey(name: 'hp_threshold_percent') required int hpThresholdPercent,
    @JsonKey(name: 'description_key') String? descriptionKey,
  }) = _EnemyPhaseDefinition;

  factory EnemyPhaseDefinition.fromJson(Map<String, dynamic> json) =>
      _$EnemyPhaseDefinitionFromJson(json);
}

@freezed
abstract class EnemyDefinition with _$EnemyDefinition {
  const factory EnemyDefinition({
    required String id,
    @JsonKey(name: 'name_key') required String nameKey,
    @JsonKey(name: 'max_hp') required int maxHp,
    required int attack,
    required int defense,
    @JsonKey(name: 'initial_turn_counter') required int initialTurnCounter,
    @JsonKey(name: 'reset_turn_counter') required int resetTurnCounter,
    @JsonKey(name: 'target_rule') required String targetRule,
    @JsonKey(name: 'status_resistance')
    @Default(<String>[])
    List<String> statusResistance,
    List<EnemyPhaseDefinition>? phases,
    @JsonKey(name: 'asset_key') String? assetKey,
  }) = _EnemyDefinition;

  factory EnemyDefinition.fromJson(Map<String, dynamic> json) =>
      _$EnemyDefinitionFromJson(json);
}
