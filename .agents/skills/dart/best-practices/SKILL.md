---
name: best-practices
description: Apply Dart code-quality conventions in company base-flutter projects, including package imports, immutability, scoped dependencies, limited globals/extensions, and concise comments. Use when writing or reviewing Dart code in a project derived from the company base.
---

# Dart Best Practices

Read `../../flutter/company-base-flutter/SKILL.md` first; it overrides this module.

- Use `package:<app_name>/...` imports for code under `lib/`, matching the base.
- Prefer `const`, then `final`; use mutable state only with clear ownership.
- Do not create feature-level globals, top-level helpers, or mutable singleton state. Keep established infrastructure entrypoints such as `getIt`, `router`, and `bootstrap`.
- Do not create feature extensions by default. Prefer instance methods or injected services.
- Keep functions small and names explanatory. Add one concise why-comment only for non-obvious constraints or workarounds.
- Never hardcode secrets, tokens, credentials, or PII.
- Preserve existing public APIs during a scoped fix unless migration is requested.
