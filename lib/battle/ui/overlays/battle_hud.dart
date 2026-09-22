import 'package:dai_viet_ki_tran_game/battle/domain/combat/enemy_runtime.dart';
import 'package:flutter/material.dart';

/// Top overlay HUD displaying current stage title, remaining turns,
/// combo counter, active enemy status (HP & countdown), and pause control.
class BattleHud extends StatelessWidget {
  const BattleHud({
    required this.stageTitle,
    required this.comboCount,
    required this.onPause,
    this.enemy,
    this.remainingTurns = 30,
    this.currentWave = 1,
    this.totalWaves = 1,
    super.key,
  });

  final String stageTitle;
  final int comboCount;
  final VoidCallback onPause;
  final EnemyRuntime? enemy;
  final int remainingTurns;
  final int currentWave;
  final int totalWaves;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Top status row
            Row(
              children: [
                // Stage title and wave indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    totalWaves > 1
                        ? '$stageTitle • Đợt $currentWave/$totalWaves'
                        : stageTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Remaining turns badge
                Container(
                  key: const Key('turn_counter_badge'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: remainingTurns <= 5
                        ? Colors.red.withValues(alpha: 0.7)
                        : Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: remainingTurns <= 5
                          ? Colors.redAccent
                          : Colors.white24,
                    ),
                  ),
                  child: Text(
                    'Lượt: $remainingTurns',
                    style: TextStyle(
                      color: remainingTurns <= 5
                          ? Colors.white
                          : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),

                const Spacer(),

                // Combo badge
                if (comboCount > 1) ...[
                  Container(
                    key: const Key('combo_badge'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9800), Color(0xFFE65100)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withValues(alpha: 0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '$comboCount COMBO!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // Pause button
                IconButton(
                  key: const Key('pause_button'),
                  icon: const Icon(
                    Icons.pause_circle_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: onPause,
                ),
              ],
            ),

            // 2. Active Enemy Banner (if combat active)
            if (enemy != null) ...[
              const SizedBox(height: 6),
              Container(
                key: const Key('enemy_combat_card'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: enemy!.isAlive
                        ? Colors.redAccent.withValues(alpha: 0.5)
                        : Colors.grey,
                  ),
                ),
                child: Row(
                  children: [
                    // Enemy icon/avatar
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.red[900]?.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.redAccent, width: 1.5),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.sports_kabaddi,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Enemy Name & HP Bar
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                enemy!.id.toUpperCase().replaceAll('_', ' '),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                '${enemy!.currentHp}/${enemy!.maxHp}',
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              key: const Key('enemy_hp_bar'),
                              value: enemy!.hpRatio,
                              minHeight: 6,
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFE53935),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Turn countdown badge
                    Container(
                      key: const Key('enemy_turn_countdown'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: enemy!.turnCounter <= 1
                            ? Colors.red.withValues(alpha: 0.8)
                            : Colors.grey[900],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: enemy!.turnCounter <= 1
                              ? Colors.redAccent
                              : Colors.white30,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${enemy!.turnCounter}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
