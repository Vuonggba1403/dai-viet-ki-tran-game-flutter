import 'package:dai_viet_ki_tran_game/app/app.dart';
import 'package:dai_viet_ki_tran_game/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() async {
    await ServiceLocator().setup();
    return const App();
  });
}
