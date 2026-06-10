import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import 'register_doctor_step2_page.dart';

class RegisterDoctorStep1Page extends StatelessWidget {
  const RegisterDoctorStep1Page({super.key});

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
              'Lengkapi data untuk membuat akun\nLangkah 1 dari 2 - Data Diri',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.dark2),
            ),
            const SizedBox(height: 20),

            const CustomTextField(
              label: 'Nama Lengkap',
              hint: 'Masukkan nama lengkapmu',
            ),
            const SizedBox(height: 15),

            const CustomTextField(
              label: 'Email',
              hint: 'Masukkan alamat emailmu',
            ),
            const SizedBox(height: 15),

            const CustomTextField(
              label: 'Nomor Telepon',
              hint: 'Masukkan nomor telepon',
            ),
            const SizedBox(height: 15),

            const CustomTextField(
              label: 'Kata Sandi',
              hint: 'Masukkan kata sandi',
              obscureText: true,
              suffixIcon: Icon(Icons.visibility_off),
            ),
            const SizedBox(height: 15),

            const CustomTextField(
              label: 'Konfirmasi Kata Sandi',
              hint: 'Konfirmasi kata sandi',
              obscureText: true,
              suffixIcon: Icon(Icons.visibility_off),
            ),

            const SizedBox(height: 24),

            CustomButton(
              text: 'Lanjut',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RegisterDoctorStep2Page(),
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
