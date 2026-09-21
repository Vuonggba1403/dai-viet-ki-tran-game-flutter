import 'package:flutter/material.dart';

class EzWorkColors {
  EzWorkColors._();
  static const int _primaryValue = 0xFF4B662C;
  static const int _secondaryValue = 0xFF8A5021;
  static const int _tertiaryValue = 0xFF505B92;
  static const int _errorValue = 0xFFBA1A1A;
  static const int _neutralValue = 0xFF777773;
  static const int _neutralVariantValue = 0xFF8E76A3;
  static const int _extendedYellowValue = 0xFFD6AF0F;

  static const MaterialColor green = MaterialColor(
    _primaryValue,
    <int, Color>{
      0: Color(0xFF000000),
      10: Color(0xFF0F2000),
      20: Color(0xFF1F3701),
      30: Color(0xFF344E15),
      40: Color(0xFF4B662B),
      50: Color(0xFF638041),
      60: Color(0xFF7C9A58),
      70: Color(0xFF96B570),
      80: Color(0xFFB1D189),
      90: Color(0xFFCCEDA3),
      95: Color(0xFFDAFCB0),
      98: Color(0xFFF0FFD7),
      99: Color(0xFFF9FFE9),
      100: Color(0xFFFFFFFF),
    },
  );

  static const MaterialColor brown = MaterialColor(
    _secondaryValue,
    <int, Color>{
      0: Color(0xFF000000),
      10: Color(0xFF301400),
      20: Color(0xFF4E2601),
      30: Color(0xFF693B15),
      40: Color(0xFF85522A),
      50: Color(0xFFA26A40),
      60: Color(0xFFBF8357),
      70: Color(0xFFDD9D6F),
      80: Color(0xFFFCB887),
      90: Color(0xFFFFDCC5),
      95: Color(0xFFFFEDE3),
      99: Color(0xFFFFFBFF),
      100: Color(0xFFFFFFFF),
    },
  );

  static const MaterialColor blue = MaterialColor(
    _tertiaryValue,
    <int, Color>{
      0: Color(0xFF000000),
      10: Color(0xFF11193C),
      20: Color(0xFF272E52),
      30: Color(0xFF3D456A),
      40: Color(0xFF555C83),
      50: Color(0xFF6E759D),
      60: Color(0xFF878EB8),
      70: Color(0xFFA2A9D4),
      80: Color(0xFFBDC4F1),
      90: Color(0xFFDDE1FF),
      95: Color(0xFFF0EFFF),
      99: Color(0xFFFCFBFF),
      100: Color(0xFFFFFFFF),
    },
  );

  static const MaterialColor red = MaterialColor(
    _errorValue,
    <int, Color>{
      0: Color(0xFF000000),
      10: Color(0xFF410002),
      20: Color(0xFF690005),
      30: Color(0xFF93000A),
      40: Color(0xFFBA1A1A),
      50: Color(0xFFDE3730),
      60: Color(0xFFFF5449),
      70: Color(0xFFFF897D),
      80: Color(0xFFFFB4AB),
      90: Color(0xFFFFDAD6),
      95: Color(0xFFFFEDEA),
      99: Color(0xFFFFFBFF),
      100: Color(0xFFFFFFFF),
    },
  );

  static const MaterialColor neutral = MaterialColor(
    _neutralValue,
    <int, Color>{
      0: Color(0xFF000000),
      10: Color(0xFF1B1C19),
      15: Color(0xFF252623),
      20: Color(0xFF30312D),
      30: Color(0xFF474743),
      35: Color(0xFF52534F),
      40: Color(0xFF5E5F5A),
      50: Color(_neutralValue),
      60: Color(0xFF91918C),
      70: Color(0xFFACABA6),
      80: Color(0xFFC8C6C1),
      90: Color(0xFFE4E2DD),
      95: Color(0xFFF2F1EB),
      99: Color(0xFFFEFCF6),
      100: Color(0xFFFFFFFF),
    },
  );

  static const MaterialColor neutralVariant = MaterialColor(
    _neutralVariantValue,
    <int, Color>{
      0: Color(0xFF000000),
      10: Color(0xFF2F2835),
      20: Color(0xFF4D3F58),
      30: Color(0xFF68517B),
      40: Color(0xFF7E6395),
      50: Color(_neutralVariantValue),
      60: Color(0xFFA389B9),
      70: Color(0xFFAF99C2),
      80: Color(0xFFCDBCDC),
      90: Color(0xFFDACDE4),
      95: Color(0xFFE6DDED),
      99: Color(0xFFFAF5FF),
      100: Color(0xFFFFFFFF),
    },
  );

  static const MaterialColor extendedYellow = MaterialColor(
    _extendedYellowValue,
    <int, Color>{
      0: Color(0xFF171302),
      10: Color(0xFF2E2605),
      20: Color(0xFF5D4C09),
      30: Color(0xFF8B720E),
      40: Color(0xFFB99713),
      50: Color(_extendedYellowValue),
      60: Color(0xFFECC013),
      70: Color(0xFFF4CC2C),
      80: Color(0xFFF7D23B),
      90: Color(0xFFFDD849),
      95: Color(0xFFFEE580),
      99: Color(0xFFFFEEAB),
      100: Color(0xFFFFFFFF),
    },
  );

  //Light Theme
  static const Color lightPrimary = Color(0xFF4B662C);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFCDEDA4);
  static const Color lightOnPrimaryContainer = Color(0xFF0F2000);
  static const Color lightPrimaryFixed = Color(0xFFCDEDA4);
  static const Color lightPrimaryFixedDim = Color(0xFFB1D18A);
  static const Color lightOnPrimaryFixed = Color(0xFF0F2000);
  static const Color lightOnPrimaryFixedVariant = Color(0xFF344E16);

  static const Color lightSurfaceDim = Color(0xFFDADBD0);
  static const Color lightSurface = Color(0xFFF9FAEF);
  static const Color lightSurfaceBright = Color(0xFFDADBD0);
  static const Color lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerLow = Color(0xFFF3F4E9);
  static const Color lightSurfaceContainer = Color(0xFFEEEFE4);
  static const Color lightSurfaceContainerHigh = Color(0xFFE8E9DE);
  static const Color lightSurfaceContainerHighest = Color(0xFFE2E3D8);
  static const Color lightOnSurface = Color(0xFF1A1C16);
  static const Color lightOnSurfaceVariant = Color(0xFF4A454E);
  static const Color lightOutline = Color(0xFF7B757F);
  static const Color lightOutlineVariant = Color(0xFFCCC4CF);

  static const Color lightSecondary = Color(0xFF8A5021);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFFFDCC5);
  static const Color lightOnSecondaryContainer = Color(0xFF301400);
  static const Color lightSecondaryFixed = Color(0xFFFFDCC5);
  static const Color lightSecondaryFixedDim = Color(0xFFFFB782);
  static const Color lightOnSecondaryFixed = Color(0xFF301400);
  static const Color lightOnSecondaryFixedVariant = Color(0xFF6D390A);

  static const Color lightTertiary = Color(0xFF505B92);
  static const Color lightOnTertiary = Color(0xFFFFFFFF);
  static const Color lightTertiaryContainer = Color(0xFFDDE1FF);
  static const Color lightOnTertiaryContainer = Color(0xFF09164B);
  static const Color lightTertiaryFixed = Color(0xFFDDE1FF);
  static const Color lightTertiaryFixedDim = Color(0xFFB9C3FF);
  static const Color lightOnTertiaryFixed = Color(0xFF09164B);
  static const Color lightOnTertiaryFixedVariant = Color(0xFF384379);

  static const Color lightError = Color(0xFFBA1A1A);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightErrorContainer = Color(0xFFFFDAD6);
  static const Color lightOnErrorContainer = Color(0xFF410002);

  static const Color lightInverseSurface = Color(0xFF2F312A);
  static const Color lightInverseOnSurface = Color(0xFFF0F2E6);
  static const Color lightInversePrimary = Color(0xFFB1D18A);
  static const Color lightScrim = Color(0xFF000000);
  static const Color lightShadow = Color(0xFF000000);

  //Dark Theme
  static const Color darkPrimary = Color(0xFFB1D18A);
  static const Color darkOnPrimary = Color(0xFF1F3701);
  static const Color darkPrimaryContainer = Color(0xFF344E16);
  static const Color darkOnPrimaryContainer = Color(0xFFCDEDA4);
  static const Color darkPrimaryFixed = Color(0xFFCDEDA4);
  static const Color darkPrimaryFixedDim = Color(0xFFB1D18A);
  static const Color darkOnPrimaryFixed = Color(0xFF0F2000);
  static const Color darkOnPrimaryFixedVariant = Color(0xFF344E16);
  static const Color darkSurfaceDim = Color(0xFF12140E);
  static const Color darkSurface = Color(0xFF12140E);
  static const Color darkSurfaceBright = Color(0xFF383A32);
  static const Color darkSurfaceContainerLowest = Color(0xFF0C0F09);
  static const Color darkSurfaceContainerLow = Color(0xFF1A1C16);
  static const Color darkSurfaceContainer = Color(0xFF1E201A);
  static const Color darkSurfaceContainerHigh = Color(0xFF282B24);
  static const Color darkSurfaceContainerHighest = Color(0xFF33362E);
  static const Color darkOnSurface = Color(0xFFE2E3D8);
  static const Color darkOnSurfaceVariant = Color(0xFFCCC4CF);
  static const Color darkOutline = Color(0xFF958E98);
  static const Color darkOutlineVariant = Color(0xFF4A454E);

  static const Color darkSecondary = Color(0xFFFFB782);
  static const Color darkOnSecondary = Color(0xFF4F2500);
  static const Color darkSecondaryContainer = Color(0xFF6D390A);
  static const Color darkOnSecondaryContainer = Color(0xFFFFDCC5);
  static const Color darkSecondaryFixed = Color(0xFFFFDCC5);
  static const Color darkSecondaryFixedDim = Color(0xFFFFB782);
  static const Color darkOnSecondaryFixed = Color(0xFF301400);
  static const Color darkOnSecondaryFixedVariant = Color(0xFF6D390A);

  static const Color darkTertiary = Color(0xFFB9C3FF);
  static const Color darkOnTertiary = Color(0xFF212C61);
  static const Color darkTertiaryContainer = Color(0xFF384379);
  static const Color darkOnTertiaryContainer = Color(0xFFDDE1FF);
  static const Color darkTertiaryFixed = Color(0xFFDDE1FF);
  static const Color darkTertiaryFixedDim = Color(0xFFB9C3FF);
  static const Color darkOnTertiaryFixed = Color(0xFF09164B);
  static const Color darkOnTertiaryFixedVariant = Color(0xFF384379);

  static const Color darkError = Color(0xFFFFB4AB);
  static const Color darkOnError = Color(0xFF690005);
  static const Color darkErrorContainer = Color(0xFF93000A);
  static const Color darkOnErrorContainer = Color(0xFFFFDAD6);

  static const Color darkInverseSurface = Color(0xFFE2E3D8);
  static const Color darkInverseOnSurface = Color(0xFF2F312A);
  static const Color darkInversePrimary = Color(0xFF4B662C);
  static const Color darkScrim = Color(0xFF000000);
  static const Color darkShadow = Color(0xFF000000);
}
