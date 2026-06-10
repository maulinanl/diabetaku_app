import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/app_sizes.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: isPrimary
              ? AppColors.primaryBlue
              : AppColors.lightBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppSizes.radius,
            ),
          ),
        ),
        child: Text(text),
      ),
    );
  }
}