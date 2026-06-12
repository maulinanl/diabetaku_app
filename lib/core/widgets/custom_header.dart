import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final bool showBack;
  final Widget? rightWidget;
  final double bottomPadding;

  const CustomHeader({
    super.key,
    required this.title,
    this.showBack = false,
    this.rightWidget,
    this.bottomPadding = 22,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, topPad + 14, 16, bottomPadding),
      color: AppColors.primaryBlue,
      child: Row(
        children: [
          if (showBack)
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            )
          else
            const SizedBox(width: 48),

          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          rightWidget ?? const SizedBox(width: 48),
        ],
      ),
    );
  }
}