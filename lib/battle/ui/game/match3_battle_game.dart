import 'package:ezwork/assets_gen/assets.gen.dart';
import 'package:ezwork/battle/domain/battle_session_controller.dart';
import 'package:ezwork/battle/domain/board/swap.dart';
import 'package:ezwork/battle/domain/board/tile_type.dart';
import 'package:ezwork/battle/ui/game/animation/battle_animation_queue.dart';
import 'package:ezwork/battle/ui/game/battle_game_config.dart';
import 'package:ezwork/battle/ui/game/components/board_component.dart';
import 'package:ezwork/battle/ui/game/input/board_gesture_controller.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// FlameGame instance managing the Match-3 rendering, input, and animation pipeline.
///
/// Strictly decoupled from Flutter widgets, GoRouter, BuildContext, and GetIt.
/// Receives the domain [BattleSessionController] and [BattleGameConfig] via constructor.
class Match3BattleGame extends FlameGame {
  Match3BattleGame({
    required this.sessionController,
    this.config = const BattleGameConfig(),
    this.onComboChanged,
    this.onAnimationStart,
    this.onAnimationComplete,
  });

  final BattleSessionController sessionController;
  final BattleGameConfig config;
  final ValueChanged<int>? onComboChanged;
  final VoidCallback? onAnimationStart;
  final VoidCallback? onAnimationComplete;

  BoardComponent? _boardComponent;
  BoardComponent get boardComponent => _boardComponent!;

  BoardGestureController? _gestureController;
  BoardGestureController get gestureController => _gestureController!;

  BattleAnimationQueue? _animationQueue;
  BattleAnimationQueue get animationQueue => _animationQueue!;

  final Map<TileType, Sprite> _sprites = {};

  bool _isInputLocked = false;
  bool _hasPendingResize = false;

  /// Whether user swipe input is currently locked.
  bool get isInputLocked =>
      _isInputLocked || (_animationQueue?.isBusy ?? false);
  set isInputLocked(bool value) {
    _isInputLocked = value;
    _gestureController?.isLocked = isInputLocked;
  }

  @override
  Color backgroundColor() => const Color(0xFF0F141C);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1. Initialize BoardComponent
    final board = BoardComponent(
      config: config,
      position: Vector2.zero(),
      size: size,
    );
    _boardComponent = board;
    await add(board);

    // 2. Initialize GestureController
    final gesture = BoardGestureController(
      boardComponent: board,
      size: board.size,
      onSwapRequested: handleSwapRequested,
    );
    _gestureController = gesture;
    await board.add(gesture);

    // 3. Initialize AnimationQueue
    _animationQueue = BattleAnimationQueue(
      onAnimationStart: () {
        gesture.isLocked = true;
        onAnimationStart?.call();
      },
      onAnimationComplete: () {
        if (_hasPendingResize) {
          _hasPendingResize = false;
          boardComponent.relayoutTiles(
            sessionController.currentBoard,
            sprites: _sprites,
          );
        }
        gestureController.isLocked = _isInputLocked;
        onAnimationComplete?.call();
      },
      onComboStep: (cycle) {
        onComboChanged?.call(cycle);
      },
    );

    // 4. Lazy-load only the 5 battle tile sprites using generated Assets API
    await _loadTileSprites();

    // 5. Populate initial board
    board.initTiles(
      sessionController.currentBoard,
      sprites: _sprites,
    );
  }

  Future<void> _loadTileSprites() async {
    try {
      images.prefix = '';
      final swordImage = await images.load(
        Assets.images.game.tiles.base.sword.path,
      );
      final fireImage = await images.load(
        Assets.images.game.tiles.base.fire.path,
      );
      final waterImage = await images.load(
        Assets.images.game.tiles.base.water.path,
      );
      final lightningImage = await images.load(
        Assets.images.game.tiles.base.lightning.path,
      );
      final heartImage = await images.load(
        Assets.images.game.tiles.base.heart.path,
      );

      _sprites[TileType.sword] = Sprite(swordImage);
      _sprites[TileType.fire] = Sprite(fireImage);
      _sprites[TileType.water] = Sprite(waterImage);
      _sprites[TileType.lightning] = Sprite(lightningImage);
      _sprites[TileType.heart] = Sprite(heartImage);
    } catch (_) {
      // In headless test environments where image asset bundle is unavailable,
      // fallback cleanly to accessible Canvas symbols.
    }
  }

  /// Handles user swap request from gesture controller.
  Future<void> handleSwapRequested(Swap swap) async {
    if (isInputLocked) return;

    gestureController.isLocked = true;
    try {
      final resolution = sessionController.attemptSwap(swap);

      await animationQueue.run(
        events: resolution.events,
        boardComponent: boardComponent,
        config: config,
        sprites: _sprites,
      );

      if (_hasPendingResize) {
        _hasPendingResize = false;
        boardComponent.relayoutTiles(
          sessionController.currentBoard,
          sprites: _sprites,
        );
      }

      if (resolution.isSuccess) {
        onComboChanged?.call(resolution.comboCount);
      }
    } finally {
      gestureController.isLocked = _isInputLocked;
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_boardComponent != null) {
      boardComponent.size = size;
      _gestureController?.size = size;
      if (animationQueue.isBusy) {
        _hasPendingResize = true;
      } else {
        boardComponent.relayoutTiles(
          sessionController.currentBoard,
          sprites: _sprites,
        );
      }
    }
  }

  /// Pauses game loop and locks input.
  void pauseBattle() {
    pauseEngine();
    isInputLocked = true;
  }

  /// Resumes game loop and restores input.
  void resumeBattle() {
    resumeEngine();
    isInputLocked = false;
  }
}
