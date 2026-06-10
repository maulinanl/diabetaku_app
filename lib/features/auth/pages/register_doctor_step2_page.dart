import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import 'email_verification_page.dart';

class RegisterDoctorStep2Page extends StatelessWidget {
  const RegisterDoctorStep2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Daftar sebagai Dokter',
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Lengkapi data untuk membuat akun\nLangkah 2 dari 2 - Data Profesional',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.dark2),
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Spesialisasi',
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Penyakit Dalam',
                  child: Text('Penyakit Dalam'),
                ),
                DropdownMenuItem(value: 'Endokrin', child: Text('Endokrin')),
              ],
              onChanged: (value) {},
            ),

            const SizedBox(height: 15),

            const CustomTextField(
              label: 'Nomor STR',
              hint: 'Masukkan nomor STR',
            ),
            const SizedBox(height: 15),

            const CustomTextField(
              label: 'Institusi',
              hint: 'Masukkan institusi atau rumah sakit',
            ),

            const SizedBox(height: 24),

            CustomButton(
              text: 'Daftar sebagai Dokter',
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EmailVerificationPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
