import 'package:ezwork/app/design_system/widgets/loading_overlay/loading_ignores_back_button_dispatcher.dart';
import 'package:flutter/widgets.dart';

class LoadingIgnoresBackButtonRouterConfig<T> extends RouterConfig<T> {
  LoadingIgnoresBackButtonRouterConfig({
    required super.routerDelegate,
    super.routeInformationProvider,
    super.routeInformationParser,
  });

  LoadingIgnoresBackButtonRouterConfig.fromRouterConfig(
    RouterConfig<T> routerConfig,
  ) : this(
          routerDelegate: routerConfig.routerDelegate,
          routeInformationProvider: routerConfig.routeInformationProvider,
          routeInformationParser: routerConfig.routeInformationParser,
        );

  final _backButtonDispatcher = LoadingIgnoresBackButtonDispatcher();

  @override
  BackButtonDispatcher? get backButtonDispatcher => _backButtonDispatcher;
}
