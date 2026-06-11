import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'register_doctor_step2_page.dart';

class RegisterDoctorStep1Page extends StatefulWidget {
  const RegisterDoctorStep1Page({super.key});

  @override
  State<RegisterDoctorStep1Page> createState() =>
      _RegisterDoctorStep1PageState();
}

class _RegisterDoctorStep1PageState extends State<RegisterDoctorStep1Page> {
  final nameCtr = TextEditingController();
  final emailCtr = TextEditingController();
  final phoneCtr = TextEditingController();
  final passwordCtr = TextEditingController();
  final confirmPasswordCtr = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirm = true;

  bool get isValid =>
    nameCtr.text.trim().isNotEmpty &&
    emailCtr.text.trim().isNotEmpty &&
    phoneCtr.text.trim().isNotEmpty &&
    passwordCtr.text.length >= 8 &&
    confirmPasswordCtr.text == passwordCtr.text &&
    confirmPasswordCtr.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    for (final c in [
      nameCtr,
      emailCtr,
      phoneCtr,
      passwordCtr,
      confirmPasswordCtr,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    nameCtr.dispose();
    emailCtr.dispose();
    phoneCtr.dispose();
    passwordCtr.dispose();
    confirmPasswordCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 18, 28, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Nama Lengkap'),
                    _input(nameCtr, 'Masukkan nama lengkapmu'),

                    _label('Email'),
                    _input(
                      emailCtr,
                      'Masukkan alamat emailmu',
                      keyboardType: TextInputType.emailAddress,
                    ),

                    _label('Nomor Telepon'),
                    _input(
                      phoneCtr,
                      'Masukkan nomor telepon (62xx)',
                      keyboardType: TextInputType.phone,
                    ),

                    _label('Kata Sandi'),
                    _input(
                      passwordCtr,
                      'Masukkan kata sandi (8+ karakter)',
                      obscure: obscurePassword,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() => obscurePassword = !obscurePassword);
                        },
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.dark2,
                        ),
                      ),
                    ),

                    _label('Konfirmasi Kata Sandi'),
                    _input(
                      confirmPasswordCtr,
                      'Konfirmasi kata sandi (8+ karakter)',
                      obscure: obscureConfirm,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() => obscureConfirm = !obscureConfirm);
                        },
                        icon: Icon(
                          obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.dark2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isValid
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const RegisterDoctorStep2Page(),
                                  ),
                                );
                              }
                            : null,
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
                        child: const Text(
                          'Lanjut',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: AppColors.dark2),
              ),
              const Expanded(
                child: Text(
                  'Daftar sebagai Dokter',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 18),
          _stepIndicator(currentStep: 1),
          const SizedBox(height: 18),
          const Text(
            'Lengkapi data untuk membuat akun',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.dark2, fontSize: 13),
          ),
          const SizedBox(height: 4),
          const Text(
            'Langkah 1 dari 2 - Data Diri',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.dark2, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _stepIndicator({required int currentStep}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 4,
          decoration: BoxDecoration(
            color: currentStep == 1 ? AppColors.primaryBlue : AppColors.light1,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 44,
          height: 4,
          decoration: BoxDecoration(
            color: currentStep == 2 ? AppColors.primaryBlue : AppColors.light1,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 12),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.dark2,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController controller,
    String hint, {
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.dark4, fontSize: 13),
        suffixIcon: suffixIcon,
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
    );
  }
}
