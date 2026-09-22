import 'package:dai_viet_ki_tran_game/app/design_system/game_breakpoints.dart';
import 'package:dai_viet_ki_tran_game/app/design_system/game_colors.dart';
import 'package:dai_viet_ki_tran_game/app/design_system/game_spacing.dart';
import 'package:dai_viet_ki_tran_game/app/di/dependencies.dart';
import 'package:dai_viet_ki_tran_game/battle/data/repositories/battle_content_repository.dart';
import 'package:dai_viet_ki_tran_game/heroes/ui/models/hero_roster_item_view_model.dart';
import 'package:dai_viet_ki_tran_game/heroes/ui/widgets/hero_card.dart';
import 'package:dai_viet_ki_tran_game/heroes/ui/widgets/hero_roster_header.dart';
import 'package:flutter/material.dart';

/// Hero Roster screen presenting collection of heroes in a 2-column grid.
class HeroesPage extends StatefulWidget {
  const HeroesPage({
    this.initialHeroes,
    this.onSelectHero,
    super.key,
  });

  static const routeName = 'heroes';
  final List<HeroRosterItemViewModel>? initialHeroes;
  final ValueChanged<HeroRosterItemViewModel>? onSelectHero;

  @override
  State<HeroesPage> createState() => _HeroesPageState();
}

class _HeroesPageState extends State<HeroesPage> {
  late List<HeroRosterItemViewModel> _heroes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialHeroes != null) {
      _heroes = widget.initialHeroes!;
      _isLoading = false;
    } else {
      _loadHeroes();
    }
  }

  Future<void> _loadHeroes() async {
    try {
      final repo = getIt<BattleContentRepository>();
      final content = await repo.getBattleContent();
      final definitions = content.heroes;
      final ranks = ['S', 'A', 'B', 'B'];

      if (mounted) {
        setState(() {
          _heroes = [
            for (var i = 0; i < definitions.length; i++)
              HeroRosterItemViewModel.fromDefinition(
                definitions[i],
                rank: i < ranks.length ? ranks[i] : 'B',
              ),
          ];
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _heroes = const [];
          _isLoading = false;
        });
      }
    }
  }

  void _handleSelectHero(HeroRosterItemViewModel hero) {
    setState(() {
      _heroes = [
        for (final h in _heroes) h.copyWith(isSelected: h.id == hero.id),
      ];
    });
    widget.onSelectHero?.call(hero);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: GameColors.goldPrimary),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HeroRosterHeader(
          currentCount: _heroes.length,
        ),
        Expanded(
          child: _heroes.isEmpty
              ? const Center(
                  child: Text(
                    'Chưa có tướng nào',
                    style: TextStyle(color: GameColors.textSecondary),
                  ),
                )
              : GridView.builder(
                  key: const Key('heroes_grid'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: GameSpacing.heroGridPadding,
                    vertical: GameSpacing.xs,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: GameBreakpoints.heroCardAspectRatio,
                    crossAxisSpacing: GameSpacing.heroGridGap,
                    mainAxisSpacing: GameSpacing.heroGridGap,
                  ),
                  itemCount: _heroes.length,
                  itemBuilder: (context, index) {
                    final hero = _heroes[index];
                    return HeroCard(
                      hero: hero,
                      onTap: () => _handleSelectHero(hero),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
