import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Color palette directly mapped from the Tailwind config in the HTML source.
///
/// Prefix [DC] stands for "Dashboard Colors" — short to keep TextStyle calls
/// readable. All values are const so they are zero-cost at runtime.
abstract final class DC {
  // ── Primary ────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF685D48);
  static const Color primaryDim = Color(0xFF5B513D);
  static const Color onPrimary = Color(0xFFFFF6EC);
  static const Color primaryContainer = Color(0xFFF0E1C6);
  static const Color onPrimaryContainer = Color(0xFF5B513D);
  static const Color primaryFixedDim = Color(0xFFE2D3B9);

  // ── Secondary ──────────────────────────────────────────────────────────────
  static const Color secondaryContainer = Color(0xFFE9E1D9);
  static const Color onSecondaryContainer = Color(0xFF55514B);

  // ── Tertiary ───────────────────────────────────────────────────────────────
  static const Color tertiary = Color(0xFF61613C);
  static const Color tertiaryContainer = Color(0xFFF7F6C7);
  static const Color onTertiaryContainer = Color(0xFF5D5E39);

  // ── Surface ────────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF9F9F9);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F4F4);
  static const Color surfaceContainer = Color(0xFFEBEEEF);
  static const Color surfaceContainerHigh = Color(0xFFE4E9EA);

  // ── On-surface ─────────────────────────────────────────────────────────────
  static const Color onSurface = Color(0xFF2D3435);
  static const Color onSurfaceVariant = Color(0xFF5A6061);
  static const Color outlineVariant = Color(0xFFADB3B4);

  // ── Stone (sidebar + dark card) ────────────────────────────────────────────
  static const Color stone50 = Color(0xFFFAFAF9);
  static const Color stone100 = Color(0xFFF5F5F4);
  static const Color stone200 = Color(0xFFE7E5E4);
  static const Color stone400 = Color(0xFFA8A29E);
  static const Color stone500 = Color(0xFF78716C);
  static const Color stone900 = Color(0xFF1C1917);

  // ── Brand accent ───────────────────────────────────────────────────────────
  /// The `text-[#2d2514]` class used throughout the HTML for headings.
  static const Color deepBrown = Color(0xFF2D2514);
  static const Color error = Color(0xFF9E422C);
}

/// Convenience: return a [TextStyle] using Manrope from google_fonts.
/// Pass any standard [TextStyle] named parameters — this is purely a shorthand
/// so call-sites stay readable without repeating fontFamily everywhere.
TextStyle manrope({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? letterSpacing,
  double? height,
  TextDecoration? decoration,
  Color? decorationColor,
}) =>
    GoogleFonts.manrope(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
    );
