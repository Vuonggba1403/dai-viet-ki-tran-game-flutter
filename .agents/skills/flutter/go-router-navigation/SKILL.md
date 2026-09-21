---
name: go-router-navigation
description: Add and maintain GoRouter routes, redirects, shell branches, and navigation effects in company base-flutter projects. Use when creating pages, route names, auth redirects, tabs, deep links, or navigation tests.
---

# GoRouter Navigation

Read `../company-base-flutter/SKILL.md` first.

- Add routes to the existing GoRouter configuration; do not add AutoRoute, GetX, or another router.
- Preserve stable route names and use named navigation where the project already does.
- Use `StatefulShellRoute.indexedStack` for persistent tab branches.
- Keep redirects and parameter validation in routing code.
- Trigger navigation from a Freezed one-time effect when it follows Cubit work.
- Add focused tests for redirects, shell behavior, parameters, and session expiration.
