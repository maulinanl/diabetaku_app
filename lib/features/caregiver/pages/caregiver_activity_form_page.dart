import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';
import '../../patient/widgets/patient_health_form_widgets.dart';
import '../widgets/caregiver_health_form_widgets.dart';

class CaregiverActivityFormPage extends StatefulWidget {
  final int patientId;
  final String patientInitial;
  final String patientName;
  final String patientInfo;

  const CaregiverActivityFormPage({
    super.key,
    required this.patientId,
    required this.patientInitial,
    required this.patientName,
    required this.patientInfo,
  });

  @override
  State<CaregiverActivityFormPage> createState() =>
      _CaregiverActivityFormPageState();
}

class _CaregiverActivityFormPageState extends State<CaregiverActivityFormPage> {
  final durationCtr = TextEditingController();
  final noteCtr = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  String selectedActivity = 'Jalan Kaki';
  String selectedIntensity = 'Sedang';
  bool isSaving = false;

  final activities = const [
    'Jalan Kaki',
    'Lari',
    'Bersepeda',
    'Senam',
    'Yoga',
    'Renang',
  ];

  final intensities = const ['Ringan', 'Sedang', 'Berat'];

  bool get isValid => int.tryParse(durationCtr.text.trim()) != null;

  int get selectedActivityTypeId {
    final index = activities.indexOf(selectedActivity);
    return index < 0 ? 1 : index + 1;
  }

  DateTime get activityDate {
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
    durationCtr.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    durationCtr.dispose();
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
      await ApiService.storeCaregiverActivity(
        patientId: widget.patientId,
        activityTypeId: selectedActivityTypeId,
        durationMinutes: int.parse(durationCtr.text.trim()),
        intensity: selectedIntensity,
        activityDate: activityDate,
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
              title: 'Tambah Data Aktivitas',
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
                    const PatientFormSectionTitle('Aktivitas Fisik'),
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
                    PatientFormSelectField(
                      label: 'Jenis aktivitas',
                      hint: 'Pilih jenis aktivitas',
                      value: selectedActivity,
                      items: activities,
                      disabled: isSaving,
                      onSelected: (value) {
                        setState(() => selectedActivity = value);
                      },
                    ),
                    const PatientFormLabel('Durasi aktivitas (menit)*'),
                    _input(
                      controller: durationCtr,
                      hint: 'Masukkan durasi aktivitas',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const PatientFormLabel('Intensitas*'),
                    Row(
                      children: intensities.map((item) {
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: item == intensities.last ? 0 : 8,
                            ),
                            child: PatientChoiceChip(
                              text: item,
                              selected: selectedIntensity == item,
                              width: double.infinity,
                              onTap: isSaving
                                  ? null
                                  : () => setState(
                                        () => selectedIntensity = item,
                                      ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const PatientFormLabel('Catatan (opsional)'),
                    _input(
                      controller: noteCtr,
                      hint: 'Tambahkan catatan aktivitas',
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
