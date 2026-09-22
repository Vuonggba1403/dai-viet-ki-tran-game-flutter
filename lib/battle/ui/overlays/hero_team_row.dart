import 'package:ezwork/battle/domain/combat/hero_runtime.dart';
import 'package:flutter/material.dart';

/// Bottom overlay widget displaying the active 4-hero combat team status.
///
/// Shows hero HP bars, Mana bars, status indicators, and skill readiness buttons.
class HeroTeamRow extends StatelessWidget {
  const HeroTeamRow({
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
    if (heroes.isEmpty) return const SizedBox.shrink();

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: heroes.map((hero) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _HeroCard(
                  hero: hero,
                  canCast: canCastSkill(hero.id),
                  onCast: () => onCastSkill(hero.id),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.hero,
    required this.canCast,
    required this.onCast,
  });

  final HeroRuntime hero;
  final bool canCast;
  final VoidCallback onCast;

  Color _elementColor() {
    return switch (hero.element.name) {
      'fire' => const Color(0xFFE53935),
      'water' => const Color(0xFF1E88E5),
      'lightning' => const Color(0xFFFDD835),
      'sword' => const Color(0xFF78909C),
      _ => Colors.grey,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isAlive = hero.isAlive;
    final elementColor = _elementColor();

    return Container(
      key: Key('hero_card_${hero.id}'),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isAlive
            ? Colors.black.withValues(alpha: 0.65)
            : Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: canCast
              ? Colors.amberAccent
              : (isAlive
                    ? elementColor.withValues(alpha: 0.7)
                    : Colors.white12),
          width: canCast ? 1.5 : 1.0,
        ),
        boxShadow: canCast
            ? [
                BoxShadow(
                  color: Colors.amberAccent.withValues(alpha: 0.4),
                  blurRadius: 6,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Element dot + Hero name snippet
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: elementColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  hero.id.split('_').first.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isAlive ? Colors.white : Colors.white38,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),

          // HP Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: hero.hpRatio,
              minHeight: 5,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(
                isAlive ? const Color(0xFF4CAF50) : Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            '${hero.currentHp}/${hero.maxHp}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 8,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 2),

          // Mana Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: hero.manaRatio,
              minHeight: 4,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF29B6F6),
              ),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            '${hero.currentMana}/${hero.maxMana}',
            style: const TextStyle(
              color: Colors.lightBlueAccent,
              fontSize: 8,
              fontWeight: FontWeight.w500,
            ),
          ),

          // Skill button if ready
          if (canCast) ...[
            const SizedBox(height: 2),
            SizedBox(
              height: 18,
              width: double.infinity,
              child: ElevatedButton(
                key: Key('hero_skill_button_${hero.id}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onPressed: onCast,
                child: const Text(
                  'CHIÊU',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
