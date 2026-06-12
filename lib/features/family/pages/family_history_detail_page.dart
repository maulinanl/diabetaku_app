import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FamilyHistoryDetailPage extends StatelessWidget {
  final String type;

  const FamilyHistoryDetailPage({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final data = _getDetailData(type);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _header(context, data),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                child: Column(
                  children: [
                    _detailSection(data),
                    const SizedBox(height: 14),
                    _noteSection(data),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () => _showDeleteSheet(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text('Hapus data ini'),
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

  Map<String, dynamic> _getDetailData(String type) {
    if (type == 'Aktivitas') {
      return {
        'title': 'Aktivitas Fisik',
        'icon': Icons.directions_run,
        'value': '45',
        'unit': 'menit',
        'date': '7 Juni 2025 • 08:20',
        'status': 'Disetujui',
        'sections': [
          ['Jenis aktivitas', 'Jalan kaki'],
          ['Durasi', '45 menit'],
          ['Intensitas', 'Sedang'],
          ['Diinput oleh', 'Sandra Ayu'],
        ],
        'note': 'Jalan pagi keliling kompleks.',
      };
    }

    if (type == 'Obat') {
      return {
        'title': 'Kepatuhan Obat',
        'icon': Icons.medication_outlined,
        'value': 'Metformin 850mg',
        'unit': 'Dosis malam',
        'date': '7 Juni 2025 • 07:00',
        'status': 'Ditolak',
        'sections': [
          ['Nama Obat', 'Metformin'],
          ['Dosis', '850 mg'],
          ['Status konsumsi', 'Diminum'],
          ['Waktu aktual minum', '07:00'],
          ['Diinput oleh', 'Sandra Ayu'],
        ],
        'note': 'Pasien menolak karena waktu minum tidak sesuai.',
      };
    }

    if (type == 'Makan') {
      return {
        'title': 'Pola Makan',
        'icon': Icons.restaurant_outlined,
        'value': '60',
        'unit': 'gram',
        'date': '7 Juni 2025 • 12:20',
        'status': 'Menunggu',
        'sections': [
          ['Tipe makan', 'Sarapan'],
          ['Estimasi karbohidrat', '60 gram'],
          ['Diinput oleh', 'Sandra Ayu'],
        ],
        'note': 'Nasi putih, ayam goreng, sayur bayam.',
      };
    }

    if (type == 'Fisiologis') {
      return {
        'title': 'Data Fisiologis',
        'icon': Icons.bar_chart_rounded,
        'value': '135/88',
        'unit': 'mmHg',
        'date': '7 Juni 2025 • 08:25',
        'status': 'Menunggu',
        'sections': [
          ['Sistolik', '135 mmHg'],
          ['Diastolik', '88 mmHg'],
          ['Berat Badan', '78.5 kg'],
          ['Diinput oleh', 'Sandra Ayu'],
        ],
        'note': '',
      };
    }

    return {
      'title': 'Data Glukosa',
      'icon': Icons.opacity,
      'value': '142',
      'unit': 'mg/dL',
      'date': '7 Juni 2025 • 08:30',
      'status': 'Disetujui',
      'sections': [
        ['Tipe pengukuran', 'Puasa'],
        ['Nilai', '142 mg/dL'],
        ['Status validasi', 'Disetujui'],
        ['Diinput oleh', 'Sandra Ayu'],
      ],
      'note': 'Setelah bangun tidur.',
    };
  }

  Widget _header(BuildContext context, Map<String, dynamic> data) {
    final topPad = MediaQuery.of(context).padding.top;
    final status = data['status'] as String;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 24),
      color: AppColors.primaryBlue,
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Expanded(
                child: Text(
                  'Riwayat',
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
          const SizedBox(height: 8),
          Text(
            data['title'],
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(height: 10),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white.withValues(alpha: 0.18),
            child: Icon(data['icon'], color: Colors.white, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            data['value'],
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            data['unit'],
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            data['date'],
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
          const SizedBox(height: 8),
          _statusBadge(status),
        ],
      ),
    );
  }

  Widget _detailSection(Map<String, dynamic> data) {
    final sections = data['sections'] as List<List<String>>;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi data',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...sections.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      row[0],
                      style: const TextStyle(
                        color: AppColors.dark2,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    row[1],
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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

  Widget _noteSection(Map<String, dynamic> data) {
    final note = data['note'] as String;

    if (note.isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Catatan',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 12,
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
              note,
              style: const TextStyle(color: AppColors.dark1, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color bg;
    Color textColor;
    IconData icon;

    if (status == 'Disetujui') {
      bg = const Color(0xFFEAFBF3);
      textColor = const Color(0xFF10C878);
      icon = Icons.check_rounded;
    } else if (status == 'Ditolak') {
      bg = AppColors.lightRed;
      textColor = AppColors.red;
      icon = Icons.close_rounded;
    } else {
      bg = const Color(0xFFFFF4C7);
      textColor = Colors.orange;
      icon = Icons.access_time_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 12),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteSheet(BuildContext context) {
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
                backgroundColor: AppColors.lightRed,
                child: Icon(
                  Icons.delete_outline,
                  color: AppColors.red,
                  size: 36,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Hapus data ini?',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Data yang dihapus tidak dapat dikembalikan. Pastikan Anda yakin sebelum melanjutkan.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.dark2, fontSize: 13),
              ),
              const SizedBox(height: 22),
              TextButton(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  _showDeletedSuccess(context);
                },
                child: const Text(
                  'Hapus',
                  style: TextStyle(color: AppColors.primaryBlue),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text('Batal'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeletedSuccess(BuildContext context) {
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
                child: Icon(Icons.check, color: Color(0xFF10C878), size: 36),
              ),
              const SizedBox(height: 18),
              const Text(
                'Data berhasil dihapus',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Data yang dipilih telah dihapus dari riwayat keluarga.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.dark2, fontSize: 13),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text('Kembali ke riwayat'),
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
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.light1),
    );
  }
}