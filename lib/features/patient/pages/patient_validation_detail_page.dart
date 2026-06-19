import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';

class PatientValidationDetailPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const PatientValidationDetailPage({
    super.key,
    required this.item,
  });

  @override
  State<PatientValidationDetailPage> createState() =>
      _PatientValidationDetailPageState();
}

class _PatientValidationDetailPageState
    extends State<PatientValidationDetailPage> {
  bool isProcessing = false;

  String get recordType => widget.item['record_type']?.toString() ?? '';

  int get recordId => int.parse(widget.item['record_id'].toString());

  String get name =>
      widget.item['input_by']?.toString() ??
      widget.item['inputBy']?.toString() ??
      '-';

  String get relation => widget.item['relation']?.toString() ?? 'Keluarga';

  String get type => widget.item['title']?.toString() ?? '-';

  String get value {
    final value = widget.item['value']?.toString() ?? '-';
    final unit = widget.item['unit']?.toString() ?? '';

    return unit.isEmpty ? value : '$value $unit';
  }

  String get time => _formatDate(widget.item['date']);

  String get note => widget.item['note']?.toString() ?? 'Tidak ada catatan.';

  IconData get icon {
    switch (recordType) {
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

  String _formatDate(dynamic value) {
    if (value == null) return '-';

    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();

    return '${date.day}/${date.month}/${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _respond(bool approve) async {
    if (isProcessing) return;

    setState(() {
      isProcessing = true;
    });

    try {
      await ApiService.respondPatientValidation(
        recordType: recordType,
        recordId: recordId,
        status: approve ? 'Valid' : 'Ditolak',
      );

      if (!mounted) return;

      setState(() {
        isProcessing = false;
      });

      _showActionSheet(context, approve, success: true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isProcessing = false;
      });

      _showActionSheet(
        context,
        approve,
        success: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                child: Column(
                  children: [
                    _detailSection(),
                    const SizedBox(height: 14),
                    _noteSection(),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                isProcessing ? null : () => _respond(false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.red,
                              side: const BorderSide(color: AppColors.red),
                              minimumSize: const Size.fromHeight(46),
                            ),
                            child: const Text('Tolak'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                isProcessing ? null : () => _respond(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: AppColors.light1,
                              minimumSize: const Size.fromHeight(46),
                              elevation: 0,
                            ),
                            child: Text(isProcessing ? 'Memproses...' : 'Setujui'),
                          ),
                        ),
                      ],
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

  Widget _header(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 24),
      color: AppColors.primaryBlue,
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context, false),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Expanded(
                child: Text(
                  'Validasi Data',
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
          const SizedBox(height: 12),
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.lightBlue,
            child: Icon(icon, color: AppColors.primaryBlue, size: 26),
          ),
          const SizedBox(height: 12),
          Text(type, style: const TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(time, style: const TextStyle(color: Colors.white, fontSize: 11)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4DA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Menunggu Validasi',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
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
          const SizedBox(height: 14),
          _row('Jenis Data', type),
          _row('Nilai', value),
          _row('Diinput Oleh', name),
          _row('Hubungan', relation),
          _row('Waktu Input', time),
        ],
      ),
    );
  }

  Widget _noteSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Catatan Keluarga',
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
            child: Text(note, style: const TextStyle(color: AppColors.dark1)),
          ),
        ],
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: AppColors.dark2, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
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
    );
  }

  void _showActionSheet(
    BuildContext context,
    bool approve, {
    required bool success,
    String? errorMessage,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final title = success
            ? (approve ? 'Data berhasil divalidasi' : 'Data ditolak')
            : 'Gagal memproses';

        final message = success
            ? (approve
                ? 'Data telah masuk ke riwayat kesehatan pasien.'
                : 'Data tidak akan dimasukkan ke riwayat kesehatan pasien.')
            : (errorMessage ?? 'Terjadi kesalahan saat memproses data.');

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor:
                    success && approve ? const Color(0xFFEAFBF3) : AppColors.lightRed,
                child: Icon(
                  success
                      ? (approve ? Icons.check : Icons.close)
                      : Icons.error_outline,
                  color:
                      success && approve ? const Color(0xFF10C878) : AppColors.red,
                  size: 34,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.dark2),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);

                    if (success) {
                      Navigator.pop(context, true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.light1),
    );
  }
}