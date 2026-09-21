import 'package:ezwork/battle/domain/board/special_tile_type.dart';
import 'package:ezwork/battle/domain/board/tile_type.dart';
import 'package:meta/meta.dart';

/// Represents an immutable tile on the Match-3 board.
///
/// [id] is a unique runtime identifier assigned upon generation/spawn,
/// ensuring Flame visual components can track identity across cascades.
@immutable
class Tile {
  const Tile({
    required this.id,
    required this.type,
    this.specialType = SpecialTileType.none,
  });

  final int id;
  final TileType type;
  final SpecialTileType specialType;

  bool get isSpecial => specialType.isSpecial;

  Tile copyWith({
    TileType? type,
    SpecialTileType? specialType,
  }) {
    return Tile(
      id: id,
      type: type ?? this.type,
      specialType: specialType ?? this.specialType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tile &&
        other.id == id &&
        other.type == type &&
        other.specialType == specialType;
  }

  @override
  int get hashCode => Object.hash(id, type, specialType);

  @override
  String toString() => 'Tile(id: $id, type: $type, special: $specialType)';
}
