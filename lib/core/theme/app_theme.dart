import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: const Color(0xFFF8FBFF),

    textTheme: GoogleFonts.plusJakartaSansTextTheme(),

    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFF8FBFF),
    ),
  );
}