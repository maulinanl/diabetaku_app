import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'register_doctor_step2_page.dart';
import 'package:flutter/services.dart';
import '../../../data/services/api_service.dart';
import 'package:diabetaku_app/core/theme/app_button_styles.dart';
import '../../../core/widgets/app_option_bottom_sheet.dart';

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
  bool isCheckingEmail = false;

  String gender = 'Laki-laki';

  bool get isValid {
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    final phoneRegex = RegExp(r'^[0-9]+$');
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');

    return nameCtr.text.trim().isNotEmpty &&
        emailRegex.hasMatch(emailCtr.text.trim()) &&
        phoneRegex.hasMatch(phoneCtr.text.trim()) &&
        passwordRegex.hasMatch(passwordCtr.text) &&
        confirmPasswordCtr.text == passwordCtr.text;
  }

  String? get emailError {
    final email = emailCtr.text.trim();

    if (email.isEmpty) return null;

    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');

    if (!emailRegex.hasMatch(email)) {
      return 'Format email tidak valid';
    }

    return null;
  }

  String? get phoneError {
    final phone = phoneCtr.text.trim();

    if (phone.isEmpty) return null;

    if (phone.length < 10) {
      return 'Nomor telepon terlalu pendek';
    }

    return null;
  }

  String? get passwordError {
    final password = passwordCtr.text;

    if (password.isEmpty) return null;
    if (password.length < 8) return 'Minimal 8 karakter';
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(password)) {
      return 'Gunakan kombinasi huruf dan angka';
    }

    return null;
  }

  String? get confirmPasswordError {
    if (confirmPasswordCtr.text.isEmpty) return null;
    if (confirmPasswordCtr.text != passwordCtr.text) {
      return 'Konfirmasi kata sandi belum sama';
    }

    return null;
  }

  @override
  void initState() {
    super.initState();

    for (final controller in [
      nameCtr,
      emailCtr,
      phoneCtr,
      passwordCtr,
      confirmPasswordCtr,
    ]) {
      controller.addListener(() => setState(() {}));
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

  Future<void> _goToStep2() async {
    setState(() => isCheckingEmail = true);

    try {
      final emailExists = await ApiService.checkEmailExists(
        emailCtr.text.trim(),
      );

      if (!mounted) return;

      setState(() => isCheckingEmail = false);

      if (emailExists) {
        _showSnackBar('Email sudah terdaftar. Gunakan email lain.');
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RegisterDoctorStep2Page(
            fullName: nameCtr.text.trim(),
            email: emailCtr.text.trim(),
            phoneNumber: phoneCtr.text.trim(),
            password: passwordCtr.text.trim(),
            confirmPassword: confirmPasswordCtr.text.trim(),
            gender: gender,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => isCheckingEmail = false);

      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
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
                      errorText: emailError,
                    ),

                    _label('Nomor Telepon'),
                    _input(
                      phoneCtr,
                      'Masukkan nomor telepon',
                      keyboardType: TextInputType.phone,
                      errorText: phoneError,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),

                    _label('Jenis Kelamin'),
                    _genderSelector(),

                    _label('Kata Sandi'),
                    _input(
                      passwordCtr,
                      'Minimal 8 karakter, huruf dan angka',
                      obscure: obscurePassword,
                      errorText: passwordError,
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
                      'Ulangi kata sandi',
                      obscure: obscureConfirm,
                      errorText: confirmPasswordError,
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
                        onPressed: isValid && !isCheckingEmail
                            ? _goToStep2
                            : null,
                        style: AppButtonStyles.primary,
                        child: isCheckingEmail
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
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

  Widget _genderSelector() {
    return InkWell(
      onTap: _showGenderSheet,
      borderRadius: BorderRadius.circular(6),
      child: InputDecorator(
        decoration: _inputDecoration(),
        child: Row(
          children: [
            Expanded(
              child: Text(
                gender,
                style: const TextStyle(color: AppColors.dark1, fontSize: 13),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.dark3,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  void _showGenderSheet() {
    const options = ['Laki-laki', 'Perempuan'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return AppOptionBottomSheet<String>(
          title: 'Pilih Jenis Kelamin',
          icon: Icons.wc_outlined,
          items: options,
          labelBuilder: (item) => item,
          isSelected: (item) => item == gender,
          onSelected: (item) {
            setState(() => gender = item);
            Navigator.pop(sheetContext);
          },
        );
      },
    );
  }

  String? get passwordHelperText {
    final password = passwordCtr.text;

    if (password.isEmpty) return null;
    if (password.length < 8) return 'Minimal 8 karakter';
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(password)) {
      return 'Gunakan kombinasi huruf dan angka';
    }

    return null;
  }

  String? get confirmPasswordHelperText {
    final confirmPassword = confirmPasswordCtr.text;

    if (confirmPassword.isEmpty) return null;
    if (confirmPassword != passwordCtr.text) {
      return 'Konfirmasi kata sandi belum sama';
    }

    return null;
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
    String? errorText,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: _inputDecoration(
        hint: hint,
        suffixIcon: suffixIcon,
        errorText: errorText,
      ),
    );
  }

  InputDecoration _inputDecoration({
    String? hint,
    Widget? suffixIcon,
    String? errorText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.dark4, fontSize: 13),
      suffixIcon: suffixIcon,
      errorText: errorText,
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.light1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.red, width: 1.4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.4),
      ),
    );
  }
}
