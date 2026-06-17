import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;
  bool isSaving = false;

  bool get isFormValid {
    final current = currentPasswordController.text.trim();
    final newPass = newPasswordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    return current.isNotEmpty &&
        newPass.length >= 8 &&
        confirm.isNotEmpty &&
        newPass == confirm &&
        current != newPass;
  }

  @override
  void initState() {
    super.initState();
    currentPasswordController.addListener(_refresh);
    newPasswordController.addListener(_refresh);
    confirmPasswordController.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _savePassword() async {
    if (!isFormValid) return;

    setState(() => isSaving = true);

    try {
      await ApiService.changePassword(
        currentPassword: currentPasswordController.text.trim(),
        newPassword: newPasswordController.text.trim(),
        confirmPassword: confirmPasswordController.text.trim(),
      );

      if (!mounted) return;

      setState(() => isSaving = false);
      _showSuccessSheet();
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
    final newPass = newPasswordController.text.trim();
    final confirm = confirmPasswordController.text.trim();
    final isMismatch = confirm.isNotEmpty && newPass != confirm;
    final isSamePassword =
        currentPasswordController.text.trim().isNotEmpty &&
        newPass.isNotEmpty &&
        currentPasswordController.text.trim() == newPass;

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
                    _passwordField(
                      label: 'Kata Sandi Saat Ini',
                      controller: currentPasswordController,
                      obscure: obscureCurrent,
                      onToggle: () {
                        setState(() => obscureCurrent = !obscureCurrent);
                      },
                    ),
                    _passwordField(
                      label: 'Kata Sandi Baru',
                      controller: newPasswordController,
                      obscure: obscureNew,
                      onToggle: () {
                        setState(() => obscureNew = !obscureNew);
                      },
                    ),
                    _passwordField(
                      label: 'Konfirmasi Kata Sandi Baru',
                      controller: confirmPasswordController,
                      obscure: obscureConfirm,
                      onToggle: () {
                        setState(() => obscureConfirm = !obscureConfirm);
                      },
                    ),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        isMismatch
                            ? 'Konfirmasi kata sandi belum sama.'
                            : isSamePassword
                            ? 'Kata sandi baru tidak boleh sama dengan kata sandi saat ini.'
                            : 'Kata sandi minimal 8 karakter.',
                        style: TextStyle(
                          color: isMismatch || isSamePassword
                              ? AppColors.red
                              : AppColors.dark3,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: isSaving || !isFormValid
                            ? null
                            : _savePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          disabledBackgroundColor: AppColors.light2,
                          disabledForegroundColor: AppColors.dark3,
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
                            : const Text('Simpan Kata Sandi'),
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
              'Ubah Kata Sandi',
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

  Widget _passwordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.white,
          suffixIcon: IconButton(
            onPressed: onToggle,
            icon: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.dark3,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.light2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.light2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(
              color: AppColors.primaryBlue,
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessSheet() {
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
              const CircleAvatar(
                radius: 34,
                backgroundColor: Color(0xFFE7F8EF),
                child: Icon(Icons.check, color: Colors.green, size: 34),
              ),
              const SizedBox(height: 16),
              const Text(
                'Kata sandi berhasil diubah',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Gunakan kata sandi baru saat login berikutnya.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.dark2),
              ),
              const SizedBox(height: 20),
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
