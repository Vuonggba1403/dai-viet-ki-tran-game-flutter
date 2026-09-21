# Bootstrap a Product from the Base

## Inventory before renaming

Record the new values for:

- Dart package name;
- display name;
- Android namespace and application ID;
- iOS bundle IDs;
- production, staging, and development API URLs;
- supported platforms;
- app icons, launch assets, and signing ownership.

## Rename consistently

1. Update `name` and description in `pubspec.yaml`.
2. Replace `package:<old_name>/` imports under `lib/` and `test/`.
3. Update Android namespace, application ID, Kotlin package/path, flavor suffixes, and app names.
4. Update iOS bundle identifiers, product display names, schemes, and flavor configurations.
5. Update desktop/web identifiers only for supported platforms.
6. Rename product-prefixed design-system classes deliberately; avoid a blind replacement inside generated or binary files.
7. Replace base URLs, contact details, store IDs, icons, and launch assets.
8. Resolve every `TODO(init)` and remove sample features that the product does not need.

## Preserve flavors

Keep these entrypoints unless the product explicitly reduces environments:

```text
lib/main_development.dart
lib/main_staging.dart
lib/main_production.dart
```

Each entrypoint must initialize the matching service locator and use the matching native flavor/scheme. Verify at least one debug launch per retained flavor.

## Rebuild and verify

```sh
flutter clean
flutter pub get
dart run build_runner build -d
flutter analyze
flutter test --test-randomize-ordering-seed random
flutter run --flavor development --target lib/main_development.dart
```

Also search the repository for the old package name, old application ID, old product name, sample credentials, and `TODO(init)` before declaring bootstrap complete.

## Do not inherit sample debt

- Remove hardcoded demo credentials and placeholder accounts.
- Replace sample API endpoints and features.
- Move real auth tokens to secure storage.
- Review logging before enabling production traffic.
- Confirm release signing and symbol storage ownership instead of copying local assumptions from the sample build script.
