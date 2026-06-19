import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';

class PatientEditProfilePage extends StatefulWidget {
  final Map<String, dynamic> profile;

  const PatientEditProfilePage({super.key, required this.profile});

  @override
  State<PatientEditProfilePage> createState() => _PatientEditProfilePageState();
}

class _PatientEditProfilePageState extends State<PatientEditProfilePage> {
  final nameCtr = TextEditingController();
  final emailCtr = TextEditingController();
  final phoneCtr = TextEditingController();
  final birthCtr = TextEditingController();
  final diagnosisCtr = TextEditingController();
  final heightCtr = TextEditingController();

  String gender = 'Perempuan';
  String dmType = 'Tipe 2';
  String bloodType = 'O';
  String rhesus = 'Positif (+)';

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    final profile = widget.profile;

    nameCtr.text = profile['full_name']?.toString() ?? '';
    emailCtr.text = profile['email']?.toString() ?? '';
    phoneCtr.text = profile['phone_number']?.toString() ?? '';
    birthCtr.text = profile['date_of_birth']?.toString() ?? '';
    diagnosisCtr.text = profile['diagnosis_date']?.toString() ?? '';
    heightCtr.text = profile['height_cm']?.toString() ?? '';

    gender = profile['gender']?.toString() ?? 'Perempuan';
    dmType = profile['diabetes_type']?.toString() ?? 'Tipe 2';
    bloodType = profile['blood_type']?.toString() ?? 'O';
    rhesus = profile['rhesus_type']?.toString() ?? 'Positif (+)';
  }

  int get bloodTypeId {
    switch (bloodType) {
      case 'A':
        return 1;
      case 'B':
        return 2;
      case 'AB':
        return 3;
      default:
        return 4;
    }
  }

  int get rhesusTypeId {
    return rhesus.contains('Positif') ? 1 : 2;
  }

  @override
  void dispose() {
    nameCtr.dispose();
    emailCtr.dispose();
    phoneCtr.dispose();
    birthCtr.dispose();
    diagnosisCtr.dispose();
    heightCtr.dispose();
    super.dispose();
  }

  DateTime _parseDate(String? value) {
    if (value == null || value.isEmpty) return DateTime.now();
    return DateTime.tryParse(value) ?? DateTime.now();
  }

  String _formatDateForApi(DateTime date) {
    return date.toIso8601String().split('T').first;
  }

  Future<void> _pickDate({
    required TextEditingController controller,
    required DateTime initialDate,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
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
        controller.text = _formatDateForApi(picked);
      });
    }
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();

    setState(() => isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final patientId = prefs.getInt('patient_id');

      if (patientId == null) {
        throw Exception('Patient ID tidak ditemukan');
      }

      await ApiService.updatePatientProfile(
        patientId: patientId,
        fullName: nameCtr.text.trim(),
        phoneNumber: phoneCtr.text.trim(),
        gender: gender,
        diabetesType: dmType,
        diagnosisDate: diagnosisCtr.text.trim(),
        dateOfBirth: birthCtr.text.trim(),
        heightCm: double.tryParse(heightCtr.text.trim()) ?? 0,
        bloodTypeId: bloodTypeId,
        rhesusTypeId: rhesusTypeId,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      _showStyledSnackBar(
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
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
                    _input(
                      emailCtr,
                      keyboardType: TextInputType.emailAddress,
                      enabled: false,
                    ),

                    _label('Nomor Telepon'),
                    _input(phoneCtr, keyboardType: TextInputType.phone),

                    _label('Tanggal Lahir'),
                    _dateInput(
                      controller: birthCtr,
                      onTap: () => _pickDate(
                        controller: birthCtr,
                        initialDate: _parseDate(birthCtr.text),
                      ),
                    ),

                    _label('Jenis Kelamin'),
                    _dropdown(
                      value: gender,
                      items: const ['Laki-laki', 'Perempuan'],
                      onChanged: (v) => setState(() => gender = v!),
                    ),

                    const SizedBox(height: 18),

                    _sectionTitle(Icons.medical_services, 'Data Medis'),

                    _label('Tipe DM'),
                    _dropdown(
                      value: dmType,
                      items: const ['Tipe 1', 'Tipe 2'],
                      onChanged: (v) => setState(() => dmType = v!),
                    ),

                    _label('Tanggal Diagnosis'),
                    _dateInput(
                      controller: diagnosisCtr,
                      onTap: () => _pickDate(
                        controller: diagnosisCtr,
                        initialDate: _parseDate(diagnosisCtr.text),
                      ),
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
                        onPressed: isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFFAFCBEA),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Simpan Perubahan',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),

                    TextButton(
                      onPressed: isSaving ? null : () => Navigator.pop(context),
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
            onPressed: isSaving ? null : () => Navigator.pop(context),
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
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: _inputDecoration(),
    );
  }

  Widget _dateInput({
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
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
      value: items.contains(value) ? value : items.first,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.light1),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.light1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.4),
      ),
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
