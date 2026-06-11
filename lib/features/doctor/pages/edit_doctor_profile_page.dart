import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class EditDoctorProfilePage extends StatelessWidget {
  const EditDoctorProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _textField('Nama Lengkap', 'dr. Agus Setiawan, S.PD'),
                    _textField('Email', 'agusSetiawan@gmail.com'),
                    _textField('Nomor Telepon', '081278564098'),
                    _dropdownField(),
                    _textField('Nomor STR', 'STR-2024-001234'),
                    _textField('Institusi', 'RS Cipto Mangunkusumo'),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () => _showSuccessSheet(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text('Simpan Perubahan'),
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

  Widget _buildHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(12, topPad + 12, 20, 18),
      decoration: const BoxDecoration(color: AppColors.primaryBlue),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              'Ubah Profil',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _textField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.white,
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
    );
  }

  Widget _dropdownField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: 'Penyakit Dalam',
        items: const [
          DropdownMenuItem(
            value: 'Penyakit Dalam',
            child: Text('Penyakit Dalam'),
          ),
          DropdownMenuItem(value: 'Endokrin', child: Text('Endokrin')),
        ],
        onChanged: (value) {},
        decoration: InputDecoration(
          labelText: 'Spesialisasi',
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  void _showSuccessSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 34,
                backgroundColor: Color(0xFFE7F8EF),
                child: Icon(Icons.check, color: Colors.green, size: 34),
              ),
              const SizedBox(height: 16),
              const Text(
                'Profil berhasil diperbarui',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Data profil Anda telah tersimpan.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.dark2),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text('Kembali ke Profil'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
