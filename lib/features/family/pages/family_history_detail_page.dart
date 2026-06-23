import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FamilyHistoryDetailPage extends StatelessWidget {
  final Map<String, dynamic> history;

  const FamilyHistoryDetailPage({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final type = history['type']?.toString() ?? '-';
    final raw = _rawData;
    final data = _getDetailData(type, raw);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _header(context, data),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  children: [
                    _detailSection(data),
                    const SizedBox(height: 14),
                    _inputInfoSection(raw),
                    const SizedBox(height: 14),
                    _noteSection(data),
                    const SizedBox(height: 18),
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

  Map<String, dynamic> get _rawData {
    final raw = history['raw'];
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return history;
  }

  String _text(dynamic value, {String fallback = '-'}) {
    if (value == null) return fallback;
    final text = value.toString();
    if (text.trim().isEmpty || text == 'null') return fallback;
    return text;
  }

  Map<String, dynamic> _getDetailData(String type, Map<String, dynamic> item) {
    if (type == 'Glukosa') {
      final value = _text(item['glucose_value'] ?? history['value']);
      final status = _text(
        item['validation_status'] ?? history['badge'] ?? history['status'],
        fallback: 'Valid',
      );

      return {
        'icon': Icons.opacity,
        'value': value,
        'unit': 'mg/dL',
        'date': _formatDetailDate(item['measured_at'] ?? history['date_raw']),
        'status': status,
        'sections': [
          ['Jenis Pengukuran', _text(item['measurement_type'])],
          ['Nilai Glukosa', '$value mg/dL'],
          ['Status Validasi', status],
          ['Waktu Pengukuran', _formatDetailDate(item['measured_at'] ?? history['date_raw'])],
        ],
        'note': _text(item['note'], fallback: ''),
      };
    }

    if (type == 'Fisiologis') {
      final systolic = _text(item['systolic']);
      final diastolic = _text(item['diastolic']);
      final status = _text(
        item['validation_status'] ?? history['badge'] ?? history['status'],
        fallback: 'Valid',
      );

      return {
        'icon': Icons.bar_chart_rounded,
        'value': '$systolic/$diastolic',
        'unit': 'mmHg',
        'date': _formatDetailDate(item['measured_at'] ?? history['date_raw']),
        'status': status,
        'sections': [
          ['Sistolik', '$systolic mmHg'],
          ['Diastolik', '$diastolic mmHg'],
          ['Berat Badan', '${_text(item['weight_kg'])} kg'],
          ['BMI', '${_text(item['bmi'])} kg/m²'],
          ['Status Validasi', status],
          ['Waktu Pengukuran', _formatDetailDate(item['measured_at'] ?? history['date_raw'])],
        ],
        'note': _text(item['note'], fallback: ''),
      };
    }

    if (type == 'Aktivitas') {
      final value = _text(item['duration_minutes'] ?? history['value']);
      final status = _text(
        item['intensity'] ?? item['validation_status'] ?? history['badge'],
      );

      return {
        'icon': Icons.directions_run,
        'value': value,
        'unit': 'menit',
        'date': _formatDetailDate(item['activity_date'] ?? history['date_raw']),
        'status': status,
        'sections': [
          ['Aktivitas', _text(item['activity_name'] ?? history['title'], fallback: 'Aktivitas Fisik')],
          ['Durasi', '$value menit'],
          ['Intensitas', _text(item['intensity'])],
          ['Status Validasi', _text(item['validation_status'] ?? history['badge'], fallback: 'Valid')],
          ['Tanggal Aktivitas', _formatDetailDate(item['activity_date'] ?? history['date_raw'])],
        ],
        'note': _text(item['note'], fallback: ''),
      };
    }

    if (type == 'Makan') {
      final carb = _text(item['carbohydrate_estimate']);
      final calories = _text(item['calories']);
      final mainValue = item['carbohydrate_estimate'] != null
          ? carb
          : _text(item['calories'] ?? history['value']);
      final unit = item['carbohydrate_estimate'] != null ? 'gram' : 'kkal';
      final status = _text(
        item['validation_status'] ?? history['badge'] ?? history['status'],
        fallback: 'Valid',
      );

      return {
        'icon': Icons.restaurant_outlined,
        'value': mainValue,
        'unit': unit,
        'date': _formatDetailDate(item['meal_date'] ?? history['date_raw']),
        'status': status,
        'sections': [
          ['Jenis Makan', _text(item['meal_type_name'] ?? history['title'], fallback: 'Pola Makan')],
          ['Deskripsi Makanan', _text(item['food_description'])],
          ['Estimasi Karbohidrat', '$carb gram'],
          ['Kalori', '$calories kkal'],
          ['Status Validasi', status],
          ['Tanggal Makan', _formatDetailDate(item['meal_date'] ?? history['date_raw'])],
        ],
        'note': _text(item['food_description'], fallback: ''),
      };
    }

    final medicationName = _text(
      item['medication_name'] ?? history['title'],
      fallback: 'Obat',
    );

    final status = _text(
      item['status'] ?? history['badge'] ?? history['status'],
    );

    return {
      'icon': Icons.medication_outlined,
      'value': medicationName,
      'unit': _text(item['session'], fallback: ''),
      'date': _formatDetailDate(item['log_date'] ?? history['date_raw']),
      'status': status,
      'sections': [
        ['Nama Obat', medicationName],
        ['Dokter', _text(history['doctor'] ?? item['doctor_name'])],
        ['Status Konsumsi', status],
        ['Status Resep', _text(history['prescriptionStatus'], fallback: 'Resep aktif')],
        ['Jadwal', _text(item['session'])],
        ['Dosis', _text(item['dose_per_session'])],
        ['Tanggal Konsumsi', _formatDetailDate(item['log_date'] ?? history['date_raw'])],
        ['Waktu Checklist', _formatDetailDate(item['checked_at'])],
        ['Status Validasi', _text(item['validation_status'], fallback: 'Valid')],
      ],
      'note': _text(item['note'], fallback: ''),
    };
  }

  Widget _header(BuildContext context, Map<String, dynamic> data) {
    final topPad = MediaQuery.of(context).padding.top;
    final status = data['status'].toString();

    final isBad = status == 'Abnormal' ||
        status == 'Ditolak' ||
        status == 'Terlewat' ||
        status == 'Tidak Diminum';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 28),
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
                  'Detail Riwayat',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 14),
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.lightBlue,
            child: Icon(
              data['icon'] as IconData,
              color: AppColors.primaryBlue,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data['value'].toString(),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (data['unit'].toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              data['unit'].toString(),
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            data['date'].toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
          if (status.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: isBad ? AppColors.red : AppColors.primaryBlue,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailSection(Map<String, dynamic> data) {
    final sections = data['sections'] as List<List<String>>;

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
          ...sections.map((row) => _detailRow(row[0], row[1])),
        ],
      ),
    );
  }

  Widget _inputInfoSection(Map<String, dynamic> item) {
    final inputByRole = _text(
      history['input_by_role'] ?? item['input_by_role'],
    );

    final inputByName = _text(
      history['input_by_name'] ?? item['input_by_name'],
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Input',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _detailRow('Diinput oleh', inputByRole),
          _detailRow('Nama Penginput', inputByName),
        ],
      ),
    );
  }

  Widget _noteSection(Map<String, dynamic> data) {
    final note = _text(data['note'], fallback: '');

    if (note.isEmpty) return const SizedBox();

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
              note,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.primaryBlue, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Riwayat pasien hanya dapat dilihat oleh keluarga dan tidak dapat diubah dari halaman ini.',
              style: TextStyle(
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
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

  String _formatDetailDate(dynamic value) {
    if (value == null) return '-';

    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();

    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
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