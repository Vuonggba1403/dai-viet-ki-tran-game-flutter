import 'package:dai_viet_ki_tran_game/battle/domain/combat/enemy_runtime.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/combat/hero_runtime.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/assets/battle_asset_catalog.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/widgets/battle_character_sprite.dart';
import 'package:dai_viet_ki_tran_game/heroes/ui/assets/hero_asset_catalog.dart';
import 'package:flutter/material.dart';

/// Upper battlefield arena rendering player hero on left facing RIGHT,
/// and enemy combatant on right facing LEFT.
class BattleArena extends StatefulWidget {
  const BattleArena({
    required this.heroes,
    this.enemy,
    this.enableIdleAnimation = true,
    super.key,
  });

  final List<HeroRuntime> heroes;
  final EnemyRuntime? enemy;
  final bool enableIdleAnimation;

  @override
  State<BattleArena> createState() => _BattleArenaState();
}

class _BattleArenaState extends State<BattleArena>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bobController;
  late final Animation<double> _bobAnimation;

  @override
  void initState() {
    super.initState();
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _bobAnimation = Tween<double>(begin: 0, end: 3.5).animate(
      CurvedAnimation(parent: _bobController, curve: Curves.easeInOut),
    );

    if (widget.enableIdleAnimation) {
      _bobController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _bobController.dispose();
    super.dispose();
  }

  HeroRuntime? get _activePlayerHero {
    for (final hero in widget.heroes) {
      if (hero.isAlive) return hero;
    }
    return widget.heroes.isNotEmpty ? widget.heroes.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final activeHero = _activePlayerHero;
    final enemy = widget.enemy;

    final heroAssetKey = activeHero?.assetKey ?? 'heroes/swordsman';
    final heroSpritePath = HeroAssetCatalog.idleRightPath(heroAssetKey);
    final enemySpritePath = enemy != null
        ? BattleAssetCatalog.enemyIdleLeftPath(enemy.id)
        : BattleAssetCatalog.enemyIdleLeftPath('bandit');

    final isBoss = enemy != null && enemy.id == 'necromancer';

    return SizedBox(
      height: 155,
      child: AnimatedBuilder(
        animation: _bobAnimation,
        builder: (context, child) {
          final bobY = widget.enableIdleAnimation ? _bobAnimation.value : 0.0;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Left side: Player Hero (facing RIGHT)
              Positioned(
                left: 16,
                bottom: 6 + bobY,
                child: KeyedSubtree(
                  key: const Key('arena_player_hero'),
                  child: SizedBox(
                    width: 125,
                    height: 145,
                    child: BattleCharacterSprite(
                      spritePath: heroSpritePath,
                      scale: 1.2,
                      fallbackColor: const Color(0xFFE53935),
                    ),
                  ),
                ),
              ),

              // 2. Right side: Enemy (facing LEFT)
              Positioned(
                right: 16,
                bottom: 6 + (3.5 - bobY),
                child: KeyedSubtree(
                  key: const Key('arena_enemy'),
                  child: SizedBox(
                    width: isBoss ? 145 : 125,
                    height: isBoss ? 160 : 145,
                    child: BattleCharacterSprite(
                      spritePath: enemySpritePath,
                      scale: isBoss ? 1.4 : 1.2,
                      fallbackColor: const Color(0xFFEF5350),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
