import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';
import 'package:diabetaku_app/core/theme/app_button_styles.dart';

class CaregiverMealFormPage extends StatefulWidget {
  final int patientId;
  final String patientInitial;
  final String patientName;
  final String patientInfo;

  const CaregiverMealFormPage({
    super.key,
    required this.patientId,
    required this.patientInitial,
    required this.patientName,
    required this.patientInfo,
  });

  @override
  State<CaregiverMealFormPage> createState() => _CaregiverMealFormPageState();
}

class _CaregiverMealFormPageState extends State<CaregiverMealFormPage> {
  int selectedMealType = 0;

  final mealTypes = const ['Sarapan', 'Makan Siang', 'Makan Malam', 'Snack'];

  final carbController = TextEditingController();
  final caloriesController = TextEditingController();
  final foodController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  bool isSaving = false;

  int get mealTypeId {
    switch (selectedMealType) {
      case 0:
        return 1;
      case 1:
        return 2;
      case 2:
        return 3;
      case 3:
        return 4;
      default:
        return 1;
    }
  }

  bool get isValid {
    final carb = double.tryParse(carbController.text.trim());

    return carb != null &&
        carb > 0 &&
        foodController.text.trim().isNotEmpty;
  }

  DateTime get mealDate {
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
  }

  @override
  void initState() {
    super.initState();

    for (final controller in [
      carbController,
      caloriesController,
      foodController,
    ]) {
      controller.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    carbController.dispose();
    caloriesController.dispose();
    foodController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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

  Future<void> _saveData() async {
    if (!isValid || isSaving) return;

    FocusScope.of(context).unfocus();
    setState(() => isSaving = true);

    try {
      await ApiService.storeCaregiverMeal(
        patientId: widget.patientId,
        mealTypeId: mealTypeId,
        carbohydrateGram: double.parse(carbController.text.trim()),
        calories: caloriesController.text.trim().isEmpty
            ? null
            : double.tryParse(caloriesController.text.trim()),
        description: foodController.text.trim(),
        mealDate: mealDate,
      );

      if (!mounted) return;
      _showSuccessSheet(context);
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
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        title: const Text(
          'Tambah Data',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _patientCard(),
            const SizedBox(height: 18),
            const Text(
              'Pola Makan',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),

            _label('Tanggal dan waktu*'),
            Row(
              children: [
                Expanded(
                  child: _dateTimeBox(
                    text: _formatDate(selectedDate),
                    icon: Icons.calendar_today_outlined,
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _dateTimeBox(
                    text: _formatTime(selectedTime),
                    icon: Icons.access_time,
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            _label('Tipe makan*'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(mealTypes.length, (index) {
                final selected = selectedMealType == index;

                return GestureDetector(
                  onTap: () => setState(() => selectedMealType = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primaryBlue : AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected
                            ? AppColors.primaryBlue
                            : AppColors.light1,
                      ),
                    ),
                    child: Text(
                      mealTypes[index],
                      style: TextStyle(
                        color: selected ? Colors.white : AppColors.primaryBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 14),

            _label('Estimasi karbohidrat (gram)*'),
            _input(
              hint: 'Masukkan estimasi karbohidrat',
              controller: carbController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
            ),

            const SizedBox(height: 14),

            _label('Estimasi kalori'),
            _input(
              hint: 'Opsional, contoh: 450',
              controller: caloriesController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
            ),

            const SizedBox(height: 14),

            _label('Deskripsi makanan*'),
            _input(
              hint: 'Contoh: Nasi putih, ayam goreng, sayur bayam',
              controller: foodController,
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: isValid && !isSaving ? _saveData : null,
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
                    : const Text('Simpan'),
              ),
            ),

            const SizedBox(height: 12),

            Center(
              child: TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(context),
                child: const Text(
                  'Batal',
                  style: TextStyle(color: AppColors.primaryBlue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _patientCard() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.light1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.lightBlue,
            child: Text(
              widget.patientInitial,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.patientName,
                  style: const TextStyle(
                    color: AppColors.dark1,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.patientInfo,
                  style: const TextStyle(color: AppColors.dark2, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 12,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
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
            Icon(icon, color: AppColors.primaryBlue, size: 17),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: AppColors.dark1,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input({
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.dark3, fontSize: 12),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 13,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.light1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
      ),
    );
  }

  void _showSuccessSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
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
                radius: 36,
                backgroundColor: Color(0xFFEAFBF3),
                child: Icon(Icons.check, color: Color(0xFF10C878), size: 36),
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
                'Data menunggu konfirmasi pasien sebelum masuk ke riwayat kesehatan.',
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
                  style: AppButtonStyles.primary,
                  child: const Text('Kembali'),
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
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
