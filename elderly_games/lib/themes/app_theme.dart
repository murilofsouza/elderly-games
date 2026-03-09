import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTheme {
  // ── Brand Colors ─────────────────────────────────────────────────────────────
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF60AD5E);
  static const Color secondaryColor = Color(0xFFF9A825);
  static const Color backgroundColor = Color(0xFFFFF8E1);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF616161);
  static const Color pointsColor = Color(0xFFFF8F00);

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
      bodySmall: GoogleFonts.nunito(
        fontSize: fontSmall,
        color: textPrimary,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: fontBody,
        color: textPrimary,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: fontBody,
        color: textPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.nunito(
        fontSize: fontTitle,
        color: textPrimary,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: GoogleFonts.nunito(
        fontSize: fontTitle,
        color: textPrimary,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: GoogleFonts.nunito(
        fontSize: fontHeading,
        color: textPrimary,
        fontWeight: FontWeight.w800,
      ),
      headlineLarge: GoogleFonts.nunito(
        fontSize: fontHero,
        color: textPrimary,
        fontWeight: FontWeight.w900,
      ),
      labelLarge: GoogleFonts.nunito(
        fontSize: fontBody,
        color: surfaceColor,
        fontWeight: FontWeight.w700,
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
          fontSize: fontTitle,
          color: surfaceColor,
          fontWeight: FontWeight.w800,
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
            fontSize: fontBody,
            fontWeight: FontWeight.w700,
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
            fontSize: fontBody,
            fontWeight: FontWeight.w700,
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
            fontSize: fontBody,
            fontWeight: FontWeight.w700,
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
          fontSize: fontBody,
          color: textSecondary,
        ),
        hintStyle: GoogleFonts.nunito(
          fontSize: fontBody,
          color: textSecondary,
        ),
      ),

      // ── Bottom Navigation ───────────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        selectedLabelStyle: GoogleFonts.nunito(
          fontSize: fontSmall,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.nunito(
          fontSize: fontSmall,
          fontWeight: FontWeight.w600,
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
