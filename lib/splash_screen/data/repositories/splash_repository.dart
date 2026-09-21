import 'package:ezwork/auth/data/repositories/user_repository.dart';
import 'package:meta/meta.dart';

class SplashRepository {
  SplashRepository({
    required this.userRepository,
  });

  @visibleForTesting
  final UserRepository userRepository;

  Future<void> init() async {
    await userRepository.init();
    // TODO(init): Init other repositories here.
  }
}
