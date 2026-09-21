import 'package:ezwork/app/design_system/widgets/loading_overlay/loading_overlay_controller.dart';
import 'package:flutter/material.dart';

/// Shows a generic loading overlay ontop of the app.
///
/// To use:
///
/// 1. Add the overlay to the builder widget of your Material/Cupertino App
/// ```dart
///   class MainApp extends StatelessWidget {
///
///   const MainApp({super.key});
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp.router(
///       builder: (context, child) {
///         return LoadingOverlay(
///           loadingIndicatorColor: Colors.blue,
///           child: child ?? const SizedBox.shrink(),
///         );
///       },
///     );
///   }
/// }
/// ```
///
/// 2. Enable or disable the overlay with the controller from a [BuildContext].
///
/// ```dart
///   void showOverlay() => context.loadingOverlay.show();
/// ```
class LoadingOverlay extends StatefulWidget {
  LoadingOverlay(
      {required this.loadingIndicatorColor,
      required this.child,
      this.backgroundColor,
      super.key});

  final Widget child;
  final Color loadingIndicatorColor;
  final Color? backgroundColor;
  final LoadingOverlayController controller = LoadingOverlayController();

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay> {
  @override
  void initState() {
    widget.controller.addListener(onControllerUpdate);
    super.initState();
  }

  void onControllerUpdate() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.controller.isVisible)
          Container(
            height: MediaQuery.sizeOf(context).height,
            width: double.infinity,
            color:
                widget.backgroundColor ?? Colors.black.withValues(alpha: 0.4),
            child: Center(
                child: CircularProgressIndicator(
                    color: widget.loadingIndicatorColor)),
          ),
      ],
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(onControllerUpdate);
    super.dispose();
  }
}

extension LoadingOverlayExtension on BuildContext {
  LoadingOverlayController get loadingOverlay => LoadingOverlayController();
}
