// Remove json serialization warning
// ignore_for_file: invalid_annotation_target

import 'package:ezwork/battle/domain/board/tile_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'skill_definition.freezed.dart';
part 'skill_definition.g.dart';

@freezed
abstract class SkillEffectDefinition with _$SkillEffectDefinition {
  const factory SkillEffectDefinition({
    required String type,
    required int magnitude,
    required int duration,
    int? count,
    @JsonKey(name: 'tile_type') TileType? tileType,
  }) = _SkillEffectDefinition;

  factory SkillEffectDefinition.fromJson(Map<String, dynamic> json) =>
      _$SkillEffectDefinitionFromJson(json);
}

@freezed
abstract class SkillDefinition with _$SkillDefinition {
  const factory SkillDefinition({
    required String id,
    @JsonKey(name: 'name_key') required String nameKey,
    @JsonKey(name: 'mana_cost') required int manaCost,
    @JsonKey(name: 'target_type') required String targetType,
    required List<SkillEffectDefinition> effects,
  }) = _SkillDefinition;

  factory SkillDefinition.fromJson(Map<String, dynamic> json) =>
      _$SkillDefinitionFromJson(json);
}
