import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/profile_badge.dart';
import '../../../data/services/api_service.dart';
import 'package:diabetaku_app/core/theme/app_button_styles.dart';

class CaregiverEditProfilePage extends StatefulWidget {
  const CaregiverEditProfilePage({super.key});

  @override
  State<CaregiverEditProfilePage> createState() =>
      _CaregiverEditProfilePageState();
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

    final name = nameCtr.text.trim();
    final phone = phoneCtr.text.trim();
    final selectedGender = gender?.trim() ?? '';

    if (name.isEmpty) {
      _showStyledSnackBar(message: 'Nama lengkap wajib diisi');
      return;
    }

    if (selectedGender.isEmpty) {
      _showStyledSnackBar(message: 'Jenis kelamin wajib dipilih');
      return;
    }

    if (phone.isNotEmpty && (phone.length < 10 || phone.length > 15)) {
      _showStyledSnackBar(message: 'Nomor telepon harus 10-15 digit');
      return;
    }

    setState(() => isSaving = true);

    try {
      await ApiService.updateCaregiverProfile(
        caregiverId: caregiverId!,
        fullName: name,
        phoneNumber: phone,
        gender: selectedGender,
      );

      if (!mounted) return;

      setState(() {
        originalName = name;
        originalPhone = phone;
        originalGender = selectedGender;
        canSaveProfile = false;
        isSaving = false;
      });

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

  Widget _buildHeader(BuildContext context) {
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
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          _selectField(
            label: 'Jenis Kelamin',
            value: gender ?? 'Pilih jenis kelamin',
            onTap: _showGenderSheet,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: canSaveProfile && !isSaving ? _saveProfile : null,
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
          TextButton(
            onPressed: isSaving ? null : () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool enabled = true,
    Widget? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: enabled && !isSaving,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: (_) => _checkFormChanged(),
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
    final isPlaceholder = value == 'Pilih jenis kelamin';

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
                  style: TextStyle(
                    color: isPlaceholder ? AppColors.dark4 : AppColors.dark1,
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
        _checkFormChanged();
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
              style: AppButtonStyles.primary,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
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
                'Data profil pendamping telah tersimpan.',
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
                height: 46,
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
