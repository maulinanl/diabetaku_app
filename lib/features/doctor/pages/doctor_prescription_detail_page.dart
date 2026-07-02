import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';
import 'doctor_prescription_form_page.dart';
import 'package:diabetaku_app/core/theme/app_button_styles.dart';

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

  Map<String, dynamic> get prescription => widget.prescription;

  int get prescriptionId =>
      int.tryParse(prescription['prescription_id']?.toString() ?? '') ?? 0;

  int get patientId =>
      int.tryParse(prescription['patient_id']?.toString() ?? '') ?? 0;

  int get doctorId =>
      int.tryParse(prescription['doctor_id']?.toString() ?? '') ?? 0;

  String get medicine => prescription['medication_name']?.toString() ?? '-';
  String get dose => prescription['dosage']?.toString() ?? '-';
  String get form => prescription['form']?.toString() ?? '-';
  String get indication => prescription['indication']?.toString() ?? '';
  String get rule => prescription['meal_rule']?.toString() ?? '-';
  String get note => prescription['notes']?.toString() ?? '';
  String get doctor => prescription['doctor_name']?.toString() ?? '-';
  String get date => prescription['start_date'] ?? prescription['valid_from']?.toString() ?? '-';
  String get validUntil => prescription['end_date'] ?? prescription['valid_until']?.toString() ?? '-';
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

  bool get stoppedByDisconnectedRelation {
    final text = '${prescription['notes'] ?? ''} ${prescription['reason'] ?? ''}'
        .toLowerCase();

    return text.contains('relasi dokter-pasien terputus');
  }

  @override
  void initState() {
    super.initState();
    _loadDoctorId();
  }

  Future<void> _loadDoctorId() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      currentDoctorId = prefs.getInt('doctor_id');
    });
  }

  Future<void> _openEditForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorPrescriptionFormPage(
          patientId: patientId,
          isEdit: true,
          initialPrescription: prescription,
        ),
      ),
    );

    if (result == true && mounted) {
      Navigator.pop(context, true);
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
                                onPressed: isSaving ? null : _openEditForm,
                                icon: const Icon(Icons.edit_outlined, size: 16),
                                label: const Text('Ubah'),
                                style: AppButtonStyles.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: OutlinedButton.icon(
                                onPressed:
                                    isSaving ? null : _showStopConfirmation,
                                icon: const Icon(Icons.block, size: 16),
                                label: const Text('Hentikan'),
                                style: AppButtonStyles.outlinedDanger,
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
      padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
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
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.lightBlue,
                  child: Icon(
                    Icons.medication_outlined,
                    color: AppColors.primaryBlue,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicine,
                        style: const TextStyle(
                          color: AppColors.dark1,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$dose • $form',
                        style: const TextStyle(
                          color: AppColors.dark2,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        scheduleText,
                        style: const TextStyle(
                          color: AppColors.dark2,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _statusBadge(status),
                          _statusBadge(isMine ? 'Resep Saya' : 'Dokter Lain'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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

    if (stoppedByDisconnectedRelation) {
      text =
          'Resep ini sudah tidak aktif karena relasi dokter-pasien telah terputus. Data tetap tersimpan sebagai riwayat.';
    } else if (!widget.isConnected) {
      text =
          'Pasien sudah tidak terhubung. Resep hanya dapat dilihat sebagai data lama.';
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
          const Icon(
            Icons.info_outline,
            color: AppColors.primaryBlue,
            size: 18,
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightBlue),
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
                  onPressed: isSaving
                      ? null
                      : () => _stopPrescription(sheetContext),
                  style: AppButtonStyles.danger,
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

  String _formatTime(dynamic value) {
    if (value == null) return '-';

    final text = value.toString();
    if (text.isEmpty || text == '-') return '-';

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
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
