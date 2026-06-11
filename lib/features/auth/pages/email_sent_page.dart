import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'login_page.dart';

class EmailSentPage extends StatelessWidget {
  const EmailSentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: AppColors.dark2),
                ),
              ),
              const SizedBox(height: 90),
              const Icon(
                Icons.mark_email_read_outlined,
                size: 68,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(height: 18),
              const Text(
                'Email Terkirim',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Kami telah mengirimkan tautan atur ulang kata sandi ke email terdaftar.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.dark2,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 22),
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Kembali ke Login',
                  style: TextStyle(color: AppColors.primaryBlue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}