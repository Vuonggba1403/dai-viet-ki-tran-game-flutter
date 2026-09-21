# State Management and Effects

## Choose the state shape

- Use Cubit plus Freezed state as the default for every new feature.
- Use a Freezed sealed union for mutually exclusive phases such as loading, success, and error.
- Use a Freezed data class with `copyWith` when several independent properties change over time.
- Use a plain state only for a truly stateless effect-only Cubit or when code generation cannot be used; document the reason.
- Use Bloc instead of Cubit only when event ordering, event transformations, or multiple external event streams require an event model; document the reason.

```dart
@freezed
sealed class OrdersState with _$OrdersState {
  const factory OrdersState.loading() = OrdersStateLoading;
  const factory OrdersState.success({required List<Order> orders}) = OrdersStateSuccess;
  const factory OrdersState.error({required String message}) = OrdersStateError;
}
```

## One-time effects

Use `CubitWithEffects<State, Effect>` for commands that should be consumed once:

- navigation;
- dialogs and snackbars;
- logout/session-expired commands;
- transient global loading-overlay commands when the existing screen uses that mechanism.

Do not place durable screen data in an effect. Loading, content, empty, and retryable error states normally belong in render state.

```dart
@freezed
sealed class OrdersEffect with _$OrdersEffect {
  const factory OrdersEffect.openDetails(String orderId) = OrdersEffectOpenDetails;
  const factory OrdersEffect.showError(String message) = OrdersEffectShowError;
}
```

## Widget selection order

Choose by responsibility; listener widgets do not replace rendering widgets.

1. Use `BlocSelector` first for rendering a selected value or the smallest state slice.
2. Use `BlocEffectListener` for navigation, dialogs, snackbars, and other one-time effects from `CubitWithEffects`.
3. Use `BlocListener` only when a non-effect Cubit has a legitimate state-transition side effect or while maintaining legacy code.
4. Use `BlocBuilder` only when the whole subtree depends on the complete state, such as an exhaustive loading/success/error screen switch.

Combine an effect listener with a selector when a page needs both. Do not replace a listener with a builder to perform side effects.

```dart
final cubit = context.read<OrdersCubit>();

BlocEffectListener<OrdersCubit, OrdersEffect>(
  effector: cubit,
  listener: (context, effect) => _onEffect(context, effect),
  child: BlocSelector<OrdersCubit, OrdersState, int>(
    bloc: cubit,
    selector: (state) => switch (state) {
      OrdersStateSuccess(:final orders) => orders.length,
      _ => 0,
    },
    builder: (context, orderCount) => OrdersSummary(
      orderCount: orderCount,
      onOpenAll: cubit.openAll,
    ),
  ),
);
```

## Ownership and lifecycle

- Register Cubits with `getIt.registerFactory`.
- Prefer `BlocProvider(create: (_) => getIt<FeatureCubit>()..load())` so the provider closes the Cubit.
- If a StatefulWidget stores `final _cubit = getIt<FeatureCubit>()`, call `_cubit.close()` from `dispose()`.
- Dispose text controllers, focus nodes, animation controllers, and stream subscriptions.
- After an `await`, check `context.mounted` before using context.
- Avoid starting network work from `build()`.
- Keep Cubit access at page/container boundaries. Pass selected values and callbacks to presentation widgets instead of passing the Cubit instance.

## Error behavior

- Catch expected transport/domain failures at the Cubit boundary or map them in the repository.
- Log an error with its stack trace, then emit a user-safe state/effect.
- Never expose raw Dio exceptions, server internals, tokens, or stack traces in UI text.
- Keep user-facing error strings compatible with the project's localization approach.

## Tests

Use `bloc_test` for transitions and effects. Cover success, expected API failure, unexpected failure, and retry when applicable. Mock the Cubit's direct dependency, not Dio from a Cubit test.
