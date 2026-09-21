import 'package:ezwork/app/app.dart';

/// define custom themes here
import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData.from(
  useMaterial3: true,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: EzWorkColors.lightPrimary,
    onPrimary: EzWorkColors.lightOnPrimary,
    primaryContainer: EzWorkColors.lightPrimaryContainer,
    onPrimaryContainer: EzWorkColors.lightOnPrimaryContainer,
    primaryFixed: EzWorkColors.lightPrimaryFixed,
    primaryFixedDim: EzWorkColors.lightPrimaryFixedDim,
    onPrimaryFixed: EzWorkColors.lightOnPrimaryFixed,
    onPrimaryFixedVariant: EzWorkColors.lightOnPrimaryFixedVariant,
    secondary: EzWorkColors.lightSecondary,
    onSecondary: EzWorkColors.lightOnSecondary,
    secondaryContainer: EzWorkColors.lightSecondaryContainer,
    onSecondaryContainer: EzWorkColors.lightOnSecondaryContainer,
    secondaryFixed: EzWorkColors.lightSecondaryFixed,
    secondaryFixedDim: EzWorkColors.lightSecondaryFixedDim,
    onSecondaryFixed: EzWorkColors.lightOnSecondaryFixed,
    onSecondaryFixedVariant: EzWorkColors.lightOnSecondaryFixedVariant,
    tertiary: EzWorkColors.lightTertiary,
    onTertiary: EzWorkColors.lightOnTertiary,
    tertiaryContainer: EzWorkColors.lightTertiaryContainer,
    onTertiaryContainer: EzWorkColors.lightOnTertiaryContainer,
    tertiaryFixed: EzWorkColors.lightTertiaryFixed,
    tertiaryFixedDim: EzWorkColors.lightTertiaryFixedDim,
    onTertiaryFixed: EzWorkColors.lightOnTertiaryFixed,
    onTertiaryFixedVariant: EzWorkColors.lightOnTertiaryFixedVariant,
    error: EzWorkColors.lightError,
    onError: EzWorkColors.lightOnError,
    errorContainer: EzWorkColors.lightErrorContainer,
    onErrorContainer: EzWorkColors.lightOnErrorContainer,
    surface: EzWorkColors.lightSurface,
    onSurface: EzWorkColors.lightOnSurface,
    surfaceDim: EzWorkColors.lightSurfaceDim,
    surfaceBright: EzWorkColors.lightSurfaceBright,
    surfaceContainerLowest: EzWorkColors.lightSurfaceContainerLowest,
    surfaceContainerLow: EzWorkColors.lightSurfaceContainerLow,
    surfaceContainer: EzWorkColors.lightSurfaceContainer,
    surfaceContainerHigh: EzWorkColors.lightSurfaceContainerHigh,
    surfaceContainerHighest: EzWorkColors.lightSurfaceContainerHighest,
    onSurfaceVariant: EzWorkColors.lightOnSurfaceVariant,
    outline: EzWorkColors.lightOutline,
    outlineVariant: EzWorkColors.lightOutlineVariant,
    shadow: EzWorkColors.lightShadow,
    scrim: EzWorkColors.lightScrim,
    inverseSurface: EzWorkColors.lightInverseSurface,
    onInverseSurface: EzWorkColors.lightInverseOnSurface,
    inversePrimary: EzWorkColors.lightInversePrimary,
    surfaceTint: EzWorkColors.lightPrimary,
  ),
  textTheme: ezworkTextTheme,
).copyWith(
  highlightColor: EzWorkColors.lightPrimary.withValues(alpha: 0.2),
  splashColor: EzWorkColors.lightPrimary.withValues(alpha: 0.2),
  appBarTheme: const AppBarTheme(
    centerTitle: false,
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: EzWorkColors.lightPrimary,
    indicatorColor: Colors.white.withValues(alpha: 0.5),
  ),
  inputDecorationTheme: InputDecorationTheme(
    errorStyle:
        ezworkTextTheme.bodySmall?.copyWith(color: EzWorkColors.lightError),
  ),
  // For filledButtonTheme, statedButtonTheme, textButtonTheme
  // This will apply to the theme, but I'm still considering whether to include them in each buttons.dart widget.
  filledButtonTheme: FilledButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return EzWorkColors.green[10];
          }
          if (states.contains(WidgetState.pressed)) {
            return EzWorkColors.lightPrimary;
          }
          return EzWorkColors.neutral[15];
        },
      ),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return EzWorkColors.green;
          }
          return EzWorkColors.green[100];
        },
      ),
      side: WidgetStateProperty.resolveWith<BorderSide?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return const BorderSide(
              color: EzWorkColors.lightPrimaryFixedDim,
              width: 2,
            );
          }
          if (states.contains(WidgetState.pressed)) {
            return const BorderSide(
              color: EzWorkColors.lightPrimaryFixedDim,
              width: 2,
            );
          }
          return BorderSide(color: EzWorkColors.neutral[15]!, width: 2);
        },
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return EzWorkColors.green[98];
          }
          if (states.contains(WidgetState.pressed)) {
            return EzWorkColors.green[98];
          }
          return EzWorkColors.green[100];
        },
      ),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return EzWorkColors.neutral[80];
          }
          if (states.contains(WidgetState.pressed)) {
            return EzWorkColors.green;
          }
          return EzWorkColors.neutral[15];
        },
      ),
      side: WidgetStateProperty.resolveWith<BorderSide?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return const BorderSide(
              color: EzWorkColors.lightOutlineVariant,
              width: 2,
            );
          }
          if (states.contains(WidgetState.pressed)) {
            return BorderSide(color: EzWorkColors.green[70]!, width: 2);
          }
          return const BorderSide(color: EzWorkColors.lightOutline, width: 2);
        },
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
        const EdgeInsets.symmetric(horizontal: EzWorkSpacing.normal),
      ),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return EzWorkColors.lightPrimary;
          }
          return EzWorkColors.lightOnTertiaryFixedVariant;
        },
      ),
    ),
  ),
);
