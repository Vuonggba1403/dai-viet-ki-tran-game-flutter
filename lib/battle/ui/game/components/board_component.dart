import 'dart:math' as math;

import 'package:ezwork/battle/domain/board/board.dart';
import 'package:ezwork/battle/domain/board/board_position.dart';
import 'package:ezwork/battle/domain/board/tile.dart';
import 'package:ezwork/battle/domain/board/tile_type.dart';
import 'package:ezwork/battle/ui/game/battle_game_config.dart';
import 'package:ezwork/battle/ui/game/components/tile_component.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Flame component that renders the 7x7 board background, grid slots,
/// and manages [TileComponent] children tracked by runtime [Tile.id].
class BoardComponent extends PositionComponent {
  BoardComponent({
    required this.config,
    super.position,
    super.size,
  });

  final BattleGameConfig config;

  final Map<int, TileComponent> _tilesById = {};

  double _tileSize = 0;
  double _boardOffsetLeft = 0;
  double _boardOffsetTop = 0;

  /// The computed width/height of an individual tile slot.
  double get tileSize => _tileSize;

  /// Returns unmodifiable view of tile components keyed by tile ID.
  Map<int, TileComponent> get tilesById => Map.unmodifiable(_tilesById);

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _computeLayout();
  }

  void _computeLayout() {
    final availableWidth = size.x - (config.boardPadding * 2);
    final availableHeight = size.y - (config.boardPadding * 2);
    final minDim = math.min(availableWidth, availableHeight);

    final totalSpacing = (config.columnCount - 1) * config.tileSpacing;
    _tileSize = (minDim - totalSpacing) / config.columnCount;

    final actualBoardWidth = config.columnCount * _tileSize + totalSpacing;
    final actualBoardHeight = config.rowCount * _tileSize + totalSpacing;

    _boardOffsetLeft = (size.x - actualBoardWidth) / 2;
    _boardOffsetTop = (size.y - actualBoardHeight) / 2;
  }

  /// Calculates the center [Vector2] position for a given [BoardPosition].
  Vector2 positionFor(BoardPosition pos) {
    final x = _boardOffsetLeft +
        pos.column * (_tileSize + config.tileSpacing) +
        (_tileSize / 2);
    final y = _boardOffsetTop +
        pos.row * (_tileSize + config.tileSpacing) +
        (_tileSize / 2);
    return Vector2(x, y);
  }

  /// Converts a local position relative to this component to a [BoardPosition],
  /// returning null if out of bounds or in margin.
  BoardPosition? boardPositionFor(Vector2 localPosition) {
    final relX = localPosition.x - _boardOffsetLeft;
    final relY = localPosition.y - _boardOffsetTop;

    if (relX < 0 || relY < 0) return null;

    final stride = _tileSize + config.tileSpacing;
    final col = (relX / stride).floor();
    final row = (relY / stride).floor();

    if (col < 0 ||
        col >= config.columnCount ||
        row < 0 ||
        row >= config.rowCount) {
      return null;
    }

    // Check if pointer hit the spacing gap between tiles
    final cellX = relX - col * stride;
    final cellY = relY - row * stride;
    if (cellX > _tileSize || cellY > _tileSize) {
      return null;
    }

    return BoardPosition(row, col);
  }

  /// Populates the board with initial [TileComponent]s from the given [Board].
  void initTiles(Board board, {Map<TileType, Sprite>? sprites}) {
    // Clear existing tiles
    for (final tile in _tilesById.values) {
      tile.removeFromParent();
    }
    _tilesById.clear();
    _computeLayout();

    for (var r = 0; r < config.rowCount; r++) {
      for (var c = 0; c < config.columnCount; c++) {
        final domainTile = board.getTileAt(r, c);
        if (domainTile == null) continue;

        final pos = positionFor(BoardPosition(r, c));
        final comp = TileComponent(
          tileId: domainTile.id,
          initialTile: domainTile,
          position: pos,
          size: Vector2.all(_tileSize),
          sprite: sprites?[domainTile.type],
        );
        _tilesById[domainTile.id] = comp;
        add(comp);
      }
    }
  }

  /// Retrieves a tile component by its stable domain tile ID.
  TileComponent? getTile(int tileId) => _tilesById[tileId];

  /// Adds a new tile component to the board and tracks its ID.
  void addTile(TileComponent component) {
    _tilesById[component.tileId] = component;
    add(component);
  }

  /// Removes a tile component from the board by its ID.
  void removeTile(int tileId) {
    final comp = _tilesById.remove(tileId);
    comp?.removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 1. Draw outer board tray
    final totalSpacing = (config.columnCount - 1) * config.tileSpacing;
    final boardW = config.columnCount * _tileSize + totalSpacing;
    final boardH = config.rowCount * _tileSize + totalSpacing;
    final trayRect = Rect.fromLTWH(
      _boardOffsetLeft - 6,
      _boardOffsetTop - 6,
      boardW + 12,
      boardH + 12,
    );
    final trayRRect = RRect.fromRectAndRadius(
      trayRect,
      const Radius.circular(12),
    );

    final trayPaint = Paint()
      ..color = const Color(0xFF1E242B)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(trayRRect, trayPaint);

    final trayBorderPaint = Paint()
      ..color = const Color(0xFF37474F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(trayRRect, trayBorderPaint);

    // 2. Draw cell slots
    final slotPaint = Paint()
      ..color = const Color(0xFF13181E)
      ..style = PaintingStyle.fill;

    for (var r = 0; r < config.rowCount; r++) {
      for (var c = 0; c < config.columnCount; c++) {
        final pos = positionFor(BoardPosition(r, c));
        final slotRect = Rect.fromCenter(
          center: Offset(pos.x, pos.y),
          width: _tileSize,
          height: _tileSize,
        );
        final slotRRect = RRect.fromRectAndRadius(
          slotRect,
          Radius.circular(_tileSize * 0.18),
        );
        canvas.drawRRect(slotRRect, slotPaint);
      }
    }
  }
}
