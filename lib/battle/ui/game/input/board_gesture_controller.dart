import 'package:ezwork/battle/domain/board/board_position.dart';
import 'package:ezwork/battle/domain/board/swap.dart';
import 'package:ezwork/battle/ui/game/components/board_component.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

/// Flame component attached to [BoardComponent] that detects user drag/swipe
/// gestures, converts coordinates to orthogonal adjacent [Swap] commands,
/// and locks input during active animations.
class BoardGestureController extends PositionComponent with DragCallbacks {
  BoardGestureController({
    required this.boardComponent,
    required this.onSwapRequested,
    this.swipeThreshold = 18.0,
    super.position,
    super.size,
  });

  final BoardComponent boardComponent;
  void Function(Swap swap) onSwapRequested;
  final double swipeThreshold;

  @override
  bool containsLocalPoint(Vector2 point) {
    return boardComponent.boardPositionFor(point) != null;
  }

  bool _isLocked = false;
  BoardPosition? _dragStartPosition;
  Vector2 _accumulatedDelta = Vector2.zero();
  bool _swapDispatched = false;

  /// Whether input is currently locked (e.g. while animation queue is executing).
  bool get isLocked => _isLocked;
  set isLocked(bool value) {
    _isLocked = value;
    if (value) {
      _reset();
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (_isLocked) return;

    final boardPos = boardComponent.boardPositionFor(event.localPosition);
    if (boardPos != null) {
      _dragStartPosition = boardPos;
      _accumulatedDelta = Vector2.zero();
      _swapDispatched = false;
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (_isLocked || _swapDispatched || _dragStartPosition == null) return;

    _accumulatedDelta += event.localDelta;

    if (_accumulatedDelta.length >= swipeThreshold) {
      final target = targetPositionForDelta(
        _dragStartPosition!,
        _accumulatedDelta,
        threshold: swipeThreshold,
        rowCount: boardComponent.config.rowCount,
        columnCount: boardComponent.config.columnCount,
      );

      if (target != null) {
        _swapDispatched = true;
        onSwapRequested(Swap(from: _dragStartPosition!, to: target));
      }
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _reset();
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _reset();
  }

  void _reset() {
    _dragStartPosition = null;
    _accumulatedDelta = Vector2.zero();
    _swapDispatched = false;
  }

  /// Calculates adjacent target [BoardPosition] given start position and delta vector.
  ///
  /// Picks dominant axis (horizontal vs vertical). Returns null if delta length
  /// is below threshold or if target would be outside board bounds.
  static BoardPosition? targetPositionForDelta(
    BoardPosition from,
    Vector2 delta, {
    required double threshold,
    int rowCount = 7,
    int columnCount = 7,
  }) {
    if (delta.length < threshold) return null;

    final absX = delta.x.abs();
    final absY = delta.y.abs();

    var targetRow = from.row;
    var targetCol = from.column;

    if (absX >= absY) {
      targetCol += delta.x > 0 ? 1 : -1;
    } else {
      targetRow += delta.y > 0 ? 1 : -1;
    }

    final target = BoardPosition(targetRow, targetCol);
    if (target.isValid(rowCount: rowCount, columnCount: columnCount)) {
      return target;
    }
    return null;
  }
}
