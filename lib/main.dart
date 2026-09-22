import 'package:dai_viet_ki_tran_game/app/app.dart';
import 'package:dai_viet_ki_tran_game/audio/audio.dart';
import 'package:dai_viet_ki_tran_game/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() async {
    await ServiceLocator().setup();
    await getIt<AudioController>().initialize();
    await getIt<AudioSettingsCubit>().loadSettings();
    return const App();
  });
}
