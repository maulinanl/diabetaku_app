import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/medication_dose_formatter.dart';
import '../../../data/services/api_service.dart';
import '../widgets/patient_health_form_widgets.dart';

class PatientMedicationFormPage extends StatefulWidget {
  const PatientMedicationFormPage({super.key});

  @override
  State<PatientMedicationFormPage> createState() =>
      _PatientMedicationFormPageState();
}

class _PatientMedicationFormPageState extends State<PatientMedicationFormPage> {
  final noteCtr = TextEditingController();

  String selectedSchedule = 'Semua';
  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  List<Map<String, dynamic>> prescriptions = [];

  List<String> get schedules {
    final result = prescriptions
        .map((e) => e['session_name']?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();

    const order = ['Pagi', 'Siang', 'Sore', 'Malam', 'Sebelum Tidur'];

    result.sort((a, b) {
      final aIndex = order.indexOf(a);
      final bIndex = order.indexOf(b);

      if (aIndex != -1 && bIndex != -1) {
        return aIndex.compareTo(bIndex);
      }

      if (aIndex != -1) return -1;
      if (bIndex != -1) return 1;

      return a.compareTo(b);
    });

    return ['Semua', ...result];
  }

  bool _isSameSchedule(Map<String, dynamic> item) {
    return selectedSchedule == 'Semua' ||
        item['session_name']?.toString() == selectedSchedule;
  }

  bool get hasMedicationChanges {
    return prescriptions.any((item) => _hasMedicationChange(item));
  }

  bool _hasMedicationChange(Map<String, dynamic> item) {
    if (!_isSameSchedule(item)) return false;

    final checked = item['checked'] == true;
    final alreadySaved = item['already_saved'] == true;
    final originalChecked = item['original_checked'] == true;

    if (!alreadySaved) return checked;

    return checked != originalChecked;
  }

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
  }

  @override
  void dispose() {
    noteCtr.dispose();
    super.dispose();
  }

  Future<void> _loadPrescriptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final patientId = prefs.getInt('patient_id');

      if (patientId == null) {
        throw Exception('Patient ID tidak ditemukan');
      }

      final data = await ApiService.getActivePrescriptions(patientId);

      if (!mounted) return;

      setState(() {
        prescriptions = data.map((item) {
          final logStatus =
              item['today_status']?.toString() ??
              item['log_status']?.toString() ??
              '';

          final alreadyLogged =
              item['already_logged'] == true ||
              item['log_id'] != null ||
              logStatus.isNotEmpty;

          final checked = logStatus == 'Diminum' || item['checked'] == true;

          return {
            ...item,
            'checked': checked,
            'already_saved': alreadyLogged,
            'original_status': logStatus,
            'original_checked': checked,
          };
        }).toList();

        selectedSchedule = 'Semua';
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  void _toggleMedicine(int index, bool? value) {
    setState(() {
      prescriptions[index]['checked'] = value ?? false;
    });
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    final changedMedicines = prescriptions.where(_hasMedicationChange).toList();

    if (changedMedicines.isEmpty) {
      showPatientFormSnackBar(
        context: context,
        message: 'Belum ada perubahan checklist obat',
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final patientId = prefs.getInt('patient_id');

      if (patientId == null) {
        throw Exception('Patient ID tidak ditemukan');
      }

      final now = DateTime.now();

      for (final item in changedMedicines) {
        final status = item['checked'] == true ? 'Diminum' : 'Dibatalkan';

        await ApiService.storeMedication(
          patientId: patientId,
          prescriptionId: int.parse(item['prescription_id'].toString()),
          scheduleId: int.parse(item['prescription_schedule_id'].toString()),
          status: status,
          consumedAt: now,
          note: noteCtr.text.trim().isEmpty ? null : noteCtr.text.trim(),
        );
      }

      if (!mounted) return;

      setState(() {
        for (final item in changedMedicines) {
          final status = item['checked'] == true ? 'Diminum' : 'Dibatalkan';
          final checked = status == 'Diminum';

          item['checked'] = checked;
          item['already_saved'] = true;
          item['log_status'] = status;
          item['today_status'] = status;
          item['original_status'] = status;
          item['original_checked'] = checked;
        }
      });

      showPatientHealthSuccessSheet(
        context: context,
        title: 'Kepatuhan obat tersimpan',
        message: 'Perubahan checklist obat berhasil disimpan.',
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

  @override
  Widget build(BuildContext context) {
    final filteredPrescriptions = prescriptions.asMap().entries.where((entry) {
      return _isSameSchedule(entry.value);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            PatientFormHeader(
              title: 'Tambah Data Obat',
              disabled: isSaving,
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                      ? _errorState()
                      : prescriptions.isEmpty
                          ? _noPrescriptionState()
                          : SingleChildScrollView(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 18, 20, 28),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const PatientFormSectionTitle(
                                    'Kepatuhan Obat',
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Checklist obat yang sudah diminum sesuai resep aktif dari dokter.',
                                    style: TextStyle(
                                      color: AppColors.dark2,
                                      fontSize: 12,
                                      height: 1.45,
                                    ),
                                  ),
                                  const PatientFormLabel('Waktu minum*'),
                                  _scheduleTabs(),
                                  const PatientFormLabel(
                                    'Daftar obat dari resep dokter*',
                                  ),
                                  if (filteredPrescriptions.isEmpty)
                                    _emptyPrescription()
                                  else
                                    Column(
                                      children:
                                          filteredPrescriptions.map((entry) {
                                        final index = entry.key;
                                        final item = entry.value;

                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 12),
                                          child: _medicineCard(
                                            index: index,
                                            medicine: item['medication_name']
                                                    ?.toString() ??
                                                '-',
                                            sessionName: item['session_name']
                                                    ?.toString() ??
                                                '-',
                                            dosage:
                                                item['dosage']?.toString() ??
                                                    '-',
                                            form: item['form']?.toString() ??
                                                '-',
                                            mealRule: item['meal_rule']
                                                    ?.toString() ??
                                                '-',
                                            notes:
                                                item['notes']?.toString() ??
                                                    '-',
                                            dosePerSession:
                                                item['dose_per_session']
                                                        ?.toString() ??
                                                    '-',
                                            reminderTime: _formatTime(
                                              item['reminder_time'] ??
                                                  item['default_reminder_time'],
                                            ),
                                            checked: item['checked'] == true,
                                            alreadySaved:
                                                item['already_saved'] == true,
                                            changed: _hasMedicationChange(item),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  const PatientFormLabel('Catatan (opsional)'),
                                  _input(
                                    controller: noteCtr,
                                    hint: 'Contoh: obat diminum setelah makan',
                                  ),
                                  const SizedBox(height: 26),
                                  PatientFormSubmitButton(
                                    label: 'Simpan Checklist',
                                    enabled: hasMedicationChanges,
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

  Widget _scheduleTabs() {
    return Row(
      children: schedules.map((item) {
        return Expanded(
          flex: _scheduleFlex(item),
          child: Padding(
            padding: EdgeInsets.only(right: item == schedules.last ? 0 : 8),
            child: PatientChoiceChip(
              text: item,
              selected: selectedSchedule == item,
              width: double.infinity,
              onTap: isSaving
                  ? null
                  : () {
                      setState(() {
                        selectedSchedule = item;
                      });
                    },
            ),
          ),
        );
      }).toList(),
    );
  }

  int _scheduleFlex(String item) {
    if (item == 'Sebelum Tidur') return 8;
    if (item == 'Semua') return 5;
    return item.length <= 5 ? 4 : 5;
  }

  Widget _medicineCard({
    required int index,
    required String medicine,
    required String sessionName,
    required String dosage,
    required String form,
    required String mealRule,
    required String notes,
    required String dosePerSession,
    required String reminderTime,
    required bool checked,
    required bool alreadySaved,
    required bool changed,
  }) {
    final selected = checked;

    return InkWell(
      onTap: isSaving ? null : () => _toggleMedicine(index, !checked),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: checked ? AppColors.veryLightBlue : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primaryBlue : AppColors.light1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: checked,
              activeColor: AppColors.primaryBlue,
              onChanged: isSaving ? null : (value) => _toggleMedicine(index, value),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          medicine,
                          style: const TextStyle(
                            color: AppColors.dark1,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (changed || alreadySaved)
                        _medicationChangeBadge(
                          changed: changed,
                          checked: checked,
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    medicationDoseLine(
                      dosage: dosage,
                      dosePerSession: dosePerSession,
                      form: form,
                    ),
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Jadwal: $sessionName',
                    style: const TextStyle(
                      color: AppColors.dark2,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Aturan: $mealRule',
                    style: const TextStyle(
                      color: AppColors.dark2,
                      fontSize: 11,
                    ),
                  ),
                  if (reminderTime != '-') ...[
                    const SizedBox(height: 4),
                    Text(
                      'Pengingat: $reminderTime',
                      style: const TextStyle(
                        color: AppColors.dark2,
                        fontSize: 11,
                      ),
                    ),
                  ],
                  if (notes != '-') ...[
                    const SizedBox(height: 4),
                    Text(
                      notes,
                      style: const TextStyle(
                        color: AppColors.dark3,
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _medicationChangeBadge({
    required bool changed,
    required bool checked,
  }) {
    final text = changed
        ? 'Belum disimpan'
        : checked
            ? 'Sudah dicatat'
            : 'Dibatalkan';

    final color = changed
        ? Colors.orange
        : checked
            ? const Color(0xFF10C878)
            : AppColors.red;

    final bg = changed
        ? const Color(0xFFFFF4C7)
        : checked
            ? const Color(0xFFEAFBF3)
            : AppColors.lightRed;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _noPrescriptionState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Belum ada resep aktif',
          style: TextStyle(color: AppColors.dark2, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _emptyPrescription() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.light1),
      ),
      child: const Text(
        'Tidak ada obat pada jadwal ini',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.dark2, fontSize: 13),
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          errorMessage!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.dark2, fontSize: 13),
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      enabled: !isSaving,
      maxLines: 3,
      decoration: patientFormInputDecoration(hint: hint),
    );
  }

  String _formatTime(dynamic value) {
    if (value == null) return '-';
    final text = value.toString();
    if (text.isEmpty) return '-';
    if (text.length >= 5) return text.substring(0, 5);
    return text;
  }
}
