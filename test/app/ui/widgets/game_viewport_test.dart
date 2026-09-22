import 'package:dai_viet_ki_tran_game/app/design_system/game_breakpoints.dart';
import 'package:dai_viet_ki_tran_game/app/ui/widgets/game_viewport.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameViewport', () {
    testWidgets('takes full width on mobile portrait screen', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GameViewport(
              useSafeArea: false,
              child: SizedBox.expand(
                key: Key('game_content'),
              ),
            ),
          ),
        ),
      );

      final content = tester.getRect(find.byKey(const Key('game_content')));
      expect(content.width, equals(390.0));
    });

    testWidgets('centers and constraints content on wide/desktop viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GameViewport(
              useSafeArea: false,
              child: SizedBox.expand(
                key: Key('game_content'),
              ),
            ),
          ),
        ),
      );

      final content = tester.getRect(find.byKey(const Key('game_content')));
      expect(content.width, equals(GameBreakpoints.maxGameContentWidth));
      expect(content.left, greaterThan(0));
    });
  });
}
