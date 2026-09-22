import 'package:bloc_effects/bloc_effects.dart';
import 'package:ezwork/battle/data/models/stage_definition.dart';
import 'package:ezwork/battle/data/repositories/battle_content_repository.dart';
import 'package:ezwork/battle/domain/battle_session_controller.dart';
import 'package:ezwork/battle/domain/board/board_generator.dart';
import 'package:ezwork/battle/domain/combat/battle_phase.dart';
import 'package:ezwork/battle/domain/random/seeded_random.dart';
import 'package:ezwork/battle/ui/cubit/battle_session_effect.dart';
import 'package:ezwork/battle/ui/cubit/battle_session_state.dart';
import 'package:logging/logging.dart';

/// Cubit managing stable battle screen states and one-shot effects.
class BattleSessionCubit
    extends CubitWithEffects<BattleSessionState, BattleSessionEffect> {
  BattleSessionCubit({
    required BattleContentRepository contentRepository,
    int? initialSeed,
  }) : _contentRepository = contentRepository,
       _seed = initialSeed ?? DateTime.now().millisecondsSinceEpoch,
       super(const BattleSessionState.initial());

  final BattleContentRepository _contentRepository;
  final int _seed;
  final _logger = Logger('BattleSessionCubit');
  String _currentStageId = 'stage_1';

  /// The most recently requested or active stage ID.
  String get currentStageId => _currentStageId;

  /// Loads battle content and initializes the session for [stageId].
  Future<void> loadStage({String stageId = 'stage_1'}) async {
    _currentStageId = stageId;
    try {
      emit(const BattleSessionState.loading());

      final content = await _contentRepository.getBattleContent();
      final matchingStages = content.stages.where((s) => s.id == stageId);
      if (matchingStages.isEmpty) {
        _logger.warning('Requested battle stage "$stageId" does not exist');
        const errorMsg = 'Màn chơi không tồn tại. Vui lòng chọn lại màn chơi.';
        emit(const BattleSessionState.error(errorMessage: errorMsg));
        emitEffect(const BattleSessionEffect.showError(message: errorMsg));
        return;
      }

      final stage = matchingStages.first;
      final rng = SeededRandom(_seed);
      final initialBoard = BoardGenerator.generate(rng);
      late final BattleSessionController controller;
      controller = BattleSessionController(
        initialBoard: initialBoard,
        randomService: rng,
        stage: stage,
        heroDefinitions: content.heroes,
        enemyDefinitions: content.enemies,
        skillDefinitions: content.skills,
        onStateChanged: () {
          _handleCombatStateChange(controller, stage);
        },
      );

      emit(
        BattleSessionState.ready(
          content: content,
          currentStage: stage,
          sessionController: controller,
        ),
      );
    } catch (e, stackTrace) {
      _logger.severe('Failed to load battle stage "$stageId"', e, stackTrace);
      final errorMsg = e is ContentValidationException
          ? e.message
          : 'Không thể tải dữ liệu trận đánh. Vui lòng thử lại.';
      emit(BattleSessionState.error(errorMessage: errorMsg));
      emitEffect(BattleSessionEffect.showError(message: errorMsg));
    }
  }

  /// Pauses the battle session.
  void pause() {
    final s = state;
    if (s is BattleSessionStateReady) {
      emit(s.copyWith(isPaused: true));
    }
  }

  /// Resumes the battle session.
  void resume() {
    final s = state;
    if (s is BattleSessionStateReady) {
      emit(s.copyWith(isPaused: false));
    }
  }

  /// Updates current combo display for the active resolution cycle.
  void updateCombo(int combo) {
    final s = state;
    if (s is BattleSessionStateReady) {
      emit(s.copyWith(comboCount: combo));
    }
  }

  /// Exits the battle back to Home.
  void exitBattle() {
    emitEffect(const BattleSessionEffect.exitToHome());
  }

  /// Retries the current stage with a fresh board.
  Future<void> retryBattle() async {
    final s = state;
    final stageIdToRetry = switch (s) {
      BattleSessionStateReady(:final currentStage) => currentStage.id,
      BattleSessionStateVictory(:final stage) => stage.id,
      BattleSessionStateDefeat(:final stage) => stage.id,
      _ => _currentStageId,
    };
    await loadStage(stageId: stageIdToRetry);
  }

  /// Casts the active skill of the hero with [heroId].
  void castSkill(String heroId) {
    final s = state;
    if (s is BattleSessionStateReady) {
      s.sessionController.castSkill(heroId);
    }
  }

  void _handleCombatStateChange(
    BattleSessionController controller,
    StageDefinition stage,
  ) {
    if (isClosed) return;
    switch (controller.currentPhase) {
      case BattlePhase.victory:
        emit(
          BattleSessionState.victory(
            stage: stage,
            score: controller.totalScore,
          ),
        );
      case BattlePhase.defeat:
        emit(
          BattleSessionState.defeat(
            stage: stage,
          ),
        );
      case BattlePhase.playerInput:
      case BattlePhase.applyingCombat:
      case BattlePhase.enemyTurn:
      case BattlePhase.resolvingBoard:
      case BattlePhase.setup:
        final s = state;
        if (s is BattleSessionStateReady) {
          emit(s.copyWith(comboCount: controller.comboCount));
        }
    }
  }
}
