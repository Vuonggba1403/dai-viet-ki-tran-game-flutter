---
name: company-base-flutter
description: "Implement, review, refactor, test, or bootstrap Flutter applications derived from the company base-flutter repository. Use for work in projects that use the base conventions: feature folders directly under lib, shared app infrastructure under lib/app, Cubit/Freezed/bloc_effects, manual GetIt registration, GoRouter, Dio/Retrofit, flutter_gen, a shared design system, and development/staging/production flavors."
---

# Company Base Flutter

Treat the target repository as the source of truth. Preserve conventions already present in the project unless the user explicitly requests a migration.

## Workflow

1. Inspect `pubspec.yaml`, `analysis_options.yaml`, `lib/app/`, a neighboring feature, and the relevant tests before editing.
2. Confirm the project is derived from this base by finding most of these markers: `lib/app/app.dart`, `lib/app/di/dependencies.dart`, `lib/app/ui/view/navigation.dart`, flavor entrypoints, `flutter_bloc`, `freezed`, `get_it`, `go_router`, `dio`, `retrofit`, and `flutter_gen`.
3. Classify the task as feature work, bug fix, refactor, bootstrap, or infrastructure change. Keep bug fixes and refactors scoped; do not force new-feature ceremony onto them.
4. Read only the references needed for the task:
   - Architecture and file placement: [architecture.md](references/architecture.md)
   - Cubit, state, effects, and lifecycle: [state-management.md](references/state-management.md)
   - Retrofit, repositories, DI, storage, and errors: [data-di-security.md](references/data-di-security.md)
   - UI, design system, routing, assets, and localization: [ui-navigation-assets.md](references/ui-navigation-assets.md)
   - Tests, generation, analysis, and delivery: [testing-delivery.md](references/testing-delivery.md)
   - Practical architecture decision thresholds: [trade-offs.md](references/trade-offs.md)
   - Creating a product from the base: [bootstrap-project.md](references/bootstrap-project.md)
   - Verified base behavior and known debt: [source-audit.md](references/source-audit.md)
5. Implement with the smallest coherent change. Reuse project components and dependencies before adding packages or abstractions.
6. Regenerate code when annotations or assets change. Never edit `*.g.dart`, `*.freezed.dart`, or `assets.gen.dart` manually.
7. After every implementation, run the mandatory project gate with `scripts/verify_project.ps1` or the exact commands in `testing-delivery.md`. Claim full completion only when all four steps pass; otherwise fix the failure or report the work as not fully verified.

## Base Defaults

- Place shared app infrastructure and design-system code under `lib/app/`.
- Place business features directly under `lib/<feature>/`; do not introduce `lib/src/features/`.
- Start every new feature from the `lib/example/` layout: feature barrel, `data/data_sources`, `data/models`, `data/repositories`, `ui/cubit`, `ui/view`, and optional `ui/widgets`.
- Model new JSON-backed requests, responses, and feature data in `data/models/` with Freezed plus JSON serialization, matching `lib/example/data/models/example_data.dart`. Keep simple enums as enums; document any other exception.
- Use package imports for files under `lib/`, matching the base.
- Use Cubit with Freezed state by default for every new feature. Use Bloc or a non-Freezed state only when a concrete requirement makes Cubit/Freezed unsuitable and document that reason.
- Use `bloc_effects` only for one-time UI commands such as navigation, dialogs, snackbars, and transient global overlay commands.
- Make pages or container widgets own Cubits. Pass immutable data and typed callbacks to child widgets; never pass Cubit/Bloc, repositories, data sources, or GetIt through widget constructors.
- Prefer `BlocSelector` for rendering selected state, `BlocEffectListener` for one-time effects, `BlocListener` only for state-driven side effects without an effect stream, and `BlocBuilder` only when a subtree needs the whole state.
- Register dependencies manually in the existing GetIt service locator. Use lazy singletons for shared services/repositories and factories for Cubits.
- Add routes to the existing GoRouter configuration; do not introduce AutoRoute, GetX routing, or another router.
- Define HTTP endpoints with Retrofit over the configured Dio instance. Keep transport details out of widgets.
- Access bundled assets through generated `Assets`; do not create a parallel manual asset-path class.
- Use the existing `lib/app/design_system/` tokens and widgets. Add reusable tokens/components there when the design system genuinely owns them.
- Preserve the three flavor entrypoints and environment-specific service locators.

## Guardrails

- Do not add Injectable, GetX, Equatable, dartz, or a second architecture solely because another template recommends it.
- Do not add feature-level extensions, top-level functions, or global variables by default. Keep only established app-level entrypoints such as `getIt`, `router`, flavor/bootstrap functions, and immutable framework configuration.
- Do not require golden tests for every UI change. Add them when pixel-level regression coverage is valuable and a stable baseline exists.
- Prefer clear naming over comments. Add at most one concise comment above a function or complex block only when its purpose, constraint, or non-obvious reason cannot be expressed clearly in code; explain why, not what each line does.
- Do not hardcode secrets. Keep authentication tokens out of `SharedPreferences`; use secure storage for real credentials.
- Do not copy known base defects into new code. Follow the corrections in `source-audit.md`.
- Do not impose a machine-specific final-response format. Summarize changed files, behavior, and verification normally.
