import 'package:bloc_effects/bloc_effects.dart';
import 'package:ezwork/app/di/dependencies.dart';
import 'package:ezwork/battle/ui/cubit/battle_session_cubit.dart';
import 'package:ezwork/battle/ui/cubit/battle_session_effect.dart';
import 'package:ezwork/battle/ui/cubit/battle_session_state.dart';
import 'package:ezwork/battle/ui/game/match3_battle_game.dart';
import 'package:ezwork/battle/ui/overlays/battle_hud.dart';
import 'package:ezwork/battle/ui/overlays/pause_overlay.dart';
import 'package:ezwork/home/ui/view/home_page.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
      );
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
              BattleSessionStateLoading() =>
                const Center(
                  child: CircularProgressIndicator(color: Colors.amberAccent),
                ),
              BattleSessionStateError(errorMessage: final msg) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.redAccent, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          msg,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: cubit.retryBattle,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                ),
              BattleSessionStateReady() ||
              BattleSessionStateVictory() ||
              BattleSessionStateDefeat() =>
                _buildActiveBattle(context, state as BattleSessionStateReady),
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
        // 1. Flame Match-3 Game Engine
        if (_game != null)
          Positioned.fill(
            child: GameWidget(
              game: _game!,
              loadingBuilder: (context) => const Center(
                child: CircularProgressIndicator(color: Colors.amberAccent),
              ),
              errorBuilder: (context, error) => Center(
                child: Text(
                  'Game error: $error',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            ),
          ),

        // 2. Top HUD with selected combo rendering
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: BlocSelector<BattleSessionCubit, BattleSessionState, int>(
            selector: (s) => s is BattleSessionStateReady ? s.comboCount : 0,
            builder: (context, combo) {
              return BattleHud(
                stageTitle: state.currentStage.displayNameKey,
                comboCount: combo,
                onPause: () {
                  _game?.pauseBattle();
                  cubit.pause();
                },
              );
            },
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
                },
                onRetry: () {
                  _game?.pauseBattle();
                  _game = null;
                  cubit.retryBattle();
                },
                onExit: cubit.exitBattle,
              ),
            );
          },
        ),
      ],
    );
  }
}
