import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';
import '../widgets/patient_health_form_widgets.dart';

class PatientGlucoseFormPage extends StatefulWidget {
  const PatientGlucoseFormPage({super.key});

  @override
  State<PatientGlucoseFormPage> createState() => _PatientGlucoseFormPageState();
}

class _PatientGlucoseFormPageState extends State<PatientGlucoseFormPage> {
  final glucoseCtr = TextEditingController();
  final noteCtr = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String selectedType = 'Puasa';
  bool isSaving = false;

  final types = const ['Puasa', 'Dua Jam Setelah Makan', 'Sewaktu'];

  bool get isValid => double.tryParse(glucoseCtr.text.trim()) != null;

  String get dateText {
    return '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}';
  }

  String get timeText {
    return '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    glucoseCtr.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    glucoseCtr.dispose();
    noteCtr.dispose();
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

      final recordedAt = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      await ApiService.storeGlucose(
        patientId: patientId,
        measurementType: selectedType,
        glucoseValue: double.parse(glucoseCtr.text.trim()),
        measuredAt: recordedAt,
      );

      if (!mounted) return;

      showPatientHealthSuccessSheet(
        context: context,
        title: 'Data berhasil disimpan',
        message: 'Data glukosa darah berhasil tersimpan.',
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
              title: 'Tambah Data Glukosa',
              disabled: isSaving,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PatientFormSectionTitle('Glukosa Darah'),
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
                    const PatientFormLabel('Tipe pengukuran*'),
                    Row(
                      children: types.map((type) {
                        final flex = type == 'Dua Jam Setelah Makan'
                            ? 11
                            : type == 'Sewaktu'
                                ? 5
                                : 4;

                        return Expanded(
                          flex: flex,
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: type == types.last ? 0 : 8,
                            ),
                            child: PatientChoiceChip(
                              text: type,
                              selected: selectedType == type,
                              width: double.infinity,
                              onTap: isSaving
                                  ? null
                                  : () => setState(() => selectedType = type),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const PatientFormLabel('Nilai glukosa*'),
                    _input(
                      controller: glucoseCtr,
                      hint: 'Masukkan nilai glukosa',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                    ),
                    const PatientFormLabel('Catatan (opsional)'),
                    _input(
                      controller: noteCtr,
                      hint: 'Tambahkan catatan',
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
