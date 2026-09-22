import 'package:dai_viet_ki_tran_game/app/design_system/game_colors.dart';
import 'package:dai_viet_ki_tran_game/app/design_system/game_radius.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/combat/hero_runtime.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/widgets/hero_skill_button.dart';
import 'package:dai_viet_ki_tran_game/heroes/ui/assets/hero_asset_catalog.dart';
import 'package:flutter/material.dart';

/// Bottom dock displaying the 4 party heroes with HP/Mana bars and skill triggers.
class BattleHeroDock extends StatelessWidget {
  const BattleHeroDock({
    required this.heroes,
    required this.canCastSkill,
    required this.onCastSkill,
    super.key,
  });

  final List<HeroRuntime> heroes;
  final bool Function(String heroId) canCastSkill;
  final ValueChanged<String> onCastSkill;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: const BoxDecoration(
        color: Color(0xEB1B1832),
        border: Border(
          top: BorderSide(color: Color(0xFF2C274D), width: 1.5),
        ),
      ),
      child: Row(
        children: [
          for (final hero in heroes) ...[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.5),
                child: _buildHeroSlot(hero),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeroSlot(HeroRuntime hero) {
    final isReady = canCastSkill(hero.id);
    final isDead = !hero.isAlive;
    final elementColor = HeroAssetCatalog.elementColor(hero.element);
    final portraitPath = HeroAssetCatalog.portraitPath(
      hero.assetKey ?? 'heroes/swordsman',
    );
    final hpRatio = hero.maxHp > 0
        ? (hero.currentHp / hero.maxHp).clamp(0.0, 1.0)
        : 0.0;
    final manaRatio = hero.maxMana > 0
        ? (hero.currentMana / hero.maxMana).clamp(0.0, 1.0)
        : 0.0;

    return Opacity(
      opacity: isDead ? 0.5 : 1.0,
      child: Container(
        key: Key('hero_card_${hero.id}'),
        decoration: BoxDecoration(
          color: const Color(0xFF24213D),
          borderRadius: GameRadius.borderMd,
          border: Border.all(
            color: isReady && !isDead
                ? GameColors.goldPrimary
                : const Color(0xFF3E3960),
            width: isReady && !isDead ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          key: Key('hero_skill_slot_${hero.id}'),
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top: Portrait + Name
            Row(
              children: [
                // Mini Portrait Frame
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: elementColor, width: 1.5),
                    color: const Color(0xFF141224),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      portraitPath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: elementColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Legible Name
                Expanded(
                  child: Text(
                    HeroAssetCatalog.localizedName(hero.nameKey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),

            // Mini HP Bar & Label
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: Container(
                    height: 9,
                    color: Colors.black54,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: hpRatio,
                      child: Container(color: GameColors.hpGreen),
                    ),
                  ),
                ),
                Text(
                  '${hero.currentHp}/${hero.maxHp}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 7.5,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 2)],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),

            // Mini Mana Bar & Label (Shows mana progress)
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: Container(
                    height: 9,
                    color: Colors.black54,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: manaRatio,
                      child: Container(color: GameColors.manaBlue),
                    ),
                  ),
                ),
                Text(
                  '${hero.currentMana}/${hero.maxMana}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 7.5,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 2)],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),

            // Skill Button: Always visible, stateful (Ready / Insufficient / Defeated)
            HeroSkillButton(
              heroId: hero.id,
              isReady: isReady,
              isAlive: !isDead,
              onPressed: () => onCastSkill(hero.id),
            ),
          ],
        ),
      ),
    );
  }
}
