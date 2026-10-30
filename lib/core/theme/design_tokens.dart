import 'package:flutter/material.dart';

/// Design tokens — single source of truth for all visual constants.
/// Based on the PRD section 13.3 design token table.
class DesignTokens {
  DesignTokens._();

  // ─── Accent Colors ───────────────────────────────────────────────────────────
  static const accent     = Color(0xFF0A84FF);  // iOS blue
  static const accentDark = Color(0xFF4DA3FF);
  static const success    = Color(0xFF34C759);
  static const warning    = Color(0xFFFF9F0A);
  static const error      = Color(0xFFFF453A);
  static const errorDark  = Color(0xFFFF6961);

  // ─── Backgrounds ────────────────────────────────────────────────────────────
  static const lightBackground = Color(0xFFF2F4F8);
  static const darkBackground  = Color(0xFF0D0E12);

  // ─── Surface / On-surface ────────────────────────────────────────────────────
  static const lightOnSurface = Color(0xFF1C1C1E);
  static const darkOnSurface  = Color(0xFFF2F2F7);
  static const lightOnSurfaceVariant = Color(0xFF6E6E73);
  static const darkOnSurfaceVariant  = Color(0xFF8E8E93);

  // ─── Glass Surfaces ──────────────────────────────────────────────────────────
  // Light: white at ~22% opacity  
  static const lightGlassSurface = Color(0x38FFFFFF);
  // Dark: white at ~10% opacity
  static const darkGlassSurface  = Color(0x1AFFFFFF);

  // ─── Glass Edge Highlights ───────────────────────────────────────────────────
  static const lightGlassEdge = Color(0x66FFFFFF);
  static const darkGlassEdge  = Color(0x38FFFFFF);

  // ─── Dividers ────────────────────────────────────────────────────────────────
  static const lightDivider = Color(0x33000000);
  static const darkDivider  = Color(0x33FFFFFF);

  // ─── Glass Blur Values ───────────────────────────────────────────────────────
  static const blurLow    = 12.0;
  static const blurMedium = 20.0;
  static const blurHigh   = 30.0;

  // ─── Corner Radii ────────────────────────────────────────────────────────────
  static const radiusCard   = 24.0;
  static const radiusSheet  = 32.0;
  static const radiusChip   = 100.0;  // fully rounded
  static const radiusButton = 100.0;  // fully rounded
  static const radiusSmall  = 12.0;
  static const radiusMedium = 16.0;

  // ─── Spacing Scale ───────────────────────────────────────────────────────────
  static const s4  = 4.0;
  static const s8  = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s24 = 24.0;
  static const s32 = 32.0;
  static const s48 = 48.0;

  // ─── Typography ──────────────────────────────────────────────────────────────
  static const fontTitle   = 28.0;
  static const fontSection = 20.0;
  static const fontBody    = 16.0;
  static const fontCaption = 13.0;

  // ─── Touch Target ────────────────────────────────────────────────────────────
  static const touchTarget = 48.0;

  // ─── Durations ───────────────────────────────────────────────────────────────
  static const durationFast   = Duration(milliseconds: 150);
  static const durationNormal = Duration(milliseconds: 250);
  static const durationSlow   = Duration(milliseconds: 350);
  static const springDuration = Duration(milliseconds: 400);

  // ─── Tab Bar ─────────────────────────────────────────────────────────────────
  static const tabBarHeight = 80.0;
}

