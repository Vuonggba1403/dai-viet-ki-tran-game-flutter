// Remove json serialization warning
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'stage_definition.freezed.dart';
part 'stage_definition.g.dart';

@freezed
abstract class StageWaveDefinition with _$StageWaveDefinition {
  const factory StageWaveDefinition({
    @JsonKey(name: 'wave_number') required int waveNumber,
    @JsonKey(name: 'enemy_ids') required List<String> enemyIds,
  }) = _StageWaveDefinition;

  factory StageWaveDefinition.fromJson(Map<String, dynamic> json) =>
      _$StageWaveDefinitionFromJson(json);
}

@freezed
abstract class StageDefinition with _$StageDefinition {
  const factory StageDefinition({
    required String id,
    @JsonKey(name: 'display_name_key') required String displayNameKey,
    @JsonKey(name: 'turn_limit') required int turnLimit,
    required List<StageWaveDefinition> waves,
    @JsonKey(name: 'first_clear_reward')
    @Default(<String, int>{})
    Map<String, int> firstClearReward,
    @JsonKey(name: 'repeat_reward')
    @Default(<String, int>{})
    Map<String, int> repeatReward,
    @JsonKey(name: 'tutorial_script') String? tutorialScript,
  }) = _StageDefinition;

  factory StageDefinition.fromJson(Map<String, dynamic> json) =>
      _$StageDefinitionFromJson(json);
}
