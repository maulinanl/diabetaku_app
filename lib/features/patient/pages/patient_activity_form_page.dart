import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';
import '../widgets/patient_health_form_widgets.dart';

class PatientActivityFormPage extends StatefulWidget {
  const PatientActivityFormPage({super.key});

  @override
  State<PatientActivityFormPage> createState() =>
      _PatientActivityFormPageState();
}

class _PatientActivityFormPageState extends State<PatientActivityFormPage> {
  final durationCtr = TextEditingController();
  final noteCtr = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  String selectedActivity = 'Jalan Kaki';
  String selectedIntensity = 'Sedang';
  bool isSaving = false;

  final activities = const [
    {'id': 1, 'name': 'Jalan Kaki'},
    {'id': 2, 'name': 'Lari'},
    {'id': 3, 'name': 'Bersepeda'},
    {'id': 4, 'name': 'Senam'},
    {'id': 5, 'name': 'Yoga'},
    {'id': 6, 'name': 'Renang'},
  ];

  final intensities = const ['Ringan', 'Sedang', 'Berat'];

  bool get isValid => durationCtr.text.trim().isNotEmpty;

  int get selectedActivityTypeId {
    final item = activities.firstWhere(
      (e) => e['name'] == selectedActivity,
      orElse: () => activities.first,
    );

    return int.parse(item['id'].toString());
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

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() => isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final patientId = prefs.getInt('patient_id');

      if (patientId == null) {
        throw Exception('Patient ID tidak ditemukan');
      }

      final activityDate = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      await ApiService.storeActivity(
        patientId: patientId,
        activityTypeId: selectedActivityTypeId,
        durationMinutes: int.parse(durationCtr.text.trim()),
        intensity: selectedIntensity,
        activityDate: activityDate,
      );

      if (!mounted) return;

      showPatientHealthSuccessSheet(
        context: context,
        title: 'Data berhasil disimpan',
        message: 'Data aktivitas fisik berhasil tersimpan.',
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
    final activityItems = activities.map((e) => e['name'].toString()).toList();

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
                      label: 'Jenis aktivitas*',
                      hint: 'Pilih jenis aktivitas',
                      value: selectedActivity,
                      items: activityItems,
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
                                  : () => setState(() {
                                        selectedIntensity = item;
                                      }),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const PatientFormLabel('Catatan (opsional)'),
                    _input(
                      controller: noteCtr,
                      hint: 'Tambahkan catatan aktivitas',
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
