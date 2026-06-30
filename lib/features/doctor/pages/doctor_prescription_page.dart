import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';
import 'doctor_prescription_detail_page.dart';
import 'doctor_prescription_form_page.dart';

class DoctorPrescriptionPage extends StatefulWidget {
  final int patientId;
  final bool isConnected;

  const DoctorPrescriptionPage({
    super.key,
    required this.patientId,
    required this.isConnected,
  });

  @override
  State<DoctorPrescriptionPage> createState() => _DoctorPrescriptionPageState();
}

class _DoctorPrescriptionPageState extends State<DoctorPrescriptionPage> {
  int selectedSubTab = 0;

  bool isLoading = true;
  bool isSaving = false;

  List<Map<String, dynamic>> activePrescriptions = [];
  List<Map<String, dynamic>> historyPrescriptions = [];

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
  }

  Future<void> _loadPrescriptions() async {
    try {
      if (mounted) setState(() => isLoading = true);

      final active = await ApiService.getDoctorPatientActivePrescriptions(
        widget.patientId,
      );

      final history = await ApiService.getDoctorPatientPrescriptionHistory(
        widget.patientId,
      );

      if (!mounted) return;

      setState(() {
        activePrescriptions = active;
        historyPrescriptions = history;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      children: [
        _subTabs(),
        const SizedBox(height: 14),
        selectedSubTab == 0 ? _activeContent() : _historyContent(),
      ],
    );
  }

  Widget _subTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.light1),
      ),
      child: Row(
        children: [_subTabItem('Aktif', 0), _subTabItem('Riwayat', 1)],
      ),
    );
  }

  Widget _subTabItem(String title, int index) {
    final selected = selectedSubTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedSubTab = index),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.lightBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: selected ? AppColors.primaryBlue : AppColors.dark1,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _activeContent() {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'RESEP AKTIF PASIEN',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (widget.isConnected)
              ElevatedButton.icon(
                onPressed: isSaving
                    ? null
                    : () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DoctorPrescriptionFormPage(
                              patientId: widget.patientId,
                            ),
                          ),
                        );

                        if (result == true) {
                          await _loadPrescriptions();
                        }
                      },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Tambah Obat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  textStyle: const TextStyle(fontSize: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (activePrescriptions.isEmpty)
          _emptyCard('Belum ada resep aktif')
        else
          ...activePrescriptions.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _PrescriptionCard(
                medicine: item['medication_name']?.toString() ?? '-',
                dose: item['dosage']?.toString() ?? '-',
                form: item['form']?.toString() ?? '-',
                schedule: _buildScheduleText(item),
                rule: item['meal_rule']?.toString() ?? '-',
                note: item['notes']?.toString() ?? '-',
                doctor: item['doctor_name']?.toString() ?? '-',
                date: _formatDate(item['start_date'] ?? item['valid_from']),
                isMine:
                    item['is_mine'] == true ||
                    item['is_mine'] == 1 ||
                    item['is_mine']?.toString() == '1',
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoctorPrescriptionDetailPage(
                        prescription: item,
                        isConnected: widget.isConnected,
                      ),
                    ),
                  );

                  if (result == true) {
                    await _loadPrescriptions();
                  }
                },
              ),
            );
          }),
      ],
    );
  }

  Widget _historyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RIWAYAT RESEP',
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        if (historyPrescriptions.isEmpty)
          _emptyCard('Belum ada riwayat resep')
        else
          ...historyPrescriptions.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: InkWell(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoctorPrescriptionDetailPage(
                        prescription: item,
                        isConnected: widget.isConnected,
                      ),
                    ),
                  );

                  if (result == true) {
                    await _loadPrescriptions();
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: _PrescriptionHistoryCard(
                  medicine: item['medication_name']?.toString() ?? '-',
                  dose: item['dosage']?.toString() ?? '-',
                  form: item['form']?.toString() ?? '-',
                  schedule: _buildScheduleText(item),
                  rule: item['meal_rule']?.toString() ?? '-',
                  doctor: item['doctor_name']?.toString() ?? '-',
                  startDate: _formatDate(item['start_date'] ?? item['valid_from']),
                  endDate: _formatDate(item['valid_until']),
                  status: item['status']?.toString() ?? 'Selesai',
                  reason:
                      item['reason']?.toString() ??
                      item['stop_reason']?.toString() ??
                      'Tidak aktif',
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _emptyCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.light1),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.dark2, fontSize: 12),
      ),
    );
  }

  String _buildScheduleText(Map<String, dynamic> prescription) {
    final schedules = List<Map<String, dynamic>>.from(
      prescription['schedules'] ?? [],
    );

    if (schedules.isEmpty) return '-';

    return schedules
        .map((item) {
          final session = item['session_name']?.toString() ?? '-';
          final dose = item['dose_per_session']?.toString() ?? '';
          final time = _normalizeTime(
            item['reminder_time'] ?? item['default_reminder_time'],
          );

          if (dose.isEmpty) return '$session $time';
          return '$session ($dose, $time)';
        })
        .join(' • ');
  }

  String _formatDate(dynamic value) {
    if (value == null) return '-';

    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();

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

class _PrescriptionCard extends StatelessWidget {
  final String medicine;
  final String dose;
  final String form;
  final String schedule;
  final String rule;
  final String note;
  final String doctor;
  final String date;
  final bool isMine;
  final VoidCallback onTap;

  const _PrescriptionCard({
    required this.medicine,
    required this.dose,
    required this.form,
    required this.schedule,
    required this.rule,
    required this.note,
    required this.doctor,
    required this.date,
    required this.isMine,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.veryLightBlue,
                  child: Icon(
                    Icons.medication_outlined,
                    color: AppColors.primaryBlue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    medicine,
                    style: const TextStyle(
                      color: AppColors.dark1,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _badge(isMine ? 'Resep Saya' : 'Dokter Lain'),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, color: AppColors.dark3),
              ],
            ),
            const SizedBox(height: 12),
            _infoRow('Dosis', '$dose • $form'),
            _infoRow('Jadwal', schedule),
            _infoRow('Aturan', rule),
            _infoRow('Catatan', note),
            const Divider(height: 24),
            Text(
              '$doctor • $date',
              style: const TextStyle(color: AppColors.dark2, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 62,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(color: AppColors.dark1, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
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
}

class _PrescriptionHistoryCard extends StatelessWidget {
  final String medicine;
  final String dose;
  final String form;
  final String schedule;
  final String rule;
  final String doctor;
  final String startDate;
  final String endDate;
  final String status;
  final String reason;

  const _PrescriptionHistoryCard({
    required this.medicine,
    required this.dose,
    required this.form,
    required this.schedule,
    required this.rule,
    required this.doctor,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.lightRed,
                child: Icon(
                  Icons.history_rounded,
                  color: AppColors.red,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  medicine,
                  style: const TextStyle(
                    color: AppColors.dark1,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _inactiveBadge(status),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow('Dosis', '$dose • $form'),
          _infoRow('Jadwal', schedule),
          _infoRow('Aturan', rule),
          _infoRow('Berlaku', '$startDate - $endDate'),
          _infoRow('Alasan', reason),
          const Divider(height: 24),
          Text(
            doctor,
            style: const TextStyle(color: AppColors.dark2, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 62,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(color: AppColors.dark1, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inactiveBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.lightRed,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.25)),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: AppColors.red,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
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
}
