import 'package:ezwork/app/app.dart';
import 'package:ezwork/app/design_system/widgets/loading_overlay/loading_ignores_back_button_router_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  /// Precaches the images and SVGs. This can be an expensive operation and should ideally be done
  /// at each screen, before it loads. We are doing it here since it makes the app development easier.
  /// Remove this if the app has too many images.
  Future<void> precacheImages() async {
    final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final imageCachingFutures = assetManifest //
        .listAssets()
        .where(
          (assetPath) =>
              assetPath.endsWith('.jpg') || assetPath.endsWith('.png'),
        )
        .map((assetPath) async {
      final imageProvider = AssetImage(assetPath);
      await precacheImage(imageProvider, context);
      if (mounted) {
        imageProvider
            .resolve(createLocalImageConfiguration(context))
            .addListener(
          ImageStreamListener((imageInfo, synchronousCall) {
            // An empty listener to keep this image alive forever.
          }),
        );
      }
    });

    final svgCachingFutures = assetManifest //
        .listAssets()
        .where((assetPath) => assetPath.endsWith('.svg'))
        .map((svgAsset) async {
      final loader = SvgAssetLoader(svgAsset);
      await svg.cache
          .putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));
    });

    await Future.wait([...imageCachingFutures, ...svgCachingFutures]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImages();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus && currentFocus.hasFocus) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: MaterialApp.router(
        theme: appTheme,
        routerConfig:
            LoadingIgnoresBackButtonRouterConfig.fromRouterConfig(router),
        builder: (context, child) => _MediaQueryWrapper(
          child: LoadingOverlay(
            loadingIndicatorColor: appTheme.colorScheme.primary,
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

class _MediaQueryWrapper extends StatefulWidget {
  const _MediaQueryWrapper({required this.child});

  final Widget child;

  @override
  __MediaQueryWrapperState createState() => __MediaQueryWrapperState();
}

class __MediaQueryWrapperState extends State<_MediaQueryWrapper> {
  late MediaQueryData _mediaQueryData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final data = MediaQuery.of(context);
    _mediaQueryData = data.copyWith(
      textScaler: data.textScaler.clamp(
        minScaleFactor: 0.8,
        maxScaleFactor: 1.2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: _mediaQueryData,
      child: LoadingOverlay(
        loadingIndicatorColor: Theme.of(context).primaryColor,
        child: widget.child,
      ),
    );
  }
}
