import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  static final log = Logger('AppBlocObserver');

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log.info('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log.severe('onError(${bloc.runtimeType})', error, stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}

void setupLogging() {
  Logger.root.onRecord.listen((record) {
    if (record.loggerName == 'GoRouter') {
      return;
    }

    final String message;
    final messageHeader =
        '${record.level.name}: ${record.loggerName} : ${record.time}: ${record.message}';
    if (record.level < Level.SEVERE) {
      message = messageHeader;
      // TODO(init): Send to crashlytics
    } else {
      message = '$messageHeader : ${record.error} : ${record.stackTrace}';
    }

    if (kDebugMode) {
      print(message);
    }
  });
}

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  await runZonedGuarded(
    () async {
      setupLogging();

      WidgetsFlutterBinding.ensureInitialized();

      await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp],
      );

      Bloc.observer = const AppBlocObserver();

      runApp(await builder());
    },
    (exception, stackTrace) {
      Logger('Bootstrap').severe(
        'Unhandled application error',
        exception,
        stackTrace,
      );
    },
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        // Suppressing prints in release builds
        if (kDebugMode) {
          parent.print(zone, line);
        }
      },
    ),
  );
}
