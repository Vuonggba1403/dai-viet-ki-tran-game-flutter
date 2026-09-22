import 'package:flame/game.dart';
import 'package:flutter/material.dart';

/// Constrains Flame [GameWidget] to a responsive square box.
///
/// Guarantees that the Match-3 board remains strictly square (1:1 aspect ratio),
/// never overflows the viewport, and does not overlap with top HUD or bottom dock.
class Match3BoardViewport extends StatelessWidget {
  const Match3BoardViewport({
    required this.gameWidget,
    super.key,
  });

  final Widget gameWidget;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;
        final dimension =
            (availableWidth < availableHeight
                    ? availableWidth
                    : availableHeight)
                .clamp(280.0, 440.0);

        return Center(
          child: SizedBox(
            width: dimension,
            height: dimension,
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: gameWidget,
              ),
            ),
          ),
        );
      },
    );
  }
}
