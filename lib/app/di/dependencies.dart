import 'package:dai_viet_ki_tran_game/battle/battle.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

class ServiceLocator {
  Future<void> setup() async {
    getIt
      ..registerLazySingleton(() => const LocalBattleContentDataSource())
      ..registerLazySingleton(
        () => BattleContentRepository(localDataSource: getIt()),
      )
      ..registerFactory(() => BattleSessionCubit(contentRepository: getIt()));
  }
}
