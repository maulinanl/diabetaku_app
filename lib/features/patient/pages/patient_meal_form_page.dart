import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';
import 'package:diabetaku_app/core/theme/app_button_styles.dart';

class PatientMealFormPage extends StatefulWidget {
  const PatientMealFormPage({super.key});

  @override
  State<PatientMealFormPage> createState() => _PatientMealFormPageState();
}

class _PatientMealFormPageState extends State<PatientMealFormPage> {
  final carbCtr = TextEditingController();
  final calorieCtr = TextEditingController();
  final descriptionCtr = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  String selectedMealType = 'Sarapan';
  bool isSaving = false;

  final mealTypes = const [
    ['Sarapan', Icons.wb_sunny_outlined],
    ['Makan Siang', Icons.restaurant_outlined],
    ['Makan Malam', Icons.dinner_dining_outlined],
    ['Camilan', Icons.cookie_outlined],
  ];

  bool get isValid {
    return carbCtr.text.trim().isNotEmpty ||
        calorieCtr.text.trim().isNotEmpty ||
        descriptionCtr.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    carbCtr.addListener(() => setState(() {}));
    calorieCtr.addListener(() => setState(() {}));
    descriptionCtr.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    carbCtr.dispose();
    calorieCtr.dispose();
    descriptionCtr.dispose();
    super.dispose();
  }

  String get dateText {
    return '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}';
  }

  String get timeText {
    return '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
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
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
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
      setState(() => selectedTime = picked);
    }
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    setState(() => isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final patientId = prefs.getInt('patient_id');

      if (patientId == null) {
        throw Exception('Patient ID tidak ditemukan');
      }

      final mealDate = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      await ApiService.storeMeal(
        patientId: patientId,
        mealType: selectedMealType,
        carbohydrateGram: carbCtr.text.trim().isEmpty
            ? null
            : double.parse(carbCtr.text.trim()),
        calories: calorieCtr.text.trim().isEmpty
            ? null
            : double.parse(calorieCtr.text.trim()),
        description: descriptionCtr.text.trim().isEmpty
            ? null
            : descriptionCtr.text.trim(),
        mealDate: mealDate,
      );

      if (!mounted) return;
      _showSuccessSheet();
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
                'Data berhasil disimpan',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Data pola makan berhasil tersimpan.',
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
                    Navigator.pop(context, true);
                  },
                  style: AppButtonStyles.primary,
                  child: const Text('Tambah data lain'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  Navigator.pop(context, true);
                },
                child: const Text(
                  'Kembali ke beranda',
                  style: TextStyle(color: AppColors.primaryBlue),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showStyledSnackBar({required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
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
                    _sectionTitle('Pola Makan'),

                    _label('Tanggal dan waktu*'),
                    Row(
                      children: [
                        Expanded(
                          child: _dateTimeBox(
                            text: dateText,
                            icon: Icons.calendar_today_outlined,
                            onTap: _pickDate,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _dateTimeBox(
                            text: timeText,
                            icon: Icons.access_time,
                            onTap: _pickTime,
                          ),
                        ),
                      ],
                    ),

                    _label('Tipe makan*'),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: mealTypes.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.95,
                      ),
                      itemBuilder: (context, index) {
                        final item = mealTypes[index];
                        final title = item[0] as String;
                        final icon = item[1] as IconData;
                        final selected = selectedMealType == title;

                        return GestureDetector(
                          onTap: isSaving
                              ? null
                              : () {
                                  setState(() => selectedMealType = title);
                                },
                          child: Container(
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.veryLightBlue
                                  : AppColors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primaryBlue
                                    : AppColors.light1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  icon,
                                  color: AppColors.primaryBlue,
                                  size: 19,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    _label('Estimasi karbohidrat (gram)'),
                    _input(
                      controller: carbCtr,
                      hint: 'Masukkan estimasi karbohidrat',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                    ),

                    _label('Estimasi kalori (kkal)'),
                    _input(
                      controller: calorieCtr,
                      hint: 'Masukkan estimasi kalori',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                    ),

                    _label('Deskripsi makanan'),
                    _input(
                      controller: descriptionCtr,
                      hint: 'Tulis makanan yang dikonsumsi',
                    ),

                    const SizedBox(height: 26),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isValid && !isSaving ? _save : null,
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
                                'Simpan',
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
              'Tambah Data Pola Makan',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.primaryBlue,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _dateTimeBox({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isSaving ? null : onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.light1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: AppColors.dark1, fontSize: 13),
              ),
            ),
            Icon(icon, color: AppColors.primaryBlue, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      enabled: !isSaving,
      decoration: InputDecoration(
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
        disabledBorder: OutlineInputBorder(
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
      ),
    );
  }
}
