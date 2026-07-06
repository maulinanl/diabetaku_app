import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';
import '../widgets/patient_health_form_widgets.dart';

class PatientPhysiologyFormPage extends StatefulWidget {
  const PatientPhysiologyFormPage({super.key});

  @override
  State<PatientPhysiologyFormPage> createState() =>
      _PatientPhysiologyFormPageState();
}

class _PatientPhysiologyFormPageState extends State<PatientPhysiologyFormPage> {
  final systolicCtr = TextEditingController();
  final diastolicCtr = TextEditingController();
  final weightCtr = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  bool isSaving = false;

  bool get isValid => double.tryParse(weightCtr.text.trim()) != null;

  double get estimatedBmi {
    final weight = double.tryParse(weightCtr.text.trim()) ?? 0;
    const heightMeter = 1.68;

    if (weight <= 0) return 0;
    return weight / (heightMeter * heightMeter);
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
    for (final controller in [systolicCtr, diastolicCtr, weightCtr]) {
      controller.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    systolicCtr.dispose();
    diastolicCtr.dispose();
    weightCtr.dispose();
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

      final measuredAt = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      await ApiService.storePhysiological(
        patientId: patientId,
        systolic: systolicCtr.text.trim().isEmpty
            ? null
            : int.parse(systolicCtr.text.trim()),
        diastolic: diastolicCtr.text.trim().isEmpty
            ? null
            : int.parse(diastolicCtr.text.trim()),
        weightKg: double.parse(weightCtr.text.trim()),
        bmi: estimatedBmi == 0 ? null : estimatedBmi,
        measuredAt: measuredAt,
      );

      if (!mounted) return;

      showPatientHealthSuccessSheet(
        context: context,
        title: 'Data berhasil disimpan',
        message: 'Data fisiologis berhasil tersimpan.',
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
    final bmi = estimatedBmi;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            PatientFormHeader(
              title: 'Tambah Data Fisiologis',
              disabled: isSaving,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PatientFormSectionTitle('Data Fisiologis'),
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
                    const PatientFormLabel('Tekanan darah (opsional)'),
                    Row(
                      children: [
                        Expanded(
                          child: _input(
                            controller: systolicCtr,
                            hint: 'Sistolik',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _input(
                            controller: diastolicCtr,
                            hint: 'Diastolik',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ],
                    ),
                    const PatientFormLabel('Berat badan (kg)*'),
                    _input(
                      controller: weightCtr,
                      hint: 'Masukkan berat badan',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _bmiBox(bmi),
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
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      enabled: !isSaving,
      decoration: patientFormInputDecoration(hint: hint),
    );
  }

  Widget _bmiBox(double bmi) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.light1),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Estimasi BMI',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            bmi == 0 ? '-' : bmi.toStringAsFixed(1),
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
