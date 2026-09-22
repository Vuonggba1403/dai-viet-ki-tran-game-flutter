import 'package:dai_viet_ki_tran_game/app/design_system/game_colors.dart';
import 'package:dai_viet_ki_tran_game/app/di/dependencies.dart';
import 'package:dai_viet_ki_tran_game/app/ui/widgets/game_viewport.dart';
import 'package:dai_viet_ki_tran_game/audio/audio.dart';
import 'package:dai_viet_ki_tran_game/battle/battle.dart';
import 'package:dai_viet_ki_tran_game/game_shell/ui/widgets/game_bottom_navigation.dart';
import 'package:dai_viet_ki_tran_game/game_shell/ui/widgets/game_top_resource_bar.dart';
import 'package:dai_viet_ki_tran_game/heroes/heroes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Game Shell containing top resource bar, active tab, and bottom navigation.
class GameShellPage extends StatefulWidget {
  const GameShellPage({
    this.initialIndex = 2, // Default to Heroes tab (index 2)
    super.key,
  });

  static const routeName = 'game_shell';
  final int initialIndex;

  @override
  State<GameShellPage> createState() => _GameShellPageState();
}

class _GameShellPageState extends State<GameShellPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    if (getIt.isRegistered<AudioController>()) {
      getIt<AudioController>().enterHome();
    }
  }

  void _handleTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: GameViewport(
        child: Column(
          children: [
            // 1. Top Resource Bar
            const GameTopResourceBar(),

            // 2. Main Active Tab Body
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  _buildPlaceholderTab('Cửa Hàng', Icons.storefront_rounded),
                  _buildPlaceholderTab('Trang Bị', Icons.shield_outlined),
                  const HeroesPage(),
                  _buildCampaignTab(context),
                  const SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: AudioSettingsSection(),
                  ),
                ],
              ),
            ),

            // 3. Bottom Navigation
            GameBottomNavigation(
              currentIndex: _currentIndex,
              onTap: _handleTabSelected,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderTab(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: GameColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: GameColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tính năng đang được phát triển',
            style: TextStyle(color: GameColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignTab(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GameColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: GameColors.goldPrimary, width: 2),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.military_tech_rounded,
                    size: 56,
                    color: GameColors.goldPrimary,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'CHIẾN DỊCH: HOA LƯ SƠN',
                    style: TextStyle(
                      color: GameColors.goldPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Đánh bại đạo tặc Đỗ Cảnh Thạc và bình định 12 sứ quân',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: GameColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                key: const Key('enter_battle_button'),
                onPressed: () => context.pushNamed(
                  BattlePage.routeName,
                  queryParameters: const {'stageId': 'stage_1'},
                ),
                icon: const Icon(
                  Icons.sports_esports_rounded,
                  color: Colors.black,
                ),
                label: const Text(
                  'VÀO TRẬN ĐÁNH',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GameColors.goldPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
