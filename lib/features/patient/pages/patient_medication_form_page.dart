import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';

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

    result.sort();
    return ['Semua', ...result];
  }

  bool _isSameSchedule(Map<String, dynamic> item) {
    return selectedSchedule == 'Semua' ||
        item['session_name']?.toString() == selectedSchedule;
  }

  bool get hasUnsavedCheckedMedicine {
    return prescriptions.any((item) {
      return _isSameSchedule(item) &&
          item['checked'] == true &&
          item['already_saved'] != true;
    });
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

          return {
            ...item,
            'checked': logStatus == 'Diminum' || item['checked'] == true,
            'already_saved': alreadyLogged,
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
    if (prescriptions[index]['already_saved'] == true) {
      _showSnackBar('Data obat ini sudah dicatat hari ini');
      return;
    }

    setState(() {
      prescriptions[index]['checked'] = value ?? false;
    });
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    final checkedMedicines = prescriptions.where((item) {
      return _isSameSchedule(item) &&
          item['checked'] == true &&
          item['already_saved'] != true;
    }).toList();

    if (checkedMedicines.isEmpty) {
      _showSnackBar('Pilih minimal satu obat yang belum dicatat');
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

      for (final item in checkedMedicines) {
        await ApiService.storeMedication(
          patientId: patientId,
          prescriptionId: int.parse(item['prescription_id'].toString()),
          scheduleId: int.parse(item['prescription_schedule_id'].toString()),
          status: 'Diminum',
          consumedAt: now,
          note: noteCtr.text.trim().isEmpty ? null : noteCtr.text.trim(),
        );
      }

      if (!mounted) return;

      setState(() {
        for (final item in checkedMedicines) {
          item['checked'] = true;
          item['already_saved'] = true;
          item['log_status'] = 'Diminum';
        }
      });

      _showSuccessSheet(now);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
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
            _header(context),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                  ? _errorState()
                  : prescriptions.isEmpty
                  ? _noPrescriptionState()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle('Kepatuhan Obat'),
                          const SizedBox(height: 6),
                          const Text(
                            'Checklist obat yang sudah diminum sesuai resep aktif dari dokter.',
                            style: TextStyle(
                              color: AppColors.dark2,
                              fontSize: 12,
                              height: 1.45,
                            ),
                          ),
                          _label('Waktu minum*'),
                          _scheduleTabs(),
                          _label('Daftar obat dari resep dokter*'),
                          if (filteredPrescriptions.isEmpty)
                            _emptyPrescription()
                          else
                            Column(
                              children: filteredPrescriptions.map((entry) {
                                final index = entry.key;
                                final item = entry.value;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _medicineCard(
                                    index: index,
                                    medicine:
                                        item['medication_name']?.toString() ??
                                        '-',
                                    sessionName:
                                        item['session_name']?.toString() ?? '-',
                                    dosage: item['dosage']?.toString() ?? '-',
                                    form: item['form']?.toString() ?? '-',
                                    mealRule:
                                        item['meal_rule']?.toString() ?? '-',
                                    notes: item['notes']?.toString() ?? '-',
                                    dosePerSession:
                                        item['dose_per_session']?.toString() ??
                                        '-',
                                    reminderTime: _formatTime(
                                      item['reminder_time'] ??
                                          item['default_reminder_time'],
                                    ),
                                    checked: item['checked'] == true,
                                    alreadySaved: item['already_saved'] == true,
                                  ),
                                );
                              }).toList(),
                            ),
                          _label('Catatan (opsional)'),
                          _input(
                            controller: noteCtr,
                            hint: 'Contoh: obat diminum setelah makan',
                          ),
                          const SizedBox(height: 26),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: hasUnsavedCheckedMedicine && !isSaving
                                  ? _save
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                disabledBackgroundColor: const Color(
                                  0xFFAFCBEA,
                                ),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: isSaving
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Simpan Checklist',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          TextButton(
                            onPressed: isSaving
                                ? null
                                : () => Navigator.pop(context),
                            child: const Center(
                              child: Text(
                                'Batal',
                                style: TextStyle(color: AppColors.primaryBlue),
                              ),
                            ),
                          ),
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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: schedules.map((item) {
        final selected = selectedSchedule == item;

        return GestureDetector(
          onTap: isSaving
              ? null
              : () {
                  setState(() {
                    selectedSchedule = item;
                  });
                },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: selected ? AppColors.primaryBlue : AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? AppColors.primaryBlue : AppColors.light1,
              ),
            ),
            child: Text(
              item,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
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
  }) {
    return InkWell(
      onTap: isSaving || alreadySaved
          ? null
          : () => _toggleMedicine(index, !checked),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: alreadySaved
              ? const Color(0xFFEAFBF3)
              : checked
              ? AppColors.veryLightBlue
              : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: alreadySaved || checked
                ? AppColors.primaryBlue
                : AppColors.light1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            alreadySaved
                ? const Icon(
                    Icons.check_circle,
                    color: Color(0xFF10C878),
                    size: 24,
                  )
                : Checkbox(
                    value: checked,
                    activeColor: AppColors.primaryBlue,
                    onChanged: isSaving
                        ? null
                        : (value) => _toggleMedicine(index, value),
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
                      if (alreadySaved)
                        const Text(
                          'Sudah dicatat',
                          style: TextStyle(
                            color: Color(0xFF10C878),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$dosage • $form • $dosePerSession',
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

  Widget _noPrescriptionState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('Belum ada resep aktif'),
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
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(errorMessage!, textAlign: TextAlign.center),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, topPad + 14, 16, 18),
      color: AppColors.primaryBlue,
      child: Row(
        children: [
          IconButton(
            onPressed: isSaving ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              'Tambah Data Obat',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.primaryBlue,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 13,
          fontWeight: FontWeight.w600,
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
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.dark4, fontSize: 13),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ),
    );
  }

  void _showSuccessSheet(DateTime now) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
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
                child: Icon(
                  Icons.check,
                  color: AppColors.primaryBlue,
                  size: 36,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Kepatuhan obat tersimpan',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text('Selesai'),
                ),
              ),
            ],
          ),
        );
      },
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
