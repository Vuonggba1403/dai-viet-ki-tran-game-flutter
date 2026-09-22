import 'package:ezwork/auth/auth.dart';
import 'package:ezwork/battle/battle.dart';
import 'package:ezwork/example/example.dart';
import 'package:ezwork/home/home.dart';
import 'package:ezwork/splash_screen/splash_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/${SplashScreenPage.routeName}',
  routes: [
    GoRoute(
      name: SplashScreenPage.routeName,
      path: '/${SplashScreenPage.routeName}',
      builder: (context, routerState) => const SplashScreenPage(),
    ),
    GoRoute(
      name: LoginPage.routeName,
      path: '/${LoginPage.routeName}',
      builder: (context, routerState) => const LoginPage(),
    ),
    GoRoute(
      name: BattlePage.routeName,
      path: '/${BattlePage.routeName}',
      builder: (context, routerState) {
        final stageId = routerState.uri.queryParameters['stageId'] ?? 'stage_1';
        return BattlePage(stageId: stageId);
      },
    ),
    StatefulShellRoute.indexedStack(
      pageBuilder: (context, routerState, navigationShell) {
        // Fade transition coming from the SplashScreenPage.
        return CustomTransitionPage<void>(
          key: routerState.pageKey,
          child: BottomNavigationShellPage(navigationShell: navigationShell),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
              child: child,
            );
          },
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: HomePage.routeName,
              path: '/${HomePage.routeName}',
              builder: (context, routerState) => const HomePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: ExamplePage.routeName,
              path: '/${ExamplePage.routeName}',
              builder: (context, routerState) => const ExamplePage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
