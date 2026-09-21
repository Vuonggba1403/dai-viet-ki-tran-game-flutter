---
name: tooling
description: Run and maintain Dart and Flutter tooling for company base-flutter projects. Use when changing analysis settings, formatting, generated code, CI checks, Freezed, JSON, Retrofit, or flutter_gen inputs.
---

# Dart Tooling

Read `../../flutter/company-base-flutter/SKILL.md` first.

- Treat the repository's `analysis_options.yaml` and `pubspec.yaml` as authoritative; do not add DCM or new lint packages unless requested.
- Format touched Dart files with the repository's formatter configuration; do not force a separate line length.
- Run `dart run build_runner build -d` after Freezed, JSON, Retrofit, or asset-generation inputs change.
- Never edit `*.freezed.dart`, `*.g.dart`, or `assets.gen.dart` manually.
- Run focused tests while developing, then execute the canonical mandatory gate before completion: format, build generation, analyze, and the randomized full test suite.
- Treat a failed or unavailable gate command as incomplete verification; never report a clean pass without successful exit codes.
- Do not change CI, Flutter versions, or dependency constraints as a side effect of feature work.
