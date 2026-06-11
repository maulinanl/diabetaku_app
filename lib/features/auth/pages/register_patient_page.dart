import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

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

  bool get isValid =>
      nameCtr.text.isNotEmpty &&
      emailCtr.text.isNotEmpty &&
      phoneCtr.text.isNotEmpty &&
      birthDate != null &&
      diagnosisDate != null &&
      dmType != null &&
      gender != null &&
      bloodType != null &&
      rhesus != null &&
      heightCtr.text.isNotEmpty &&
      passwordCtr.text.length >= 8 &&
      confirmPasswordCtr.text == passwordCtr.text;

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
              _input(emailCtr, 'Masukkan alamat emailmu'),

              _label('Nomor Telepon'),
              _input(
                phoneCtr,
                'Masukkan nomor telepon (62xx)',
                keyboardType: TextInputType.phone,
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
                    child: _dropdown(
                      label: 'Tipe DM',
                      hint: 'Tipe DM',
                      value: dmType,
                      items: const ['DM Tipe 1', 'DM Tipe 2'],
                      onChanged: (v) => setState(() => dmType = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _dropdown(
                      label: 'Jenis Kelamin',
                      hint: 'Jenis Kelamin',
                      value: gender,
                      items: const ['Laki-laki', 'Perempuan'],
                      onChanged: (v) => setState(() => gender = v),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _dropdown(
                      label: 'Golongan Darah',
                      hint: 'Tipe Goldar',
                      value: bloodType,
                      items: const ['A', 'B', 'AB', 'O'],
                      onChanged: (v) => setState(() => bloodType = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _dropdown(
                      label: 'Rhesus',
                      hint: 'Tipe Rhesus',
                      value: rhesus,
                      items: const ['Positif (+)', 'Negatif (-)'],
                      onChanged: (v) => setState(() => rhesus = v),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              _label('Tinggi Badan (cm)'),
              _input(
                heightCtr,
                'Masukkan Tinggi badan',
                keyboardType: TextInputType.number,
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
                  onPressed: isValid ? () {} : null,
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

  Widget _dropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(color: AppColors.dark4, fontSize: 13),
          ),
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, style: const TextStyle(fontSize: 13)),
                ),
              )
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
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
      ],
    );
  }
}
