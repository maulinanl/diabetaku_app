import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';
import '../../patient/widgets/patient_health_form_widgets.dart';
import '../widgets/caregiver_health_form_widgets.dart';

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

  int get mealTypeId {
    switch (selectedMealType) {
      case 'Sarapan':
        return 1;
      case 'Makan Siang':
        return 2;
      case 'Makan Malam':
        return 3;
      case 'Camilan':
        return 4;
      default:
        return 1;
    }
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

    if (picked != null) setState(() => selectedDate = picked);
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

    if (picked != null) setState(() => selectedTime = picked);
  }

  Future<void> _save() async {
    if (!isValid || isSaving) return;

    FocusScope.of(context).unfocus();
    setState(() => isSaving = true);

    try {
      await ApiService.storeCaregiverMeal(
        patientId: widget.patientId,
        mealTypeId: mealTypeId,
        carbohydrateGram: carbCtr.text.trim().isEmpty
            ? null
            : double.parse(carbCtr.text.trim()),
        calories: calorieCtr.text.trim().isEmpty
            ? null
            : double.parse(calorieCtr.text.trim()),
        description:
            descriptionCtr.text.trim().isEmpty ? null : descriptionCtr.text.trim(),
        mealDate: mealDate,
      );

      if (!mounted) return;
      showCaregiverHealthSuccessSheet(context: context);
    } catch (e) {
      if (!mounted) return;
      showCaregiverFormSnackBar(
        context: context,
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
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
      decoration: patientFormInputDecoration(hint: hint),
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
                    CaregiverPatientFormCard(
                      initial: widget.patientInitial,
                      name: widget.patientName,
                      info: widget.patientInfo,
                    ),
                    const SizedBox(height: 18),
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
                        final title = item[0] as String;
                        final icon = item[1] as IconData;

                        return PatientMealTypeCard(
                          text: title,
                          icon: icon,
                          selected: selectedMealType == title,
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
}
