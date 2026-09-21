# Data, DI, Errors, and Security

## Retrofit and models

- Define remote endpoints in `<feature>/data/data_sources/` using `@RestApi`, `@GET`, `@POST`, and typed request/response models.
- Reuse the app's configured Dio instance so timeouts, authorization, and logging are consistent.
- Use Freezed plus JSON serialization by default for every new JSON-backed request, response, and feature data model under `<feature>/data/models/`, matching `lib/example/data/models/example_data.dart`.
- Include both `part '<name>.freezed.dart';` and `part '<name>.g.dart';`, define a `const factory`, and expose `fromJson` for JSON-backed models.
- Keep simple enums as Dart enums. Use a non-Freezed model only when serialization/code generation is technically unsuitable, and record the reason in the implementation summary.
- Do not apply Freezed to Retrofit data-source declarations, repositories, services, use cases, or Cubit classes. Apply it to Cubit state/effect and immutable models.
- Keep API envelopes such as `BaseResponse<T>` in shared network infrastructure.
- Do not decode response maps in widgets or Cubits.

```dart
part 'order_data.freezed.dart';
part 'order_data.g.dart';

@freezed
abstract class OrderData with _$OrderData {
  const factory OrderData({
    required String id,
    required String title,
  }) = _OrderData;

  factory OrderData.fromJson(Map<String, Object?> json) =>
      _$OrderDataFromJson(json);
}
```

## Repositories and use cases

- Let repositories coordinate remote/local data, caching, and model persistence.
- Return the type expected by the neighboring code. Do not introduce a new `Result<T>` hierarchy into one feature unless the project is being migrated consistently.
- Add a use case for reusable business orchestration, not as a mandatory wrapper around every repository method.
- Keep Retrofit annotations and Dio request options out of repositories' consumers.

## Manual GetIt registration

Register in dependency order inside `lib/app/di/dependencies.dart`:

1. environment constants and external primitives;
2. local storage and interceptors;
3. Dio and Retrofit data sources;
4. repositories;
5. use cases;
6. Cubit factories.

Use `registerSingleton` for an initialized instance, `registerLazySingleton` for shared services/repositories, and `registerFactory` for Cubits and short-lived coordinators. Extend `ProductionServiceLocator` for staging/development overrides rather than duplicating the graph.

## Token refresh

- Attach access tokens in the authorization interceptor.
- Ensure concurrent 401 responses do not start parallel refresh requests. Queue or share one refresh future.
- Retry each request at most once after refresh.
- Exclude login and refresh endpoints from recursive refresh handling.
- On refresh failure, clear credentials and emit a session-expired path without logging secrets.

## Storage and secrets

- Use `SharedPreferencesAsync` only for non-sensitive preferences and cache data.
- Store access tokens, refresh tokens, and sensitive PII with platform-backed secure storage in production applications.
- Never hardcode API keys, signing secrets, or service credentials in Dart or committed config.
- Environment URLs may remain in flavor constants when they are not secrets.
- Redact authorization headers, passwords, tokens, and PII from Dio/application logs.

## Naming correction

The sampled base defines `ApiExeption`. Do not create more misspelled public APIs. Prefer `ApiException` in new shared infrastructure; when compatibility matters, migrate references atomically or add a temporary deprecated alias.
