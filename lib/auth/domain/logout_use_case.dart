import 'package:ezwork/auth/auth.dart';
import 'package:meta/meta.dart';

class LogoutUseCase {
  LogoutUseCase({
    required this.userRepository,
  });

  @visibleForTesting
  final UserRepository userRepository;

  Future<void> call() async {
    await userRepository.logout();
    // TODO(init): Clear other data
  }
}
