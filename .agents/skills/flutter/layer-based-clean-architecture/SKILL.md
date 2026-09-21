---
name: layer-based-clean-architecture
description: Detect or migrate legacy root-layer architecture in projects derived from company base-flutter. Use only when domain/infrastructure/application/presentation folders already exist or the user requests migration to the canonical feature layout.
---

# Layer Architecture Legacy Guard

Read `../company-base-flutter/SKILL.md` first.

- Do not create root `domain`, `infrastructure`, `application`, or `presentation` layers in canonical projects.
- Create new work under `lib/<feature>/data` and `lib/<feature>/ui`, with optional feature-local `domain/` use cases.
- Preserve legacy boundaries during scoped fixes; do not mix layouts inside one feature.
- Migrate one complete feature at a time, including imports, DI, routes, tests, and generated parts.
- Do not introduce mandatory repository interfaces, DTO-to-domain mapping, or `Result<T>` solely to imitate generic Clean Architecture.
