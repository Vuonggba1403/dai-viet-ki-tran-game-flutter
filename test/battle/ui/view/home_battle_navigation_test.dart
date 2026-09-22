import 'package:dai_viet_ki_tran_game/app/di/dependencies.dart';
import 'package:dai_viet_ki_tran_game/app/ui/view/navigation.dart';
import 'package:dai_viet_ki_tran_game/battle/data/data_sources/local_battle_content_data_source.dart';
import 'package:dai_viet_ki_tran_game/battle/data/repositories/battle_content_repository.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/cubit/battle_session_cubit.dart';
import 'package:dai_viet_ki_tran_game/battle/ui/view/battle_page.dart';
import 'package:dai_viet_ki_tran_game/home/ui/view/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' hide MatchFinder;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Home to Battle Navigation', () {
    setUp(() {
      final repository = BattleContentRepository(
        localDataSource: const LocalBattleContentDataSource(),
      );
      getIt.registerFactory(
        () => BattleSessionCubit(
          contentRepository: repository,
          initialSeed: 42,
        ),
      );
      router.goNamed(HomePage.routeName);
    });

    tearDown(() async {
      router.goNamed(HomePage.routeName);
      await getIt.reset();
    });

    testWidgets('starts on HomePage without authentication redirect', (
      tester,
    ) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pump();

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byKey(const Key('enter_battle_button')), findsOneWidget);
    });

    testWidgets('router navigates to BattlePage via named route', (
      tester,
    ) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      router.goNamed(BattlePage.routeName);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(BattlePage), findsOneWidget);
    });

    testWidgets('tapping enter battle button pushes BattlePage', (
      tester,
    ) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pump();

      await tester.tap(find.byKey(const Key('enter_battle_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(BattlePage), findsOneWidget);
    });
  });
}
