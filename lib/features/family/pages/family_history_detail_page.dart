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
                      const SizedBox(height: 16),

                      ...(data['details'] as List<List<String>>).map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  e[0],
                                  style: const TextStyle(
                                    color: AppColors.dark2,
                                  ),
                                ),
                              ),
                              Text(
                                e[1],
                                style: const TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if ((data['note'] as String).isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Catatan',
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(data['note']),
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

  Widget _header(BuildContext context, Map<String, dynamic> data) {
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
            data['title'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            data['value'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            data['unit'],
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getDetailData(String type) {
    switch (type) {
      case 'Glukosa':
        return {
          'title': 'Glukosa Puasa',
          'value': '142',
          'unit': 'mg/dL',
          'details': [
            ['Jenis', 'Puasa'],
            ['Nilai', '142 mg/dL'],
            ['Status', 'Disetujui'],
          ],
          'note': 'Data telah diverifikasi pasien',
        };

      case 'Fisiologis':
        return {
          'title': 'Tekanan Darah',
          'value': '135/88',
          'unit': 'mmHg',
          'details': [
            ['Sistolik', '135'],
            ['Diastolik', '88'],
            ['Berat Badan', '78 kg'],
          ],
          'note': '',
        };

      case 'Aktivitas':
        return {
          'title': 'Aktivitas Fisik',
          'value': '45',
          'unit': 'Menit',
          'details': [
            ['Aktivitas', 'Jalan Kaki'],
            ['Durasi', '45 menit'],
          ],
          'note': 'Dilakukan pagi hari',
        };

      case 'Makan':
        return {
          'title': 'Pola Makan',
          'value': 'Sarapan',
          'unit': '',
          'details': [
            ['Menu', 'Nasi, Telur, Sayur'],
            ['Kalori', '450 kkal'],
          ],
          'note': '',
        };

      default:
        return {
          'title': 'Kepatuhan Obat',
          'value': 'Diminum',
          'unit': '',
          'details': [
            ['Obat', 'Metformin'],
            ['Dosis', '850 mg'],
            ['Status', 'Diminum'],
          ],
          'note': '',
        };
    }
  }
}