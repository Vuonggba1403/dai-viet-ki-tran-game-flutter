---
name: retrofit-networking
description: Implement Dio and Retrofit data sources with Freezed JSON models in company base-flutter features. Use when adding endpoints, request/response models, repositories, interceptors, authentication, pagination, or token refresh.
---

# Retrofit Networking

Read `../company-base-flutter/SKILL.md` and `../company-base-flutter/references/data-di-security.md` first.

- Put Retrofit declarations in `lib/<feature>/data/data_sources/` and models in `lib/<feature>/data/models/`.
- Use Freezed plus JSON serialization for every new JSON-backed request, response, and feature data model; keep simple enums as enums.
- Keep Retrofit data-source declarations, repositories, services, use cases, and Cubit classes as normal Dart classes.
- Reuse the app's configured Dio, authorization interceptor, base response, timeout, and logging behavior.
- Let repositories coordinate transport and persistence; never decode maps or use Dio directly in widgets/Cubits.
- Share one token-refresh operation across concurrent 401s and retry each request at most once.
- Register data sources/repositories manually with GetIt.
