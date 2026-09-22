import 'package:dai_viet_ki_tran_game/battle/data/models/hero_definition.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/tile_type.dart';
import 'package:dai_viet_ki_tran_game/heroes/ui/assets/hero_asset_catalog.dart';
import 'package:flutter/foundation.dart';

/// Presentation view model for a hero in the roster/inventory screen.
@immutable
class HeroRosterItemViewModel {
  const HeroRosterItemViewModel({
    required this.id,
    required this.name,
    required this.rank,
    required this.element,
    required this.heroClass,
    required this.assetKey,
    required this.portraitPath,
    this.level = 1,
    this.power = 1200,
    this.isSelected = false,
  });

  /// Factory adapter creating view model from domain [HeroDefinition].
  factory HeroRosterItemViewModel.fromDefinition(
    HeroDefinition def, {
    String? rank,
    int? level,
    int? power,
    bool isSelected = false,
  }) {
    final assetKey = def.assetKey ?? 'heroes/swordsman';
    final effectiveRank = rank ?? def.rank;
    final effectiveLevel = level ?? def.level;
    final effectivePower =
        power ??
        def.power ??
        (def.baseHp + def.baseAttack * 3 + def.baseDefense * 2);
    return HeroRosterItemViewModel(
      id: def.id,
      name: HeroAssetCatalog.localizedName(def.nameKey),
      rank: effectiveRank,
      element: def.element,
      heroClass: def.heroClass,
      assetKey: assetKey,
      portraitPath: HeroAssetCatalog.portraitPath(assetKey),
      level: effectiveLevel,
      power: effectivePower,
      isSelected: isSelected,
    );
  }

  final String id;
  final String name;
  final String rank;
  final TileType element;
  final String heroClass;
  final String assetKey;
  final String portraitPath;
  final int level;
  final int power;
  final bool isSelected;

  HeroRosterItemViewModel copyWith({
    bool? isSelected,
    int? level,
  }) {
    return HeroRosterItemViewModel(
      id: id,
      name: name,
      rank: rank,
      element: element,
      heroClass: heroClass,
      assetKey: assetKey,
      portraitPath: portraitPath,
      level: level ?? this.level,
      power: power,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeroRosterItemViewModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          isSelected == other.isSelected &&
          level == other.level;

  @override
  int get hashCode => Object.hash(id, isSelected, level);
}
