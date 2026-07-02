import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/profile_badge.dart';
import '../../../data/services/api_service.dart';
import 'package:diabetaku_app/core/theme/app_button_styles.dart';

class EditDoctorProfilePage extends StatefulWidget {
  final Map<String, dynamic> profile;

  const EditDoctorProfilePage({super.key, required this.profile});

  @override
  State<EditDoctorProfilePage> createState() => _EditDoctorProfilePageState();
}

class _EditDoctorProfilePageState extends State<EditDoctorProfilePage> {
  late TextEditingController fullNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController strController;
  late TextEditingController institutionController;

  bool isSaving = false;

  String get emailBadge {
    if (!widget.profile.containsKey('email_verified_at')) return 'Terverifikasi';

    final verifiedAt = widget.profile['email_verified_at'];
    return verifiedAt == null ? 'Belum Verifikasi' : 'Terverifikasi';
  }

  late String gender;
  late int specializationId;
  String? dateOfBirth;

  late String initialFullName;
  late String initialPhone;
  late String initialGender;
  late int initialSpecializationId;
  late String initialInstitution;

  List<Map<String, dynamic>> specializations = [];
  bool isLoadingSpecialization = true;

  bool get _hasChanges {
    return fullNameController.text.trim() != initialFullName ||
        phoneController.text.trim() != initialPhone ||
        gender != initialGender ||
        specializationId != initialSpecializationId ||
        institutionController.text.trim() != initialInstitution;
  }

  @override
  void initState() {
    super.initState();

    fullNameController = TextEditingController(
      text: widget.profile['full_name']?.toString() ?? '',
    );
    emailController = TextEditingController(
      text: widget.profile['email']?.toString() ?? '',
    );
    phoneController = TextEditingController(
      text: widget.profile['phone_number']?.toString() ?? '',
    );
    strController = TextEditingController(
      text: widget.profile['str_number']?.toString() ?? '',
    );
    institutionController = TextEditingController(
      text: widget.profile['institution']?.toString() ?? '',
    );

    gender = widget.profile['gender']?.toString() ?? 'Laki-laki';
    specializationId =
        int.tryParse(widget.profile['specialization_id']?.toString() ?? '1') ??
        1;
    dateOfBirth = widget.profile['date_of_birth']?.toString();

    initialFullName = fullNameController.text.trim();
    initialPhone = phoneController.text.trim();
    initialGender = gender;
    initialSpecializationId = specializationId;
    initialInstitution = institutionController.text.trim();

    fullNameController.addListener(_onFormChanged);
    phoneController.addListener(_onFormChanged);
    institutionController.addListener(_onFormChanged);

    _loadSpecializations();
  }

  void _onFormChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    fullNameController.removeListener(_onFormChanged);
    phoneController.removeListener(_onFormChanged);
    institutionController.removeListener(_onFormChanged);

    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    strController.dispose();
    institutionController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_hasChanges) return;

    setState(() => isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final doctorId = prefs.getInt('doctor_id');

      if (doctorId == null) {
        throw Exception('Doctor ID tidak ditemukan. Coba login ulang.');
      }

      await ApiService.updateDoctorProfile(
        doctorId: doctorId,
        fullName: fullNameController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        gender: gender,
        specializationId: specializationId,
        institution: institutionController.text.trim(),
        dateOfBirth: dateOfBirth,
      );

      if (!mounted) return;

      setState(() => isSaving = false);
      _showSuccessSheet(context);
    } catch (e) {
      if (!mounted) return;

      setState(() => isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
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
                      controller: fullNameController,
                    ),
                    _textField(
                      label: 'Email',
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: false,
                      suffix: ProfileBadge.emailVerification(emailBadge),
                    ),
                    _textField(
                      label: 'Nomor Telepon',
                      controller: phoneController,
                    ),
                    _selectField(
                      label: 'Jenis Kelamin',
                      value: gender,
                      onTap: _showGenderSheet,
                    ),
                    _selectField(
                      label: 'Spesialisasi',
                      value: isLoadingSpecialization
                          ? 'Memuat...'
                          : _selectedSpecializationName(),
                      onTap: isLoadingSpecialization
                          ? null
                          : _showSpecializationSheet,
                    ),
                    _textField(
                      label: 'Nomor STR',
                      controller: strController,
                      enabled: false,
                    ),
                    _textField(
                      label: 'Institusi',
                      controller: institutionController,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: AppButtonStyles.height,
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
                            : const Text('Simpan Perubahan'),
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
            onPressed: () => Navigator.pop(context),
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
        enabled: enabled,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppColors.dark1, fontSize: 14),
        decoration: _inputDecoration(label, enabled: enabled, suffix: suffix),
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
        onTap: onTap,
        child: InputDecorator(
          decoration: _inputDecoration(label),
          child: Text(
            value,
            style: const TextStyle(color: AppColors.dark1, fontSize: 14),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label, {
    bool enabled = true,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.dark2, fontSize: 14),
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
      suffixIcon: suffix == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Center(widthFactor: 1, child: suffix),
            ),
      suffixIconConstraints: suffix == null
          ? null
          : const BoxConstraints(minWidth: 0, minHeight: 0),
    );
  }

  void _showGenderSheet() {
    const genderOptions = ['Laki-laki', 'Perempuan'];

    _showOptionSheet<String>(
      title: 'Pilih Jenis Kelamin',
      items: genderOptions,
      itemLabel: (item) => item,
      isSelected: (item) => item == gender,
      onSelected: (item) {
        setState(() => gender = item);
      },
    );
  }

  Future<void> _loadSpecializations() async {
    try {
      final data = await ApiService.getSpecializations();

      if (!mounted) return;

      setState(() {
        specializations = data;
        isLoadingSpecialization = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoadingSpecialization = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  String _selectedSpecializationName() {
    final selected = specializations.where((item) {
      return int.tryParse(item['specialization_id'].toString()) ==
          specializationId;
    }).toList();

    if (selected.isEmpty) {
      return widget.profile['specialization_name']?.toString() ??
          'Pilih spesialisasi';
    }

    return selected.first['specialization_name']?.toString() ??
        'Pilih spesialisasi';
  }

  void _showSpecializationSheet() {
    _showOptionSheet<Map<String, dynamic>>(
      title: 'Pilih Spesialisasi',
      items: specializations,
      itemLabel: (item) => item['specialization_name']?.toString() ?? '-',
      isSelected: (item) {
        final id = int.tryParse(item['specialization_id'].toString()) ?? 0;
        return id == specializationId;
      },
      onSelected: (item) {
        final id = int.tryParse(item['specialization_id'].toString()) ?? 0;
        setState(() => specializationId = id);
      },
      maxHeightFactor: 0.55,
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
                height: AppButtonStyles.height,
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
}
