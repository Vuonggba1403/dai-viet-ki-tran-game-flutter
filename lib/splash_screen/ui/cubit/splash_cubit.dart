import 'package:ezwork/auth/data/repositories/user_repository.dart';
import 'package:ezwork/splash_screen/data/repositories/splash_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'splash_cubit.freezed.dart';

@freezed
sealed class SplashState with _$SplashState {
  const factory SplashState.loading() = SplashStateLoading;

  const factory SplashState.loaded({
    required bool hasUserLoggedIn,
  }) = SplashStateLoaded;
}

class SplashCubit extends Cubit<SplashState> {
  SplashCubit({
    required this.splashRepository,
    required this.userRepository,
  }) : super(const SplashState.loading());

  @visibleForTesting
  final SplashRepository splashRepository;

  @visibleForTesting
  final UserRepository userRepository;

  static const _delayTime = Duration(seconds: 2);

  Future<void> load() async {
    await Future.wait([
      Future.delayed(_delayTime, () {}),
      splashRepository.init(),
    ]);

    final hasUserLoggedIn = userRepository.hasUserLoggedIn();
    emit(SplashState.loaded(hasUserLoggedIn: hasUserLoggedIn));
  }
}
