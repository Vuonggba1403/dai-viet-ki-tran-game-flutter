import 'package:dai_viet_ki_tran_game/game_shell/game_shell.dart';
import 'package:flutter/material.dart';

/// Main container page hosting the game shell and hero roster.
class HomePage extends StatelessWidget {
  const HomePage({
    this.initialTab = 2, // Default to Heroes tab
    super.key,
  });

  static const routeName = 'home';
  final int initialTab;

  @override
  Widget build(BuildContext context) {
    return GameShellPage(initialIndex: initialTab);
  }
}
