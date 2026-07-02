import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'login_page.dart';
import 'package:diabetaku_app/core/theme/app_button_styles.dart';

class AdminVerificationWaitingPage extends StatelessWidget {
  const AdminVerificationWaitingPage({super.key});

  void _goToLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  ButtonStyle _buttonStyle() {
    return AppButtonStyles.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  46,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => _goToLogin(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.dark3,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Icon(
                  Icons.description_outlined,
                  size: 82,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(height: 22),
                const Text(
                  'Menunggu Verifikasi Admin',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Email Anda telah terverifikasi.\n'
                  'Akun sedang dalam proses verifikasi admin.\n'
                  'Proses ini memerlukan 1–2 hari kerja.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.dark2,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
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
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _goToLogin(context),
                    style: _buttonStyle(),
                    child: const Text(
                      'Kembali ke Login',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone ? AppColors.primaryBlue : AppColors.veryLightBlue,
              border: Border.all(color: AppColors.primaryBlue),
            ),
            child: Icon(
              isDone ? Icons.check : Icons.access_time,
              color: isDone ? Colors.white : AppColors.primaryBlue,
              size: 19,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.dark1,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
