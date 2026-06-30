import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';

class CaregiverEditProfilePage extends StatefulWidget {
  const CaregiverEditProfilePage({super.key});

  @override
  State<CaregiverEditProfilePage> createState() => _CaregiverEditProfilePageState();
}

class _CaregiverEditProfilePageState extends State<CaregiverEditProfilePage> {
  final nameCtr = TextEditingController();
  final emailCtr = TextEditingController();
  final phoneCtr = TextEditingController();

  String? gender;
  String? emailVerifiedAt;

  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;
  bool canSaveProfile = false;

  int? caregiverId;

  String originalName = '';
  String originalPhone = '';
  String originalGender = '';

  String get emailBadge {
    return emailVerifiedAt == null ? 'Belum Verifikasi' : 'Terverifikasi';
  }

  @override
  void initState() {
    super.initState();
    nameCtr.addListener(_checkFormChanged);
    phoneCtr.addListener(_checkFormChanged);
    _loadProfile();
  }

  @override
  void dispose() {
    nameCtr.removeListener(_checkFormChanged);
    phoneCtr.removeListener(_checkFormChanged);
    nameCtr.dispose();
    emailCtr.dispose();
    phoneCtr.dispose();
    super.dispose();
  }
  bool _isChanged() {
  return nameCtr.text.trim() != originalName ||
      phoneCtr.text.trim() != originalPhone ||
      (gender ?? '').trim() != originalGender;
}

void _checkFormChanged() {
  if (!mounted) return;

  setState(() {
    canSaveProfile = _isChanged();
  });
}

  Future<void> _loadProfile() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      canSaveProfile = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedCaregiverId = prefs.getInt('caregiver_id');

      if (storedCaregiverId == null) {
        throw Exception('Caregiver ID tidak ditemukan. Coba login ulang.');
      }

      final data = await ApiService.getCaregiverProfile(storedCaregiverId);

      if (!mounted) return;

      final loadedName = data['full_name']?.toString() ?? '';
      final loadedEmail = data['email']?.toString() ?? '';
      final loadedPhone = data['phone_number']?.toString() ?? '';
      final loadedGender = data['gender']?.toString() ?? '';

      setState(() {
        caregiverId = storedCaregiverId;

        originalName = loadedName.trim();
        originalPhone = loadedPhone.trim();
        originalGender = loadedGender.trim();

        nameCtr.text = originalName;
        emailCtr.text = loadedEmail.trim();
        phoneCtr.text = originalPhone;
        gender = originalGender.isEmpty ? null : originalGender;

        emailVerifiedAt = data['email_verified_at']?.toString();

        canSaveProfile = false;
        isLoading = false;
      });

      _checkFormChanged();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
  FocusScope.of(context).unfocus();

  if (!_isChanged() || caregiverId == null) return;

  final phone = phoneCtr.text.trim();

  if (phone.isNotEmpty && (phone.length < 10 || phone.length > 15)) {
    _showSnackBar(
      message: 'Nomor telepon harus 10-15 digit',
    );
    return;
  }

  setState(() => isSaving = true);

  try {
    await ApiService.updateCaregiverProfile(
      caregiverId: caregiverId!,
      fullName: nameCtr.text.trim(),
      phoneNumber: phone,
      gender: gender?.trim() ?? '',
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  } catch (e) {
    if (!mounted) return;

    _showSnackBar(
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
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                      ? _errorState()
                      : _formContent(),
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
      padding: EdgeInsets.fromLTRB(12, topPad + 12, 20, 20),
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

  Widget _formContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.person, 'Data Diri'),

          _label('Nama Lengkap'),
          _input(controller: nameCtr, hint: 'Masukkan nama lengkap'),

          _label('Email'),
          _input(
            controller: emailCtr,
            hint: 'Email',
            enabled: false,
            suffix: _miniBadge(emailBadge),
          ),

          _label('Nomor Telepon'),
          _input(
            controller: phoneCtr,
            hint: 'Masukkan nomor telepon',
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),

          _label('Jenis Kelamin'),
          _selectField(
            hint: 'Pilih jenis kelamin',
            value: gender,
            items: const ['Laki-laki', 'Perempuan'],
            onSelected: (value) {
              gender = value;
              _checkFormChanged();
            },
          ),

          const SizedBox(height: 26),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: canSaveProfile && !isSaving ? _saveProfile : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                disabledBackgroundColor: const Color(0xFFAFCBEA),
                disabledForegroundColor: Colors.white,
                foregroundColor: Colors.white,
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

  Widget _input({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool enabled = true,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled && !isSaving,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: (_) => _checkFormChanged(),
      decoration: _inputDecoration(
        hint: hint,
        suffixIcon: suffix == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Center(widthFactor: 1, child: suffix),
              ),
      ),
    );
  }

  Widget _selectField({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String> onSelected,
  }) {
    return InkWell(
      onTap: isSaving
          ? null
          : () => _showOptionSheet(
                title: 'Jenis Kelamin',
                items: items,
                selectedValue: value,
                onSelected: onSelected,
              ),
      borderRadius: BorderRadius.circular(6),
      child: InputDecorator(
        decoration: _inputDecoration(),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? hint,
                style: TextStyle(
                  color: value == null ? AppColors.dark4 : AppColors.dark1,
                  fontSize: 13,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      suffixIcon: suffixIcon,
      hintStyle: const TextStyle(color: AppColors.dark4, fontSize: 13),
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

  void _showOptionSheet({
    required String title,
    required List<String> items,
    required String? selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          decoration: const BoxDecoration(
            color: AppColors.white,
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
              const SizedBox(height: 22),
              CircleAvatar(
                radius: 34,
                backgroundColor: AppColors.lightBlue,
                child: Icon(
                  title == 'Jenis Kelamin'
                      ? Icons.wc_outlined
                      : Icons.check_circle_outline,
                  color: AppColors.primaryBlue,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pilih $title',
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              ...items.map((item) {
                final selected = item == selectedValue;

                return InkWell(
                  onTap: () {
                    onSelected(item);
                    Navigator.pop(sheetContext);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.veryLightBlue
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? AppColors.lightBlue
                            : AppColors.light1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item,
                            style: TextStyle(
                              color: selected
                                  ? AppColors.primaryBlue
                                  : AppColors.dark1,
                              fontSize: 13,
                              fontWeight:
                                  selected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (selected)
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.primaryBlue,
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        );
      },
    );
  }

  Widget _miniBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightBlue),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.red, size: 42),
            const SizedBox(height: 12),
            Text(
              errorMessage ?? 'Gagal memuat profil',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.dark2, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar({required String message, bool isError = true}) {
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