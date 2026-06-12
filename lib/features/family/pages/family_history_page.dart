import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'family_history_detail_page.dart';
import 'family_recommendation_detail_page.dart';

class FamilyHistoryPage extends StatefulWidget {
  const FamilyHistoryPage({super.key});

  @override
  State<FamilyHistoryPage> createState() => _FamilyHistoryPageState();
}

class _FamilyHistoryPageState extends State<FamilyHistoryPage> {
  int mainTab = 0;
  int selectedPatientIndex = 0;
  int selectedFilter = 0;

  final patients = [
    {
      'initial': 'BS',
      'name': 'Budi Santoso',
      'info': 'Ayah • DM Tipe 2 • 58 th',
    },
    {
      'initial': 'SR',
      'name': 'Sari Rahayu',
      'info': 'Ibu • DM Tipe 2 • 55 th',
    },
  ];

  final filters = [
    'Semua',
    'Glukosa',
    'Fisiologis',
    'Aktivitas',
    'Makan',
    'Obat',
  ];

  final List<Map<String, Object>> histories = [
    {
      'patient': 'Budi Santoso',
      'type': 'Glukosa',
      'title': 'Glukosa Puasa',
      'time': '7 Jun • 08:30',
      'value': '142',
      'unit': 'mg/dL',
      'status': 'Disetujui',
      'icon': Icons.opacity,
      'color': Colors.orange,
    },
    {
      'patient': 'Budi Santoso',
      'type': 'Fisiologis',
      'title': 'Tekanan Darah',
      'time': '7 Jun • 08:25',
      'value': '135/88',
      'unit': 'mmHg',
      'status': 'Menunggu',
      'icon': Icons.bar_chart_rounded,
      'color': Colors.orange,
    },
    {
      'patient': 'Sari Rahayu',
      'type': 'Obat',
      'title': 'Kepatuhan Obat',
      'time': '7 Jun • 07:00',
      'value': '',
      'unit': '',
      'status': 'Ditolak',
      'icon': Icons.medication_outlined,
      'color': AppColors.red,
    },
  ];

  final List<Map<String, String>> recommendationHistories = [
    {
      'patient': 'Budi Santoso',
      'doctor': 'dr. Agus Setiawan, Sp.PD',
      'date': '7 Jun 2025 • 09:41',
      'status': 'Tidak Stabil',
      'description':
          'Glukosa postprandial tinggi. Keluarga diminta membantu memantau pola makan dan kepatuhan obat pasien.',
      'initial': 'AS',
    },
    {
      'patient': 'Sari Rahayu',
      'doctor': 'dr. Sarah Puspita, Sp.PD',
      'date': '1 Jun 2025 • 11:00',
      'status': 'Stabil',
      'description':
          'Kondisi pasien stabil. Tetap bantu pantau aktivitas ringan dan jadwal minum obat pasien.',
      'initial': 'SP',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final selectedPatient = patients[selectedPatientIndex];

    final healthData = histories.where((item) {
      final samePatient = item['patient'] == selectedPatient['name'];
      final sameFilter =
          selectedFilter == 0 || item['type'] == filters[selectedFilter];
      return samePatient && sameFilter;
    }).toList();

    final recommendationData = recommendationHistories.where((item) {
      return item['patient'] == selectedPatient['name'];
    }).toList();

    return Container(
      color: AppColors.primaryBlue,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: Container(
                color: AppColors.background,
                child: Column(
                  children: [
                    _patientCard(selectedPatient),
                    Expanded(
                      child: mainTab == 0
                          ? _healthContent(healthData)
                          : _recommendationContent(recommendationData),
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
      padding: EdgeInsets.fromLTRB(24, topPad + 30, 24, 26),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Riwayat',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 28),
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.light1),
            ),
            child: Row(
              children: [
                _mainTabItem('Data Kesehatan', 0),
                _mainTabItem('Rekomendasi', 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mainTabItem(String title, int index) {
    final selected = mainTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => mainTab = index),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.lightBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
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

  Widget _patientCard(Map<String, String> patient) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.light1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.lightBlue,
            child: Text(
              patient['initial']!,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient['name']!,
                  style: const TextStyle(
                    color: AppColors.dark1,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  patient['info']!,
                  style: const TextStyle(color: AppColors.dark2, fontSize: 11),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: _showPatientSelector,
            icon: const Icon(Icons.swap_horiz, size: 15),
            label: const Text('Ganti'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              side: const BorderSide(color: AppColors.light1),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _healthContent(List<Map<String, Object>> data) {
    return Column(
      children: [
        _filterChips(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            children: [
              const Text(
                '7 JUN 2025',
                style: TextStyle(
                  color: AppColors.dark2,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              if (data.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(
                    child: Text(
                      'Belum ada riwayat untuk pasien ini',
                      style: TextStyle(color: AppColors.dark2),
                    ),
                  ),
                )
              else
                ...data.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FamilyHistoryDetailPage(
                              type: item['type'] as String,
                            ),
                          ),
                        );
                      },
                      child: _HistoryCard(
                        title: item['title'] as String,
                        time: item['time'] as String,
                        value: item['value'] as String,
                        unit: item['unit'] as String,
                        status: item['status'] as String,
                        icon: item['icon'] as IconData,
                        color: item['color'] as Color,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _recommendationContent(List<Map<String, String>> data) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
      children: [
        const Text(
          'REKOMENDASI DOKTER',
          style: TextStyle(
            color: AppColors.dark2,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        if (data.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 80),
            child: Center(
              child: Text(
                'Belum ada rekomendasi untuk pasien ini',
                style: TextStyle(color: AppColors.dark2),
              ),
            ),
          )
        else
          ...data.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FamilyRecommendationDetailPage(),
                    ),
                  );
                },
                child: _RecommendationHistoryCard(
                  initial: item['initial']!,
                  doctor: item['doctor']!,
                  date: item['date']!,
                  status: item['status']!,
                  description: item['description']!,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _filterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Row(
        children: List.generate(filters.length, (index) {
          final selected = selectedFilter == index;

          return GestureDetector(
            onTap: () => setState(() => selectedFilter = index),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? AppColors.primaryBlue : AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected ? AppColors.primaryBlue : AppColors.light1,
                ),
              ),
              child: Text(
                filters[index],
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.primaryBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _showPatientSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(patients.length, (index) {
              final patient = patients[index];
              final selected = selectedPatientIndex == index;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      selected ? AppColors.primaryBlue : AppColors.lightBlue,
                  child: Text(
                    patient['initial']!,
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(patient['name']!),
                subtitle: Text(patient['info']!),
                trailing: Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: AppColors.primaryBlue,
                ),
                onTap: () {
                  setState(() => selectedPatientIndex = index);
                  Navigator.pop(sheetContext);
                },
              );
            }),
          ),
        );
      },
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String title;
  final String time;
  final String value;
  final String unit;
  final String status;
  final IconData icon;
  final Color color;

  const _HistoryCard({
    required this.title,
    required this.time,
    required this.value,
    required this.unit,
    required this.status,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.veryLightBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 20),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  time,
                  style: const TextStyle(color: AppColors.dark2, fontSize: 12),
                ),
                const SizedBox(height: 6),
                _statusBadge(status),
              ],
            ),
          ),
          if (hasValue)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  unit,
                  style: const TextStyle(color: AppColors.dark2, fontSize: 10),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color bg;
    Color textColor;

    if (status == 'Disetujui') {
      bg = const Color(0xFFEAFBF3);
      textColor = const Color(0xFF10C878);
    } else if (status == 'Ditolak') {
      bg = AppColors.lightRed;
      textColor = AppColors.red;
    } else {
      bg = const Color(0xFFFFF4C7);
      textColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
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

class _RecommendationHistoryCard extends StatelessWidget {
  final String initial;
  final String doctor;
  final String date;
  final String status;
  final String description;

  const _RecommendationHistoryCard({
    required this.initial,
    required this.doctor,
    required this.date,
    required this.status,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isStable = status == 'Stabil';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.lightBlue,
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor,
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
                        color: AppColors.dark2,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _badge(
                text: 'Rekomendasi',
                bg: AppColors.veryLightBlue,
                color: AppColors.primaryBlue,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _badge(
            text: status,
            bg: isStable ? const Color(0xFFEAFBF3) : const Color(0xFFFFF4DA),
            color: isStable ? const Color(0xFF10C878) : Colors.orange,
            icon: isStable ? Icons.check_rounded : Icons.warning_amber_rounded,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.send_outlined, color: AppColors.primaryBlue, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Rekomendasi diterima keluarga',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.dark3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge({
    required String text,
    required Color bg,
    required Color color,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.light1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.07),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}