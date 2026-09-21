import 'package:bloc_effects/bloc_effects.dart';
import 'package:ezwork/app/di/dependencies.dart';
import 'package:ezwork/auth/auth.dart';
import 'package:ezwork/home/ui/home_cubit/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

/// The main page of the app, acting as a shell for showing the pages selected by the
/// bottom [NavigationBar].
class BottomNavigationShellPage extends StatelessWidget {
  const BottomNavigationShellPage({
    required this.navigationShell,
    super.key,
  });

  static const routeName = 'main';

  final StatefulNavigationShell navigationShell;

  void handleDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: handleDestinationSelected,
        selectedIndex: navigationShell.currentIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Example',
          ),
        ],
      ),
    );
  }
}

class NavigationDestinationIconSvg extends StatelessWidget {
  const NavigationDestinationIconSvg({
    required this.svgPath,
    required this.isSelected,
    super.key,
  });

  final String svgPath;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      svgPath,
      height: 30,
      colorFilter: ColorFilter.mode(
        isSelected //
            ? Theme.of(context).navigationBarTheme.backgroundColor!
            : Theme.of(context).colorScheme.onSurface,
        BlendMode.srcIn,
      ),
    );
  }
}

/// The home page that's shown inside the [NavigationBar].
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const routeName = 'home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeCubit _bloc = getIt<HomeCubit>();

  @override
  void initState() {
    super.initState();
    _bloc.getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return BlocEffectListener(
      effector: _bloc,
      listener: (context, effect) {
        switch (effect) {
          case HomeStateEffectLogout():
            context.goNamed(LoginPage.routeName);
          case HomeStateEffectError(errorMessage: final errorMessage):
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMessage)),
            );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: _bloc.logout,
            ),
          ],
        ),
        body: const Center(
          child: Text('Welcome!'),
        ),
      ),
    );
  }
}
