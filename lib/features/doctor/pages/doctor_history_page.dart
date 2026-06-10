import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'clinical_note_detail_page.dart';

class DoctorHistoryPage extends StatefulWidget {
  const DoctorHistoryPage({super.key});

  @override
  State<DoctorHistoryPage> createState() => _DoctorHistoryPageState();
}

class _DoctorHistoryPageState extends State<DoctorHistoryPage> {
  int selectedFilter = 0;

  final filters = ['Semua', 'Catatan Klinis', '+ Rekomendasi'];

  final histories = [
    {
      'initial': 'SG',
      'name': 'Sona Gemilang',
      'age': '32 tahun • Laki-laki',
      'type': 'Rekomendasi',
      'status': 'Tidak Stabil',
      'description':
          'Glukosa postprandial 187 mg/dL, melebihi batas normal. Penyesuaian dosis Metformin diperlukan.',
      'followUp': 'Follow up: 7 Jul 2025',
    },
    {
      'initial': 'AB',
      'name': 'Ahmad Barik',
      'age': '27 tahun • Perempuan',
      'type': 'Catatan Klinis',
      'status': 'Stabil',
      'description':
          'Kondisi pasien stabil. Glukosa puasa dalam batas normal. Tekanan darah terkontrol baik.',
      'followUp': 'Tanpa rekomendasi',
    },
    {
      'initial': 'WH',
      'name': 'Wijaya',
      'age': '52 tahun • Laki-laki',
      'type': 'Rekomendasi',
      'status': 'Perlu perhatian',
      'description':
          'HbA1c turun ke 7.2% dan berat badan mulai terkontrol. Edukasi aktivitas fisik tetap dilanjutkan.',
      'followUp': 'Follow up: 10 Jul 2025',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = histories.where((item) {
      if (selectedFilter == 0) return true;
      if (selectedFilter == 1) return item['type'] == 'Catatan Klinis';
      return item['type'] == 'Rekomendasi';
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
                      children: [
                        const Text(
                          '7 Jun 2025 - Hari ini',
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...filtered.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ClinicalNoteDetailPage(),
                                  ),
                                );
                              },
                              child: _HistoryCard(
                                initial: item['initial']!,
                                name: item['name']!,
                                age: item['age']!,
                                type: item['type']!,
                                status: item['status']!,
                                description: item['description']!,
                                followUp: item['followUp']!,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18, topPad + 18, 18, 20),
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            decoration: InputDecoration(
              hintText: 'Cari nama pasien',
              hintStyle: const TextStyle(fontSize: 13, color: AppColors.dark3),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.primaryBlue,
                size: 20,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(filters.length, (index) {
              final selected = selectedFilter == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedFilter = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primaryBlue : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: selected
                            ? AppColors.primaryBlue
                            : AppColors.light1,
                      ),
                    ),
                    child: Text(
                      filters[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selected ? Colors.white : AppColors.primaryBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.veryLightBlue,
              child: Icon(
                Icons.history_toggle_off,
                color: AppColors.primaryBlue,
                size: 36,
              ),
            ),
            SizedBox(height: 18),
            Text(
              'Belum ada riwayat',
              style: TextStyle(
                color: AppColors.dark1,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Catatan klinis dengan rekomendasi akan muncul di sini setelah kamu membuat catatan klinis untuk pasien.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.primaryBlue, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String initial;
  final String name;
  final String age;
  final String type;
  final String status;
  final String description;
  final String followUp;

  const _HistoryCard({
    required this.initial,
    required this.name,
    required this.age,
    required this.type,
    required this.status,
    required this.description,
    required this.followUp,
  });

  @override
  Widget build(BuildContext context) {
    final isRecommendation = type == 'Rekomendasi';
    final statusColor = status == 'Stabil'
        ? const Color(0xFF10C878)
        : status == 'Tidak Stabil'
        ? Colors.orange
        : AppColors.primaryBlue;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.light1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.lightBlue,
                child: Text(
                  initial,
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
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.dark1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      age,
                      style: const TextStyle(
                        color: AppColors.dark2,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.veryLightBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isRecommendation ? '+ Rekomendasi' : 'Catatan Klinis',
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: status == 'Tidak Stabil'
                  ? const Color(0xFFFFF8E8)
                  : AppColors.veryLightBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  status == 'Stabil'
                      ? Icons.check_circle_outline
                      : Icons.warning_amber_rounded,
                  size: 16,
                  color: statusColor,
                ),
                const SizedBox(width: 6),
                Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.dark2,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  followUp,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 11,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.dark3),
            ],
          ),
        ],
      ),
    );
  }
}
