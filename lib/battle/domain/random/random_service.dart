/// Interface for injectable pseudo-random number generator.
abstract interface class RandomService {
  /// Generates a non-negative random integer uniformly distributed in the range
  /// from 0, inclusive, to [max], exclusive.
  int nextInt(int max);

  /// Generates a non-negative random floating point value uniformly distributed
  /// in the range from 0.0, inclusive, to 1.0, exclusive.
  double nextDouble();

  /// Returns a random boolean value.
  bool nextBool();
}
