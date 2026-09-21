---
alwaysApply: false
---

# Company Base Flutter Feature UI Rule

Apply this rule when implementing a new screen or user-facing feature in a project derived from the company base. Do not apply it wholesale to a narrow bug fix or refactor.

Follow `.trae/skills/flutter/company-base-flutter/SKILL.md`, especially the architecture, state-management, UI/navigation/assets, and testing references.

## Feature checklist

1. Inspect the nearest feature, the design system, router, DI registrations, and tests.
2. Create the feature from the `lib/example/` layout: barrel file, `data/data_sources`, `data/models`, `data/repositories`, `ui/cubit`, `ui/view`, and optional `ui/widgets`.
3. Implement new JSON-backed request, response, and feature data models in `data/models/` with Freezed plus JSON serialization; keep only simple enums or documented technical exceptions outside this default.
4. Keep transport/storage calls behind repositories; only the page/container talks to a Cubit, while presentation widgets receive data and callbacks.
5. Use Cubit with Freezed state by default. Model durable rendering data as state and one-time UI commands as Freezed `bloc_effects` effects.
6. Register data sources/repositories as shared dependencies and Cubits as factories. Ensure Cubit/controllers/subscriptions have an owner that disposes them.
7. Keep Cubit access in the page/container. Pass data and typed callbacks to child widgets; reject constructors that accept Cubit/Bloc, repositories, data sources, or GetIt.
8. Prefer `BlocSelector` for rendering, `BlocEffectListener` for effects, `BlocListener` only for justified state side effects, and `BlocBuilder` only when the complete state drives the subtree.
9. Add navigation to the existing GoRouter configuration.
10. Use design-system tokens/components and generated `Assets`; do not add raw asset-path constants or hardcoded hex colors.
11. Do not add feature-level extensions, top-level helper functions, or global variables. Add at most one concise why-comment above genuinely difficult logic.
12. Follow the target project's localization system. Do not introduce GetX when localization is absent or uses another solution.
13. Add focused Cubit/widget tests. Add golden coverage only when a stable visual baseline provides real value.
14. Before completion, run and pass `dart format lib test`, `dart run build_runner build -d`, `flutter analyze`, and `flutter test --test-randomize-ordering-seed random`; otherwise report incomplete verification.
