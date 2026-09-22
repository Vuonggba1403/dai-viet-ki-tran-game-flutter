import 'package:dai_viet_ki_tran_game/app/design_system/themes.dart';
import 'package:dai_viet_ki_tran_game/app/di/dependencies.dart';
import 'package:dai_viet_ki_tran_game/app/ui/view/navigation.dart';
import 'package:dai_viet_ki_tran_game/audio/audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<AudioSettingsCubit>(),
      child: AudioUnlockListener(
        audioController: getIt<AudioController>(),
        child: MaterialApp.router(
          title: 'Dai Viet Ki Tran',
          debugShowCheckedModeBanner: false,
          theme: appTheme,
          routerConfig: router,
        ),
      ),
    );
  }
}
