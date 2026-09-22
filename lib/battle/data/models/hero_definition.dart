// Remove json serialization warning
// ignore_for_file: invalid_annotation_target

import 'package:dai_viet_ki_tran_game/battle/domain/board/tile_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'hero_definition.freezed.dart';
part 'hero_definition.g.dart';

@freezed
abstract class HeroDefinition with _$HeroDefinition {
  const factory HeroDefinition({
    required String id,
    @JsonKey(name: 'name_key') required String nameKey,
    required TileType element,
    @JsonKey(name: 'hero_class') required String heroClass,
    @JsonKey(name: 'base_hp') required int baseHp,
    @JsonKey(name: 'base_attack') required int baseAttack,
    @JsonKey(name: 'base_defense') required int baseDefense,
    @JsonKey(name: 'max_mana') required int maxMana,
    @JsonKey(name: 'starting_mana') required int startingMana,
    @JsonKey(name: 'active_skill_id') required String activeSkillId,
    @JsonKey(name: 'asset_key') String? assetKey,
    @JsonKey(name: 'placeholder_color') String? placeholderColor,
    @Default('B') String rank,
    @Default(1) int level,
    int? power,
  }) = _HeroDefinition;

  factory HeroDefinition.fromJson(Map<String, dynamic> json) =>
      _$HeroDefinitionFromJson(json);
}
