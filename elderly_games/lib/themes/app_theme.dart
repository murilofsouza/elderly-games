import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_colors.dart';

abstract class AppTheme {
  // ── Brand Colors ─────────────────────────────────────────────────────────────
  static const Color primaryColor = AppColors.azulPolie;
  static const Color primaryLight = AppColors.verde;
  static const Color secondaryColor = AppColors.amarelo;
  static const Color backgroundColor = AppColors.bgSurface;
  static const Color surfaceColor = AppColors.bgPrimary;
  static const Color errorColor = AppColors.error;
  static const Color successColor = AppColors.success;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color pointsColor = AppColors.amarelo;

  // ── Font Sizes ────────────────────────────────────────────────────────────────
  static const double fontSmall = 18;
  static const double fontBody = 20;
  static const double fontTitle = 26;
  static const double fontHeading = 32;
  static const double fontHero = 48;

  // ── Touch / Layout ────────────────────────────────────────────────────────────
  static const double minTouchTarget = 56;
  static const double buttonHeight = 60;
  static const double cardBorderRadius = 20;
  static const double buttonBorderRadius = 16;
  static const double appBarHeight = 70;

  // ── ThemeData ─────────────────────────────────────────────────────────────────
  static ThemeData get themeData {
    final base = GoogleFonts.nunitoTextTheme().copyWith(
      // ── Display — Screen titles, hero text ──
      displayLarge: GoogleFonts.nunito(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: AppColors.textPrimary,
      ),
      // ── Display Small — Section headers ──
      displaySmall: GoogleFonts.nunito(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: AppColors.textPrimary,
      ),
      // ── Headline — Card titles, game names ──
      headlineMedium: GoogleFonts.nunito(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3, // 1.2 → 1.3 for better readability in cards
        color: AppColors.textPrimary,
      ),
      // ── Title Large — Sub-headers, important labels ──
      titleLarge: GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: AppColors.textPrimary,
      ),
      // ── Title Medium — Secondary titles ──
      titleMedium: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: AppColors.textPrimary,
      ),
      // ── Body Large — Main body text, descriptions ──
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.textPrimary,
      ),
      // ── Body Medium — Secondary text, subtitles ──
      bodyMedium: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w500, // w400 → w500 for readability at 14px
        height: 1.5,
        color: AppColors.textSecondary,
      ),
      // ── Label Large — Button text, primary actions ──
      labelLarge: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: AppColors.btnPrimaryText,
      ),
      // ── Label Medium — Tags, chips, badges ──
      labelMedium: GoogleFonts.nunito(
        fontSize: 14, // 13 → 14: minimum for elderly users
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: AppColors.textSecondary,
      ),
      // ── Label Small — Captions, timestamps (use sparingly) ──
      labelSmall: GoogleFonts.nunito(
        fontSize: 14, // 11 → 14: original was illegible for 60+ users
        fontWeight: FontWeight.w400,
        height: 1.5, // 1.8 → 1.5: normalized since size increased
        color: AppColors.textHint,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: surfaceColor,
        onSecondary: textPrimary,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: base,

      // ── AppBar ──────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: surfaceColor,
        elevation: 0,
        toolbarHeight: appBarHeight,
        centerTitle: false,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.5,
          color: AppColors.bgPrimary,
        ),
      ),

      // ── Elevated Button ─────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: surfaceColor,
          minimumSize: const Size(double.infinity, buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
          elevation: 3,
        ),
      ),

      // ── Outlined Button ─────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          minimumSize: const Size(double.infinity, buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          side: const BorderSide(color: primaryColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
        ),
      ),

      // ── Text Button ─────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          minimumSize: const Size(minTouchTarget, minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
        ),
      ),

      // ── Card ────────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 3,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardBorderRadius),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // ── Input ───────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonBorderRadius),
          borderSide: const BorderSide(color: primaryLight, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonBorderRadius),
          borderSide: const BorderSide(color: primaryLight, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonBorderRadius),
          borderSide: const BorderSide(color: primaryColor, width: 2.5),
        ),
        labelStyle: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: AppColors.textSecondary,
        ),
        hintStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.5,
          color: AppColors.textHint,
        ),
      ),

      // ── Bottom Navigation ───────────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        selectedLabelStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          height: 1.5,
        ),
        unselectedLabelStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.5,
        ),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // ── Icon ────────────────────────────────────────────────────────────────
      iconTheme: const IconThemeData(color: primaryColor, size: 28),
    );
  }
}
