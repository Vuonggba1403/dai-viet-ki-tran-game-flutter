---
name: widgets
description: Build maintainable presentation widgets for company base-flutter features. Use when extracting page sections, list items, forms, buttons, dialogs, or reusable UI components.
---

# Flutter Widgets

Read `../company-base-flutter/SKILL.md` first.

- Default to StatelessWidget and const constructors.
- Accept immutable data and typed callbacks; never accept Cubit/Bloc, repository, data source, or GetIt in child-widget constructors.
- Keep Cubit access and BlocSelector at page/container boundaries, then pass selected values down.
- Use existing design-system tokens/components and generated assets.
- Use lazy list builders for dynamic collections and stable layout constraints to prevent shifts/overflow.
- Extract meaningful UI units, not trivial wrappers.
- Add widget tests for important rendering, validation, callbacks, and accessibility behavior.
