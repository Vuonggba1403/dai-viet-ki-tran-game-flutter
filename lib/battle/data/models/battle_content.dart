import 'package:ezwork/battle/data/models/enemy_definition.dart';
import 'package:ezwork/battle/data/models/hero_definition.dart';
import 'package:ezwork/battle/data/models/skill_definition.dart';
import 'package:ezwork/battle/data/models/stage_definition.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'battle_content.freezed.dart';
part 'battle_content.g.dart';

@freezed
abstract class BattleContent with _$BattleContent {
  const factory BattleContent({
    required List<HeroDefinition> heroes,
    required List<SkillDefinition> skills,
    required List<EnemyDefinition> enemies,
    required List<StageDefinition> stages,
  }) = _BattleContent;

  factory BattleContent.fromJson(Map<String, dynamic> json) =>
      _$BattleContentFromJson(json);
}
