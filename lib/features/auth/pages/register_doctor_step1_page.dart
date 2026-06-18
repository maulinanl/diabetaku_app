import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'register_doctor_step2_page.dart';
import 'package:flutter/services.dart';

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

  void _goToStep2() {
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
                        onPressed: isValid ? _goToStep2 : null,
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

  Widget _genderSelector() {
    return InkWell(
      onTap: _showGenderSheet,
      child: InputDecorator(
        decoration: _inputDecoration(),
        child: Text(
          gender,
          style: const TextStyle(color: AppColors.dark1, fontSize: 13),
        ),
      ),
    );
  }

  void _showGenderSheet() {
    const options = ['Laki-laki', 'Perempuan'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.light1,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Pilih Jenis Kelamin',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...options.map((item) {
                final selected = item == gender;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    item,
                    style: TextStyle(
                      color: selected ? AppColors.primaryBlue : AppColors.dark1,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  trailing: selected
                      ? const Icon(Icons.check, color: AppColors.primaryBlue)
                      : null,
                  onTap: () {
                    setState(() => gender = item);
                    Navigator.pop(sheetContext);
                  },
                );
              }),
            ],
          ),
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
