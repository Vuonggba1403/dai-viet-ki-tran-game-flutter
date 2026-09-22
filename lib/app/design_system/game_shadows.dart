import 'package:flutter/material.dart';

/// BoxShadow constants for game UI depth and glowing elements.
abstract final class GameShadows {
  static const BoxShadow card = BoxShadow(
    color: Color(0x66000000),
    offset: Offset(0, 4),
    blurRadius: 8,
  );

  static const BoxShadow cardHover = BoxShadow(
    color: Color(0x99000000),
    offset: Offset(0, 6),
    blurRadius: 12,
  );

  static const BoxShadow goldGlow = BoxShadow(
    color: Color(0x66F4B942),
    blurRadius: 10,
    spreadRadius: 2,
  );

  static const BoxShadow characterShadow = BoxShadow(
    color: Color(0x88000000),
    offset: Offset(0, 6),
    blurRadius: 6,
    spreadRadius: 2,
  );

  static const BoxShadow hudPanel = BoxShadow(
    color: Color(0x80000000),
    offset: Offset(0, 4),
    blurRadius: 8,
  );
}
