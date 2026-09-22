import 'dart:math' as math;
import 'package:dai_viet_ki_tran_game/battle/data/models/hero_definition.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/tile_type.dart';

/// Runtime combat state of an active hero in the player's 4-hero team.
///
/// Pure Dart domain model — zero dependencies on Flutter, Flame, or GetIt.
class HeroRuntime {
  HeroRuntime({
    required this.id,
    required this.nameKey,
    required this.element,
    required this.heroClass,
    required this.maxHp,
    required int currentHp,
    required this.attack,
    required this.defense,
    required this.maxMana,
    required int currentMana,
    required this.activeSkillId,
    this.assetKey,
    this.placeholderColor,
  }) : _currentHp = currentHp.clamp(0, maxHp),
       _currentMana = currentMana.clamp(0, maxMana);

  factory HeroRuntime.fromDefinition(HeroDefinition def) {
    return HeroRuntime(
      id: def.id,
      nameKey: def.nameKey,
      element: def.element,
      heroClass: def.heroClass,
      maxHp: def.baseHp,
      currentHp: def.baseHp,
      attack: def.baseAttack,
      defense: def.baseDefense,
      maxMana: def.maxMana,
      currentMana: def.startingMana,
      activeSkillId: def.activeSkillId,
      assetKey: def.assetKey,
      placeholderColor: def.placeholderColor,
    );
  }

  final String id;
  final String nameKey;
  final TileType element;
  final String heroClass;
  final int maxHp;
  int _currentHp;
  final int attack;
  final int defense;
  final int maxMana;
  int _currentMana;
  final String activeSkillId;
  final String? assetKey;
  final String? placeholderColor;

  int get currentHp => _currentHp;
  int get currentMana => _currentMana;
  bool get isAlive => _currentHp > 0;
  double get hpRatio => maxHp > 0 ? _currentHp / maxHp : 0.0;
  double get manaRatio => maxMana > 0 ? _currentMana / maxMana : 0.0;

  /// Applies damage, reducing HP down to 0. Returns actual damage taken.
  int takeDamage(int amount) {
    if (amount <= 0 || !isAlive) return 0;
    final previousHp = _currentHp;
    _currentHp = math.max(0, _currentHp - amount);
    return previousHp - _currentHp;
  }

  /// Restores HP, capped at [maxHp]. Returns actual amount healed.
  int heal(int amount) {
    if (amount <= 0 || !isAlive) return 0;
    final previousHp = _currentHp;
    _currentHp = math.min(maxHp, _currentHp + amount);
    return _currentHp - previousHp;
  }

  /// Adds mana, capped at [maxMana]. Returns actual mana gained.
  int gainMana(int amount) {
    if (amount <= 0 || !isAlive) return 0;
    final previousMana = _currentMana;
    _currentMana = math.min(maxMana, _currentMana + amount);
    return _currentMana - previousMana;
  }

  /// Spends mana if sufficient. Returns true if spent successfully.
  bool spendMana(int amount) {
    if (amount <= 0) return true;
    if (_currentMana < amount) return false;
    _currentMana -= amount;
    return true;
  }

  HeroRuntime copy() {
    return HeroRuntime(
      id: id,
      nameKey: nameKey,
      element: element,
      heroClass: heroClass,
      maxHp: maxHp,
      currentHp: _currentHp,
      attack: attack,
      defense: defense,
      maxMana: maxMana,
      currentMana: _currentMana,
      activeSkillId: activeSkillId,
      assetKey: assetKey,
      placeholderColor: placeholderColor,
    );
  }
}
