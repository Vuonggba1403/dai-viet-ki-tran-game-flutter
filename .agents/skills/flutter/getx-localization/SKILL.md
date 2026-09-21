---
name: getx-localization
description: Detect and migrate legacy GetX localization in projects derived from company base-flutter. Use only when GetX localization already exists or the user requests migration; never introduce GetX into a canonical base project.
---

# GetX Localization Legacy Guard

Read `../company-base-flutter/SKILL.md` first.

- Follow the target project's existing localization system.
- Do not add GetX, `.tr`, `GetMaterialApp`, locale maps, or GetX routing to a canonical base project.
- If localization is absent, treat selecting and configuring Flutter localization as a separate project-wide change.
- When maintaining legacy GetX code, preserve key coverage without expanding GetX into new architecture.
- Migrate legacy keys and locale resolution atomically before removing GetX dependencies.
