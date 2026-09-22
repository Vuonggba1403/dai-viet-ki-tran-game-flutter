import 'package:dai_viet_ki_tran_game/app/design_system/game_colors.dart';
import 'package:dai_viet_ki_tran_game/app/design_system/game_radius.dart';
import 'package:dai_viet_ki_tran_game/app/design_system/game_shadows.dart';
import 'package:dai_viet_ki_tran_game/app/design_system/game_typography.dart';
import 'package:dai_viet_ki_tran_game/heroes/ui/assets/hero_asset_catalog.dart';
import 'package:dai_viet_ki_tran_game/heroes/ui/models/hero_roster_item_view_model.dart';
import 'package:dai_viet_ki_tran_game/heroes/ui/widgets/hero_class_badge.dart';
import 'package:dai_viet_ki_tran_game/heroes/ui/widgets/hero_portrait.dart';
import 'package:dai_viet_ki_tran_game/heroes/ui/widgets/hero_rank_badge.dart';
import 'package:flutter/material.dart';

/// 2-column portrait hero card matching the game reference aesthetic.
class HeroCard extends StatelessWidget {
  const HeroCard({
    required this.hero,
    this.onTap,
    super.key,
  });

  final HeroRosterItemViewModel hero;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = hero.isSelected
        ? GameColors.goldPrimary
        : const Color(0xFF4A4468);
    final borderWidth = hero.isSelected ? 2.5 : 1.5;

    return RepaintBoundary(
      child: GestureDetector(
        key: Key('hero_card_${hero.id}'),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: GameRadius.borderLg,
            gradient: HeroAssetCatalog.cardGradient(hero.element),
            border: Border.all(
              color: borderColor,
              width: borderWidth,
            ),
            boxShadow: [
              GameShadows.card,
              if (hero.isSelected) GameShadows.goldGlow,
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Subtle radial glow behind character
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      radius: 0.8,
                      colors: [
                        Colors.white.withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Hero Character Portrait (takes ~80% height, bottom-aligned)
              Positioned(
                left: 8,
                right: 8,
                bottom: 6,
                top: 24,
                child: HeroPortrait(
                  portraitPath: hero.portraitPath,
                  fallbackColor: HeroAssetCatalog.elementColor(hero.element),
                ),
              ),

              // 3. Bottom gradient scrim for high-contrast name display
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 48,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.75),
                        Colors.black.withValues(alpha: 0.90),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. Rank Badge (top-left)
              Positioned(
                top: 6,
                left: 6,
                child: HeroRankBadge(rank: hero.rank),
              ),

              // 5. Class / Weapon Badge (bottom-left)
              Positioned(
                bottom: 8,
                left: 8,
                child: HeroClassBadge(heroClass: hero.heroClass),
              ),

              // 6. Hero Name (bottom-right)
              Positioned(
                bottom: 12,
                right: 10,
                left: 42,
                child: Text(
                  hero.name,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GameTypography.heroCardName,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
