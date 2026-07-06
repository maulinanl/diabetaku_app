import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';
import '../../patient/widgets/patient_health_form_widgets.dart';
import '../widgets/caregiver_health_form_widgets.dart';

class CaregiverGlucoseFormPage extends StatefulWidget {
  final int patientId;
  final String patientInitial;
  final String patientName;
  final String patientInfo;

  const CaregiverGlucoseFormPage({
    super.key,
    required this.patientId,
    required this.patientInitial,
    required this.patientName,
    required this.patientInfo,
  });

  @override
  State<CaregiverGlucoseFormPage> createState() =>
      _CaregiverGlucoseFormPageState();
}

class _CaregiverGlucoseFormPageState extends State<CaregiverGlucoseFormPage> {
  final glucoseCtr = TextEditingController();
  final noteCtr = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String selectedType = 'Puasa';
  bool isSaving = false;

  final types = const ['Puasa', 'Dua Jam Setelah Makan', 'Sewaktu'];

  bool get isValid {
    final value = double.tryParse(glucoseCtr.text.trim());
    return value != null && value > 0;
  }

  DateTime get measuredAt {
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
    glucoseCtr.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    glucoseCtr.dispose();
    noteCtr.dispose();
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
      await ApiService.storeCaregiverGlucose(
        patientId: widget.patientId,
        measurementType: selectedType,
        glucoseValue: double.parse(glucoseCtr.text.trim()),
        measuredAt: measuredAt,
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
                    CaregiverPatientFormCard(
                      initial: widget.patientInitial,
                      name: widget.patientName,
                      info: widget.patientInfo,
                    ),
                    const SizedBox(height: 18),
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
                    const PatientFormLabel('Nilai Glukosa*'),
                    TextField(
                      controller: glucoseCtr,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      enabled: !isSaving,
                      decoration: patientFormInputDecoration(
                        hint: 'Masukkan nilai glukosa',
                      ),
                    ),
                    const PatientFormLabel('Catatan (opsional)'),
                    TextField(
                      controller: noteCtr,
                      enabled: !isSaving,
                      decoration: patientFormInputDecoration(
                        hint: 'Tambahkan catatan',
                      ),
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
