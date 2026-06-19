import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FamilyHistoryDetailPage extends StatelessWidget {
  final Map<String, dynamic> history;

  const FamilyHistoryDetailPage({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final type = history['type']?.toString() ?? '-';
    final title = history['title']?.toString() ?? '-';
    final value = history['value']?.toString() ?? '-';
    final unit = history['unit']?.toString() ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _header(context, title: title, value: value, unit: unit),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.light1),
                  ),
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

                      const SizedBox(height: 20),

                      ..._buildDetail(type),

                      if ((history['note'] ?? '').toString().isNotEmpty) ...[
                        const SizedBox(height: 24),

                        const Text(
                          'Catatan',
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          history['note'].toString(),
                          style: const TextStyle(color: AppColors.dark1),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(
    BuildContext context, {
    required String title,
    required String value,
    required String unit,
  }) {
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
                  ),
                ),
              ),

              const SizedBox(width: 48),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (unit.isNotEmpty)
            Text(unit, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  List<Widget> _buildDetail(String type) {
    switch (type) {
      case 'Glukosa':
        return [
          _detailRow('Jenis', history['glucose_type']?.toString() ?? '-'),
          _detailRow('Nilai', '${history['value']} mg/dL'),
          _detailRow('Tanggal', history['recorded_at']?.toString() ?? '-'),
          _detailRow('Status', history['status']?.toString() ?? '-'),
        ];

      case 'Fisiologis':
        return [
          _detailRow(
            'Tekanan Darah',
            '${history['systolic'] ?? '-'} / ${history['diastolic'] ?? '-'}',
          ),
          _detailRow('Berat Badan', '${history['weight_kg'] ?? '-'} kg'),
          _detailRow('BMI', history['bmi']?.toString() ?? '-'),
          _detailRow('Tanggal', history['recorded_at']?.toString() ?? '-'),
        ];

      case 'Aktivitas':
        return [
          _detailRow('Aktivitas', history['activity_name']?.toString() ?? '-'),
          _detailRow('Durasi', '${history['duration_minutes'] ?? '-'} menit'),
          _detailRow('Intensitas', history['intensity']?.toString() ?? '-'),
          _detailRow('Tanggal', history['recorded_at']?.toString() ?? '-'),
        ];

      case 'Makan':
        return [
          _detailRow('Jenis Makan', history['meal_type']?.toString() ?? '-'),
          _detailRow('Kalori', '${history['calories'] ?? '-'} kkal'),
          _detailRow('Karbohidrat', '${history['carbs'] ?? '-'} gr'),
          _detailRow('Tanggal', history['recorded_at']?.toString() ?? '-'),
        ];

      case 'Obat':
        return [
          _detailRow('Obat', history['medication_name']?.toString() ?? '-'),
          _detailRow('Dosis', history['dosage']?.toString() ?? '-'),
          _detailRow('Status', history['status']?.toString() ?? '-'),
          _detailRow('Tanggal', history['recorded_at']?.toString() ?? '-'),
        ];

      default:
        return [_detailRow('Informasi', '-')];
    }
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: AppColors.dark2)),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
