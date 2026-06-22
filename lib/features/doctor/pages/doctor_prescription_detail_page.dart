import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';

class DoctorPrescriptionDetailPage extends StatefulWidget {
  final Map<String, dynamic> prescription;
  final bool isConnected;

  const DoctorPrescriptionDetailPage({
    super.key,
    required this.prescription,
    this.isConnected = true,
  });

  @override
  State<DoctorPrescriptionDetailPage> createState() =>
      _DoctorPrescriptionDetailPageState();
}

class _DoctorPrescriptionDetailPageState
    extends State<DoctorPrescriptionDetailPage> {
  bool isSaving = false;
  int? currentDoctorId;

  late TextEditingController dosageCtr;
  late TextEditingController formCtr;
  late TextEditingController indicationCtr;
  late TextEditingController ruleCtr;
  late TextEditingController noteCtr;
  late TextEditingController validFromCtr;
  late TextEditingController validUntilCtr;

  Map<String, dynamic> get prescription => widget.prescription;

  int get prescriptionId =>
      int.tryParse(prescription['prescription_id']?.toString() ?? '') ?? 0;

  int get patientId =>
      int.tryParse(prescription['patient_id']?.toString() ?? '') ?? 0;

  int get medicationId =>
      int.tryParse(prescription['medication_id']?.toString() ?? '') ?? 0;

  int get doctorId =>
      int.tryParse(prescription['doctor_id']?.toString() ?? '') ?? 0;

  String get medicine => prescription['medication_name']?.toString() ?? '-';
  String get dose => prescription['dosage']?.toString() ?? '-';
  String get form => prescription['form']?.toString() ?? '-';
  String get indication => prescription['indication']?.toString() ?? '';
  String get rule => prescription['meal_rule']?.toString() ?? '-';
  String get note => prescription['notes']?.toString() ?? '';
  String get doctor => prescription['doctor_name']?.toString() ?? '-';
  String get date => prescription['valid_from']?.toString() ?? '-';
  String get validUntil => prescription['valid_until']?.toString() ?? '-';
  String get status => prescription['status']?.toString() ?? 'Aktif';

  bool get isMine => currentDoctorId != null && currentDoctorId == doctorId;

  List<Map<String, dynamic>> get schedules {
    return List<Map<String, dynamic>>.from(prescription['schedules'] ?? []);
  }

  String get scheduleText {
    if (schedules.isEmpty) return '-';

    return schedules.map((item) {
      final session = item['session_name']?.toString() ?? '-';
      final dosePerSession = item['dose_per_session']?.toString() ?? '-';
      final reminder = _formatTime(
        item['reminder_time'] ?? item['default_reminder_time'],
      );

      return '$session ($dosePerSession, $reminder)';
    }).join(', ');
  }

  @override
  void initState() {
    super.initState();

    dosageCtr = TextEditingController(text: dose == '-' ? '' : dose);
    formCtr = TextEditingController(text: form == '-' ? '' : form);
    indicationCtr = TextEditingController(text: indication);
    ruleCtr = TextEditingController(text: rule == '-' ? '' : rule);
    noteCtr = TextEditingController(text: note);
    validFromCtr = TextEditingController(text: date == '-' ? '' : _dateOnly(date));
    validUntilCtr = TextEditingController(
      text: validUntil == '-' ? '' : _dateOnly(validUntil),
    );

    _loadDoctorId();
  }

  Future<void> _loadDoctorId() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      currentDoctorId = prefs.getInt('doctor_id');
    });
  }

  @override
  void dispose() {
    dosageCtr.dispose();
    formCtr.dispose();
    indicationCtr.dispose();
    ruleCtr.dispose();
    noteCtr.dispose();
    validFromCtr.dispose();
    validUntilCtr.dispose();
    super.dispose();
  }

  Future<void> _updatePrescription(BuildContext sheetContext) async {
    FocusScope.of(context).unfocus();

    if (currentDoctorId == null) {
      _showSnackBar('Doctor ID tidak ditemukan');
      return;
    }

    if (dosageCtr.text.trim().isEmpty ||
        formCtr.text.trim().isEmpty ||
        validFromCtr.text.trim().isEmpty ||
        validUntilCtr.text.trim().isEmpty ||
        schedules.isEmpty) {
      _showSnackBar('Dosis, bentuk, masa berlaku, dan jadwal wajib diisi');
      return;
    }

    setState(() => isSaving = true);

    try {
      await ApiService.updatePrescription(
        prescriptionId: prescriptionId,
        doctorId: currentDoctorId!,
        patientId: patientId,
        medicationId: medicationId,
        dosage: dosageCtr.text.trim(),
        form: formCtr.text.trim(),
        indication: indicationCtr.text.trim(),
        mealRule: ruleCtr.text.trim(),
        notes: noteCtr.text.trim(),
        validFrom: validFromCtr.text.trim(),
        validUntil: validUntilCtr.text.trim(),
        schedules: schedules.map((item) {
          return {
            'session_id': item['session_id'],
            'dose_per_session': item['dose_per_session']?.toString() ?? '1 tablet',
            'reminder_time': _normalizeReminderTime(
              item['reminder_time'] ?? item['default_reminder_time'],
            ),
          };
        }).toList(),
      );

      if (!mounted) return;

      Navigator.pop(sheetContext);
      await _showSuccessSheet('Resep berhasil diperbarui');

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Future<void> _stopPrescription(BuildContext sheetContext) async {
    if (currentDoctorId == null) {
      _showSnackBar('Doctor ID tidak ditemukan');
      return;
    }

    setState(() => isSaving = true);

    try {
      await ApiService.stopPrescription(
        prescriptionId: prescriptionId,
        doctorId: currentDoctorId!,
        reason: 'Obat dihentikan oleh dokter',
      );

      if (!mounted) return;

      Navigator.pop(sheetContext);
      await _showSuccessSheet('Obat berhasil dihentikan');

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final initialDate = DateTime.tryParse(controller.text) ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
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

    if (picked != null) {
      setState(() {
        controller.text = picked.toIso8601String().split('T').first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = widget.isConnected && isMine && status == 'Aktif';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  children: [
                    _detailCard(),
                    const SizedBox(height: 14),
                    _noteCard(),
                    const SizedBox(height: 22),
                    if (canEdit)
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: ElevatedButton.icon(
                                onPressed: isSaving ? null : _showEditForm,
                                icon: const Icon(Icons.edit_outlined, size: 16),
                                label: const Text('Ubah'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: OutlinedButton.icon(
                                onPressed: isSaving ? null : _showStopConfirmation,
                                icon: const Icon(Icons.block, size: 16),
                                label: const Text('Hentikan'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.red,
                                  side: const BorderSide(color: AppColors.red),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      _readonlyInfo(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 28),
      color: AppColors.primaryBlue,
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: isSaving ? null : () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Expanded(
                child: Text(
                  'Detail Resep',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 14),
          const CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.lightBlue,
            child: Icon(
              Icons.medication_outlined,
              color: AppColors.primaryBlue,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '$medicine $dose',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            scheduleText,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(height: 10),
          _statusBadge(isMine ? 'Resep Saya' : 'Dokter Lain'),
        ],
      ),
    );
  }

  Widget _detailCard() {
    final details = [
      ['Nama Obat', medicine],
      ['Dosis', dose],
      ['Bentuk', form],
      ['Indikasi', indication.isEmpty ? '-' : indication],
      ['Jadwal', scheduleText],
      ['Aturan Minum', rule],
      ['Dokter', doctor],
      ['Status Resep', status],
      ['Mulai Berlaku', _formatDate(date)],
      ['Berlaku Sampai', _formatDate(validUntil)],
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Data',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ...details.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item[0],
                      style: const TextStyle(
                        color: AppColors.dark2,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item[1],
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _noteCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Catatan',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.veryLightBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              note.isEmpty ? 'Tidak ada catatan tambahan.' : note,
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

  Widget _readonlyInfo() {
    String text;

    if (!widget.isConnected) {
      text = 'Pasien sudah tidak terhubung. Resep hanya dapat dilihat sebagai data lama.';
    } else if (!isMine) {
      text = 'Resep ini dibuat oleh dokter lain, sehingga hanya dapat dilihat.';
    } else {
      text = 'Resep ini sudah tidak aktif, sehingga hanya dapat dilihat.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primaryBlue, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showEditForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.light1,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Ubah Resep',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _label('Nama Obat'),
                  _readonlyInput(medicine),
                  const SizedBox(height: 12),
                  _label('Dosis*'),
                  _input(dosageCtr),
                  const SizedBox(height: 12),
                  _label('Bentuk Sediaan*'),
                  _input(formCtr),
                  const SizedBox(height: 12),
                  _label('Indikasi'),
                  _input(indicationCtr),
                  const SizedBox(height: 12),
                  _label('Aturan Minum'),
                  _input(ruleCtr),
                  const SizedBox(height: 12),
                  _label('Mulai Berlaku*'),
                  _dateInput(
                    controller: validFromCtr,
                    onTap: () => _pickDate(validFromCtr),
                  ),
                  const SizedBox(height: 12),
                  _label('Berlaku Sampai*'),
                  _dateInput(
                    controller: validUntilCtr,
                    onTap: () => _pickDate(validUntilCtr),
                  ),
                  const SizedBox(height: 12),
                  _label('Jadwal Minum'),
                  _schedulePreview(),
                  const SizedBox(height: 12),
                  _label('Catatan'),
                  _input(noteCtr, maxLines: 3),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () => _updatePrescription(sheetContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFAFCBEA),
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
                          : const Text('Simpan Perubahan'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _schedulePreview() {
    if (schedules.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.veryLightBlue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Jadwal belum tersedia',
          style: TextStyle(color: AppColors.dark2, fontSize: 12),
        ),
      );
    }

    return Column(
      children: schedules.map((item) {
        final session = item['session_name']?.toString() ?? '-';
        final dose = item['dose_per_session']?.toString() ?? '-';
        final reminder = _formatTime(
          item['reminder_time'] ?? item['default_reminder_time'],
        );

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.veryLightBlue,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.light1),
          ),
          child: Text(
            '$session • $dose • $reminder',
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showStopConfirmation() {
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
                backgroundColor: AppColors.lightRed,
                child: Icon(Icons.block, color: AppColors.red, size: 36),
              ),
              const SizedBox(height: 18),
              const Text(
                'Hentikan obat ini?',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Status resep akan menjadi Selesai dan tetap tersimpan dalam riwayat resep.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.dark2, fontSize: 13),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed:
                      isSaving ? null : () => _stopPrescription(sheetContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.lightRed,
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
                      : const Text('Ya, Hentikan'),
                ),
              ),
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(sheetContext),
                child: const Text(
                  'Batal',
                  style: TextStyle(color: AppColors.primaryBlue),
                ),
              ),
            ],
          ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
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

  Widget _input(TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      enabled: !isSaving,
      decoration: _inputDecoration(),
    );
  }

  Widget _readonlyInput(String value) {
    return TextField(
      controller: TextEditingController(text: value),
      enabled: false,
      decoration: _inputDecoration(),
    );
  }

  Widget _dateInput({
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      enabled: !isSaving,
      onTap: isSaving ? null : onTap,
      decoration: _inputDecoration(
        suffixIcon: const Icon(
          Icons.calendar_today_outlined,
          color: AppColors.primaryBlue,
          size: 18,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({Widget? suffixIcon}) {
    return InputDecoration(
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
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
        borderSide: const BorderSide(color: AppColors.primaryBlue),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.light1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  String _formatDate(dynamic value) {
    if (value == null) return '-';

    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _dateOnly(dynamic value) {
    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();

    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(dynamic value) {
    if (value == null) return '-';

    final text = value.toString();
    if (text.isEmpty || text == '-') return '-';

    if (text.length >= 5) return text.substring(0, 5);

    return text;
  }

  String _normalizeReminderTime(dynamic value) {
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}