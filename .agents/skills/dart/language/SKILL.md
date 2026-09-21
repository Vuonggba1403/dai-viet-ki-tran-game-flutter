---
name: language
description: Use modern Dart language features consistently with company base-flutter conventions. Use for null safety, sealed classes, pattern matching, records, async code, Freezed models/states, and language-level refactors in derived projects.
---

# Dart Language

Read `../../flutter/company-base-flutter/SKILL.md` first.

- Use null-safe APIs and avoid `!` when control flow can prove safety.
- Use sealed Freezed unions for Cubit phases/effects and Freezed plus JSON for new JSON-backed feature models.
- Use exhaustive pattern matching for sealed state handling.
- Use records only for small local multi-value results; use named models at API or feature boundaries.
- Check `context.mounted` after asynchronous gaps before using `BuildContext`.
- Add an extension only for a stable, project-wide, stateless semantic API on a type the project does not own. Do not use extensions to hide dependencies or side effects.
- Keep enums as enums when they only represent a closed set of values.
