# Architecture and File Placement

## Canonical layout

```text
lib/
|-- app/
|   |-- authorization/
|   |-- constant/
|   |-- design_system/
|   |-- di/
|   |-- helpers/
|   |-- network/
|   |-- storage/
|   `-- ui/view/
|-- <feature>/
|   |-- <feature>.dart
|   |-- data/
|   |   |-- data_sources/
|   |   |-- models/
|   |   `-- repositories/
|   |-- domain/                 # Optional; add use cases only when useful.
|   `-- ui/
|       |-- cubit/
|       |-- view/
|       `-- widgets/            # Add when page-owned widgets need extraction.
|-- assets_gen/                 # Generated.
|-- bootstrap.dart
|-- main_development.dart
|-- main_staging.dart
`-- main_production.dart
```

## Placement rules

- Use `lib/example/` as the structural template for every new feature. Copy its feature barrel and data/UI folder boundaries, but not its known lifecycle or rendering defects.
- Put cross-feature app infrastructure in `lib/app/` only when it is truly shared.
- Keep feature-owned models, APIs, repositories, Cubits, pages, and widgets inside `lib/<feature>/`.
- Put request, response, and data models in `data/models/`; use Freezed plus JSON serialization for new JSON-backed models, following `lib/example/data/models/example_data.dart`.
- Export the feature's public API from `lib/<feature>/<feature>.dart`. Keep implementation-only types unexported.
- Add a `domain/` use case when it coordinates multiple dependencies, expresses reusable business behavior, or makes a workflow independently testable. Do not create pass-through use cases by default.
- Keep widgets free of direct Dio, Retrofit, storage, and repository calls. UI invokes Cubit methods and renders state/effects.
- Use `ui/cubit/` and `ui/view/` for new features. Preserve a different existing layout only when changing that feature without a requested migration.

## Widget boundaries

- Let the page or a small container widget obtain and own the Cubit.
- Pass immutable display data and typed callbacks such as `VoidCallback` or `ValueChanged<T>` to child widgets.
- Never pass Cubit/Bloc, repositories, data sources, service locators, or mutable state holders through child-widget constructors.
- Keep leaf widgets presentation-only. Put `BlocSelector` close to the smallest subtree that needs selected state, then pass the selected value down.

```dart
OrderTile(
  order: order,
  onPressed: () => context.read<OrdersCubit>().open(order.id),
);
```

## Extensions, globals, and comments

- Do not create extensions inside ordinary feature code. Add one only for a stable, project-wide, stateless semantic API on a type the project does not own; prefer a named helper/service when dependencies or side effects are involved.
- Do not create feature-level top-level functions or global variables. Use private instance methods, injected services, or narrowly owned static utilities.
- Never create mutable global state. Retain established app-level infrastructure such as `getIt`, `router`, `appTheme`, `bootstrap`, and flavor entrypoints only where the base already owns them.
- Prefer descriptive names and small functions. Add one short comment above a difficult function or complex block only when it explains a non-obvious intent, constraint, workaround, or reason. Do not narrate obvious code.

## Dependency direction

```text
page/container -> Cubit -> use case (optional) -> repository -> data source
                                                      -> local storage
page/container -> selected data + callbacks -> presentation widgets
```

The base uses concrete repositories rather than mandatory repository interfaces. Introduce an interface only when multiple implementations, a package boundary, or a testing boundary makes it useful.

## Imports and generated code

- Use `package:<package_name>/...` imports for project code, matching the base and lint setup.
- Group imports in the order enforced by the formatter/analyzer.
- Never edit generated Freezed, JSON, Retrofit, or flutter_gen output.
- Check the feature barrel before adding direct imports across features.
