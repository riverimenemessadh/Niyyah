// lib/core/theme.dart
//
// This is the single source of truth for all colors, text styles,
// and reusable decorations in the Niyyah app.
// Every screen imports this file instead of hardcoding colors or fonts.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────
class NiyyahColors {
  NiyyahColors._(); // private constructor — this class is never instantiated

  static const Color primary      = Color(0xFF1A7A6E);
  static const Color primaryDark  = Color(0xFF14584F);
  static const Color primaryLight = Color(0xFF7ECEC4);
  static const Color gold         = Color(0xFFD4A843);
  static const Color background   = Color(0xFFF7F5F2);
  static const Color surface      = Color(0xFFFFFFFF);
  static const Color textPrimary  = Color(0xFF1C1C1E);
  static const Color textSecondary= Color(0xFF6B6B6B);
  static const Color streak       = Color(0xFFE8943A);
  static const Color success      = Color(0xFF4CAF80);

  // Habit badge
  static const Color habitBadgeBg   = Color(0xFFE0F5F3);
  static const Color habitBadgeText = Color(0xFF1A7A6E);

  // Goal badge
  static const Color goalBadgeBg    = Color(0xFFFDF3DC);
  static const Color goalBadgeText  = Color(0xFFC4922A);
}

// ─────────────────────────────────────────────
// TEXT STYLES
// All text in the app uses Nunito.
// Arabic accent (app name on login only) uses Amiri.
// ─────────────────────────────────────────────
class NiyyahText {
  NiyyahText._();

  // Display — used for the large name on home screen header
  static TextStyle display = GoogleFonts.nunito(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: NiyyahColors.textPrimary,
  );

  // Heading — screen titles, card titles
  static TextStyle heading = GoogleFonts.nunito(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: NiyyahColors.textPrimary,
  );

  // Subheading — section labels like "TODAY'S HABITS"
  static TextStyle subheading = GoogleFonts.nunito(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: NiyyahColors.textSecondary,
  );

  // Body — regular readable text
  static TextStyle body = GoogleFonts.nunito(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: NiyyahColors.textPrimary,
  );

  // BodySecondary — muted supporting text
  static TextStyle bodySecondary = GoogleFonts.nunito(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: NiyyahColors.textSecondary,
  );

  // Button — used inside all action buttons
  static TextStyle button = GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: NiyyahColors.surface,
  );

  // Label — chip labels, badge text
  static TextStyle label = GoogleFonts.nunito(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: NiyyahColors.textPrimary,
  );

  // Arabic — only used for "نيّة" on login screen
  static TextStyle arabic = GoogleFonts.amiri(
    fontSize: 52,
    fontWeight: FontWeight.w700,
    color: NiyyahColors.gold,
  );
}

// ─────────────────────────────────────────────
// INPUT DECORATION
// Reusable field styling — call NiyyahTheme.inputDecoration('Label')
// in any form field instead of repeating the styling.
// ─────────────────────────────────────────────
class NiyyahTheme {
  NiyyahTheme._();

  static InputDecoration inputDecoration(String label, {Widget? prefixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.nunito(color: NiyyahColors.textSecondary),
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: const Color(0xFFF2F2F2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none, // no border by default
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: NiyyahColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  // Primary full-width button style
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: NiyyahColors.primaryDark,
    foregroundColor: NiyyahColors.surface,
    minimumSize: const Size(double.infinity, 52),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 0,
    textStyle: NiyyahText.button,
  );

  // The app-wide MaterialApp theme
  static ThemeData get themeData => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: NiyyahColors.primary),
    scaffoldBackgroundColor: NiyyahColors.background,
    fontFamily: GoogleFonts.nunito().fontFamily,
    useMaterial3: true,
  );
}

Widget categoryIcon(String category, Color color, {double size = 22}) {
  final Map<String, String> icons = {
    'Salah':   'assets/icons/salah.svg',
    'Quran':   'assets/icons/quran.svg',
    'Fasting': 'assets/icons/fasting.svg',
    'Dhikr':   'assets/icons/dhikr.svg',
    'Sadaqah': 'assets/icons/sadaqah.svg',
    'Sunnah':  'assets/icons/sunnah.svg',
    'Dua':     'assets/icons/dua.svg',
    'Tawbah':  'assets/icons/tawbah.svg',
    'Other':   'assets/icons/other.svg',
  };

  final path = icons[category] ?? 'assets/icons/other.svg';

  return SvgPicture.asset(
    path,
    width: size,
    height: size,
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
  );
}
