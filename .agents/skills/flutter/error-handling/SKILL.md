---
name: error-handling
description: Handle Dio, API, repository, Cubit, and session errors consistently with company base-flutter. Use when mapping failures, displaying user-safe errors, refreshing tokens, logging exceptions, or changing repository return behavior.
---

# Error Handling

Read `../company-base-flutter/SKILL.md` and `../company-base-flutter/references/data-di-security.md` first.

- Preserve the target project's existing response/exception contract; do not introduce `Result<T>`, Failure hierarchies, Equatable, or dartz in one feature.
- Keep Dio/API details below the UI boundary. Catch expected failures in repositories or Cubits as established nearby.
- Log errors with stack traces while redacting tokens, credentials, and PII.
- Emit user-safe Freezed states/effects; never show raw exception text or server internals.
- Retry authenticated requests at most once after one shared token-refresh operation.
- Treat a project-wide error-model migration as a separate explicit task.
