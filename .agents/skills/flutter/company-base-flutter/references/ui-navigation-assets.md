# UI, Navigation, Assets, and Localization

## Design system

- Use `Theme.of(context)`, the shared color scheme, typography, spacing tokens, and widgets from `lib/app/design_system/`.
- Do not hardcode hex colors or duplicate shared text styles in feature widgets.
- Add a design-system component only when it is reused across features or represents an established product pattern.
- Keep feature-specific widgets in `lib/<feature>/ui/widgets/` or beside the owning view, following the local feature.
- Split a page when extraction improves readability, reuse, independent state selection, or testing. Do not create one-line wrapper widgets to satisfy a quota.
- Build feature widgets as presentation components: accept data and callbacks, not Cubit/Bloc or service dependencies.
- Prefer const widgets, lazy list builders, bounded layouts, and responsive constraints. Avoid expensive work in `build()`.

## GoRouter

- Add routes to `lib/app/ui/view/navigation.dart` or the router module that evolved from it.
- Give pages stable `routeName` values and use named navigation when the base already does.
- Use `StatefulShellRoute.indexedStack` for persistent tab branches.
- Keep route parsing and redirects in routing code; trigger navigation from one-time effects or route guards.
- Do not add AutoRoute, GetX navigation, or raw Navigator 2.0 beside GoRouter.

## Assets

- Place assets in a semantic subdirectory already declared by `pubspec.yaml`, currently `assets/images/` and `assets/animations/`.
- Use lowercase semantic `snake_case` filenames. Preserve useful Figma traceability without copying opaque export IDs.
- Run build generation after changing assets.
- Access assets through the generated class under `lib/assets_gen/assets.gen.dart`, for example `Assets.images.logo`.
- Do not maintain a second `AppAssets` class with raw path strings.
- Use the existing rendering package for SVG/Lottie assets and configure flutter_gen integration only when the project needs typed helper methods.

## Localization

The sampled base has `intl` but no configured localization framework. Therefore:

- If the target project already has localization, add every user-facing string through that existing system.
- If localization is absent, do not introduce GetX solely for a feature. Ask or establish a project-wide Flutter localization approach as a dedicated change.
- Keep temporary raw strings centralized enough to migrate later; never hardcode server errors or secrets into UI copy.

## Accessibility and behavior

- Preserve system text scaling unless the product has a documented accessibility decision. Avoid arbitrary global clamping in new code.
- Provide semantic labels/tooltips for icon-only actions where meaning is not obvious.
- Keep touch targets usable and test overflow at small and large text scales.
