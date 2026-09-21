---
name: feature-based-clean-architecture
description: Organize new company base-flutter features using the canonical lib/example-derived data and ui layout. Use when creating features, choosing file locations, defining feature barrels, or reviewing feature boundaries.
---

# Feature-Based Architecture

Read `../company-base-flutter/SKILL.md` and `../company-base-flutter/references/architecture.md` first.

- Create features directly under `lib/<feature>/`; never introduce `lib/src/features/`.
- Start with `<feature>.dart`, `data/data_sources`, `data/models`, `data/repositories`, `ui/cubit`, `ui/view`, and optional `ui/widgets`.
- Use Freezed plus JSON for new JSON-backed models and Cubit plus Freezed for state/effects.
- Add `domain/` use cases only for meaningful reusable orchestration; do not force repository interfaces or pass-through use cases.
- Keep shared infrastructure in `lib/app/` only when multiple features genuinely own it.
- Export only the feature API needed by other modules through the feature barrel.
