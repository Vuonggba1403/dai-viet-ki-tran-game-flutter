---
name: dependency-injection
description: Register and test dependencies using the manual GetIt service locator in company base-flutter projects. Use when adding data sources, repositories, services, use cases, Cubits, Dio configuration, storage, or flavor overrides.
---

# Dependency Injection

Read `../company-base-flutter/SKILL.md` first.

- Register dependencies manually in `lib/app/di/dependencies.dart`; do not add Injectable or generated DI.
- Register initialized primitives with `registerSingleton`.
- Register shared Dio, data sources, repositories, and services with `registerLazySingleton`.
- Register Cubits and short-lived coordinators with `registerFactory`.
- Preserve dependency order: constants/storage/interceptors, Dio/data sources, repositories, use cases, then Cubits.
- Extend the production locator for staging/development overrides instead of duplicating the graph.
- Override direct dependencies in tests and reset GetIt state between isolated test groups when needed.
