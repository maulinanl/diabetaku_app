import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'role_selection_page.dart';
import '../../doctor/pages/doctor_main_page.dart';
import '../../patient/pages/patient_main_page.dart';
import '../../family/pages/family_main_page.dart';
import 'forgot_password_page.dart';
import '../../../data/services/api_service.dart';

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

  Future<void> _handleLogin() async {
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Role pengguna tidak dikenali')),
        );
      }
    } catch (e) {
      if (!mounted) return;

      final errorMessage = e.toString().replaceFirst('Exception: ', '');

      setState(() {
        if (errorMessage.contains('menunggu verifikasi') ||
            errorMessage.contains('belum aktif')) {
          showPendingVerification = true;
          showLoginError = false;
        } else {
          showLoginError = true;
          showPendingVerification = false;
        }
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
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
                  title: 'Email atau kata sandi salah.',
                  message:
                      'Percobaan ke-3 dari 5. Akun dikunci 30 menit setelah 5 kali gagal.',
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
}
