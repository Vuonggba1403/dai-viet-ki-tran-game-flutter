# Verified Base Audit

This reference records the conventions observed in `D:/Dev/Source/flutter_code/base-flutter` on 2026-07-12. Re-check the target repository because derived projects may evolve.

## Verified conventions

- `lib/app/` owns DI, constants, storage, network concerns, routing, root UI, and design system.
- Features such as `auth`, `home`, `example`, and `splash_screen` live directly under `lib/`.
- Cubits are registered as GetIt factories; repositories and services are lazy singletons.
- Rendering state uses Cubit and Freezed sealed unions where needed.
- `bloc_effects` carries one-time actions in login and home flows.
- GoRouter uses named routes and `StatefulShellRoute.indexedStack`.
- Dio, Retrofit, Freezed, JSON serialization, and flutter_gen use build_runner.
- Development, staging, and production entrypoints initialize service-locator subclasses.
- Assets generate into `lib/assets_gen/`.
- The analyzer is based on `very_good_analysis`.

## Known debt to avoid copying

- Factory-created Cubits stored by pages are not visibly closed. New work must use provider ownership or close them in `dispose()`.
- `lib/example/` is the required folder template for new features, but its page-level direct Cubit field and broad `BlocBuilder` are reference debt, not patterns to copy. Prefer provider ownership, selectors, and callback-only child widgets.
- `ApiExeption` is misspelled. Use the migration guidance in `data-di-security.md`.
- Access and refresh tokens are persisted through shared preferences. Real credentials require secure storage.
- Demo email/password values and several raw UI strings exist in the login sample. Do not ship them.
- Global text-scale clamping can reduce accessibility. Preserve user scaling unless product requirements justify limits.
- The root app nests `LoadingOverlay` twice. Do not reproduce duplicate wrappers.
- The global image/SVG precache strategy may retain too much memory for asset-heavy products. Prefer screen-level precaching when scale grows.
- The build script contains product-specific vault, Sentry, signing, and cleanup assumptions. Validate them for each product and CI environment.
- Test coverage is currently sparse; the build-generation cleanliness test alone is not sufficient for new behavior.
- The source contains naming drift (`EzWo`, `EzWork`, `HeDa`, `ezwork`, `com.mywo`, `com.smexapp`). Bootstrap must normalize product identity.
- The base contains a `BuildContext` extension and several top-level infrastructure symbols. Keep those compatibility points but do not create feature-level extensions, globals, or top-level helpers by default.

## Decision rule

Follow verified conventions that define compatibility. Correct known debt in touched code when the fix is local and low risk; otherwise report it and propose a dedicated migration rather than expanding the task silently.
