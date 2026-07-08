import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';
import 'package:diabetaku_app/core/theme/app_button_styles.dart';

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

  String get relation => widget.item['relation']?.toString() ?? 'Pendamping';

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

  void _confirmRespond(bool approve) {
    if (isProcessing) return;

    final iconBg = approve ? const Color(0xFFEAFBF3) : AppColors.lightRed;
    final iconColor = approve ? const Color(0xFF10C878) : AppColors.red;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 26),
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
                  backgroundColor: iconBg,
                  child: Icon(
                    approve
                        ? Icons.check_rounded
                        : Icons.close_rounded,
                    color: iconColor,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  approve ? 'Setujui data ini?' : 'Tolak data ini?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  approve
                      ? 'Pastikan data dari pendamping sudah benar sebelum disetujui.'
                      : 'Pastikan data memang tidak sesuai sebelum ditolak.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.dark2,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.veryLightBlue,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.light1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type,
                        style: const TextStyle(
                          color: AppColors.dark1,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$value • $time',
                        style: const TextStyle(
                          color: AppColors.dark2,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Diinput oleh: $name ($relation)',
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          style: approve
                              ? AppButtonStyles.outlined
                              : AppButtonStyles.outlinedDanger,
                          child: const Text('Batal'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            _respond(approve);
                          },
                          style: approve
                              ? AppButtonStyles.primary
                              : AppButtonStyles.danger,
                          child: Text(
                            approve ? 'Setujui' : 'Tolak',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
                          child: SizedBox(
                            height: 50,
                            child: OutlinedButton(
                              onPressed: isProcessing
                                  ? null
                                  : () => _confirmRespond(false),
                              style: AppButtonStyles.outlinedDanger,
                              child: const Text('Tolak'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: isProcessing
                                  ? null
                                  : () => _confirmRespond(true),
                              style: AppButtonStyles.primary,
                              child: Text(
                                isProcessing ? 'Memproses...' : 'Setujui',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
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
      padding: EdgeInsets.fromLTRB(12, topPad + 12, 20, 24),
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
                onPressed: () => Navigator.pop(context, false),
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
            'Catatan Pendamping',
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
      isScrollControlled: true,
      builder: (sheetContext) {
        final title = success
            ? (approve ? 'Data berhasil divalidasi' : 'Data ditolak')
            : 'Gagal memproses';

        final message = success
            ? (approve
                ? 'Data telah masuk ke riwayat kesehatan pasien.'
                : 'Data tidak akan dimasukkan ke riwayat kesehatan pasien.')
            : (errorMessage ?? 'Terjadi kesalahan saat memproses data.');

        final iconData = success
            ? (approve ? Icons.check_rounded : Icons.close_rounded)
            : Icons.error_outline;
        final bgColor = success && approve
            ? const Color(0xFFEAFBF3)
            : AppColors.lightRed;
        final iconColor = success && approve
            ? const Color(0xFF10C878)
            : AppColors.red;

        return SafeArea(
          top: false,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 26),
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
                  backgroundColor: bgColor,
                  child: Icon(iconData, color: iconColor, size: 36),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.dark2,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);

                      if (success) {
                        Navigator.pop(context, true);
                      }
                    },
                    style: AppButtonStyles.primary,
                    child: const Text('Selesai'),
                  ),
                ),
              ],
            ),
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
