import 'dart:async';

import 'package:ezwork/app/design_system/widgets/loading_overlay/loading_overlay_controller.dart';
import 'package:flutter/widgets.dart';

class LoadingIgnoresBackButtonDispatcher extends RootBackButtonDispatcher {
  final loadingOverlayController = LoadingOverlayController();

  @override
  Future<bool> didPopRoute() async {
    if (!loadingOverlayController.isVisible) {
      return super.didPopRoute();
    }

    return true;
  }
}
