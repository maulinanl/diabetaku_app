import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'email_verification_page.dart';

class RegisterDoctorStep2Page extends StatefulWidget {
  const RegisterDoctorStep2Page({super.key});

  @override
  State<RegisterDoctorStep2Page> createState() =>
      _RegisterDoctorStep2PageState();
}

class _RegisterDoctorStep2PageState extends State<RegisterDoctorStep2Page> {
  final strCtr = TextEditingController();
  final institutionCtr = TextEditingController();

  String? specialization;

  bool get isValid =>
      specialization != null &&
      strCtr.text.isNotEmpty &&
      institutionCtr.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    strCtr.addListener(() => setState(() {}));
    institutionCtr.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    strCtr.dispose();
    institutionCtr.dispose();
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
                    _label('Spesialisasi'),
                    _dropdown(),

                    _label('Nomor STR'),
                    _input(strCtr, 'Masukkan nomor STR'),

                    _label('Institusi'),
                    _input(
                      institutionCtr,
                      'Masukkan institusi atau rumah sakit',
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isValid
                            ? () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const EmailVerificationPage(),
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
                          'Daftar sebagai Dokter',
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
          _stepIndicator(currentStep: 2),
          const SizedBox(height: 18),
          const Text(
            'Lengkapi data untuk membuat akun',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.dark2, fontSize: 13),
          ),
          const SizedBox(height: 4),
          const Text(
            'Langkah 2 dari 2 - Data Profesional',
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

  Widget _input(TextEditingController controller, String hint) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.dark4, fontSize: 13),
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

  Widget _dropdown() {
    return DropdownButtonFormField<String>(
      value: specialization,
      hint: const Text(
        'Pilih spesialisasi',
        style: TextStyle(color: AppColors.dark4, fontSize: 13),
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.primaryBlue,
      ),
      items: const [
        DropdownMenuItem(
          value: 'Penyakit Dalam',
          child: Text('Penyakit Dalam'),
        ),
        DropdownMenuItem(value: 'Endokrin', child: Text('Endokrin')),
        DropdownMenuItem(value: 'Dokter Umum', child: Text('Dokter Umum')),
      ],
      onChanged: (value) {
        setState(() {
          specialization = value;
        });
      },
      decoration: InputDecoration(
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
      style: const TextStyle(color: AppColors.dark1, fontSize: 13),
      dropdownColor: AppColors.white,
    );
  }
}
