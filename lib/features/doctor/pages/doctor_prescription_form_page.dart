import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';
import 'package:diabetaku_app/core/theme/app_button_styles.dart';

class DoctorPrescriptionFormPage extends StatefulWidget {
  final int patientId;
  final bool isEdit;
  final Map<String, dynamic>? initialPrescription;

  const DoctorPrescriptionFormPage({
    super.key,
    required this.patientId,
    this.isEdit = false,
    this.initialPrescription,
  });

  @override
  State<DoctorPrescriptionFormPage> createState() =>
      _DoctorPrescriptionFormPageState();
}

class _DoctorPrescriptionFormPageState
    extends State<DoctorPrescriptionFormPage> {
  final medicineCtr = TextEditingController();
  final dosageCtr = TextEditingController();
  final notesCtr = TextEditingController();

  Timer? _debounce;

  bool isLoading = true;
  bool isSaving = false;
  bool isSearchingMedication = false;

  int? doctorId;
  int? selectedMedicationId;
  String selectedMedicationDescription = '';

  String selectedForm = 'Tablet';
  String? selectedMealRule;

  DateTime validFrom = DateTime.now();
  DateTime validUntil = DateTime.now().add(const Duration(days: 30));

  List<Map<String, dynamic>> medications = [];
  List<Map<String, dynamic>> sessions = [];
  List<String> mealRules = [];

  final Map<int, Map<String, dynamic>> selectedSessions = {};

  final dosageForms = const [
    'Tablet',
    'Kapsul',
    'Sirup',
    'Injeksi',
    'Tetes',
    'Krim/Salep',
  ];

  Map<String, dynamic>? get initial => widget.initialPrescription;

  int get prescriptionId {
    return int.tryParse(initial?['prescription_id']?.toString() ?? '') ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    medicineCtr.dispose();
    dosageCtr.dispose();
    notesCtr.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedDoctorId = prefs.getInt('doctor_id');

      final loadedSessions = await ApiService.getMedicationSessions();
      final loadedMealRules = await ApiService.getPrescriptionMealRules();

      if (!mounted) return;

      setState(() {
        doctorId = savedDoctorId;
        sessions = loadedSessions;
        mealRules = loadedMealRules;

        if (widget.isEdit && initial != null) {
          _fillInitialPrescription(loadedMealRules);
        } else {
          selectedMealRule = loadedMealRules.isNotEmpty
              ? loadedMealRules.first
              : null;
        }

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _fillInitialPrescription(List<String> loadedMealRules) {
    final item = initial!;

    selectedMedicationId = int.tryParse(
      item['medication_id']?.toString() ?? '',
    );

    medicineCtr.text = item['medication_name']?.toString() ?? '';
    selectedMedicationDescription =
        item['description']?.toString() ??
        item['medication_description']?.toString() ??
        '';

    dosageCtr.text = item['dosage']?.toString() ?? '';
    selectedForm = item['form']?.toString().isNotEmpty == true
        ? item['form'].toString()
        : selectedForm;

    final rule = item['meal_rule']?.toString();
    selectedMealRule = rule != null && rule.trim().isNotEmpty
        ? rule
        : loadedMealRules.isNotEmpty
        ? loadedMealRules.first
        : null;

    notesCtr.text = item['notes']?.toString() ?? '';

    validFrom =
        _parseDate(item['start_date'] ?? item['valid_from']) ?? DateTime.now();
    validUntil =
        _parseDate(item['end_date'] ?? item['valid_until']) ??
        DateTime.now().add(const Duration(days: 30));

    selectedSessions.clear();

    final existingSchedules = List<Map<String, dynamic>>.from(
      item['schedules'] ?? [],
    );

    for (final schedule in existingSchedules) {
      final sessionId = int.tryParse(schedule['session_id']?.toString() ?? '');
      if (sessionId == null) continue;

      selectedSessions[sessionId] = {
        'session_id': sessionId,
        'session_name': schedule['session_name']?.toString() ?? '-',
        'default_reminder_time': _normalizeTime(
          schedule['default_reminder_time'] ?? schedule['reminder_time'],
        ),
      };
    }
  }

  void _onMedicationChanged(String keyword) {
    _debounce?.cancel();

    setState(() {
      selectedMedicationId = null;
      selectedMedicationDescription = '';
      medications = [];
    });

    if (keyword.trim().isEmpty) return;

    _debounce = Timer(const Duration(milliseconds: 450), () {
      _searchMedication(keyword);
    });
  }

  Future<void> _searchMedication(String keyword) async {
    setState(() => isSearchingMedication = true);

    try {
      final data = await ApiService.searchMedications(keyword.trim());

      if (!mounted) return;

      setState(() {
        medications = data;
        isSearchingMedication = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        medications = [];
        isSearchingMedication = false;
      });
    }
  }

  Future<void> _savePrescription() async {
    if (doctorId == null) {
      _showSnackBar('Doctor ID tidak ditemukan. Coba login ulang.');
      return;
    }

    if (selectedMedicationId == null ||
        medicineCtr.text.trim().isEmpty ||
        dosageCtr.text.trim().isEmpty ||
        selectedMealRule == null ||
        selectedSessions.isEmpty) {
      _showSnackBar('Nama obat, dosis, aturan minum, dan jadwal wajib diisi');
      return;
    }

    if (validUntil.isBefore(validFrom)) {
      _showSnackBar('Tanggal selesai tidak boleh sebelum tanggal mulai');
      return;
    }

    if (widget.isEdit && prescriptionId == 0) {
      _showSnackBar('ID resep tidak ditemukan');
      return;
    }

    final schedulesPayload = selectedSessions.values.map((item) {
      return {'session_id': item['session_id']};
    }).toList();

    setState(() => isSaving = true);

    try {
      if (widget.isEdit) {
        await ApiService.updatePrescription(
          prescriptionId: prescriptionId,
          doctorId: doctorId!,
          patientId: widget.patientId,
          medicationId: selectedMedicationId!,
          dosage: dosageCtr.text.trim(),
          form: selectedForm,
          mealRule: selectedMealRule,
          notes: notesCtr.text.trim().isEmpty ? null : notesCtr.text.trim(),
          validFrom: _dateOnly(validFrom),
          validUntil: _dateOnly(validUntil),
          schedules: schedulesPayload,
        );
      } else {
        await ApiService.storeDoctorPrescription(
          patientId: widget.patientId,
          medicationId: selectedMedicationId!,
          dosage: dosageCtr.text.trim(),
          form: selectedForm,
          mealRule: selectedMealRule,
          notes: notesCtr.text.trim().isEmpty ? null : notesCtr.text.trim(),
          validFrom: _dateOnly(validFrom),
          validUntil: _dateOnly(validUntil),
          schedules: schedulesPayload,
        );
      }

      if (!mounted) return;

      await _showSuccessSheet(
        widget.isEdit
            ? 'Resep berhasil diperbarui'
            : 'Resep berhasil ditambahkan',
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Data Obat'),
                    _label('Nama Obat*'),
                    _medicineTypeAhead(),

                    if (selectedMedicationDescription.trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _descriptionBox(selectedMedicationDescription),
                    ],

                    const SizedBox(height: 14),
                    _label('Dosis*'),
                    _input(controller: dosageCtr, hint: 'Contoh: 500 mg'),

                    const SizedBox(height: 14),
                    _label('Bentuk Sediaan*'),
                    _optionBox(
                      value: selectedForm,
                      onTap: () => _showOptionSheet(
                        title: 'Pilih Bentuk Sediaan',
                        options: dosageForms,
                        selected: selectedForm,
                        onSelected: (value) {
                          setState(() => selectedForm = value);
                        },
                      ),
                    ),

                    const SizedBox(height: 22),
                    _sectionTitle('Aturan dan Jadwal'),

                    _label('Aturan Minum*'),
                    _optionBox(
                      value: selectedMealRule ?? 'Pilih aturan minum',
                      onTap: mealRules.isEmpty
                          ? () => _showSnackBar(
                              'Data aturan minum belum tersedia',
                            )
                          : () => _showOptionSheet(
                              title: 'Pilih Aturan Minum',
                              options: mealRules,
                              selected: selectedMealRule ?? '',
                              onSelected: (value) {
                                setState(() => selectedMealRule = value);
                              },
                            ),
                    ),

                    const SizedBox(height: 14),
                    _label('Jadwal Minum*'),
                    _scheduleSection(),

                    const SizedBox(height: 22),
                    _sectionTitle('Masa Berlaku'),
                    Row(
                      children: [
                        Expanded(
                          child: _dateBox(
                            label: 'Mulai',
                            date: validFrom,
                            onTap: () async {
                              final picked = await _pickDate(validFrom);
                              if (picked != null) {
                                setState(() => validFrom = picked);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _dateBox(
                            label: 'Sampai',
                            date: validUntil,
                            onTap: () async {
                              final picked = await _pickDate(validUntil);
                              if (picked != null) {
                                setState(() => validUntil = picked);
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),
                    _sectionTitle('Catatan'),
                    _input(
                      controller: notesCtr,
                      hint: 'Contoh: Diminum rutin sesuai jadwal dokter',
                      maxLines: 4,
                    ),

                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : _savePrescription,
                        style: AppButtonStyles.primary,
                        child: isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                widget.isEdit
                                    ? 'Simpan Perubahan'
                                    : 'Simpan Resep',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
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

  Widget _header() {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 22),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: isSaving ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Expanded(
            child: Text(
              widget.isEdit ? 'Ubah Resep' : 'Tambah Resep',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _medicineTypeAhead() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _input(
          controller: medicineCtr,
          hint: 'Ketik nama obat',
          onChanged: _onMedicationChanged,
          suffixIcon: selectedMedicationId != null
              ? const Icon(
                  Icons.check_circle,
                  color: Color(0xFF10C878),
                  size: 18,
                )
              : null,
        ),
        if (isSearchingMedication) ...[
          const SizedBox(height: 6),
          _infoBox('Mencari obat...'),
        ],
        if (!isSearchingMedication && medications.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.light1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: medications.map((item) {
                final id = int.tryParse(item['medication_id'].toString());
                final name = item['medication_name']?.toString() ?? '-';
                final description = item['description']?.toString() ?? '';

                return InkWell(
                  onTap: () {
                    if (id == null) return;

                    FocusScope.of(context).unfocus();

                    setState(() {
                      selectedMedicationId = id;
                      medicineCtr.text = name;
                      selectedMedicationDescription = description;
                      medications = [];
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 11,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.veryLightBlue,
                          child: Icon(
                            Icons.medication_outlined,
                            size: 17,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  color: AppColors.dark1,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (description.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  description,
                                  style: const TextStyle(
                                    color: AppColors.dark2,
                                    fontSize: 11,
                                    height: 1.3,
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
              }).toList(),
            ),
          ),
        ],
        if (!isSearchingMedication &&
            medicineCtr.text.trim().isNotEmpty &&
            medications.isEmpty &&
            selectedMedicationId == null) ...[
          const SizedBox(height: 6),
          _infoBox('Pilih obat dari daftar master data'),
        ],
      ],
    );
  }

  Widget _descriptionBox(String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.light1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.primaryBlue,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                color: AppColors.dark1,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scheduleSection() {
    if (sessions.isEmpty) {
      return _infoBox('Data jadwal minum belum tersedia');
    }

    return Column(
      children: sessions.map((item) {
        final sessionId = int.tryParse(item['session_id'].toString());
        final sessionName = item['session_name']?.toString() ?? '-';
        final defaultTime = _normalizeTime(item['default_reminder_time']);

        final selected =
            sessionId != null && selectedSessions.containsKey(sessionId);

        final selectedItem = sessionId == null
            ? null
            : selectedSessions[sessionId];
        final reminder = _normalizeTime(
          selectedItem?['default_reminder_time'] ?? defaultTime,
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: sessionId == null
                ? null
                : () {
                    if (!selected) {
                      _selectSession(
                        sessionId: sessionId,
                        sessionName: sessionName,
                        defaultTime: defaultTime,
                      );
                    } else {
                      _removeSession(sessionId);
                    }
                  },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selected ? AppColors.veryLightBlue : AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected ? AppColors.primaryBlue : AppColors.light1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    selected ? Icons.check_box : Icons.check_box_outline_blank,
                    color: selected ? AppColors.primaryBlue : AppColors.dark3,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sessionName,
                          style: TextStyle(
                            color: selected
                                ? AppColors.primaryBlue
                                : AppColors.dark1,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          selected
                              ? 'Reminder $reminder'
                              : 'Jam default $defaultTime',
                          style: const TextStyle(
                            color: AppColors.dark2,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Hapus jadwal',
                      onPressed: isSaving
                          ? null
                          : () => _removeSession(sessionId),
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.red,
                        size: 17,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _selectSession({
    required int sessionId,
    required String sessionName,
    required String defaultTime,
  }) {
    setState(() {
      selectedSessions[sessionId] = {
        'session_id': sessionId,
        'session_name': sessionName,
        'default_reminder_time': defaultTime,
      };
    });
  }

  void _removeSession(int sessionId) {
    setState(() {
      selectedSessions.remove(sessionId);
    });
  }

  Widget _dateBox({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isSaving ? null : onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.light1),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.primaryBlue,
              size: 17,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.dark2,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _formatDate(date),
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      enabled: !isSaving,
      onChanged: onChanged,
      decoration: _inputDecoration(hint: hint, suffixIcon: suffixIcon),
    );
  }

  Widget _optionBox({required String value, required VoidCallback onTap}) {
    return InkWell(
      onTap: isSaving ? null : onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.light1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: const TextStyle(color: AppColors.dark1, fontSize: 12),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.dark2, fontSize: 12),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.dark3, fontSize: 12),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.light1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaryBlue),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.light1),
      ),
    );
  }

  Future<void> _showOptionSheet({
    required String title,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.75,
            ),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
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
                const SizedBox(height: 18),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final item = options[index];
                      final isSelected = item == selected;

                      return ListTile(
                        title: Text(item),
                        trailing: Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: AppColors.primaryBlue,
                        ),
                        onTap: () {
                          onSelected(item);
                          Navigator.pop(sheetContext);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<DateTime?> _pickDate(DateTime current) async {
    return showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  Future<void> _showSuccessSheet(String message) async {
    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
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
                child: Icon(Icons.check, color: Color(0xFF10C878), size: 36),
              ),
              const SizedBox(height: 18),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
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
                  onPressed: () => Navigator.pop(sheetContext),
                  style: AppButtonStyles.primary,
                  child: const Text('Selesai'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  String _dateOnly(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _normalizeTime(dynamic value) {
    if (value == null) return '07:00';

    final text = value.toString();
    if (text.isEmpty || text == '-') return '07:00';

    if (text.length >= 5) return text.substring(0, 5);

    return text;
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
}
