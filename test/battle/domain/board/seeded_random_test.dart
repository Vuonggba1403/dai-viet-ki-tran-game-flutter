import 'package:ezwork/battle/domain/random/seeded_random.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SeededRandom', () {
    test('produces identical deterministic sequences for identical seeds', () {
      final rng1 = SeededRandom(12345);
      final rng2 = SeededRandom(12345);

      final seq1 = List.generate(20, (_) => rng1.nextInt(100));
      final seq2 = List.generate(20, (_) => rng2.nextInt(100));

      expect(seq1, equals(seq2));
    });

    test('different seeds produce different sequences', () {
      final rng1 = SeededRandom(111);
      final rng2 = SeededRandom(222);

      final seq1 = List.generate(20, (_) => rng1.nextInt(100));
      final seq2 = List.generate(20, (_) => rng2.nextInt(100));

      expect(seq1, isNot(equals(seq2)));
    });

    test('nextInt throws on non-positive max', () {
      final rng = SeededRandom(42);
      expect(() => rng.nextInt(0), throwsArgumentError);
      expect(() => rng.nextInt(-5), throwsArgumentError);
    });

    test('nextDouble returns values in [0.0, 1.0)', () {
      final rng = SeededRandom(999);
      for (var i = 0; i < 50; i++) {
        final val = rng.nextDouble();
        expect(val, greaterThanOrEqualTo(0.0));
        expect(val, lessThan(1.0));
      }
    });
  });
}
