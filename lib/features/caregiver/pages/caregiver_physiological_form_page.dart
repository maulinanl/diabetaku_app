import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';
import '../../patient/widgets/patient_health_form_widgets.dart';
import '../widgets/caregiver_health_form_widgets.dart';

class CaregiverPhysiologicalFormPage extends StatefulWidget {
  final int patientId;
  final String patientInitial;
  final String patientName;
  final String patientInfo;

  const CaregiverPhysiologicalFormPage({
    super.key,
    required this.patientId,
    required this.patientInitial,
    required this.patientName,
    required this.patientInfo,
  });

  @override
  State<CaregiverPhysiologicalFormPage> createState() =>
      _CaregiverPhysiologicalFormPageState();
}

class _CaregiverPhysiologicalFormPageState
    extends State<CaregiverPhysiologicalFormPage> {
  final systolicCtr = TextEditingController();
  final diastolicCtr = TextEditingController();
  final weightCtr = TextEditingController();
  final heightCtr = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  bool isSaving = false;
  bool isLoadingHeight = true;

  bool get isValid {
    return systolicCtr.text.trim().isNotEmpty ||
        diastolicCtr.text.trim().isNotEmpty ||
        weightCtr.text.trim().isNotEmpty;
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

  double? get bmi {
    final weight = double.tryParse(weightCtr.text.trim());
    final heightCm = double.tryParse(heightCtr.text.trim());

    if (weight == null || heightCm == null || heightCm <= 0) return null;

    final heightM = heightCm / 100;
    return double.parse((weight / (heightM * heightM)).toStringAsFixed(1));
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

    _loadPatientHeight();
  }

  @override
  void dispose() {
    systolicCtr.dispose();
    diastolicCtr.dispose();
    weightCtr.dispose();
    heightCtr.dispose();
    super.dispose();
  }

  Future<void> _loadPatientHeight() async {
    try {
      final data = await ApiService.getCaregiverPatientDashboard(widget.patientId);
      final profile = data['profile'] ?? {};
      final height = profile['height_cm'];

      if (!mounted) return;

      setState(() {
        heightCtr.text = height == null ? '' : height.toString();
        isLoadingHeight = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoadingHeight = false);
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
      await ApiService.storeCaregiverPhysiological(
        patientId: widget.patientId,
        systolic: int.tryParse(systolicCtr.text.trim()),
        diastolic: int.tryParse(diastolicCtr.text.trim()),
        weightKg: double.tryParse(weightCtr.text.trim()),
        bmi: bmi,
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

  Widget _bmiBox() {
    final value = bmi;

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
            value == null ? '-' : value.toStringAsFixed(1),
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

  Widget _input({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      enabled: !isSaving,
      readOnly: readOnly,
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
              title: 'Tambah Data Fisiologis',
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
                    const PatientFormLabel('Tekanan Darah (opsional)'),
                    Row(
                      children: [
                        Expanded(
                          child: _input(
                            controller: systolicCtr,
                            hint: 'Sistolik',
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _input(
                            controller: diastolicCtr,
                            hint: 'Diastolik',
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          ),
                        ),
                      ],
                    ),
                    const PatientFormLabel('Berat Badan (kg)'),
                    _input(
                      controller: weightCtr,
                      hint: 'Masukkan berat badan',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                    ),
                    const PatientFormLabel('Tinggi Badan (cm)'),
                    _input(
                      controller: heightCtr,
                      hint: isLoadingHeight
                          ? 'Mengambil tinggi badan...'
                          : 'Tinggi badan pasien',
                      keyboardType: TextInputType.number,
                      readOnly: true,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tinggi badan diambil dari profil pasien dan tidak dapat diubah oleh pendamping.',
                      style: TextStyle(
                        color: AppColors.dark2,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _bmiBox(),
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
