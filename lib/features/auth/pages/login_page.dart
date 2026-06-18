import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'role_selection_page.dart';
import '../../doctor/pages/doctor_main_page.dart';
import '../../patient/pages/patient_main_page.dart';
import '../../family/pages/family_main_page.dart';
import 'forgot_password_page.dart';
import '../../../data/services/api_service.dart';
import 'email_verification_page.dart';
import 'admin_verification_waiting_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isFormValid = false;
  bool isLoading = false;

  bool showPendingVerification = false;
  bool showLoginError = false;

  String loginErrorTitle = '';
  String loginErrorMessage = '';

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
      showLoginError = false;
      showPendingVerification = false;
    });

    try {
      final result = await ApiService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final roleId = result['user']['role_id'];

      if (!mounted) return;

      if (roleId == 2) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DoctorMainPage()),
        );
      } else if (roleId == 3) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PatientMainPage()),
        );
      } else if (roleId == 4) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FamilyMainPage()),
        );
      } else {
        _showStyledSnackBar(message: 'Role pengguna tidak dikenali');
      }
    } catch (e) {
      if (!mounted) return;

      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      final email = emailController.text.trim();

      final parts = errorMessage.split('|');
      final status = parts.first;
      final message = parts.length > 1 ? parts[1] : errorMessage;
      final lockedUntil = parts.length > 2 ? parts[2] : '';

      if (status == 'email_unverified') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EmailVerificationPage(email: email),
          ),
        );
        return;
      }

      if (status == 'admin_unverified') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AdminVerificationWaitingPage(),
          ),
        );
        return;
      }

      if (status == 'invalid_credentials') {
        setState(() {
          showLoginError = true;
          showPendingVerification = false;
          loginErrorTitle = 'Email atau kata sandi salah.';
          loginErrorMessage =
              'Akun dapat dikunci sementara setelah beberapa kali percobaan gagal.';
        });
        return;
      }

      if (status == 'account_locked') {
        final lockedDate = DateTime.tryParse(lockedUntil);
        String timeMessage = message;

        if (lockedDate != null) {
          final diff = lockedDate.difference(DateTime.now());
          final minutes = diff.inMinutes <= 0 ? 1 : diff.inMinutes;

          timeMessage = 'Coba lagi dalam $minutes menit.';
        }

        setState(() {
          showLoginError = true;
          showPendingVerification = false;
          loginErrorTitle = 'Akun dikunci sementara.';
          loginErrorMessage = timeMessage;
        });
        return;
      }

      if (status == 'admin_rejected') {
        setState(() {
          showLoginError = true;
          showPendingVerification = false;
          loginErrorTitle = 'Registrasi dokter ditolak.';
          loginErrorMessage = message;
        });
        return;
      }

      _showStyledSnackBar(message: message);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      isFormValid =
          emailController.text.trim().isNotEmpty &&
          passwordController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Selamat Datang',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark1,
                  ),
                ),
              ),
              const Center(
                child: Text(
                  'Masuk Akun',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Center(child: Image.asset('assets/images/logo.png', width: 210)),

              const SizedBox(height: 34),

              if (showPendingVerification) ...[
                _infoBox(
                  icon: Icons.access_time,
                  title: 'Akun menunggu verifikasi admin',
                  message:
                      'Akun sedang dalam proses verifikasi admin (1–2 hari kerja). Anda akan menerima notifikasi email setelah disetujui.',
                  color: AppColors.primaryBlue,
                  bgColor: AppColors.veryLightBlue,
                ),
                const SizedBox(height: 18),
              ],

              if (showLoginError) ...[
                _infoBox(
                  icon: Icons.info_outline,
                  title: loginErrorTitle,
                  message: loginErrorMessage,
                  color: AppColors.red,
                  bgColor: AppColors.lightRed,
                ),
                const SizedBox(height: 18),
              ],

              const Text(
                'Email',
                style: TextStyle(
                  color: AppColors.dark2,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: emailController,
                decoration: _inputDecoration(hint: 'Email atau phone'),
              ),

              const SizedBox(height: 18),

              const Text(
                'Password',
                style: TextStyle(
                  color: AppColors.dark2,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: _inputDecoration(
                  hint: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordPage(),
                      ),
                    );
                  },
                  child: const Text('Lupa kata sandi?'),
                ),
              ),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isFormValid && !isLoading ? _handleLogin : null,
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
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Masuk',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              const Row(
                children: [
                  Expanded(child: Divider(color: AppColors.dark2)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'atau',
                      style: TextStyle(color: AppColors.dark1),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.dark2)),
                ],
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RoleSelectionPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Daftar Akun Baru',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 34),

              Center(
                child: RichText(
                  text: const TextSpan(
                    text: 'Butuh bantuan? ',
                    style: TextStyle(color: AppColors.dark1, fontSize: 13),
                    children: [
                      TextSpan(
                        text: 'Hubungi admin',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    bool error = false,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.dark4, fontSize: 14),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: error ? AppColors.red : AppColors.light1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(
          color: error ? AppColors.red : AppColors.primaryBlue,
          width: 1.4,
        ),
      ),
    );
  }

  Widget _infoBox({
    required IconData icon,
    required String title,
    required String message,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: title,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  TextSpan(
                    text: '\n$message',
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStyledSnackBar({
    required String message,
    Color backgroundColor = AppColors.red,
    IconData icon = Icons.info_outline,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
