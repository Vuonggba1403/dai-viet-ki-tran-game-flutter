import 'package:dai_viet_ki_tran_game/battle/battle.dart';
import 'package:dai_viet_ki_tran_game/home/home.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/${HomePage.routeName}',
  routes: [
    GoRoute(
      name: HomePage.routeName,
      path: '/${HomePage.routeName}',
      builder: (context, routerState) => const HomePage(),
    ),
    GoRoute(
      name: BattlePage.routeName,
      path: '/${BattlePage.routeName}',
      builder: (context, routerState) {
        final stageId = routerState.uri.queryParameters['stageId'] ?? 'stage_1';
        return BattlePage(stageId: stageId);
      },
    ),
  ],
);
