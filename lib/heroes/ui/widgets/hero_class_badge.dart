import 'package:dai_viet_ki_tran_game/heroes/ui/assets/hero_asset_catalog.dart';
import 'package:flutter/material.dart';

/// Circular badge showing hero class or weapon icon at bottom-left of hero card.
class HeroClassBadge extends StatelessWidget {
  const HeroClassBadge({
    required this.heroClass,
    this.size = 28.0,
    super.key,
  });

  final String heroClass;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            offset: Offset(0, 2),
            blurRadius: 3,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          HeroAssetCatalog.classIcon(heroClass),
          size: size * 0.60,
          color: Colors.white,
        ),
      ),
    );
  }
}
