import 'package:dai_viet_ki_tran_game/app/design_system/game_colors.dart';
import 'package:dai_viet_ki_tran_game/app/design_system/game_radius.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/combat/enemy_runtime.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/combat/hero_runtime.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/assets/battle_asset_catalog.dart';
import 'package:dai_viet_ki_tran_game/heroes/ui/assets/hero_asset_catalog.dart';
import 'package:flutter/material.dart';

/// Versus Combat HUD positioned between the arena and the Match-3 board.
/// Blue player panel on left, central round/combo badge, red enemy panel on right.
class BattleVersusHud extends StatelessWidget {
  const BattleVersusHud({
    required this.heroes,
    required this.comboCount,
    this.enemy,
    this.remainingTurns = 30,
    super.key,
  });

  final List<HeroRuntime> heroes;
  final EnemyRuntime? enemy;
  final int comboCount;
  final int remainingTurns;

  HeroRuntime? get _activeHero {
    for (final hero in heroes) {
      if (hero.isAlive) return hero;
    }
    return heroes.isNotEmpty ? heroes.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final activeHero = _activeHero;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xE61B1832),
        borderRadius: GameRadius.borderMd,
        border: Border.all(color: const Color(0xFF3B3563), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            offset: Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Left: Blue Player Status Panel
          Expanded(
            child: _buildPlayerPanel(activeHero),
          ),

          // 2. Center: Round & Combo Indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: _buildCenterBadge(),
          ),

          // 3. Right: Red Enemy Combat Card
          Expanded(
            child: _buildEnemyPanel(enemy),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerPanel(HeroRuntime? hero) {
    final name = hero != null
        ? HeroAssetCatalog.localizedName(hero.nameKey)
        : 'Đại Việt';
    final hpRatio = hero != null && hero.maxHp > 0
        ? (hero.currentHp / hero.maxHp).clamp(0.0, 1.0)
        : 0.0;
    final manaRatio = hero != null && hero.maxMana > 0
        ? (hero.currentMana / hero.maxMana).clamp(0.0, 1.0)
        : 0.0;

    return Row(
      children: [
        // Avatar frame
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF42A5F5), width: 1.5),
            color: const Color(0xFF152642),
          ),
          child: const Center(
            child: Icon(
              Icons.person_rounded,
              size: 24,
              color: Color(0xFF90CAF9),
            ),
          ),
        ),
        const SizedBox(width: 6),

        // HP and Mana bars
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              // HP Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Container(
                  height: 6,
                  color: Colors.black45,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: hpRatio,
                    child: Container(color: GameColors.hpGreen),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              // Mana Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Container(
                  height: 4,
                  color: Colors.black45,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: manaRatio,
                    child: Container(color: GameColors.manaBlue),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCenterBadge() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: GameColors.goldPrimary,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'VS',
            style: TextStyle(
              color: Colors.black,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (comboCount > 1) ...[
          const SizedBox(height: 2),
          Container(
            key: const Key('combo_badge'),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.amberAccent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$comboCount COMBO!',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEnemyPanel(EnemyRuntime? enemy) {
    final name = enemy != null
        ? BattleAssetCatalog.localizedEnemyName(enemy.nameKey)
        : 'Quái';
    final hp = enemy?.currentHp ?? 0;
    final maxHp = enemy?.maxHp ?? 1;
    final hpRatio = (hp / maxHp).clamp(0.0, 1.0);
    final turnCountdown = enemy?.turnCounter ?? 0;

    return Row(
      key: const Key('enemy_combat_card'),
      children: [
        // HP bar and Name
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              // HP Bar
              ClipRRect(
                key: const Key('enemy_hp_bar'),
                borderRadius: BorderRadius.circular(3),
                child: Container(
                  height: 6,
                  color: Colors.black45,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: hpRatio,
                    child: Container(color: GameColors.hpRed),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$hp/$maxHp',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),

        // Avatar frame with turn countdown overlay
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              key: const Key('enemy_avatar'),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: GameColors.hpRed, width: 1.5),
                color: const Color(0xFF33141E),
              ),
              child: const Center(
                child: Icon(
                  Icons.smart_toy_rounded,
                  size: 22,
                  color: Color(0xFFEF9A9A),
                ),
              ),
            ),
            // Countdown badge
            Positioned(
              bottom: -2,
              left: -4,
              child: Container(
                key: const Key('enemy_turn_countdown'),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: turnCountdown <= 1
                      ? Colors.redAccent
                      : Colors.amberAccent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white),
                ),
                child: Text(
                  '$turnCountdown',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
