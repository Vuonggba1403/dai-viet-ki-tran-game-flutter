---
name: ui-implementation-standard
description: Implement feature pages and widgets using company base-flutter structure, design system, generated assets, callback-only child APIs, and Cubit/Freezed state. Use for new screens, components, responsive layouts, or design implementation.
---

# UI Implementation Standard

Read `../company-base-flutter/SKILL.md`, `../company-base-flutter/references/architecture.md`, and `../company-base-flutter/references/ui-navigation-assets.md` first.

- Place pages in `lib/<feature>/ui/view/` and feature widgets in optional `lib/<feature>/ui/widgets/`; never use `lib/src/features/.../presentation/components`.
- Let pages/containers own Cubits. Pass immutable data and typed callbacks to child widgets; reject Cubit/Bloc/service constructor parameters.
- Prefer `BlocSelector` for selected rendering and combine it with `BlocEffectListener` when one-time effects are needed.
- Use the existing design-system colors, typography, spacing, theme, and shared widgets; do not hardcode hex colors or duplicate shared styles.
- Access assets through generated `Assets`; preserve actual design assets and semantic filenames.
- Extract a widget when it improves readability, reuse, state selection, or testing; do not split one-line wrappers to meet a quota.
- Test overflow, text scaling, loading, empty, success, error, and disabled interactions as relevant.
