import 'package:dai_viet_ki_tran_game/app/design_system/game_breakpoints.dart';
import 'package:dai_viet_ki_tran_game/app/design_system/game_colors.dart';
import 'package:flutter/material.dart';

/// Wraps game screens in a portrait-constrained viewport.
///
/// On mobile portrait, it takes the full available width.
/// On web, desktop, and tablet landscape, it centers the game content
/// within a constrained portrait column ([GameBreakpoints.maxGameContentWidth])
/// surrounded by a clean dark backdrop to preserve game layout integrity.
class GameViewport extends StatelessWidget {
  const GameViewport({
    required this.child,
    this.backgroundColor = GameColors.background,
    this.useSafeArea = true,
    this.maxWidth = GameBreakpoints.maxGameContentWidth,
    super.key,
  });

  final Widget child;
  final Color backgroundColor;
  final bool useSafeArea;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    var content = child;
    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > maxWidth) {
          return Container(
            color: const Color(0xFF0D0B18), // Deep letterbox backdrop
            alignment: Alignment.center,
            child: SizedBox(
              width: maxWidth,
              height: constraints.maxHeight,
              child: ColoredBox(
                color: backgroundColor,
                child: content,
              ),
            ),
          );
        }

        return ColoredBox(
          color: backgroundColor,
          child: content,
        );
      },
    );
  }
}
