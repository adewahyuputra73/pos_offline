import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Color palette directly mapped from the Minimalist Red POS System (Stitch)
///
/// Prefix [DC] stands for "Dashboard Colors".
abstract final class DC {
  // ── Primary ────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFFE53E3E); // Vibrant Red
  static const Color primaryDim = Color(0xFFC53030); // Darker Red
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFFED7D7); // Light Red
  static const Color onPrimaryContainer = Color(0xFF742A2A); // Deep Red
  static const Color primaryFixedDim = Color(0xFFFEB2B2);

  // ── Secondary ──────────────────────────────────────────────────────────────
  static const Color secondaryContainer = Color(0xFFEDF2F7);
  static const Color onSecondaryContainer = Color(0xFF2D3748);

  // ── Tertiary ───────────────────────────────────────────────────────────────
  static const Color tertiary = Color(0xFF4A5568);
  static const Color tertiaryContainer = Color(0xFFE2E8F0);
  static const Color onTertiaryContainer = Color(0xFF1A202C);

  // ── Surface ────────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF7FAFC); // Light Gray
  static const Color surfaceContainer = Color(0xFFEDF2F7);
  static const Color surfaceContainerHigh = Color(0xFFE2E8F0);

  // ── On-surface ─────────────────────────────────────────────────────────────
  static const Color onSurface = Color(0xFF1A202C); // Slate Neutrals
  static const Color onSurfaceVariant = Color(0xFF4A5568);
  static const Color outlineVariant = Color(0xFFE2E8F0); // Subtle borders

  // ── Stone (mapped to slate/white) ──────────────────────────────────────────
  static const Color stone50 = Color(0xFFFFFFFF);
  static const Color stone100 = Color(0xFFF7FAFC);
  static const Color stone200 = Color(0xFFEDF2F7);
  static const Color stone400 = Color(0xFFA0AEC0);
  static const Color stone500 = Color(0xFF718096);
  static const Color stone900 = Color(0xFF1A202C);

  // ── Brand accent ───────────────────────────────────────────────────────────
  static const Color deepBrown = Color(0xFF1A202C); // Replaced with Slate Dark
  static const Color error = Color(0xFFE53E3E); // Primary red as error/alert
}

/// Convenience: return a [TextStyle] using Inter from google_fonts.
/// Function named manrope to avoid breaking existing imports/calls, 
/// but it actually returns Inter now based on the Stitch design system.
TextStyle manrope({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? letterSpacing,
  double? height,
  TextDecoration? decoration,
  Color? decorationColor,
}) =>
    GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
    );
