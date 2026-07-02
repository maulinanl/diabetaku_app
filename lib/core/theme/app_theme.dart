import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_button_styles.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    // Kunci font utama aplikasi
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(),

    scaffoldBackgroundColor: AppColors.background,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryBlue,
      brightness: Brightness.light,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.dark1,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.dark1,
      ),
    ),



    elevatedButtonTheme: ElevatedButtonThemeData(
      style: AppButtonStyles.primary,
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: AppButtonStyles.outlined,
    ),

    textButtonTheme: TextButtonThemeData(
      style: AppButtonStyles.text,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.dark2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.dark2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.primaryBlue,
          width: 1.5,
        ),
      ),
    ),
  );
}