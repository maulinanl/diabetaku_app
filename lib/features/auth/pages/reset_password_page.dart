import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'login_page.dart';
import '../../../data/services/api_service.dart';
import 'package:diabetaku_app/core/theme/app_button_styles.dart';

class ResetPasswordPage extends StatefulWidget {
  final String token;
  final String email;

  const ResetPasswordPage({
    super.key,
    required this.token,
    required this.email,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirm = true;
  bool isLoading = false;

  bool get isValid =>
      passwordController.text.trim().length >= 8 &&
      confirmController.text.trim() == passwordController.text.trim();

  @override
  void initState() {
    super.initState();
    passwordController.addListener(() => setState(() {}));
    confirmController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: Color(0xFFEAFBF3),
                child: Icon(
                  Icons.lock_reset,
                  color: Color(0xFF10C878),
                  size: 36,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Kata Sandi Berhasil Diubah!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Kata sandi Anda telah berhasil diperbarui. Silakan gunakan kata sandi baru untuk masuk ke akun Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.dark2, fontSize: 13),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  },
                  style: AppButtonStyles.primary,
                  child: const Text('Masuk'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(28, 12, 28, 24 + bottomInset),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.dark2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Atur Ulang Kata Sandi',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Masukkan kata sandi setidaknya 8 karakter',
                      style: TextStyle(color: AppColors.dark2, fontSize: 12),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(
                        label: 'Kata Sandi',
                        hint: 'Masukkan kata sandi baru',
                        obscure: obscurePassword,
                        onToggle: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: confirmController,
                      obscureText: obscureConfirm,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        if (isValid && !isLoading) {
                          _resetPassword();
                        }
                      },
                      decoration: _inputDecoration(
                        label: 'Konfirmasi Kata Sandi',
                        hint: 'Konfirmasi kata sandi',
                        obscure: obscureConfirm,
                        onToggle: () {
                          setState(() {
                            obscureConfirm = !obscureConfirm;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed:
                            isValid && !isLoading ? _resetPassword : null,
                        style: AppButtonStyles.primary,
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Atur Ulang Kata Sandi'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _resetPassword() async {
    FocusScope.of(context).unfocus();
    setState(() => isLoading = true);

    try {
      await ApiService.resetPassword(
        token: widget.token,
        email: widget.email,
        password: passwordController.text.trim(),
        passwordConfirmation: confirmController.text.trim(),
      );

      if (!mounted) return;

      _showSuccessSheet();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: AppColors.white,
      suffixIcon: IconButton(
        onPressed: onToggle,
        icon: Icon(
          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.dark2,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.light1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.light1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.primaryBlue),
      ),
    );
  }
}
