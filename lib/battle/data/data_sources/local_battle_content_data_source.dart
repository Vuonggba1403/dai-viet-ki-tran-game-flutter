import 'dart:convert';

import 'package:ezwork/assets_gen/assets.gen.dart';
import 'package:flutter/services.dart';

/// Loads raw JSON content files using typed [Assets.gameData] paths.
class LocalBattleContentDataSource {
  const LocalBattleContentDataSource({AssetBundle? bundle}) : _bundle = bundle;

  final AssetBundle? _bundle;

  AssetBundle get _effectiveBundle => _bundle ?? rootBundle;

  /// Loads raw heroes JSON array.
  Future<List<dynamic>> loadHeroesJson() async {
    final raw = await _effectiveBundle.loadString(Assets.gameData.heroes);
    return jsonDecode(raw) as List<dynamic>;
  }

  /// Loads raw skills JSON array.
  Future<List<dynamic>> loadSkillsJson() async {
    final raw = await _effectiveBundle.loadString(Assets.gameData.skills);
    return jsonDecode(raw) as List<dynamic>;
  }

  /// Loads raw enemies JSON array.
  Future<List<dynamic>> loadEnemiesJson() async {
    final raw = await _effectiveBundle.loadString(Assets.gameData.enemies);
    return jsonDecode(raw) as List<dynamic>;
  }

  /// Loads raw stages JSON array.
  Future<List<dynamic>> loadStagesJson() async {
    final raw = await _effectiveBundle.loadString(Assets.gameData.stages);
    return jsonDecode(raw) as List<dynamic>;
  }
}
