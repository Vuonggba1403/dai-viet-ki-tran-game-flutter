import 'package:dai_viet_ki_tran_game/app/design_system/themes.dart';
import 'package:dai_viet_ki_tran_game/app/ui/view/navigation.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Dai Viet Ki Tran',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      routerConfig: router,
    );
  }
}
