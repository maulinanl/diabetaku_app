import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PatientEditProfilePage extends StatefulWidget {
  const PatientEditProfilePage({super.key});

  @override
  State<PatientEditProfilePage> createState() => _PatientEditProfilePageState();
}

class _PatientEditProfilePageState extends State<PatientEditProfilePage> {
  final nameCtr = TextEditingController(text: 'Angelica Sabi Gita');
  final emailCtr = TextEditingController(text: 'angelicaSabiGit@gmail.com');
  final phoneCtr = TextEditingController(text: '081234567890');
  final birthCtr = TextEditingController(text: '12 Mei 1994');
  final addressCtr = TextEditingController(
    text: 'Jl. Kertanegara No. 12 Majapahit',
  );

  String dmType = 'DM Tipe 2';
  String bloodType = 'O';
  String rhesus = 'Positif (+)';
  final heightCtr = TextEditingController(text: '168');

  @override
  void dispose() {
    nameCtr.dispose();
    emailCtr.dispose();
    phoneCtr.dispose();
    birthCtr.dispose();
    addressCtr.dispose();
    heightCtr.dispose();
    super.dispose();
  }

  void _showSuccessSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.light1,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 24),
              const CircleAvatar(
                radius: 36,
                backgroundColor: Color(0xFFEAFBF3),
                child: Icon(
                  Icons.check,
                  color: Color(0xFF10C878),
                  size: 36,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Profil berhasil diperbarui',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Data profil Anda telah tersimpan. Perubahan langsung berlaku di seluruh fitur aplikasi.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.dark2, fontSize: 13),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
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

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1994, 5, 12),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        birthCtr.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(Icons.person, 'Data Diri'),
                    _label('Nama Lengkap'),
                    _input(nameCtr),
                    _label('Email'),
                    _input(emailCtr, keyboardType: TextInputType.emailAddress),
                    _label('Nomor Telepon'),
                    _input(phoneCtr, keyboardType: TextInputType.phone),
                    _label('Tanggal Lahir'),
                    _dateInput(),
                    _label('Alamat'),
                    _input(addressCtr),

                    const SizedBox(height: 18),
                    _sectionTitle(Icons.medical_services, 'Data Medis'),
                    _label('Tipe DM'),
                    _dropdown(
                      value: dmType,
                      items: const ['DM Tipe 1', 'DM Tipe 2'],
                      onChanged: (v) => setState(() => dmType = v!),
                    ),
                    _label('Golongan Darah'),
                    Row(
                      children: [
                        Expanded(
                          child: _dropdown(
                            value: bloodType,
                            items: const ['A', 'B', 'AB', 'O'],
                            onChanged: (v) => setState(() => bloodType = v!),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _dropdown(
                            value: rhesus,
                            items: const ['Positif (+)', 'Negatif (-)'],
                            onChanged: (v) => setState(() => rhesus = v!),
                          ),
                        ),
                      ],
                    ),
                    _label('Tinggi Badan (cm)'),
                    _input(heightCtr, keyboardType: TextInputType.number),

                    const SizedBox(height: 26),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
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
                        child: const Text(
                          'Simpan Perubahan',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Center(
                        child: Text(
                          'Batal',
                          style: TextStyle(color: AppColors.primaryBlue),
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
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12, topPad + 12, 20, 18),
      color: AppColors.primaryBlue,
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

  Widget _sectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 16),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.dark2,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _inputDecoration(),
    );
  }

  Widget _dateInput() {
    return TextFormField(
      controller: birthCtr,
      readOnly: true,
      onTap: _pickBirthDate,
      decoration: _inputDecoration(
        suffixIcon: const Icon(
          Icons.calendar_today_outlined,
          color: AppColors.primaryBlue,
          size: 18,
        ),
      ),
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 13)),
            ),
          )
          .toList(),
      onChanged: onChanged,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.primaryBlue,
      ),
      decoration: _inputDecoration(),
    );
  }

  InputDecoration _inputDecoration({Widget? suffixIcon}) {
    return InputDecoration(
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
    );
  }
}