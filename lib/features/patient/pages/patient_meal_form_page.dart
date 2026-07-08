import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';
import '../widgets/patient_health_form_widgets.dart';

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
    {'name': 'Sarapan', 'icon': Icons.wb_sunny_outlined},
    {'name': 'Makan Siang', 'icon': Icons.restaurant_outlined},
    {'name': 'Makan Malam', 'icon': Icons.dinner_dining_outlined},
    {'name': 'Camilan', 'icon': Icons.cookie_outlined},
  ];

  bool get isValid {
    return carbCtr.text.trim().isNotEmpty ||
        calorieCtr.text.trim().isNotEmpty ||
        descriptionCtr.text.trim().isNotEmpty;
  }

  String get dateText {
    return '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}';
  }

  String get timeText {
    return '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    for (final controller in [carbCtr, calorieCtr, descriptionCtr]) {
      controller.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    carbCtr.dispose();
    calorieCtr.dispose();
    descriptionCtr.dispose();
    super.dispose();
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

      showPatientHealthSuccessSheet(
        context: context,
        title: 'Data berhasil disimpan',
        message: 'Data pola makan berhasil tersimpan.',
      );
    } catch (e) {
      if (!mounted) return;
      showPatientFormSnackBar(
        context: context,
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
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
            colorScheme: const ColorScheme.light(primary: AppColors.primaryBlue),
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
            colorScheme: const ColorScheme.light(primary: AppColors.primaryBlue),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => selectedTime = picked);
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
            PatientFormHeader(
              title: 'Tambah Data Pola Makan',
              disabled: isSaving,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PatientFormSectionTitle('Pola Makan'),
                    const PatientFormLabel('Tanggal dan waktu*'),
                    Row(
                      children: [
                        Expanded(
                          child: PatientDateTimeBox(
                            text: dateText,
                            icon: Icons.calendar_today_outlined,
                            onTap: _pickDate,
                            disabled: isSaving,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: PatientDateTimeBox(
                            text: timeText,
                            icon: Icons.access_time,
                            onTap: _pickTime,
                            disabled: isSaving,
                          ),
                        ),
                      ],
                    ),
                    const PatientFormLabel('Tipe makan*'),
                    GridView.builder(
                      padding: EdgeInsets.zero,
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
                        final title = item['name'] as String;
                        final icon = item['icon'] as IconData;
                        final selected = selectedMealType == title;

                        return PatientMealTypeCard(
                          text: title,
                          icon: icon,
                          selected: selected,
                          onTap: isSaving
                              ? null
                              : () => setState(() => selectedMealType = title),
                        );
                      },
                    ),
                    const PatientFormLabel('Estimasi karbohidrat (gram)'),
                    _input(
                      controller: carbCtr,
                      hint: 'Masukkan estimasi karbohidrat',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                    ),
                    const PatientFormLabel('Estimasi kalori (kkal)'),
                    _input(
                      controller: calorieCtr,
                      hint: 'Masukkan estimasi kalori',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                    ),
                    const PatientFormLabel('Deskripsi makanan'),
                    _input(
                      controller: descriptionCtr,
                      hint: 'Tulis makanan yang dikonsumsi',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 26),
                    PatientFormSubmitButton(
                      label: 'Simpan',
                      enabled: isValid,
                      isSaving: isSaving,
                      onPressed: _save,
                    ),
                    PatientFormCancelButton(disabled: isSaving),
                  ],
                ),
              ),
            ),
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
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      enabled: !isSaving,
      decoration: patientFormInputDecoration(hint: hint),
    );
  }
}
