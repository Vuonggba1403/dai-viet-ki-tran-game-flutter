---
name: idiomatic-flutter
description: Apply idiomatic Flutter composition, lifecycle, async, layout, and dependency-boundary practices in company base-flutter projects. Use when creating or refactoring widgets and pages.
---

# Idiomatic Flutter

Read `../company-base-flutter/SKILL.md` first.

- Prefer StatelessWidget unless local controllers or lifecycle ownership require StatefulWidget.
- Let page/container widgets access Cubits; pass immutable data and typed callbacks to presentation widgets.
- Use `const` constructors, `SizedBox`, `Padding`, and existing design-system spacing. Do not add `gap` solely for layout.
- Check `context.mounted` after async gaps and dispose every owned controller/subscription/Cubit.
- Avoid feature extensions, global helpers, intrinsic layout, and expensive work in `build()`.
- Add one concise why-comment only for genuinely non-obvious logic.
