import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppButtonStyles {
  static const double radius = 6;
  static const double height = 50;

  static TextStyle get _buttonText => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      );

  static ButtonStyle get primary => ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        disabledBackgroundColor: const Color(0xFFAFCBEA),
        disabledForegroundColor: AppColors.white,
        foregroundColor: AppColors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size(0, height),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        textStyle: _buttonText,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      );

  static ButtonStyle primaryWithColor(Color color) => ElevatedButton.styleFrom(
        backgroundColor: color,
        disabledBackgroundColor: const Color(0xFFAFCBEA),
        disabledForegroundColor: AppColors.white,
        foregroundColor: AppColors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size(0, height),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        textStyle: _buttonText,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      );

  static ButtonStyle get danger => ElevatedButton.styleFrom(
        backgroundColor: AppColors.red,
        disabledBackgroundColor: AppColors.lightRed,
        disabledForegroundColor: AppColors.red,
        foregroundColor: AppColors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size(0, height),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        textStyle: _buttonText,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      );

  static ButtonStyle get soft => ElevatedButton.styleFrom(
        backgroundColor: AppColors.veryLightBlue,
        disabledBackgroundColor: AppColors.light2,
        disabledForegroundColor: AppColors.dark3,
        foregroundColor: AppColors.primaryBlue,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size(0, height),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        textStyle: _buttonText,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      );

  static ButtonStyle get outlined => OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryBlue,
        disabledForegroundColor: AppColors.dark3,
        backgroundColor: AppColors.white,
        minimumSize: const Size(0, height),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        textStyle: _buttonText,
        side: const BorderSide(color: AppColors.primaryBlue, width: 1.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      );

  static ButtonStyle get outlinedDanger => OutlinedButton.styleFrom(
        foregroundColor: AppColors.red,
        disabledForegroundColor: AppColors.dark3,
        backgroundColor: AppColors.white,
        minimumSize: const Size(0, height),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        textStyle: _buttonText,
        side: const BorderSide(color: AppColors.red, width: 1.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      );

  static ButtonStyle get text => TextButton.styleFrom(
        foregroundColor: AppColors.primaryBlue,
        disabledForegroundColor: AppColors.dark3,
        textStyle: _buttonText,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}
