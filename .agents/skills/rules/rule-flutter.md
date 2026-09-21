---
alwaysApply: false
---

# Company Base Flutter Rule

Apply this rule to implementation, review, refactor, testing, and project-bootstrap work in applications derived from the company `base-flutter` repository.

Use `.trae/skills/flutter/company-base-flutter/SKILL.md` as the canonical source of truth. Inspect the target repository first and preserve conventions that have intentionally evolved from the sampled base.

## Required behavior

- Keep shared infrastructure under `lib/app/` and features under `lib/<feature>/`.
- Create new features from the `lib/example/` folder structure and use Cubit with Freezed state by default.
- Use Freezed plus JSON serialization for new JSON-backed request, response, and data models in `data/models/`, matching the `example` feature.
- Reuse `bloc_effects`, manual GetIt, GoRouter, Dio/Retrofit, flutter_gen, and the shared design system already present in the project.
- Pass immutable data and typed callbacks to child widgets; do not pass Cubit/Bloc or service dependencies through widget constructors.
- Prefer `BlocSelector` for selected rendering, `BlocEffectListener` for one-time effects, `BlocListener` for exceptional state-transition side effects, and `BlocBuilder` only for whole-state rendering.
- Avoid feature-level extensions, top-level functions, and globals. Retain only established base infrastructure entrypoints and never add mutable global state.
- Add a single concise comment only when a difficult function or block needs its non-obvious intent or constraint explained.
- Do not introduce competing architecture, routing, DI, localization, asset, or state-management frameworks without an explicit migration request.
- Never edit generated Dart files manually.
- Keep bug fixes and refactors scoped. Apply the complete feature workflow only to new feature work.
- After every implementation, require all four project gates to pass: `dart format lib test`, `dart run build_runner build -d`, `flutter analyze`, and `flutter test --test-randomize-ordering-seed random`.
- Do not claim full completion when any gate fails or cannot run; fix it or report incomplete verification.
- Report actual verification results and remaining risk; do not force a custom final-response schema.
