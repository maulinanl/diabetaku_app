import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';
import 'email_verification_page.dart';

class RegisterDoctorStep2Page extends StatefulWidget {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;
  final String confirmPassword;
  final String gender;

  const RegisterDoctorStep2Page({
    super.key,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.confirmPassword,
    required this.gender,
  });

  @override
  State<RegisterDoctorStep2Page> createState() =>
      _RegisterDoctorStep2PageState();
}

class _RegisterDoctorStep2PageState extends State<RegisterDoctorStep2Page> {
  final strCtr = TextEditingController();
  final institutionCtr = TextEditingController();

  int? specializationId;
  List<Map<String, dynamic>> specializations = [];

  bool isLoadingSpecialization = true;
  bool isRegistering = false;

  bool get isValid =>
      specializationId != null &&
      strCtr.text.trim().isNotEmpty &&
      institutionCtr.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();

    strCtr.addListener(() => setState(() {}));
    institutionCtr.addListener(() => setState(() {}));

    _loadSpecializations();
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

  Future<void> _registerDoctor() async {
    setState(() => isRegistering = true);

    try {
      await ApiService.registerDoctor(
        fullName: widget.fullName,
        email: widget.email,
        phoneNumber: widget.phoneNumber,
        password: widget.password,
        confirmPassword: widget.confirmPassword,
        gender: widget.gender,
        specializationId: specializationId!,
        strNumber: strCtr.text.trim(),
        institution: institutionCtr.text.trim(),
      );

      if (!mounted) return;

      setState(() => isRegistering = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EmailVerificationPage(email: widget.email),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => isRegistering = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  void dispose() {
    strCtr.dispose();
    institutionCtr.dispose();
    super.dispose();
  }

  String _selectedSpecializationName() {
    final selected = specializations.where((item) {
      return int.tryParse(item['specialization_id'].toString()) ==
          specializationId;
    }).toList();

    if (selected.isEmpty) return 'Pilih spesialisasi';

    return selected.first['specialization_name']?.toString() ??
        'Pilih spesialisasi';
  }

  void _showSpecializationSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
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
                const Text(
                  'Pilih Spesialisasi',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    children: specializations.map((item) {
                      final id =
                          int.tryParse(item['specialization_id'].toString()) ??
                              0;
                      final name =
                          item['specialization_name']?.toString() ?? '-';
                      final selected = id == specializationId;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          name,
                          style: TextStyle(
                            color: selected
                                ? AppColors.primaryBlue
                                : AppColors.dark1,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                        trailing: selected
                            ? const Icon(
                                Icons.check,
                                color: AppColors.primaryBlue,
                              )
                            : null,
                        onTap: () {
                          setState(() => specializationId = id);
                          Navigator.pop(sheetContext);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 18, 28, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Spesialisasi'),
                    _specializationField(),

                    _label('Nomor STR'),
                    _input(strCtr, 'Masukkan nomor STR'),

                    _label('Institusi'),
                    _input(
                      institutionCtr,
                      'Masukkan institusi atau rumah sakit',
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                            isValid && !isRegistering ? _registerDoctor : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          disabledBackgroundColor: const Color(0xFFAFCBEA),
                          disabledForegroundColor: AppColors.white,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: isRegistering
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Daftar sebagai Dokter',
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

  Widget _specializationField() {
    return InkWell(
      onTap: isLoadingSpecialization ? null : _showSpecializationSheet,
      child: InputDecorator(
        decoration: _inputDecoration(),
        child: Text(
          isLoadingSpecialization ? 'Memuat...' : _selectedSpecializationName(),
          style: TextStyle(
            color: specializationId == null ? AppColors.dark4 : AppColors.dark1,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed:
                    isRegistering ? null : () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: AppColors.dark2),
              ),
              const Expanded(
                child: Text(
                  'Daftar sebagai Dokter',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 18),
          _stepIndicator(currentStep: 2),
          const SizedBox(height: 18),
          const Text(
            'Lengkapi data untuk membuat akun',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.dark2, fontSize: 13),
          ),
          const SizedBox(height: 4),
          const Text(
            'Langkah 2 dari 2 - Data Profesional',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.dark2, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _stepIndicator({required int currentStep}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 4,
          decoration: BoxDecoration(
            color: currentStep == 1 ? AppColors.primaryBlue : AppColors.light1,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 44,
          height: 4,
          decoration: BoxDecoration(
            color: currentStep == 2 ? AppColors.primaryBlue : AppColors.light1,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 12),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.dark2,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _input(TextEditingController controller, String hint) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(hint: hint),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.dark4, fontSize: 13),
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