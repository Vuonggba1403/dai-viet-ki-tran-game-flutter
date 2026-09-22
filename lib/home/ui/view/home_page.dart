import 'package:dai_viet_ki_tran_game/battle/battle.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const routeName = 'home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đại Việt Kỳ Trận')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Loạn 12 Sứ Quân'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              key: const Key('enter_battle_button'),
              onPressed: () => context.pushNamed(BattlePage.routeName),
              icon: const Icon(Icons.sports_esports_rounded),
              label: const Text('Vào trận'),
            ),
          ],
        ),
      ),
    );
  }
}
