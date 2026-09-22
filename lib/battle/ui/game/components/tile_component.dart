import 'package:ezwork/battle/domain/board/special_tile_type.dart';
import 'package:ezwork/battle/domain/board/tile.dart';
import 'package:ezwork/battle/domain/board/tile_type.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

/// Visual Flame component representing a Match-3 tile on the board.
///
/// Component identity is strictly tracked by [tileId] across gravity drops
/// and shuffles to preserve component instance reuse and avoid rebuilding.
class TileComponent extends PositionComponent {
  TileComponent({
    required this.tileId,
    required Tile initialTile,
    super.position,
    super.size,
    this.sprite,
  })  : tile = initialTile,
        super(
          anchor: Anchor.center,
        );

  /// Stable unique runtime ID corresponding to [Tile.id].
  final int tileId;

  /// The current domain tile represented by this component.
  Tile tile;

  /// Optional sprite loaded from typed assets.
  Sprite? sprite;

  /// Animates movement to [targetPosition] over [duration] seconds.
  void moveTo(
    Vector2 targetPosition, {
    required double duration,
    VoidCallback? onComplete,
  }) {
    if (duration <= 0) {
      position = targetPosition;
      onComplete?.call();
      return;
    }

    add(
      MoveEffect.to(
        targetPosition,
        EffectController(duration: duration, curve: Curves.easeInOut),
        onComplete: onComplete,
      ),
    );
  }

  /// Animates scaling to [targetScale] over [duration] seconds.
  void animateScale(
    Vector2 targetScale, {
    required double duration,
    VoidCallback? onComplete,
  }) {
    if (duration <= 0) {
      scale = targetScale;
      onComplete?.call();
      return;
    }

    add(
      ScaleEffect.to(
        targetScale,
        EffectController(duration: duration, curve: Curves.easeInOut),
        onComplete: onComplete,
      ),
    );
  }

  /// Animates scale down to zero and calls [onComplete] when cleared.
  void animateClear({
    required double duration,
    VoidCallback? onComplete,
  }) {
    animateScale(
      Vector2.zero(),
      duration: duration,
      onComplete: onComplete,
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(size.x * 0.18));

    // 1. Draw base rounded rect with element-specific color
    final bgPaint = Paint()
      ..color = _colorForType(tile.type)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, bgPaint);

    // 2. Draw subtle border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(rrect, borderPaint);

    // 3. Draw sprite if loaded, otherwise render distinct symbol for accessibility
    if (sprite != null) {
      sprite!.render(
        canvas,
        position: Vector2(size.x * 0.1, size.y * 0.1),
        size: Vector2(size.x * 0.8, size.y * 0.8),
      );
    } else {
      _renderSymbol(canvas, rect);
    }

    // 4. Render special tile overlays
    if (tile.isSpecial) {
      _renderSpecialOverlay(canvas, rect);
    }
  }

  void _renderSymbol(Canvas canvas, Rect rect) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: _symbolForType(tile.type),
        style: TextStyle(
          color: Colors.white,
          fontSize: size.x * 0.42,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(
              blurRadius: 3,
              color: Colors.black54,
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final textOffset = Offset(
      (rect.width - textPainter.width) / 2,
      (rect.height - textPainter.height) / 2,
    );
    textPainter.paint(canvas, textOffset);
  }

  void _renderSpecialOverlay(Canvas canvas, Rect rect) {
    final overlayPaint = Paint()
      ..color = Colors.amberAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    switch (tile.specialType) {
      case SpecialTileType.lineHorizontal:
        // Draw horizontal glowing lines
        final y = rect.height / 2;
        canvas.drawLine(
          Offset(4, y),
          Offset(rect.width - 4, y),
          overlayPaint..color = Colors.yellowAccent,
        );
      case SpecialTileType.lineVertical:
        // Draw vertical glowing lines
        final x = rect.width / 2;
        canvas.drawLine(
          Offset(x, 4),
          Offset(x, rect.height - 4),
          overlayPaint..color = Colors.cyanAccent,
        );
      case SpecialTileType.bomb:
        // Draw glowing circular ring
        final radius = rect.width * 0.38;
        canvas.drawCircle(
          rect.center,
          radius,
          overlayPaint..color = Colors.orangeAccent,
        );
      case SpecialTileType.powerGem:
        // Draw diamond frame
        final path = Path()
          ..moveTo(rect.center.dx, 2)
          ..lineTo(rect.width - 2, rect.center.dy)
          ..lineTo(rect.center.dx, rect.height - 2)
          ..lineTo(2, rect.center.dy)
          ..close();
        canvas.drawPath(path, overlayPaint..color = Colors.purpleAccent);
      case SpecialTileType.none:
        break;
    }
  }

  static Color _colorForType(TileType type) {
    return switch (type) {
      TileType.sword => const Color(0xFF78909C), // Steel Grey
      TileType.fire => const Color(0xFFE53935), // Fiery Red
      TileType.water => const Color(0xFF1E88E5), // Ocean Blue
      TileType.lightning => const Color(0xFFFBC02D), // Electric Amber
      TileType.heart => const Color(0xFFE91E63), // Pink Heart
    };
  }

  static String _symbolForType(TileType type) {
    return switch (type) {
      TileType.sword => '⚔',
      TileType.fire => '🔥',
      TileType.water => '💧',
      TileType.lightning => '⚡',
      TileType.heart => '♥',
    };
  }
}
