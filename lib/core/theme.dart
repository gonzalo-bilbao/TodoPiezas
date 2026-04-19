import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary    = Color(0xFFE85D04);
  static const Color primaryEnd = Color(0xFFF48C06);
  static const Color secondary  = Color(0xFF1A1A2E);
  static const Color background = Color(0xFFF5F5F5);

  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [primary, primaryEnd],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  static ThemeData get theme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
          secondary: secondary,
        ),
        textTheme: GoogleFonts.interTextTheme().copyWith(
          displayLarge:  GoogleFonts.exo2(fontSize: 32, fontWeight: FontWeight.bold,   color: secondary),
          headlineLarge: GoogleFonts.exo2(fontSize: 24, fontWeight: FontWeight.bold,   color: secondary),
          headlineMedium:GoogleFonts.exo2(fontSize: 20, fontWeight: FontWeight.bold,   color: secondary),
          titleLarge:    GoogleFonts.exo2(fontSize: 18, fontWeight: FontWeight.w600,   color: secondary),
          titleMedium:   GoogleFonts.exo2(fontSize: 16, fontWeight: FontWeight.w600,   color: secondary),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: secondary,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.exo2(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            textStyle: GoogleFonts.exo2(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          color: Colors.white,
        ),
        scaffoldBackgroundColor: background,
        useMaterial3: true,
      );

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
          primary: primary,
          secondary: primaryEnd,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
          displayLarge:  GoogleFonts.exo2(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          headlineLarge: GoogleFonts.exo2(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          headlineMedium:GoogleFonts.exo2(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          titleLarge:    GoogleFonts.exo2(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          titleMedium:   GoogleFonts.exo2(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF0F0F1A),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.exo2(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            textStyle: GoogleFonts.exo2(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
          filled: true,
          fillColor: const Color(0xFF1E1E2E),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          color: Color(0xFF1E1E2E),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        useMaterial3: true,
      );
}
