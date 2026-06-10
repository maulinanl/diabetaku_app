import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DoctorRequestPage extends StatefulWidget {
  const DoctorRequestPage({super.key});

  @override
  State<DoctorRequestPage> createState() => _DoctorRequestPageState();
}

class _DoctorRequestPageState extends State<DoctorRequestPage> {
  int selectedTab = 0;

  final tabs = ['Menunggu', 'Diterima', 'Ditolak'];

  final pendingRequests = [
    {
      'initial': 'WP',
      'name': 'Wahyu Prasetyo',
      'info': 'DM Tipe 2 • 47 tahun • Laki-laki',
      'diagnosis': 'Diagnosis: 2019',
      'time': '2 jam lalu',
    },
    {
      'initial': 'MP',
      'name': 'Maya Putri Sari',
      'info': 'DM Tipe 1 • 28 tahun • Perempuan',
      'diagnosis': 'Diagnosis: 2020',
      'time': '5 jam lalu',
    },
  ];

  final acceptedRequests = [
    {
      'initial': 'WP',
      'name': 'Wahyu Prasetyo',
      'info': 'DM Tipe 2 • 47 tahun • Laki-laki',
      'diagnosis': 'Diagnosis: 2019',
      'time': '2 jam lalu',
    },
  ];

  final rejectedRequests = [
    {
      'initial': 'WP',
      'name': 'Wahyu Prasetyo',
      'info': 'DM Tipe 2 • 47 tahun • Laki-laki',
      'diagnosis': 'Diagnosis: 2018',
      'time': '2 jam lalu',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final data = selectedTab == 0
        ? pendingRequests
        : selectedTab == 1
        ? acceptedRequests
        : rejectedRequests;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              color: AppColors.primaryBlue,
              child: const Center(
                child: Text(
                  'Permintaan Koneksi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: List.generate(tabs.length, (index) {
                  final selected = selectedTab == index;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTab = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primaryBlue
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.light1),
                        ),
                        child: Text(
                          tabs[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : AppColors.primaryBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            Expanded(
              child: data.isEmpty
                  ? _emptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: data.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final item = data[index];

                        return _RequestCard(
                          initial: item['initial']!,
                          name: item['name']!,
                          info: item['info']!,
                          diagnosis: item['diagnosis']!,
                          time: item['time']!,
                          status: selectedTab,
                          onDetail: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RequestDetailPage(),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_add_alt_1_rounded,
            size: 72,
            color: AppColors.primaryBlue,
          ),
          SizedBox(height: 18),
          Text(
            'Tidak ada Permintaan',
            style: TextStyle(
              color: AppColors.dark1,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Pasien yang ingin terhubung denganmu akan muncul di sini untuk kamu terima atau tolak.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.primaryBlue, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final String initial;
  final String name;
  final String info;
  final String diagnosis;
  final String time;
  final int status;
  final VoidCallback onDetail;

  const _RequestCard({
    required this.initial,
    required this.name,
    required this.info,
    required this.diagnosis,
    required this.time,
    required this.status,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    final isRejected = status == 2;

    return GestureDetector(
      onTap: onDetail,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 8,
              offset: const Offset(0, 4),
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
                        info,
                        style: TextStyle(
                          color: isRejected
                              ? AppColors.red
                              : AppColors.primaryBlue,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    color: isRejected ? AppColors.red : AppColors.primaryBlue,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: isRejected
                    ? AppColors.lightRed
                    : AppColors.veryLightBlue,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                diagnosis,
                style: TextStyle(
                  color: isRejected ? AppColors.red : AppColors.primaryBlue,
                  fontSize: 11,
                ),
              ),
            ),
            if (status == 0) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.red,
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: AppColors.light1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text('Tolak'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text('Terima'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class RequestDetailPage extends StatelessWidget {
  const RequestDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
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
                          'Permintaan Koneksi',
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
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.lightBlue,
                          child: Icon(
                            Icons.person_add_alt_1,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Permintaan koneksi baru\n7 Jun 2025\n08:15',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.light1),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Pasien',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 14),
                    _DetailRow(label: 'Nama', value: 'Wahyu Tri Utomo'),
                    _DetailRow(label: 'Tipe DM', value: 'DM Tipe 2'),
                    _DetailRow(label: 'Usia', value: '47 tahun'),
                    _DetailRow(label: 'Tahun diagnosis', value: '2019'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text('Terima permintaan'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text('Tolak permintaan'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 12,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: AppColors.dark1, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
