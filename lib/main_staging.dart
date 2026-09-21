import 'package:ezwork/app/app.dart';
import 'package:ezwork/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() async {
    await StagingServiceLocator().setup();
    return const App();
  });
}
