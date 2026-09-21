---
name: performance
description: Diagnose and improve Flutter rebuild, list, image, async, and memory performance while preserving company base-flutter architecture. Use for performance reviews, jank, excessive rebuilds, large lists, image memory, or expensive parsing.
---

# Flutter Performance

Read `../company-base-flutter/SKILL.md` first.

- Measure or identify a concrete cost before adding optimization complexity.
- Prefer `BlocSelector` to limit rebuilds and `BlocBuilder` only for whole-state subtrees.
- Use lazy builders for large/dynamic lists and stable keys when identity matters.
- Use `const` widgets and move parsing/computation out of `build()`; use isolates only for measured heavy CPU work.
- Precache assets at screen scope when useful; avoid retaining every app asset globally.
- Reuse existing image packages. Do not add CachedNetworkImage or another dependency without a requirement.
- Dispose animations, image listeners, streams, and Cubits owned by the UI.
