import 'package:dio/dio.dart';
import 'package:ezwork/app/app.dart';
import 'package:ezwork/app/authorization/authorization_interceptor.dart';
import 'package:ezwork/auth/auth.dart';
import 'package:ezwork/battle/battle.dart';
import 'package:ezwork/example/data/data_sources/example_rest_data_source.dart';
import 'package:ezwork/example/example.dart' hide ExampleRestDataSource;
import 'package:ezwork/home/ui/home_cubit/home_cubit.dart';
import 'package:ezwork/splash_screen/splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt getIt = GetIt.instance;

class ProductionServiceLocator {
  AppConstants get appConstants => AppConstants();

  @mustCallSuper
  Future<void> setup() async {
    final sharedPreferences = SharedPreferencesAsync();
    getIt.registerSingleton(sharedPreferences);

    final localStorageDataSource = LocalStorageDataSource(
      sharedPreferences: getIt(),
    );
    await localStorageDataSource.init();

    getIt
      ..registerSingleton(localStorageDataSource)
      ..registerSingleton(appConstants)
      ..registerLazySingleton(
        () => AuthorizationInterceptor(
          appConstants: getIt(),
          localStorageDataSource: getIt(),
        ),
      )
      ..registerLazySingleton(() => createDio(getIt()))
      ..registerLazySingleton(() => ExampleRestDataSource(getIt()))
      ..registerLazySingleton(
        () => ExampleRepository(exampleFeatureRestDataSource: getIt()),
      )
      ..registerFactory(() => ExampleCubit(exampleRepository: getIt()))
      ..registerLazySingleton(
        () => RemoteUserDataSource(getIt(), baseUrl: appConstants.baseUrl),
      )
      ..registerLazySingleton(
        () => UserRepository(
          localStorageDataSource: getIt(),
          remoteUserDataSource: getIt(),
        ),
      )
      ..registerLazySingleton(() => SplashRepository(userRepository: getIt()))
      ..registerFactory(() => LogoutUseCase(userRepository: getIt()))
      ..registerFactory(() => RefreshTokenUseCase(getIt(), getIt(), getIt()))
      ..registerFactory(
        () => HomeCubit(userRepository: getIt(), logoutUseCase: getIt()),
      )
      ..registerFactory(
        () => SplashCubit(userRepository: getIt(), splashRepository: getIt()),
      )
      ..registerFactory(() => LoginCubit(userRepository: getIt()))
      ..registerLazySingleton(() => const LocalBattleContentDataSource())
      ..registerLazySingleton(
        () => BattleContentRepository(localDataSource: getIt()),
      )
      ..registerFactory(() => BattleSessionCubit(contentRepository: getIt()));
  }

  Dio createDio(AuthorizationInterceptor authorization) {
    final options = BaseOptions(
      baseUrl: appConstants.baseUrl,
      connectTimeout: appConstants.connectTimeout,
      receiveTimeout: appConstants.responseTimeOut,
    );
    final dio = Dio(options);

    dio.interceptors.add(authorization);
    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestBody: true,
          requestHeader: true,
        ),
      );
    }
    return dio;
  }
}

class StagingServiceLocator extends ProductionServiceLocator {
  @override
  AppConstants get appConstants => StagingAppConstants();
}

class DevelopmentServiceLocator extends ProductionServiceLocator {
  @override
  AppConstants get appConstants => DevelopmentAppConstants();
}
