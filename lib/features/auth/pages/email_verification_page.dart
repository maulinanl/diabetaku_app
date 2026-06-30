import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';
import 'admin_verification_waiting_page.dart';
import 'login_page.dart';

enum VerificationRoleType { doctor, patient, caregiver }

class EmailVerificationPage extends StatefulWidget {
  final String email;
  final VerificationRoleType roleType;

  const EmailVerificationPage({
    super.key,
    required this.email,
    required this.roleType,
  });

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool isResending = false;
  bool isChecking = false;

  int remainingSeconds = 60;
  Timer? timer;

  bool get canResend => remainingSeconds == 0;

  bool get needsAdminVerification =>
      widget.roleType == VerificationRoleType.doctor;

  String get successMessage {
    switch (widget.roleType) {
      case VerificationRoleType.doctor:
        return 'Email berhasil diverifikasi. Menunggu verifikasi admin.';
      case VerificationRoleType.patient:
        return 'Email berhasil diverifikasi. Silakan login.';
      case VerificationRoleType.caregiver:
        return 'Email berhasil diverifikasi. Silakan login.';
    }
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (remainingSeconds <= 0) {
        timer.cancel();
        return;
      }

      setState(() {
        remainingSeconds--;
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _checkVerificationStatus() async {
    if (isChecking) return;

    setState(() => isChecking = true);

    try {
      final isVerified = await ApiService.checkEmailVerification(widget.email);

      if (!mounted) return;

      if (isVerified) {
        _showStyledSnackBar(message: successMessage, isError: false);

        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;

          if (needsAdminVerification) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminVerificationWaitingPage(),
              ),
            );
          } else {
            _goToLogin();
          }
        });
      } else {
        _showStyledSnackBar(
          message: 'Email belum terverifikasi. Silakan cek email Anda.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showStyledSnackBar(
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => isChecking = false);
      }
    }
  }

  Future<void> _resendEmail() async {
    if (!canResend || isResending) return;

    setState(() => isResending = true);

    try {
      await ApiService.resendVerificationEmail(widget.email);

      if (!mounted) return;

      _showStyledSnackBar(
        message: 'Email verifikasi berhasil dikirim ulang',
        isError: false,
      );

      setState(() {
        remainingSeconds = 60;
      });

      _startTimer();
    } catch (e) {
      if (!mounted) return;

      _showStyledSnackBar(
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => isResending = false);
      }
    }
  }

  void _goToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  ButtonStyle _buttonStyle({
    required Color backgroundColor,
    Color foregroundColor = Colors.white,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      disabledBackgroundColor: const Color(0xFFAFCBEA),
      disabledForegroundColor: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    );
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
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  46,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: _goToLogin,
                    icon: const Icon(Icons.arrow_back, color: AppColors.dark3),
                  ),
                ),

                const SizedBox(height: 40),

                const Icon(
                  Icons.mark_email_read_outlined,
                  size: 82,
                  color: AppColors.primaryBlue,
                ),

                const SizedBox(height: 22),

                const Text(
                  'Verifikasi Email Anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Kami telah mengirimkan tautan verifikasi ke alamat berikut.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.dark2,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Tautan berlaku selama 24 jam.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.dark2,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 18),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.veryLightBlue,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.lightBlue),
                  ),
                  child: Text(
                    widget.email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                ..._buildVerificationSteps(),

                const SizedBox(height: 26),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isChecking ? null : _checkVerificationStatus,
                    style: _buttonStyle(backgroundColor: AppColors.primaryBlue),
                    child: isChecking
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Saya Sudah Verifikasi Email',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: canResend && !isResending ? _resendEmail : null,
                    style: _buttonStyle(backgroundColor: AppColors.primaryBlue),
                    child: isResending
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            canResend
                                ? 'Kirim Ulang Email Verifikasi'
                                : 'Kirim ulang dalam ${remainingSeconds}s',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildVerificationSteps() {
    final steps = <Widget>[
      const _VerificationStep(text: 'Registrasi berhasil', isDone: true),
      const _VerificationStep(text: 'Email belum terverifikasi', isDone: false),
    ];

    if (widget.roleType == VerificationRoleType.doctor) {
      steps.add(
        const _VerificationStep(
          text: 'Menunggu verifikasi admin',
          isDone: false,
        ),
      );
    }

    return steps;
  }

  void _showStyledSnackBar({required String message, bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? AppColors.red : AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Row(
          children: [
            Icon(
              isError ? Icons.info_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationStep extends StatelessWidget {
  final String text;
  final bool isDone;

  const _VerificationStep({required this.text, required this.isDone});

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
