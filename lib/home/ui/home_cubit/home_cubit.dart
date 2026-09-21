import 'package:bloc_effects/bloc_effects.dart';
import 'package:ezwork/auth/auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';

part 'home_cubit.freezed.dart';

@freezed
sealed class HomeStateEffect with _$HomeStateEffect {
  const factory HomeStateEffect.logout() = HomeStateEffectLogout;

  const factory HomeStateEffect.error({required String errorMessage}) =
      HomeStateEffectError;
}

class HomeState {}

class HomeCubit extends CubitWithEffects<HomeState, HomeStateEffect> {
  HomeCubit({
    required this.userRepository,
    required this.logoutUseCase,
  }) : super(HomeState());

  @visibleForTesting
  final UserRepository userRepository;

  @visibleForTesting
  final LogoutUseCase logoutUseCase;

  final _logger = Logger('HomeCubit');

  Future<void> getProfile() async {
    try {
      await userRepository.getProfile();
    } catch (e, stackTrace) {
      _logger.info('Get profile error', e, stackTrace);
    }
  }

  Future<void> logout() async {
    try {
      await logoutUseCase.call();
      emitEffect(const HomeStateEffect.logout());
    } catch (e, stackTrace) {
      _logger.info('Logout error', e, stackTrace);
      emitEffect(const HomeStateEffect.error(
          errorMessage:
              'Somthing went wrong. Please check your internet connection and try again.'));
    }
  }
}
