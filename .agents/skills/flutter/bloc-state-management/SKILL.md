---
name: bloc-state-management
description: Implement Cubit, Freezed state/effects, BlocSelector rendering, and lifecycle-safe UI composition in company base-flutter features. Use when creating or changing Cubits, states, effects, listeners, selectors, or state-driven widgets.
---

# Cubit State Management

Read `../company-base-flutter/SKILL.md` and `../company-base-flutter/references/state-management.md` first.

- Use Cubit plus Freezed state by default. Use Bloc only for a documented event-model requirement.
- Use `CubitWithEffects` plus a Freezed effect for navigation, dialogs, snackbars, and other one-time commands.
- Prefer `BlocSelector` for selected rendering, then `BlocBuilder` only for whole-state subtrees.
- Prefer `BlocEffectListener` for effects; use `BlocListener` only for justified state-transition side effects or legacy maintenance.
- Let a page/container own the Cubit. Pass immutable data and typed callbacks to child widgets; never pass Cubit/Bloc through constructors.
- Register Cubits as GetIt factories and close them through `BlocProvider` ownership or explicit `dispose()`.
- Test state transitions and effects with `bloc_test`.
