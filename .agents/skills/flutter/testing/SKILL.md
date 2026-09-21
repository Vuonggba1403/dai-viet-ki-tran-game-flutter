---
name: testing
description: Add and run focused unit, bloc, widget, routing, repository, generation, and optional golden tests for company base-flutter projects. Use when implementing behavior, fixing regressions, or verifying generated code.
---

# Flutter Testing

Read `../company-base-flutter/SKILL.md` and `../company-base-flutter/references/testing-delivery.md` first.

- Test Cubit state/effects with `bloc_test`, mocking the Cubit's direct dependency.
- Test repositories for mapping, success, expected API failure, and malformed/empty responses where relevant.
- Test widget rendering/interactions with controlled dependencies and the existing GoRouter when navigation matters.
- Keep `test/build_runner/build_runner_test.dart` passing after generated inputs change.
- Add golden tests only for stable, visually important UI with an approved maintainable baseline; never create or update goldens merely to silence a diff.
- Do not add AutoRoute/GetX test wrappers or legacy `base_image_testing` workflows.
- Run focused tests while developing, then run `dart format lib test`, `dart run build_runner build -d`, `flutter analyze`, and `flutter test --test-randomize-ordering-seed random` before completion.
- Treat any failed or unavailable command as incomplete verification and report it explicitly.
