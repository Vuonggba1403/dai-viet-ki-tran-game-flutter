import 'package:bloc_effects/bloc_effects.dart';
import 'package:dai_viet_ki_tran_game/app/design_system/game_colors.dart';
import 'package:dai_viet_ki_tran_game/app/di/dependencies.dart';
import 'package:dai_viet_ki_tran_game/app/ui/widgets/game_viewport.dart';
import 'package:dai_viet_ki_tran_game/audio/audio.dart';
import 'package:dai_viet_ki_tran_game/battle/data/models/stage_definition.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/cubit/battle_session_cubit.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/cubit/battle_session_effect.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/cubit/battle_session_state.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/game/match3_battle_game.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/overlays/battle_hud.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/overlays/defeat_overlay.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/overlays/hero_team_row.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/overlays/pause_overlay.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/overlays/victory_overlay.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/widgets/battle_arena.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/widgets/battle_background.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/widgets/match3_board_viewport.dart';
import 'package:dai_viet_ki_tran_game/home/ui/view/home_page.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

/// Screen container for the active Match-3 battle.
///
/// Owns the [BattleSessionCubit] and exactly one [Match3BattleGame] instance per session,
/// ensuring complete disposal on exit and zero coupling between Flame and Flutter infrastructure.
class BattlePage extends StatelessWidget {
  const BattlePage({this.stageId = 'stage_1', super.key});

  static const routeName = 'battle';
  final String stageId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BattleSessionCubit>()..loadStage(stageId: stageId),
      child: const _BattlePageView(),
    );
  }
}

class _BattlePageView extends StatefulWidget {
  const _BattlePageView();

  @override
  State<_BattlePageView> createState() => _BattlePageViewState();
}

class _BattlePageViewState extends State<_BattlePageView> {
  static final _logger = Logger('BattlePage');
  Match3BattleGame? _game;

  @override
  void dispose() {
    _game?.pauseBattle();
    _game = null;
    super.dispose();
  }

  void _initGameIfNeeded(BattleSessionStateReady state) {
    if (_game == null) {
      final cubit = context.read<BattleSessionCubit>();
      _game = Match3BattleGame(
        sessionController: state.sessionController,
        onComboChanged: cubit.updateCombo,
        onBoardEvent: (event) {
          final cue = const AudioEventMapper().mapBoardEvent(event);
          if (cue != null && getIt.isRegistered<AudioController>()) {
            getIt<AudioController>().playSfx(cue);
          }
        },
        onCombatEvent: (event) {
          final cue = const AudioEventMapper().mapCombatEvent(event);
          if (cue != null && getIt.isRegistered<AudioController>()) {
            getIt<AudioController>().playSfx(cue);
          }
        },
      );

      final enemy = state.sessionController.currentEnemy;
      final isBoss = enemy != null &&
          enemy.phases != null &&
          enemy.phases!.isNotEmpty;
      if (getIt.isRegistered<AudioController>()) {
        getIt<AudioController>().enterBattle(isBoss: isBoss);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BattleSessionCubit>();

    return BlocEffectListener(
      effector: cubit,
      listener: (context, effect) {
        switch (effect) {
          case BattleSessionEffectExitToHome():
            if (getIt.isRegistered<AudioController>()) {
              getIt<AudioController>().enterHome();
            }
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(HomePage.routeName);
            }
          case BattleSessionEffectShowError(message: final msg):
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg)),
            );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F141C),
        body: BlocBuilder<BattleSessionCubit, BattleSessionState>(
          builder: (context, state) {
            return switch (state) {
              BattleSessionStateInitial() ||
              BattleSessionStateLoading() => const Center(
                child: CircularProgressIndicator(color: Colors.amberAccent),
              ),
              BattleSessionStateError(errorMessage: final msg) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        msg,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 16,
                        runSpacing: 10,
                        children: [
                          ElevatedButton(
                            key: const Key('session_error_retry_button'),
                            onPressed: cubit.retryBattle,
                            child: const Text('Thử lại'),
                          ),
                          OutlinedButton(
                            key: const Key('session_error_exit_button'),
                            onPressed: cubit.exitBattle,
                            child: const Text('Thoát'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              BattleSessionStateReady() => _buildActiveBattle(context, state),
              BattleSessionStateVictory(
                stage: final stage,
                score: final score,
              ) =>
                _buildVictoryView(context, stage, score),
              BattleSessionStateDefeat(stage: final stage) => _buildDefeatView(
                context,
                stage,
              ),
            };
          },
        ),
      ),
    );
  }

  Widget _buildActiveBattle(
    BuildContext context,
    BattleSessionStateReady state,
  ) {
    _initGameIfNeeded(state);
    final cubit = context.read<BattleSessionCubit>();

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Stage background with vignette overlay
        Positioned.fill(
          child: BattleBackground(stageId: state.currentStage.id),
        ),

        // 2. Main portrait column constrained by GameViewport
        Positioned.fill(
          child: GameViewport(
            backgroundColor: Colors.transparent,
            child: Column(
              children: [
                // Top HUD with stage info, arena, and versus combat HUD
                BlocSelector<
                  BattleSessionCubit,
                  BattleSessionState,
                  ({int combo, int revision})
                >(
                  selector: (s) => s is BattleSessionStateReady
                      ? (combo: s.comboCount, revision: s.combatRevision)
                      : (combo: 0, revision: 0),
                  builder: (context, data) {
                    return BattleHud(
                      stageTitle: state.currentStage.displayNameKey,
                      comboCount: data.combo,
                      enemy: state.sessionController.currentEnemy,
                      heroes: state.sessionController.heroes,
                      remainingTurns: state.sessionController.remainingTurns,
                      currentWave: state.sessionController.currentWaveNumber,
                      totalWaves: state.sessionController.totalWaves,
                      arena: BattleArena(
                        heroes: state.sessionController.heroes,
                        enemy: state.sessionController.currentEnemy,
                      ),
                      onPause: () {
                        _game?.pauseBattle();
                        cubit.pause();
                        if (getIt.isRegistered<AudioController>()) {
                          getIt<AudioController>().pauseBattle();
                        }
                      },
                    );
                  },
                ),

                // Match-3 Board Viewport: 1:1 AspectRatio square box hosting GameWidget
                Expanded(
                  child: Match3BoardViewport(
                    gameWidget: _game != null
                        ? GameWidget(
                            key: const Key('battle_flame_game_widget'),
                            game: _game!,
                            loadingBuilder: (context) => const Center(
                              child: CircularProgressIndicator(
                                color: GameColors.goldPrimary,
                              ),
                            ),
                            errorBuilder: (context, error) {
                              _logger.severe(
                                'GameWidget encountered an internal engine error',
                                error,
                              );
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.amberAccent,
                                        size: 48,
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Đã xảy ra lỗi trong trận đấu. Vui lòng thử lại.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ElevatedButton(
                                            key: const Key(
                                              'game_error_retry_button',
                                            ),
                                            onPressed: () {
                                              _game?.pauseBattle();
                                              _game = null;
                                              cubit.retryBattle();
                                            },
                                            child: const Text('Thử lại'),
                                          ),
                                          const SizedBox(width: 16),
                                          OutlinedButton(
                                            key: const Key(
                                              'game_error_exit_button',
                                            ),
                                            onPressed: () {
                                              _game?.pauseBattle();
                                              _game = null;
                                              cubit.exitBattle();
                                            },
                                            child: const Text('Thoát'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : const SizedBox.shrink(),
                  ),
                ),

                // Bottom Hero Team Row (4 heroes HP, Mana, and skill buttons)
                BlocSelector<BattleSessionCubit, BattleSessionState, int>(
                  selector: (s) =>
                      s is BattleSessionStateReady ? s.combatRevision : 0,
                  builder: (context, _) {
                    return HeroTeamRow(
                      heroes: state.sessionController.heroes,
                      canCastSkill: state.sessionController.canCastSkill,
                      onCastSkill: (heroId) {
                        final hero = state.sessionController.heroes
                            .where((h) => h.id == heroId)
                            .firstOrNull;
                        if (hero != null) {
                          final cue = const AudioEventMapper()
                              .mapSkillId(hero.activeSkillId);
                          if (cue != null &&
                              getIt.isRegistered<AudioController>()) {
                            getIt<AudioController>().playSfx(cue);
                          }
                        }
                        cubit.castSkill(heroId);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // 3. Pause Overlay
        BlocSelector<BattleSessionCubit, BattleSessionState, bool>(
          selector: (s) => s is BattleSessionStateReady && s.isPaused,
          builder: (context, isPaused) {
            if (!isPaused) return const SizedBox.shrink();
            return Positioned.fill(
              child: PauseOverlay(
                onResume: () {
                  _game?.resumeBattle();
                  cubit.resume();
                  if (getIt.isRegistered<AudioController>()) {
                    getIt<AudioController>().resumeBattle();
                  }
                },
                onRetry: () {
                  _game?.pauseBattle();
                  _game = null;
                  if (getIt.isRegistered<AudioController>()) {
                    getIt<AudioController>().resumeBattle();
                  }
                  cubit.retryBattle();
                },
                onExit: () {
                  if (getIt.isRegistered<AudioController>()) {
                    getIt<AudioController>().enterHome();
                  }
                  cubit.exitBattle();
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVictoryView(
    BuildContext context,
    StageDefinition stage,
    int score,
  ) {
    _game?.pauseBattle();
    if (getIt.isRegistered<AudioController>()) {
      getIt<AudioController>().handleVictory();
    }
    final cubit = context.read<BattleSessionCubit>();

    return VictoryOverlay(
      stage: stage,
      score: score,
      onRetry: () {
        _game = null;
        if (getIt.isRegistered<AudioController>()) {
          getIt<AudioController>().resumeBattle();
        }
        cubit.retryBattle();
      },
      onExit: () {
        if (getIt.isRegistered<AudioController>()) {
          getIt<AudioController>().enterHome();
        }
        cubit.exitBattle();
      },
    );
  }

  Widget _buildDefeatView(
    BuildContext context,
    StageDefinition stage,
  ) {
    _game?.pauseBattle();
    if (getIt.isRegistered<AudioController>()) {
      getIt<AudioController>().handleDefeat();
    }
    final cubit = context.read<BattleSessionCubit>();

    return DefeatOverlay(
      stage: stage,
      onRetry: () {
        _game = null;
        if (getIt.isRegistered<AudioController>()) {
          getIt<AudioController>().resumeBattle();
        }
        cubit.retryBattle();
      },
      onExit: () {
        if (getIt.isRegistered<AudioController>()) {
          getIt<AudioController>().enterHome();
        }
        cubit.exitBattle();
      },
    );
  }
}
