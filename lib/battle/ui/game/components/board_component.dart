import 'dart:math' as math;

import 'package:dai_viet_ki_tran_game/app/design_system/game_colors.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/board.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/board_position.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/tile.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/tile_type.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/game/battle_game_config.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/game/components/tile_component.dart';
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
    final x =
        _boardOffsetLeft +
        pos.column * (_tileSize + config.tileSpacing) +
        (_tileSize / 2);
    final y =
        _boardOffsetTop +
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

  /// Remaps an existing tile component to a new tile ID and data (e.g. upon special tile creation).
  void remapTile(int oldId, Tile newTile, {Sprite? sprite}) {
    final comp = _tilesById.remove(oldId);
    if (comp != null) {
      comp
        ..tileId = newTile.id
        ..tile = newTile;
      if (sprite != null) {
        comp.sprite = sprite;
      }
      _tilesById[newTile.id] = comp;
    }
  }

  /// Relayouts all existing tile components to fit resized board geometry.
  /// Reconciles components against [currentBoard] without duplicating or losing tiles.
  void relayoutTiles(Board currentBoard, {Map<TileType, Sprite>? sprites}) {
    _computeLayout();
    final newTileSize = Vector2.all(_tileSize);

    // 1. Identify all active tile IDs in current domain board
    final activeIds = <int>{};
    for (var r = 0; r < Board.rowCount; r++) {
      for (var c = 0; c < Board.columnCount; c++) {
        final tile = currentBoard.getTileAt(r, c);
        if (tile != null) activeIds.add(tile.id);
      }
    }

    // 2. Remove any orphaned tile components not in current domain board
    final obsoleteIds = _tilesById.keys
        .where((id) => !activeIds.contains(id))
        .toList();
    for (final id in obsoleteIds) {
      final comp = _tilesById.remove(id);
      comp?.removeFromParent();
    }

    // 3. Update or reconcile all 49 slots
    for (var r = 0; r < Board.rowCount; r++) {
      for (var c = 0; c < Board.columnCount; c++) {
        final pos = BoardPosition(r, c);
        final tile = currentBoard.getTileAt(r, c);
        if (tile != null) {
          var comp = _tilesById[tile.id];
          if (comp == null) {
            comp = TileComponent(
              tileId: tile.id,
              initialTile: tile,
              position: positionFor(pos),
              size: newTileSize,
              sprite: sprites?[tile.type],
            );
            _tilesById[tile.id] = comp;
            add(comp);
          } else {
            comp
              ..tile = tile
              ..size = newTileSize
              ..position = positionFor(pos);
            if (sprites?[tile.type] != null) {
              comp.sprite = sprites![tile.type];
            }
          }
        }
      }
    }
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
      ..color = GameColors.woodBoard
      ..style = PaintingStyle.fill;
    canvas.drawRRect(trayRRect, trayPaint);

    final trayBorderPaint = Paint()
      ..color = GameColors.goldBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawRRect(trayRRect, trayBorderPaint);

    // Inner bevel line
    final innerBevelPaint = Paint()
      ..color = const Color(0xFF5D3A20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        trayRect.deflate(2),
        const Radius.circular(10),
      ),
      innerBevelPaint,
    );

    // 2. Draw cell slots with alternating light/dark wood
    final slotLightPaint = Paint()
      ..color = GameColors.woodSlotLight
      ..style = PaintingStyle.fill;
    final slotDarkPaint = Paint()
      ..color = GameColors.woodSlotDark
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
        final isEvenCell = (r + c).isEven;
        canvas.drawRRect(
          slotRRect,
          isEvenCell ? slotLightPaint : slotDarkPaint,
        );
      }
    }
  }
}
