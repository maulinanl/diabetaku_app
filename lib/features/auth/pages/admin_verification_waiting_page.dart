import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'login_page.dart';

class AdminVerificationWaitingPage extends StatelessWidget {
  const AdminVerificationWaitingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.description_outlined,
                size: 80,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(height: 20),
              const Text(
                'Menunggu Verifikasi Admin',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Email Anda telah terverifikasi. Akun sedang dalam proses verifikasi admin.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.dark2),
              ),
              const SizedBox(height: 20),

              const _VerificationStep(
                text: 'Registrasi berhasil',
                isDone: true,
              ),
              const _VerificationStep(
                text: 'Email Terverifikasi',
                isDone: true,
              ),
              const _VerificationStep(
                text: 'Menunggu Verifikasi Admin',
                isDone: false,
              ),

              const SizedBox(height: 24),

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
                child: const Text('Kembali ke Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerificationStep extends StatelessWidget {
  final String text;
  final bool isDone;

  const _VerificationStep({
    required this.text,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        isDone ? Icons.check_circle : Icons.radio_button_checked,
        color: AppColors.primaryBlue,
      ),
      title: Text(text),
      contentPadding: EdgeInsets.zero,
    );
  }
}