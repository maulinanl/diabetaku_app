import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import 'admin_verification_waiting_page.dart';

class EmailVerificationPage extends StatelessWidget {
  const EmailVerificationPage({super.key});

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
                Icons.mark_email_read_outlined,
                size: 80,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(height: 20),
              const Text(
                'Verifikasi Email Anda',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Kami telah mengirimkan tautan verifikasi ke alamat email Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.dark2),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.veryLightBlue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Center(
                  child: Text(
                    'guest@diabetaku.com',
                    style: TextStyle(color: AppColors.primaryBlue),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const _VerificationStep(
                text: 'Registrasi berhasil',
                isDone: true,
              ),
              const _VerificationStep(
                text: 'Email Terverifikasi',
                isDone: false,
              ),
              const _VerificationStep(
                text: 'Menunggu Verifikasi Admin',
                isDone: false,
              ),

              const SizedBox(height: 24),

              CustomButton(
                text: 'Kirim Ulang Email Verifikasi',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminVerificationWaitingPage(),
                    ),
                  );
                },
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