import 'package:ezwork/battle/domain/board/board_position.dart';
import 'package:ezwork/battle/domain/board/special_tile_type.dart';
import 'package:ezwork/battle/domain/board/tile_type.dart';
import 'package:meta/meta.dart';

/// Represents a validated group of matched tiles of identical [TileType].
@immutable
class MatchGroup {
  const MatchGroup({
    required this.tileType,
    required this.positions,
    this.specialCreated = SpecialTileType.none,
    this.specialSpawnPosition,
  });

  final TileType tileType;
  final Set<BoardPosition> positions;
  final SpecialTileType specialCreated;
  final BoardPosition? specialSpawnPosition;

  int get count => positions.length;

  bool get createsSpecial => specialCreated != SpecialTileType.none;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MatchGroup) return false;
    if (tileType != other.tileType ||
        specialCreated != other.specialCreated ||
        specialSpawnPosition != other.specialSpawnPosition ||
        positions.length != other.positions.length) {
      return false;
    }
    return positions.containsAll(other.positions);
  }

  @override
  int get hashCode => Object.hash(
        tileType,
        Object.hashAll(positions),
        specialCreated,
        specialSpawnPosition,
      );

  @override
  String toString() =>
      'MatchGroup($tileType, count: $count, special: $specialCreated @ $specialSpawnPosition)';
}
