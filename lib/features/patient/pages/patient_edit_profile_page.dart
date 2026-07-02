import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/profile_badge.dart';
import '../../../data/services/api_service.dart';
import 'package:diabetaku_app/core/theme/app_button_styles.dart';

class PatientEditProfilePage extends StatefulWidget {
  final Map<String, dynamic> profile;

  const PatientEditProfilePage({super.key, required this.profile});

  @override
  State<PatientEditProfilePage> createState() => _PatientEditProfilePageState();
}

class _PatientEditProfilePageState extends State<PatientEditProfilePage> {
  late TextEditingController nameCtr;
  late TextEditingController emailCtr;
  late TextEditingController phoneCtr;
  late TextEditingController birthCtr;
  late TextEditingController diagnosisCtr;
  late TextEditingController heightCtr;

  bool isSaving = false;

  String get emailBadge {
    // Response lama profil pasien belum selalu membawa email_verified_at.
    // Pasien yang sudah masuk aplikasi sudah melewati verifikasi email.
    if (!widget.profile.containsKey('email_verified_at')) return 'Terverifikasi';

    final verifiedAt = widget.profile['email_verified_at'];
    return verifiedAt == null ? 'Belum Verifikasi' : 'Terverifikasi';
  }

  late String gender;
  late String dmType;
  late String bloodType;
  late String rhesus;

  late String initialName;
  late String initialPhone;
  late String initialBirth;
  late String initialDiagnosis;
  late String initialHeight;
  late String initialGender;
  late String initialDmType;
  late String initialBloodType;
  late String initialRhesus;

  bool get _hasChanges {
    return nameCtr.text.trim() != initialName ||
        phoneCtr.text.trim() != initialPhone ||
        birthCtr.text.trim() != initialBirth ||
        diagnosisCtr.text.trim() != initialDiagnosis ||
        heightCtr.text.trim() != initialHeight ||
        gender != initialGender ||
        dmType != initialDmType ||
        bloodType != initialBloodType ||
        rhesus != initialRhesus;
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
    return rhesus == 'Negatif (-)' ? 2 : 1;
  }

  @override
  void initState() {
    super.initState();

    final profile = widget.profile;

    nameCtr = TextEditingController(
      text: profile['full_name']?.toString() ?? '',
    );
    emailCtr = TextEditingController(
      text: profile['email']?.toString() ?? '',
    );
    phoneCtr = TextEditingController(
      text: profile['phone_number']?.toString() ?? '',
    );
    birthCtr = TextEditingController(
      text: profile['date_of_birth']?.toString() ?? '',
    );
    diagnosisCtr = TextEditingController(
      text: profile['diagnosis_date']?.toString() ?? '',
    );
    heightCtr = TextEditingController(
      text: profile['height_cm']?.toString() ?? '',
    );

    gender = _normalizeGender(profile['gender']?.toString());
    dmType = _normalizeDiabetesType(profile['diabetes_type']?.toString());
    bloodType = _normalizeBloodType(profile['blood_type']?.toString());
    rhesus = _normalizeRhesus(profile['rhesus_type']?.toString());

    initialName = nameCtr.text.trim();
    initialPhone = phoneCtr.text.trim();
    initialBirth = birthCtr.text.trim();
    initialDiagnosis = diagnosisCtr.text.trim();
    initialHeight = heightCtr.text.trim();
    initialGender = gender;
    initialDmType = dmType;
    initialBloodType = bloodType;
    initialRhesus = rhesus;

    nameCtr.addListener(_onFormChanged);
    phoneCtr.addListener(_onFormChanged);
    birthCtr.addListener(_onFormChanged);
    diagnosisCtr.addListener(_onFormChanged);
    heightCtr.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    nameCtr.removeListener(_onFormChanged);
    phoneCtr.removeListener(_onFormChanged);
    birthCtr.removeListener(_onFormChanged);
    diagnosisCtr.removeListener(_onFormChanged);
    heightCtr.removeListener(_onFormChanged);

    nameCtr.dispose();
    emailCtr.dispose();
    phoneCtr.dispose();
    birthCtr.dispose();
    diagnosisCtr.dispose();
    heightCtr.dispose();
    super.dispose();
  }

  String _normalizeGender(String? value) {
    final normalized = value?.trim().toLowerCase() ?? '';
    if (normalized == 'laki-laki' || normalized == 'laki laki') {
      return 'Laki-laki';
    }
    return 'Perempuan';
  }

  String _normalizeDiabetesType(String? value) {
    final normalized = value?.trim().toLowerCase() ?? '';
    if (normalized == 'tipe 1' || normalized == 'type 1') {
      return 'Tipe 1';
    }
    return 'Tipe 2';
  }

  String _normalizeBloodType(String? value) {
    final normalized = value?.trim().toUpperCase() ?? '';
    if (normalized == 'A' || normalized == 'B' || normalized == 'AB') {
      return normalized;
    }
    return 'O';
  }

  String _normalizeRhesus(String? value) {
    final normalized = value?.trim().toLowerCase() ?? '';
    if (normalized.contains('-') || normalized.contains('negatif')) {
      return 'Negatif (-)';
    }
    return 'Positif (+)';
  }

  DateTime _parseDate(String? value) {
    if (value == null || value.trim().isEmpty) return DateTime.now();
    return DateTime.tryParse(value) ?? DateTime.now();
  }

  String _formatDateForApi(DateTime date) {
    return date.toIso8601String().split('T').first;
  }

  Future<void> _pickDate({
    required TextEditingController controller,
    required DateTime initialDate,
  }) async {
    final now = DateTime.now();
    final safeInitialDate = initialDate.isAfter(now) ? now : initialDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: safeInitialDate,
      firstDate: DateTime(1950),
      lastDate: now,
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
    if (!_hasChanges || isSaving) return;

    FocusScope.of(context).unfocus();
    setState(() => isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final patientId = prefs.getInt('patient_id');

      if (patientId == null) {
        throw Exception('Patient ID tidak ditemukan. Coba login ulang.');
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

      setState(() => isSaving = false);
      _showSuccessSheet(context);
    } catch (e) {
      if (!mounted) return;

      setState(() => isSaving = false);
      _showStyledSnackBar(
        message: e.toString().replaceFirst('Exception: ', ''),
      );
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
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _textField(
                      label: 'Nama Lengkap',
                      controller: nameCtr,
                    ),
                    _textField(
                      label: 'Email',
                      controller: emailCtr,
                      keyboardType: TextInputType.emailAddress,
                      enabled: false,
                      suffix: ProfileBadge.emailVerification(emailBadge),
                    ),
                    _textField(
                      label: 'Nomor Telepon',
                      controller: phoneCtr,
                      keyboardType: TextInputType.phone,
                    ),
                    _selectField(
                      label: 'Tanggal Lahir',
                      value: birthCtr.text.isEmpty
                          ? 'Pilih tanggal lahir'
                          : birthCtr.text,
                      onTap: () => _pickDate(
                        controller: birthCtr,
                        initialDate: _parseDate(birthCtr.text),
                      ),
                    ),
                    _selectField(
                      label: 'Jenis Kelamin',
                      value: gender,
                      onTap: _showGenderSheet,
                    ),
                    _selectField(
                      label: 'Tipe Diabetes',
                      value: dmType,
                      onTap: _showDiabetesTypeSheet,
                    ),
                    _selectField(
                      label: 'Tanggal Diagnosis',
                      value: diagnosisCtr.text.isEmpty
                          ? 'Pilih tanggal diagnosis'
                          : diagnosisCtr.text,
                      onTap: () => _pickDate(
                        controller: diagnosisCtr,
                        initialDate: _parseDate(diagnosisCtr.text),
                      ),
                    ),
                    _selectField(
                      label: 'Golongan Darah',
                      value: bloodType,
                      onTap: _showBloodTypeSheet,
                    ),
                    _selectField(
                      label: 'Rhesus',
                      value: rhesus,
                      onTap: _showRhesusSheet,
                    ),
                    _textField(
                      label: 'Tinggi Badan (cm)',
                      controller: heightCtr,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isSaving || !_hasChanges
                            ? null
                            : _saveProfile,
                        style: AppButtonStyles.primary,
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
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12, topPad + 12, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
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
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool enabled = true,
    Widget? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: enabled && !isSaving,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppColors.dark1, fontSize: 14),
        decoration: _inputDecoration(
          label,
          enabled: enabled && !isSaving,
          suffixIcon: suffix == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Center(widthFactor: 1, child: suffix),
                ),
        ),
      ),
    );
  }

  Widget _selectField({
    required String label,
    required String value,
    required VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: isSaving ? null : onTap,
        borderRadius: BorderRadius.circular(6),
        child: InputDecorator(
          decoration: _inputDecoration(label),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.dark1,
                    fontSize: 14,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.primaryBlue,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label, {
    bool enabled = true,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.dark2, fontSize: 14),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: enabled ? AppColors.white : AppColors.light2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.light2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.light2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.light2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.4),
      ),
    );
  }


  void _showGenderSheet() {
    _showOptionSheet<String>(
      title: 'Pilih Jenis Kelamin',
      items: const ['Laki-laki', 'Perempuan'],
      itemLabel: (item) => item,
      isSelected: (item) => item == gender,
      onSelected: (item) {
        setState(() => gender = item);
      },
    );
  }

  void _showDiabetesTypeSheet() {
    _showOptionSheet<String>(
      title: 'Pilih Tipe Diabetes',
      items: const ['Tipe 1', 'Tipe 2'],
      itemLabel: (item) => item,
      isSelected: (item) => item == dmType,
      onSelected: (item) {
        setState(() => dmType = item);
      },
    );
  }

  void _showBloodTypeSheet() {
    _showOptionSheet<String>(
      title: 'Pilih Golongan Darah',
      items: const ['A', 'B', 'AB', 'O'],
      itemLabel: (item) => item,
      isSelected: (item) => item == bloodType,
      onSelected: (item) {
        setState(() => bloodType = item);
      },
    );
  }

  void _showRhesusSheet() {
    _showOptionSheet<String>(
      title: 'Pilih Rhesus',
      items: const ['Positif (+)', 'Negatif (-)'],
      itemLabel: (item) => item,
      isSelected: (item) => item == rhesus,
      onSelected: (item) {
        setState(() => rhesus = item);
      },
    );
  }

  void _showOptionSheet<T>({
    required String title,
    required List<T> items,
    required String Function(T item) itemLabel,
    required bool Function(T item) isSelected,
    required void Function(T item) onSelected,
    double? maxHeightFactor,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final content = Column(
          mainAxisSize: maxHeightFactor == null
              ? MainAxisSize.min
              : MainAxisSize.max,
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
              title,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 2),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final selected = isSelected(item);

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      itemLabel(item),
                      style: TextStyle(
                        color: selected
                            ? AppColors.primaryBlue
                            : AppColors.dark1,
                        fontSize: 14,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    trailing: selected
                        ? const Icon(
                            Icons.check,
                            color: AppColors.primaryBlue,
                            size: 20,
                          )
                        : null,
                    onTap: () {
                      onSelected(item);
                      Navigator.pop(sheetContext);
                    },
                  );
                },
              ),
            ),
          ],
        );

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: maxHeightFactor == null
              ? content
              : SizedBox(
                  height: MediaQuery.of(context).size.height * maxHeightFactor,
                  child: content,
                ),
        );
      },
    );
  }

  void _showSuccessSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
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
              const SizedBox(height: 22),
              const CircleAvatar(
                radius: 34,
                backgroundColor: Color(0xFFE7F8EF),
                child: Icon(Icons.check, color: Colors.green, size: 34),
              ),
              const SizedBox(height: 16),
              const Text(
                'Profil berhasil diperbarui',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Data profil Anda telah tersimpan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.dark2,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.pop(context, true);
                  },
                  style: AppButtonStyles.primary,
                  child: const Text(
                    'Kembali ke Profil',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
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
