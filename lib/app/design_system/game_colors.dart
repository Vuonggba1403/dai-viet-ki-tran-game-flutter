import 'package:flutter/material.dart';

/// Design tokens for Đại Việt Kỳ Trận game palette.
abstract final class GameColors {
  // --- Core Game Backgrounds & Surfaces ---
  /// Deep navy purple background for game screens (#17152B).
  static const Color background = Color(0xFF17152B);

  /// Card and container surface background (#24213D).
  static const Color surface = Color(0xFF24213D);

  /// Elevated surface for dialogs, modals, and popups (#302B4D).
  static const Color surfaceElevated = Color(0xFF302B4D);

  /// Outer border for dark panels.
  static const Color panelBorder = Color(0xFF453F6B);

  // --- Gold & Accent Colors ---
  /// Primary golden yellow for active tabs, highlights, and CTA buttons (#F4B942).
  static const Color goldPrimary = Color(0xFFF4B942);

  /// Rich gold border and bevel trim (#D58B28).
  static const Color goldBorder = Color(0xFFD58B28);

  /// Dark gold shade for button gradient bottoms (#A66617).
  static const Color goldDark = Color(0xFFA66617);

  // --- Combat & Status Indicators ---
  /// Enemy and damage Red HP (#EF476F).
  static const Color hpRed = Color(0xFFEF476F);

  /// Player and ally Green HP (#62D26F).
  static const Color hpGreen = Color(0xFF62D26F);

  /// Blue mana gauge and skill indicator (#43B7E8).
  static const Color manaBlue = Color(0xFF43B7E8);

  // --- Wooden Match-3 Board ---
  /// Wooden frame for the 7x7 board tray (#9A633D).
  static const Color woodBoard = Color(0xFF9A633D);

  /// Alternating light wood slot cell (#B77A4E).
  static const Color woodSlotLight = Color(0xFFB77A4E);

  /// Alternating dark wood slot cell (#A96842).
  static const Color woodSlotDark = Color(0xFFA96842);

  // --- Typography Colors ---
  /// Crisp warm cream text primary (#FFF8E7).
  static const Color textPrimary = Color(0xFFFFF8E7);

  /// Soft lilac secondary text for subtitles, stats, and hints (#C8C2D9).
  static const Color textSecondary = Color(0xFFC8C2D9);

  /// Muted tertiary text.
  static const Color textMuted = Color(0xFF8E88A8);

  // --- Element & Class Theme Colors ---
  static const Color elementFire = Color(0xFFE53935);
  static const Color elementWater = Color(0xFF1E88E5);
  static const Color elementLightning = Color(0xFFFBC02D);
  static const Color elementSword = Color(0xFF78909C);
  static const Color elementHeart = Color(0xFFEF476F);

  // --- Rank Tiers ---
  static const Color rankS = Color(0xFFFFB300);
  static const Color rankA = Color(0xFFAB47BC);
  static const Color rankB = Color(0xFF42A5F5);
  static const Color rankC = Color(0xFF66BB6A);
}
