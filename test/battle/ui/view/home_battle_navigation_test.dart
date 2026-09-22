import 'package:ezwork/app/di/dependencies.dart';
import 'package:ezwork/app/ui/view/navigation.dart';
import 'package:ezwork/auth/data/models/user.dart';
import 'package:ezwork/auth/data/repositories/user_repository.dart';
import 'package:ezwork/auth/domain/logout_use_case.dart';
import 'package:ezwork/battle/data/data_sources/local_battle_content_data_source.dart';
import 'package:ezwork/battle/data/repositories/battle_content_repository.dart';
import 'package:ezwork/battle/ui/cubit/battle_session_cubit.dart';
import 'package:ezwork/battle/ui/view/battle_page.dart';
import 'package:ezwork/home/ui/home_cubit/home_cubit.dart';
import 'package:ezwork/splash_screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' hide MatchFinder;
import 'package:mocktail/mocktail.dart';

class _MockUserRepository extends Mock implements UserRepository {}

class _MockLogoutUseCase extends Mock implements LogoutUseCase {}

class _MockSplashCubit extends Mock implements SplashCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Home to Battle Navigation', () {
    late _MockUserRepository mockUserRepository;
    late _MockLogoutUseCase mockLogoutUseCase;
    late _MockSplashCubit mockSplashCubit;
    late BattleContentRepository battleContentRepository;

    setUp(() {
      mockUserRepository = _MockUserRepository();
      mockLogoutUseCase = _MockLogoutUseCase();
      mockSplashCubit = _MockSplashCubit();
      battleContentRepository = BattleContentRepository(
        localDataSource: const LocalBattleContentDataSource(),
      );

      when(() => mockUserRepository.getProfile())
          .thenAnswer((_) async => const User(id: 'test_id', fname: 'Test'));
      when(() => mockUserRepository.hasUserLoggedIn()).thenReturn(true);

      when(() => mockSplashCubit.state)
          .thenReturn(const SplashState.loaded(hasUserLoggedIn: true));
      when(() => mockSplashCubit.stream)
          .thenAnswer((_) => const Stream.empty());
      when(() => mockSplashCubit.load()).thenAnswer((_) async {});

      if (!getIt.isRegistered<SplashCubit>()) {
        getIt.registerFactory<SplashCubit>(() => mockSplashCubit);
      }

      if (!getIt.isRegistered<HomeCubit>()) {
        getIt.registerFactory(
          () => HomeCubit(
            userRepository: mockUserRepository,
            logoutUseCase: mockLogoutUseCase,
          ),
        );
      }

      if (!getIt.isRegistered<BattleSessionCubit>()) {
        getIt.registerFactory(
          () => BattleSessionCubit(
            contentRepository: battleContentRepository,
            initialSeed: 42,
          ),
        );
      }
    });

    tearDown(() {
      if (getIt.isRegistered<SplashCubit>()) {
        getIt.unregister<SplashCubit>();
      }
      if (getIt.isRegistered<HomeCubit>()) {
        getIt.unregister<HomeCubit>();
      }
      if (getIt.isRegistered<BattleSessionCubit>()) {
        getIt.unregister<BattleSessionCubit>();
      }
    });

    testWidgets('router navigates to BattlePage via named route',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      router.goNamed(BattlePage.routeName);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(BattlePage), findsOneWidget);
    });

    testWidgets('tapping enter battle button on HomePage pushes BattlePage',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      router.go('/home');
      await tester.pumpAndSettle();

      final enterBtn = find.byKey(const Key('enter_battle_button'));
      expect(enterBtn, findsOneWidget);

      await tester.tap(enterBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(BattlePage), findsOneWidget);
    });
  });
}
