---
name: flutter-gen-assets
description: Generate and consume strongly typed assets using the existing flutter_gen configuration in company base-flutter projects. Use when changing pubspec assets, generated asset access, images, animations, SVGs, or flutter_gen configuration.
---

# Flutter Gen Assets

Read `../company-base-flutter/SKILL.md` first.

- Preserve the target configuration; the sampled base outputs to `lib/assets_gen/`.
- Declare only real asset directories in `pubspec.yaml`; do not force `assets/icons/` or `lib/gen/`.
- Access files through generated `Assets` members, never raw path strings or a parallel `AppAssets` class.
- Enable SVG/Lottie integration only when required and compatible with existing usage.
- Regenerate with `dart run build_runner build -d` after asset/config changes.
- Never edit `assets.gen.dart` manually.
