import 'package:diabetaku_app/features/auth/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_colors.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.primaryBlue,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  runApp(const DiabetAkuApp());
}

class DiabetAkuApp extends StatelessWidget {
  const DiabetAkuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'diabetAku',
      debugShowCheckedModeBanner: false,
      home: SplashPage(),
    );
  }
}
