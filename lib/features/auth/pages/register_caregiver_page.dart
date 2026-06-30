import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';
import '../../auth/pages/email_verification_page.dart';

class RegisterCaregiverPage extends StatefulWidget {
  const RegisterCaregiverPage({super.key});

  @override
  State<RegisterCaregiverPage> createState() => _RegisterCaregiverPageState();
}

class _RegisterCaregiverPageState extends State<RegisterCaregiverPage> {
  final nameCtr = TextEditingController();
  final emailCtr = TextEditingController();
  final phoneCtr = TextEditingController();
  final passwordCtr = TextEditingController();
  final confirmPasswordCtr = TextEditingController();

  String? gender;

  bool obscurePassword = true;
  bool obscureConfirm = true;
  bool isRegistering = false;

  bool get isValid {
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    final phoneRegex = RegExp(r'^[0-9]+$');
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');

    return nameCtr.text.trim().isNotEmpty &&
        emailRegex.hasMatch(emailCtr.text.trim()) &&
        phoneRegex.hasMatch(phoneCtr.text.trim()) &&
        phoneCtr.text.trim().length >= 10 &&
        gender != null &&
        passwordRegex.hasMatch(passwordCtr.text) &&
        confirmPasswordCtr.text == passwordCtr.text;
  }

  String? get emailError {
    final email = emailCtr.text.trim();
    if (email.isEmpty) return null;

    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!emailRegex.hasMatch(email)) return 'Format email tidak valid';

    return null;
  }

  String? get phoneError {
    final phone = phoneCtr.text.trim();
    if (phone.isEmpty) return null;
    if (phone.length < 10) return 'Nomor telepon terlalu pendek';
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

  Future<void> _registerCaregiver() async {
    FocusScope.of(context).unfocus();
    setState(() => isRegistering = true);

    try {
      await ApiService.registerCaregiver(
        fullName: nameCtr.text.trim(),
        email: emailCtr.text.trim(),
        phoneNumber: phoneCtr.text.trim(),
        password: passwordCtr.text.trim(),
        confirmPassword: confirmPasswordCtr.text.trim(),
        gender: gender!,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EmailVerificationPage(
            email: emailCtr.text.trim(),
            roleType: VerificationRoleType.caregiver,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      _showStyledSnackBar(
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => isRegistering = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 18, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context),
              const SizedBox(height: 26),

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
              _selectField(
                label: 'Jenis Kelamin',
                hint: 'Jenis Kelamin',
                value: gender,
                items: const ['Laki-laki', 'Perempuan'],
                onSelected: (v) => setState(() => gender = v),
              ),
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
                  onPressed: isValid && !isRegistering ? _registerCaregiver : null,
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
                  child: isRegistering
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Daftar',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.dark2),
        ),
        const Expanded(
          child: Text(
            'Daftar sebagai pendamping',
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
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.dark4, fontSize: 13),
        suffixIcon: suffixIcon,
        errorText: errorText,
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
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _selectField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        InkWell(
          onTap: () => _showOptionSheet(
            title: label,
            items: items,
            selectedValue: value,
            onSelected: onSelected,
          ),
          child: InputDecorator(
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
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
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? hint,
                    style: TextStyle(
                      color: value == null ? AppColors.dark4 : AppColors.dark1,
                      fontSize: 13,
                    ),
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
        ),
      ],
    );
  }

  void _showOptionSheet({
    required String title,
    required List<String> items,
    required String? selectedValue,
    required ValueChanged<String> onSelected,
  }) {
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
              Text(
                'Pilih $title',
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...items.map((item) {
                final selected = item == selectedValue;

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
                    onSelected(item);
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
