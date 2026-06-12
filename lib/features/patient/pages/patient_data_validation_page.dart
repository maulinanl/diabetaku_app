import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PatientDataValidationPage extends StatefulWidget {
  const PatientDataValidationPage({super.key});

  @override
  State<PatientDataValidationPage> createState() =>
      _PatientDataValidationPageState();
}

class _PatientDataValidationPageState extends State<PatientDataValidationPage> {
  final List<Map<String, String>> pendingData = [
    {
      'title': 'Glukosa Postprandial',
      'date': '7 Jun, 08:30',
      'value': '165',
      'unit': 'mg/dL',
      'inputBy': 'Kartika Putri Citra',
      'relation': 'Istri',
    },
    {
      'title': 'Tekanan Darah',
      'date': '7 Jun, 08:25',
      'value': '130/85',
      'unit': 'mmHg',
      'inputBy': 'Kartika Putri Citra',
      'relation': 'Istri',
    },
  ];

  void _acceptData(int index) {
    final item = pendingData[index];

    setState(() {
      pendingData.removeAt(index);
    });

    _showResultSheet(
      title: 'Data diterima',
      message:
          '${item['title']} berhasil diterima dan akan masuk ke riwayat kesehatanmu.',
      icon: Icons.check,
      color: const Color(0xFF10C878),
      bg: const Color(0xFFEAFBF3),
    );
  }

  void _rejectData(int index) {
    final item = pendingData[index];

    setState(() {
      pendingData.removeAt(index);
    });

    _showResultSheet(
      title: 'Data ditolak',
      message:
          '${item['title']} tidak disimpan ke riwayat kesehatanmu.',
      icon: Icons.close,
      color: AppColors.red,
      bg: AppColors.lightRed,
    );
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
            Expanded(
              child: pendingData.isEmpty
                  ? _emptyState()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                      children: [
                        _infoBox(),
                        const SizedBox(height: 22),
                        ...List.generate(
                          pendingData.length,
                          (index) {
                            final item = pendingData[index];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 18),
                              child: _ValidationCard(
                                title: item['title']!,
                                date: item['date']!,
                                value: item['value']!,
                                unit: item['unit']!,
                                inputBy: item['inputBy']!,
                                relation: item['relation']!,
                                onAccept: () => _acceptData(index),
                                onReject: () => _rejectData(index),
                              ),
                            );
                          },
                        ),
                      ],
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
      padding: EdgeInsets.fromLTRB(16, topPad + 14, 16, 18),
      color: AppColors.primaryBlue,
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
                fontSize: 21,
                fontWeight: FontWeight.bold,
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
          Icon(
            Icons.info_outline,
            color: AppColors.primaryBlue,
            size: 22,
          ),
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
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _ValidationCard({
    required this.title,
    required this.date,
    required this.value,
    required this.unit,
    required this.inputBy,
    required this.relation,
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
                child: const Icon(
                  Icons.opacity,
                  color: AppColors.primaryBlue,
                  size: 22,
                ),
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
                      text: ' $unit',
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
                const Icon(
                  Icons.person,
                  color: AppColors.primaryBlue,
                  size: 16,
                ),
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
                    onPressed: onAccept,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Terima'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
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
                    onPressed: onReject,
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Tolak'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      foregroundColor: Colors.white,
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