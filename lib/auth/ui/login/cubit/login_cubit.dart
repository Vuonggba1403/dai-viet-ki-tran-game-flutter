import 'package:bloc_effects/bloc_effects.dart';
import 'package:ezwork/app/network/data/models/base_response.dart';
import 'package:ezwork/auth/auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';

part 'login_cubit.freezed.dart';

class LoginState {}

@freezed
sealed class LoginStateEffect with _$LoginStateEffect {
  const factory LoginStateEffect.loading() = LoginStateEffectLoading;

  const factory LoginStateEffect.success({
    required User user,
  }) = LoginStateEffectSuccess;

  const factory LoginStateEffect.error({
    required String errorMessage,
  }) = LoginStateEffectError;
}

class LoginCubit extends CubitWithEffects<LoginState, LoginStateEffect> {
  LoginCubit({
    required this.userRepository,
  }) : super(LoginState());

  @visibleForTesting
  final UserRepository userRepository;

  final _logger = Logger('LoginCubit');

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emitEffect(const LoginStateEffect.loading());
    try {
      final response = await userRepository.login(email, password);
      if (response.success && response.data != null) {
        emitEffect(LoginStateEffect.success(user: response.data!));
      } else {
        emitEffect(LoginStateEffect.error(errorMessage: response.message));
      }
    } on ApiExeption catch (e, stacktrace) {
      _logger.info('Login error', e, stacktrace);
      emitEffect(LoginStateEffect.error(errorMessage: e.errorDetail.message));
    } catch (e, stacktrace) {
      _logger.info('Login error', e, stacktrace);
      emitEffect(const LoginStateEffect.error(
          errorMessage:
              'Somthing went wrong. Please check your internet connection and try again.'));
    }
  }
}
