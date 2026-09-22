import 'package:dai_viet_ki_tran_game/app/design_system/colors.dart';
import 'package:dai_viet_ki_tran_game/app/design_system/spacing.dart';
import 'package:dai_viet_ki_tran_game/app/design_system/typography.dart';

/// define custom themes here
import 'package:flutter/material.dart';

final ThemeData appTheme =
    ThemeData.from(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: GameColors.lightPrimary,
        onPrimary: GameColors.lightOnPrimary,
        primaryContainer: GameColors.lightPrimaryContainer,
        onPrimaryContainer: GameColors.lightOnPrimaryContainer,
        primaryFixed: GameColors.lightPrimaryFixed,
        primaryFixedDim: GameColors.lightPrimaryFixedDim,
        onPrimaryFixed: GameColors.lightOnPrimaryFixed,
        onPrimaryFixedVariant: GameColors.lightOnPrimaryFixedVariant,
        secondary: GameColors.lightSecondary,
        onSecondary: GameColors.lightOnSecondary,
        secondaryContainer: GameColors.lightSecondaryContainer,
        onSecondaryContainer: GameColors.lightOnSecondaryContainer,
        secondaryFixed: GameColors.lightSecondaryFixed,
        secondaryFixedDim: GameColors.lightSecondaryFixedDim,
        onSecondaryFixed: GameColors.lightOnSecondaryFixed,
        onSecondaryFixedVariant: GameColors.lightOnSecondaryFixedVariant,
        tertiary: GameColors.lightTertiary,
        onTertiary: GameColors.lightOnTertiary,
        tertiaryContainer: GameColors.lightTertiaryContainer,
        onTertiaryContainer: GameColors.lightOnTertiaryContainer,
        tertiaryFixed: GameColors.lightTertiaryFixed,
        tertiaryFixedDim: GameColors.lightTertiaryFixedDim,
        onTertiaryFixed: GameColors.lightOnTertiaryFixed,
        onTertiaryFixedVariant: GameColors.lightOnTertiaryFixedVariant,
        error: GameColors.lightError,
        onError: GameColors.lightOnError,
        errorContainer: GameColors.lightErrorContainer,
        onErrorContainer: GameColors.lightOnErrorContainer,
        surface: GameColors.lightSurface,
        onSurface: GameColors.lightOnSurface,
        surfaceDim: GameColors.lightSurfaceDim,
        surfaceBright: GameColors.lightSurfaceBright,
        surfaceContainerLowest: GameColors.lightSurfaceContainerLowest,
        surfaceContainerLow: GameColors.lightSurfaceContainerLow,
        surfaceContainer: GameColors.lightSurfaceContainer,
        surfaceContainerHigh: GameColors.lightSurfaceContainerHigh,
        surfaceContainerHighest: GameColors.lightSurfaceContainerHighest,
        onSurfaceVariant: GameColors.lightOnSurfaceVariant,
        outline: GameColors.lightOutline,
        outlineVariant: GameColors.lightOutlineVariant,
        shadow: GameColors.lightShadow,
        scrim: GameColors.lightScrim,
        inverseSurface: GameColors.lightInverseSurface,
        onInverseSurface: GameColors.lightInverseOnSurface,
        inversePrimary: GameColors.lightInversePrimary,
        surfaceTint: GameColors.lightPrimary,
      ),
      textTheme: gameTextTheme,
    ).copyWith(
      highlightColor: GameColors.lightPrimary.withValues(alpha: 0.2),
      splashColor: GameColors.lightPrimary.withValues(alpha: 0.2),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: GameColors.lightPrimary,
        indicatorColor: Colors.white.withValues(alpha: 0.5),
      ),
      inputDecorationTheme: InputDecorationTheme(
        errorStyle: gameTextTheme.bodySmall?.copyWith(
          color: GameColors.lightError,
        ),
      ),
      // For filledButtonTheme, statedButtonTheme, textButtonTheme
      // This will apply to the theme, but I'm still considering whether to include them in each buttons.dart widget.
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return GameColors.green[10];
              }
              if (states.contains(WidgetState.pressed)) {
                return GameColors.lightPrimary;
              }
              return GameColors.neutral[15];
            },
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return GameColors.green;
              }
              return GameColors.green[100];
            },
          ),
          side: WidgetStateProperty.resolveWith<BorderSide?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return const BorderSide(
                  color: GameColors.lightPrimaryFixedDim,
                  width: 2,
                );
              }
              if (states.contains(WidgetState.pressed)) {
                return const BorderSide(
                  color: GameColors.lightPrimaryFixedDim,
                  width: 2,
                );
              }
              return BorderSide(color: GameColors.neutral[15]!, width: 2);
            },
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return GameColors.green[98];
              }
              if (states.contains(WidgetState.pressed)) {
                return GameColors.green[98];
              }
              return GameColors.green[100];
            },
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return GameColors.neutral[80];
              }
              if (states.contains(WidgetState.pressed)) {
                return GameColors.green;
              }
              return GameColors.neutral[15];
            },
          ),
          side: WidgetStateProperty.resolveWith<BorderSide?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return const BorderSide(
                  color: GameColors.lightOutlineVariant,
                  width: 2,
                );
              }
              if (states.contains(WidgetState.pressed)) {
                return BorderSide(color: GameColors.green[70]!, width: 2);
              }
              return const BorderSide(
                color: GameColors.lightOutline,
                width: 2,
              );
            },
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(horizontal: GameSpacing.normal),
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return GameColors.lightPrimary;
              }
              return GameColors.lightOnTertiaryFixedVariant;
            },
          ),
        ),
      ),
    );
