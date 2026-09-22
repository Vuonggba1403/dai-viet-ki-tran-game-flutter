import 'package:flutter/material.dart';

/// Top overlay HUD displaying current stage title, combo counter, and pause control.
class BattleHud extends StatelessWidget {
  const BattleHud({
    required this.stageTitle,
    required this.comboCount,
    required this.onPause,
    super.key,
  });

  final String stageTitle;
  final int comboCount;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Stage title
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                stageTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),

            const Spacer(),

            // Combo badge
            if (comboCount > 1) ...[
              Container(
                key: const Key('combo_badge'),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                    fontSize: 15,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],

            // Pause button
            IconButton(
              key: const Key('pause_button'),
              icon: const Icon(Icons.pause_circle_outline,
                  color: Colors.white, size: 30),
              onPressed: onPause,
            ),
          ],
        ),
      ),
    );
  }
}
