import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';

class FamilyMedicationFormPage extends StatefulWidget {
  final int patientId;
  final String patientInitial;
  final String patientName;
  final String patientInfo;

  const FamilyMedicationFormPage({
    super.key,
    required this.patientId,
    required this.patientInitial,
    required this.patientName,
    required this.patientInfo,
  });

  @override
  State<FamilyMedicationFormPage> createState() =>
      _FamilyMedicationFormPageState();
}

class _FamilyMedicationFormPageState extends State<FamilyMedicationFormPage> {
  final noteCtr = TextEditingController();

  String selectedSchedule = '';
  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  List<Map<String, dynamic>> prescriptions = [];

  List<String> get schedules {
    return prescriptions
        .map((e) => e['session']?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
  }

  bool get hasCheckedMedicine {
    return prescriptions.any((item) {
      return item['session'] == selectedSchedule && item['checked'] == true;
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
      final data = await ApiService.getActivePrescriptions(widget.patientId);

      if (!mounted) return;

      setState(() {
        prescriptions = data.map((item) {
          return {
            ...item,
            'checked': false,
          };
        }).toList();

        if (prescriptions.isNotEmpty) {
          selectedSchedule = prescriptions.first['session'].toString();
        }

        isLoading = false;
        errorMessage = null;
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
    setState(() => isSaving = true);

    try {
      final now = DateTime.now();

      final checkedMedicines = prescriptions.where((item) {
        return item['session'] == selectedSchedule && item['checked'] == true;
      }).toList();

      for (final item in checkedMedicines) {
        await ApiService.storeMedication(
          patientId: widget.patientId,
          prescriptionId: int.parse(item['prescription_id'].toString()),
          scheduleId: int.parse(item['schedule_id'].toString()),
          status: 'Diminum',
          consumedAt: now,
          note: noteCtr.text.trim().isEmpty ? null : noteCtr.text.trim(),
        );
      }

      if (!mounted) return;

      _showSuccessSheet(now);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredPrescriptions = prescriptions
        .asMap()
        .entries
        .where((entry) => entry.value['session'] == selectedSchedule)
        .toList();

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
                              padding:
                                  const EdgeInsets.fromLTRB(20, 18, 20, 28),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _patientCard(),
                                  const SizedBox(height: 18),
                                  _sectionTitle('Kepatuhan Obat'),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Checklist obat sesuai resep aktif dari dokter. Data akan menunggu validasi pasien.',
                                    style: TextStyle(
                                      color: AppColors.dark2,
                                      fontSize: 12,
                                      height: 1.45,
                                    ),
                                  ),
                                  _label('Waktu minum*'),
                                  Row(
                                    children: schedules.map((item) {
                                      final selected =
                                          selectedSchedule == item;

                                      return Expanded(
                                        child: GestureDetector(
                                          onTap: isSaving
                                              ? null
                                              : () {
                                                  setState(() {
                                                    selectedSchedule = item;
                                                  });
                                                },
                                          child: Container(
                                            height: 42,
                                            margin: const EdgeInsets.only(
                                              right: 8,
                                            ),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: selected
                                                  ? AppColors.primaryBlue
                                                  : AppColors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: selected
                                                    ? AppColors.primaryBlue
                                                    : AppColors.light1,
                                              ),
                                            ),
                                            child: Text(
                                              item,
                                              style: TextStyle(
                                                color: selected
                                                    ? Colors.white
                                                    : AppColors.primaryBlue,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  _label('Daftar obat dari resep dokter*'),
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
                                            dosage:
                                                item['dosage']?.toString() ??
                                                    '-',
                                            form:
                                                item['form']?.toString() ?? '-',
                                            instruction: item['instruction']
                                                    ?.toString() ??
                                                '-',
                                            dosePerSession:
                                                item['dose_per_session']
                                                        ?.toString() ??
                                                    '-',
                                            checked: item['checked'] as bool,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  _label('Catatan (opsional)'),
                                  _input(
                                    controller: noteCtr,
                                    hint:
                                        'Contoh: obat diminum setelah makan',
                                  ),
                                  const SizedBox(height: 26),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed:
                                          hasCheckedMedicine && !isSaving
                                              ? _save
                                              : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppColors.primaryBlue,
                                        disabledBackgroundColor:
                                            const Color(0xFFAFCBEA),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
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
                                        style: TextStyle(
                                          color: AppColors.primaryBlue,
                                        ),
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

  Widget _patientCard() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.light1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.lightBlue,
            child: Text(
              widget.patientInitial,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.patientName,
                  style: const TextStyle(
                    color: AppColors.dark1,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.patientInfo,
                  style: const TextStyle(color: AppColors.dark2, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _medicineCard({
    required int index,
    required String medicine,
    required String dosage,
    required String form,
    required String instruction,
    required String dosePerSession,
    required bool checked,
  }) {
    return InkWell(
      onTap: isSaving ? null : () => _toggleMedicine(index, !checked),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: checked ? AppColors.primaryBlue : AppColors.light1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Checkbox(
              value: checked,
              activeColor: AppColors.primaryBlue,
              onChanged:
                  isSaving ? null : (value) => _toggleMedicine(index, value),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine,
                    style: const TextStyle(
                      color: AppColors.dark1,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$dosage • $form • $dosePerSession',
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    instruction,
                    style: const TextStyle(
                      color: AppColors.dark2,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noPrescriptionState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.light1),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.medication_outlined,
                color: AppColors.primaryBlue,
                size: 42,
              ),
              SizedBox(height: 12),
              Text(
                'Belum ada resep aktif',
                style: TextStyle(
                  color: AppColors.dark1,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Checklist obat akan muncul setelah dokter memberikan resep aktif kepada pasien.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.dark2,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
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
        style: TextStyle(
          color: AppColors.dark1,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
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
          style: const TextStyle(
            color: AppColors.dark1,
            fontSize: 13,
          ),
        ),
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
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.dark4, fontSize: 13),
        filled: true,
        fillColor: AppColors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.light1),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.light1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide:
              const BorderSide(color: AppColors.primaryBlue, width: 1.4),
        ),
      ),
    );
  }

  void _showSuccessSheet(DateTime now) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
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
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.light1,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 24),
              const CircleAvatar(
                radius: 36,
                backgroundColor: Color(0xFFEAFBF3),
                child: Icon(Icons.check, color: Color(0xFF10C878), size: 36),
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
              const SizedBox(height: 8),
              Text(
                'Data obat pasien pada jadwal $selectedSchedule berhasil dicatat dan menunggu validasi pasien.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.dark2,
                  fontSize: 13,
                  height: 1.4,
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text('Kembali'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}