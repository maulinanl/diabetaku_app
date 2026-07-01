import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'email_sent_page.dart';
import '../../../data/services/api_service.dart';
import 'login_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();

  bool get isValid => emailController.text.trim().isNotEmpty;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    emailController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
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
                    const SizedBox(height: 40),
                    const Icon(
                      Icons.lock_outline,
                      size: 64,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Lupa Kata Sandi',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Masukkan email yang terdaftar untuk mengatur ulang kata sandi.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.dark2, fontSize: 13),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        if (isValid && !isLoading) {
                          _sendResetEmail();
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Masukkan alamat emailmu',
                        hintStyle: const TextStyle(
                          color: AppColors.dark4,
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: AppColors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 15,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppColors.light1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: AppColors.primaryBlue,
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed:
                            isValid && !isLoading ? _sendResetEmail : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          disabledBackgroundColor: const Color(0xFFAFCBEA),
                          disabledForegroundColor: AppColors.white,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Kirim',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Ingat kata sandi? ',
                          style: TextStyle(
                            color: AppColors.dark2,
                            fontSize: 13,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            FocusScope.of(context).unfocus();
                            await Future.delayed(
                              const Duration(milliseconds: 80),
                            );
                            if (!mounted) return;
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                              (route) => false,
                            );
                          },
                          child: const Text(
                            'Masuk',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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

  Future<void> _sendResetEmail() async {
    FocusScope.of(context).unfocus();
    setState(() => isLoading = true);

    try {
      await ApiService.forgotPassword(email: emailController.text.trim());

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const EmailSentPage()),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
}
