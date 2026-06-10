import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/app_sizes.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final bool obscureText;
  final Widget? suffixIcon;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.dark2,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,

            suffixIcon: suffixIcon,

            filled: true,
            fillColor: AppColors.white,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppSizes.radius,
              ),
              borderSide: const BorderSide(
                color: AppColors.light2,
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppSizes.radius,
              ),
              borderSide: const BorderSide(
                color: AppColors.light2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}