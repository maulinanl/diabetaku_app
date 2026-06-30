import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';

class PatientDataValidationPage extends StatefulWidget {
  const PatientDataValidationPage({super.key});

  @override
  State<PatientDataValidationPage> createState() =>
      _PatientDataValidationPageState();
}

class _PatientDataValidationPageState extends State<PatientDataValidationPage> {
  bool isLoading = true;
  String? errorMessage;
  bool isProcessing = false;

  List<Map<String, dynamic>> pendingData = [];

  @override
  void initState() {
    super.initState();
    _loadPendingData();
  }

  Future<void> _loadPendingData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final patientId = prefs.getInt('patient_id');

      if (patientId == null) {
        throw Exception('Patient ID tidak ditemukan. Coba login ulang.');
      }

      final data = await ApiService.getPatientPendingValidations(patientId);

      if (!mounted) return;

      setState(() {
        pendingData = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString().replaceAll('Exception: ', '');
        isLoading = false;
      });
    }
  }

  Future<void> _acceptData(int index) async {
    await _respondData(index: index, status: 'Valid');
  }

  Future<void> _rejectData(int index) async {
    await _respondData(index: index, status: 'Ditolak');
  }

  Future<void> _respondData({
    required int index,
    required String status,
  }) async {
    if (isProcessing) return;

    final item = pendingData[index];

    setState(() {
      isProcessing = true;
    });

    try {
      await ApiService.respondPatientValidation(
        recordType: item['record_type'].toString(),
        recordId: int.parse(item['record_id'].toString()),
        status: status,
      );

      if (!mounted) return;

      setState(() {
        pendingData.removeAt(index);
        isProcessing = false;
      });

      final isAccepted = status == 'Valid';

      _showResultSheet(
        title: isAccepted ? 'Data diterima' : 'Data ditolak',
        message: isAccepted
            ? '${item['title']} berhasil diterima dan akan masuk ke riwayat kesehatanmu.'
            : '${item['title']} tidak disimpan ke riwayat kesehatanmu.',
        icon: isAccepted ? Icons.check : Icons.close,
        color: isAccepted ? const Color(0xFF10C878) : AppColors.red,
        bg: isAccepted ? const Color(0xFFEAFBF3) : AppColors.lightRed,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isProcessing = false;
      });

      _showResultSheet(
        title: 'Gagal memproses',
        message: e.toString().replaceAll('Exception: ', ''),
        icon: Icons.error_outline,
        color: AppColors.red,
        bg: AppColors.lightRed,
      );
    }
  }

  String _formatDate(dynamic value) {
    if (value == null) return '-';

    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();

    return '${date.day}/${date.month}/${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  IconData _iconByType(String type) {
    switch (type) {
      case 'glucose':
        return Icons.opacity;
      case 'physiological':
        return Icons.favorite_border;
      case 'activity':
        return Icons.directions_run;
      case 'meal':
        return Icons.restaurant_outlined;
      default:
        return Icons.assignment_outlined;
    }
  }

  void _showResultSheet({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
    required Color bg,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.white,
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
              CircleAvatar(
                radius: 36,
                backgroundColor: bg,
                child: Icon(icon, color: color, size: 36),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
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
                  onPressed: () => Navigator.pop(sheetContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text('Mengerti'),
                ),
              ),
            ],
          ),
        );
      },
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
            _header(context),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.red,
                size: 42,
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.dark2,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPendingData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (pendingData.isEmpty) {
      return _emptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadPendingData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
        children: [
          _infoBox(),
          const SizedBox(height: 22),
          ...List.generate(pendingData.length, (index) {
            final item = pendingData[index];

            final type = item['record_type']?.toString() ?? '';
            final title = item['title']?.toString() ?? '-';
            final date = _formatDate(item['date']);
            final value = item['value']?.toString() ?? '-';
            final unit = item['unit']?.toString() ?? '';
            final inputBy =
                item['input_by']?.toString() ??
                item['inputBy']?.toString() ??
                '-';
            final relation = item['relation']?.toString() ?? 'Keluarga';

            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: _ValidationCard(
                title: title,
                date: date,
                value: value,
                unit: unit,
                inputBy: inputBy,
                relation: relation,
                icon: _iconByType(type),
                isProcessing: isProcessing,
                onAccept: () => _acceptData(index),
                onReject: () => _rejectData(index),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12, topPad + 12, 20, 24),
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
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              'Validasi Data',
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
    );
  }

  Widget _infoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightBlue),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.primaryBlue, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Data berikut diinput oleh anggota keluargamu. Konfirmasi jika data benar, atau tolak jika tidak sesuai.',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 38),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 38,
              backgroundColor: AppColors.veryLightBlue,
              child: Icon(
                Icons.verified_outlined,
                color: AppColors.primaryBlue,
                size: 38,
              ),
            ),
            SizedBox(height: 18),
            Text(
              'Tidak ada data menunggu validasi',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.dark1,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Data dari keluarga yang perlu dikonfirmasi akan muncul di halaman ini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ValidationCard extends StatelessWidget {
  final String title;
  final String date;
  final String value;
  final String unit;
  final String inputBy;
  final String relation;
  final IconData icon;
  final bool isProcessing;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _ValidationCard({
    required this.title,
    required this.date,
    required this.value,
    required this.unit,
    required this.inputBy,
    required this.relation,
    required this.icon,
    required this.isProcessing,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.light1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.veryLightBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primaryBlue, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.dark1,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: unit.isEmpty ? '' : ' $unit',
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.veryLightBlue.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.light1),
            ),
            child: Row(
              children: [
                const Icon(Icons.person, color: AppColors.primaryBlue, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Diinput oleh: $inputBy ($relation)',
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: isProcessing ? null : onAccept,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Terima'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.light1,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: isProcessing ? null : onReject,
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Tolak'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.light1,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}