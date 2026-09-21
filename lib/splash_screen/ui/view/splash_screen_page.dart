import 'package:ezwork/app/app.dart';
import 'package:ezwork/auth/auth.dart';
import 'package:ezwork/home/home.dart';
import 'package:ezwork/splash_screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  static const routeName = 'splash';

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  final SplashCubit _bloc = getIt<SplashCubit>();

  @override
  void initState() {
    super.initState();
    _bloc.load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      bloc: _bloc,
      listener: (context, state) {
        if (state is SplashStateLoaded) {
          _showNextScreen(hasUserLoggedIn: state.hasUserLoggedIn);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: const Center(),
      ),
    );
  }

  void _showNextScreen({required bool hasUserLoggedIn}) {
    if (hasUserLoggedIn) {
      context.goNamed(HomePage.routeName);
    } else {
      context.goNamed(LoginPage.routeName);
    }
  }
}
