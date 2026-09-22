import 'dart:math' as math;
import 'package:dai_viet_ki_tran_game/battle/domain/random/random_service.dart';

/// Deterministic [RandomService] implementation wrapping [math.Random].
class SeededRandom implements RandomService {
  SeededRandom([this.seed]) : _random = math.Random(seed);

  final int? seed;
  final math.Random _random;

  @override
  int nextInt(int max) {
    if (max <= 0) {
      throw ArgumentError.value(max, 'max', 'Must be positive');
    }
    return _random.nextInt(max);
  }

  @override
  double nextDouble() => _random.nextDouble();

  @override
  bool nextBool() => _random.nextBool();
}
