import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';
import '../../auth/pages/email_verification_page.dart';
import 'package:diabetaku_app/core/theme/app_button_styles.dart';
import '../../../core/widgets/app_option_bottom_sheet.dart';

class RegisterPatientPage extends StatefulWidget {
  const RegisterPatientPage({super.key});

  @override
  State<RegisterPatientPage> createState() => _RegisterPatientPageState();
}

class _RegisterPatientPageState extends State<RegisterPatientPage> {
  final nameCtr = TextEditingController();
  final emailCtr = TextEditingController();
  final phoneCtr = TextEditingController();
  final heightCtr = TextEditingController();
  final passwordCtr = TextEditingController();
  final confirmPasswordCtr = TextEditingController();

  DateTime? birthDate;
  DateTime? diagnosisDate;

  String? dmType;
  String? gender;
  String? bloodType;
  String? rhesus;

  bool obscurePassword = true;
  bool obscureConfirm = true;

  bool isRegistering = false;

  int get bloodTypeId {
    if (bloodType == 'A') return 1;
    if (bloodType == 'B') return 2;
    if (bloodType == 'AB') return 3;
    return 4;
  }

  int get rhesusTypeId {
    if (rhesus == 'Positif (+)') return 1;
    return 2;
  }

  bool get isValid {
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    final phoneRegex = RegExp(r'^[0-9]+$');
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');

    return nameCtr.text.trim().isNotEmpty &&
        emailRegex.hasMatch(emailCtr.text.trim()) &&
        phoneRegex.hasMatch(phoneCtr.text.trim()) &&
        phoneCtr.text.trim().length >= 10 &&
        birthDate != null &&
        diagnosisDate != null &&
        dmType != null &&
        gender != null &&
        bloodType != null &&
        rhesus != null &&
        double.tryParse(heightCtr.text.trim()) != null &&
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

  String? get heightError {
    final height = heightCtr.text.trim();
    if (height.isEmpty) return null;

    final value = double.tryParse(height);
    if (value == null) return 'Tinggi badan harus berupa angka';
    if (value < 50 || value > 250) return 'Tinggi badan tidak valid';

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
      heightCtr,
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
    heightCtr.dispose();
    passwordCtr.dispose();
    confirmPasswordCtr.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _pickDate({required bool isBirthDate}) async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: isBirthDate
          ? birthDate ?? DateTime(now.year - 20)
          : diagnosisDate ?? now,
      firstDate: DateTime(1950),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
              child: Material(color: Colors.transparent, child: child!),
            ),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isBirthDate) {
          birthDate = picked;
        } else {
          diagnosisDate = picked;
        }
      });
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

              Row(
                children: [
                  Expanded(
                    child: _dateField(
                      label: 'Tanggal Lahir',
                      value: _formatDate(birthDate),
                      hint: 'DD/MM/YYYY',
                      onTap: () => _pickDate(isBirthDate: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _dateField(
                      label: 'Tanggal Diagnosis',
                      value: _formatDate(diagnosisDate),
                      hint: 'DD/MM/YYYY',
                      onTap: () => _pickDate(isBirthDate: false),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _selectField(
                      label: 'Tipe DM',
                      hint: 'Tipe DM',
                      value: dmType,
                      items: const ['Tipe 1', 'Tipe 2'],
                      onSelected: (v) => setState(() => dmType = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _selectField(
                      label: 'Jenis Kelamin',
                      hint: 'Jenis Kelamin',
                      value: gender,
                      items: const ['Laki-laki', 'Perempuan'],
                      onSelected: (v) => setState(() => gender = v),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _selectField(
                      label: 'Golongan Darah',
                      hint: 'Tipe Goldar',
                      value: bloodType,
                      items: const ['A', 'B', 'AB', 'O'],
                      onSelected: (v) => setState(() => bloodType = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _selectField(
                      label: 'Rhesus',
                      hint: 'Tipe Rhesus',
                      value: rhesus,
                      items: const ['Positif (+)', 'Negatif (-)'],
                      onSelected: (v) => setState(() => rhesus = v),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              _label('Tinggi Badan (cm)'),
              _input(
                heightCtr,
                'Masukkan tinggi badan',
                keyboardType: TextInputType.number,
                errorText: heightError,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                  onPressed: isValid && !isRegistering
                      ? _registerPatient
                      : null,
                  style: AppButtonStyles.primary,
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

  Future<void> _registerPatient() async {
    FocusScope.of(context).unfocus();

    setState(() => isRegistering = true);

    try {
      await ApiService.registerPatient(
        fullName: nameCtr.text.trim(),
        email: emailCtr.text.trim(),
        phoneNumber: phoneCtr.text.trim(),
        password: passwordCtr.text.trim(),
        confirmPassword: confirmPasswordCtr.text.trim(),
        gender: gender!,
        diabetesType: dmType!,
        birthDate: birthDate!,
        diagnosisDate: diagnosisDate!,
        heightCm: double.parse(heightCtr.text.trim()),
        bloodTypeId: bloodTypeId,
        rhesusTypeId: rhesusTypeId,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EmailVerificationPage(
            email: emailCtr.text.trim(),
            roleType: VerificationRoleType.patient,
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

  Widget _header(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.dark2),
        ),
        const Expanded(
          child: Text(
            'Daftar sebagai Pasien',
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

  Widget _dateField({
    required String label,
    required String value,
    required String hint,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.light1),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              value.isEmpty ? hint : value,
              style: TextStyle(
                color: value.isEmpty ? AppColors.dark4 : AppColors.dark1,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
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
    final displayTitle = title.toLowerCase().startsWith('pilih')
        ? title
        : 'Pilih $title';

    final icon = displayTitle.toLowerCase().contains('jenis kelamin')
        ? Icons.wc_outlined
        : displayTitle.toLowerCase().contains('darah') ||
                displayTitle.toLowerCase().contains('rhesus')
            ? Icons.bloodtype_outlined
            : Icons.check_circle_outline;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return AppOptionBottomSheet<String>(
          title: displayTitle,
          icon: icon,
          items: items,
          labelBuilder: (item) => item,
          isSelected: (item) => item == selectedValue,
          onSelected: (item) {
            onSelected(item);
            Navigator.pop(sheetContext);
          },
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
