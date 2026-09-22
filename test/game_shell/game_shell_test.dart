import 'package:dai_viet_ki_tran_game/app/di/dependencies.dart';
import 'package:dai_viet_ki_tran_game/battle/data/data_sources/local_battle_content_data_source.dart';
import 'package:dai_viet_ki_tran_game/battle/data/repositories/battle_content_repository.dart';
import 'package:dai_viet_ki_tran_game/game_shell/game_shell.dart';
import 'package:dai_viet_ki_tran_game/heroes/heroes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameShell', () {
    setUp(() {
      if (!getIt.isRegistered<BattleContentRepository>()) {
        getIt.registerSingleton<BattleContentRepository>(
          BattleContentRepository(
            localDataSource: const LocalBattleContentDataSource(),
          ),
        );
      }
    });

    tearDown(() async {
      await getIt.reset();
    });

    testWidgets('renders top resource bar and 5 bottom navigation tabs', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GameShellPage(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify top resource bar elements
      expect(find.byType(GameTopResourceBar), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.text('9/9'), findsOneWidget);

      // Verify 5 bottom navigation tabs
      expect(find.byKey(const Key('nav_shop')), findsOneWidget);
      expect(find.byKey(const Key('nav_equipment')), findsOneWidget);
      expect(find.byKey(const Key('nav_heroes')), findsOneWidget);
      expect(find.byKey(const Key('nav_campaign')), findsOneWidget);
      expect(find.byKey(const Key('nav_settings')), findsOneWidget);

      // Default tab is Heroes
      expect(find.byType(HeroesPage), findsOneWidget);
    });

    testWidgets('switching tabs updates active content and highlighted tab', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GameShellPage(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap on Campaign tab
      await tester.tap(find.byKey(const Key('nav_campaign')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('CHIẾN DỊCH: HOA LƯ SƠN'), findsOneWidget);
      expect(find.byKey(const Key('enter_battle_button')), findsWidgets);

      // Tap on Shop tab
      await tester.tap(find.byKey(const Key('nav_shop')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Cửa Hàng'), findsOneWidget);
    });
  });
}
