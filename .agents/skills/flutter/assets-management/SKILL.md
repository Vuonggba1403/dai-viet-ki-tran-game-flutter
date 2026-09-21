---
name: assets-management
description: Add, rename, organize, and verify assets in company base-flutter projects. Use for images, animations, SVGs, fonts, pubspec asset declarations, or design exports.
---

# Assets Management

Read `../company-base-flutter/SKILL.md` first.

- Use semantic lowercase `snake_case` filenames; reject opaque export IDs and generic names.
- Place files only in asset directories declared by the target project, currently `assets/images/` and `assets/animations/` in the sampled base. Add a new directory only when required.
- Access assets through generated `Assets` APIs; do not maintain raw path constants.
- Preserve the target project's `flutter_gen` output and integrations.
- Regenerate after adding, renaming, or deleting assets.
- Add golden baselines only when a stable visual regression test is explicitly valuable; do not create `base_image_testing` by default.
