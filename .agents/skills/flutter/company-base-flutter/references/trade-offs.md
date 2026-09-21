# Intentional Trade-offs

Use these rules to keep the architecture practical without weakening boundaries.

## Concrete repositories

Use a concrete repository by default because the base injects and mocks concrete classes successfully. Introduce an interface only when there are multiple implementations, a package/API boundary, environment-specific behavior, or a deliberate project-wide abstraction. Do not create one-to-one interfaces only to satisfy a diagram.

## Optional domain and use cases

Call a repository directly from a Cubit for a simple single-step operation. Add a use case when behavior coordinates multiple repositories/services, contains reusable business rules, must be shared by multiple Cubits, or needs an independent transaction/test boundary. Do not create pass-through use cases.

## Manual GetIt

Keep manual registration because it matches the base and makes the object graph explicit. When the locator grows, split registration into private methods on the locator class by concern/feature; do not switch to Injectable or add top-level registration helpers without an explicit migration.

## Freezed and JSON

Use Freezed plus JSON for new JSON-backed requests, responses, and feature data to keep immutability, equality, copying, and serialization consistent. Keep simple enums as enums. Allow a non-Freezed exception only when code generation is technically unsuitable and record the reason.

## Callback-only widgets

Pass data and typed callbacks to presentation widgets so they remain testable and independent from Cubit. If callbacks are passed through more than two widget levels or a constructor becomes difficult to scan, move a page/container boundary closer to that subtree or group immutable display data into a Freezed view model. Do not solve callback growth by passing the Cubit.

## BlocSelector equality

Use BlocSelector only when the selected value is immutable and has stable equality. Reuse existing immutable values or select a primitive, record, enum, or Freezed view model. Avoid allocating a fresh mutable list/map in every selector call. Use BlocBuilder when the complete sealed state genuinely controls the whole subtree.
