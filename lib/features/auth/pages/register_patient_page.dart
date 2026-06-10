import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class RegisterPatientPage extends StatelessWidget {
  const RegisterPatientPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const Expanded(
                      child: Text(
                        'Daftar sebagai Pasien',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),

                const SizedBox(height: 20),

                const Center(
                  child: Text(
                    'Lengkapi data untuk membuat akun',
                    style: TextStyle(color: AppColors.dark2, fontSize: 13),
                  ),
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
                  hint: 'Masukkan nomor telepon (62xx)',
                ),

                const SizedBox(height: 15),

                Row(
                  children: const [
                    Expanded(
                      child: CustomTextField(
                        label: 'Tanggal Lahir',
                        hint: 'DD/MM/YYYY',
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: CustomTextField(
                        label: 'Tanggal Diagnosis',
                        hint: 'DD/MM/YYYY',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                Row(
                  children: const [
                    Expanded(
                      child: _CustomDropdown(
                        label: 'Tipe DM',
                        hint: 'Tipe DM',
                        items: ['Tipe 1', 'Tipe 2'],
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _CustomDropdown(
                        label: 'Jenis Kelamin',
                        hint: 'Jenis Kelamin',
                        items: ['Laki-laki', 'Perempuan'],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                Row(
                  children: const [
                    Expanded(
                      child: _CustomDropdown(
                        label: 'Golongan Darah',
                        hint: 'Tipe Goldar',
                        items: ['A', 'B', 'AB', 'O'],
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _CustomDropdown(
                        label: 'Rhesus',
                        hint: 'Tipe Rhesus',
                        items: ['Positif', 'Negatif'],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                const CustomTextField(
                  label: 'Tinggi Badan (cm)',
                  hint: 'Masukkan tinggi badan',
                ),

                const SizedBox(height: 15),

                const CustomTextField(
                  label: 'Kata Sandi',
                  hint: 'Masukkan kata sandi (8+ karakter)',
                  obscureText: true,
                  suffixIcon: Icon(Icons.visibility_off),
                ),

                const SizedBox(height: 24),

                CustomButton(text: 'Daftar sebagai Pasien', onPressed: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomDropdown extends StatelessWidget {
  final String label;
  final String hint;
  final List<String> items;

  const _CustomDropdown({
    required this.label,
    required this.hint,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.dark2, fontSize: 13),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: null,
          hint: Text(
            hint,
            style: const TextStyle(color: AppColors.dark4, fontSize: 13),
          ),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: (value) {},
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.light1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.light1),
            ),
          ),
        ),
      ],
    );
  }
}
