import 'package:flutter/material.dart';

// ACCESSIBILITY NOTES:
// • This app targets elderly users. ALL text is minimum 18sp, so WCAG "large
//   text" rules apply (3:1 for AA, 4.5:1 for AAA).
// • amarelo and verde must NEVER be used as text color on white — background
//   fills, icons, and badges only.
// • coral can have white text ON a coral background, but coral text on white
//   is only AA for large text (3.98:1).
// • When in doubt, always pair text with textPrimary or textSecondary.
//   Both pass AAA on all app backgrounds.

abstract class AppColors {
  // ─── Brand ────────────────────────────────────────────────────────────────

  /// Primary brand color (10.6:1 on white ✅ AAA)
  static const Color azulPolie = Color(0xFF2D3782);

  /// Accent — NEVER use as text on white (1.55:1). Only for backgrounds, icons, badges.
  static const Color amarelo = Color(0xFFFFC800);

  /// Accent — only use with white text ON coral bg (3.98:1 ✅ AA large text).
  /// Do NOT use coral as text color on white.
  static const Color coral = Color(0xFFE64628);

  /// Accent — NEVER use as text on white (2.7:1). Only for icons, badges, success indicators.
  static const Color verde = Color(0xFF32B450);

  // ─── Background ───────────────────────────────────────────────────────────

  static const Color bgPrimary = Color(0xFFFFFFFF);
  static const Color bgSurface = Color(0xFFF4F5FB);
  static const Color bgSurfaceAlt = Color(0xFFECEEF8);

  // ─── Text ─────────────────────────────────────────────────────────────────

  /// Main text (15.6:1 on white ✅ AAA)
  static const Color textPrimary = Color(0xFF1A1F4B);

  /// Secondary text (5.67:1 on white ✅ AA)
  static const Color textSecondary = Color(0xFF4A5587);

  /// Hint / placeholder (4.48:1 on white — OK for 18sp+ fonts ✅ AA large)
  static const Color textHint = Color(0xFF6B74A8);

  // ─── Button ───────────────────────────────────────────────────────────────

  static const Color btnPrimaryBg = Color(0xFF2D3782);

  /// (10.6:1 ✅ AAA)
  static const Color btnPrimaryText = Color(0xFFFFFFFF);

  static const Color btnSecondaryBg = Color(0xFFFFC800);

  /// (10.07:1 ✅ AAA)
  static const Color btnSecondaryText = Color(0xFF1A1F4B);

  static const Color btnGhostBg = Color(0xFFECEEF8);

  /// (9.17:1 ✅ AAA)
  static const Color btnGhostText = Color(0xFF2D3782);

  // ─── Feedback ─────────────────────────────────────────────────────────────

  static const Color success = Color(0xFF1E7A32);

  /// (5.41:1 ✅ AA)
  static const Color successText = Color(0xFFFFFFFF);

  static const Color warning = Color(0xFFFFC800);

  /// (10.07:1 ✅ AAA)
  static const Color warningText = Color(0xFF1A1F4B);

  static const Color error = Color(0xFFC23A1E);

  /// (5.36:1 ✅ AA)
  static const Color errorText = Color(0xFFFFFFFF);

  /// CHANGED from #9EA5CC for better contrast
  static const Color disabled = Color(0xFFB8BDD8);

  /// CHANGED from #5C6494 for better contrast (3.5:1 ✅ AA large)
  static const Color disabledText = Color(0xFF4A5180);
}
