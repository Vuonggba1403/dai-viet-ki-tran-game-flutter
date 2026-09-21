import 'package:ezwork/app/app.dart';
import 'package:ezwork/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() async {
    await ProductionServiceLocator().setup();
    return const App();
  });
}
