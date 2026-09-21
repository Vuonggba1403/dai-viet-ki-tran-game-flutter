---
name: auto-route-navigation
description: Detect and migrate legacy AutoRoute usage in projects derived from company base-flutter. Use only when AutoRoute code already exists or the user explicitly requests an AutoRoute-to-GoRouter migration; never introduce AutoRoute into a canonical base project.
---

# AutoRoute Legacy Guard

Read `../company-base-flutter/SKILL.md` first.

- Use the existing GoRouter configuration for all new routes.
- Do not add `auto_route`, `@RoutePage`, generated route classes, or a second router.
- When legacy AutoRoute exists, preserve behavior during scoped fixes and propose migration separately.
- During migration, map guards to GoRouter redirects, nested tabs to `StatefulShellRoute.indexedStack`, and typed parameters to GoRouter route data or validated state.
- Remove AutoRoute dependencies/generated files only after every route and test is migrated.
