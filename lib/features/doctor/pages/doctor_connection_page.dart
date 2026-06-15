import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'patient_detail_page.dart';

class DoctorConnectionPage extends StatefulWidget {
  const DoctorConnectionPage({super.key});

  @override
  State<DoctorConnectionPage> createState() => _DoctorConnectionPageState();
}

class _DoctorConnectionPageState extends State<DoctorConnectionPage> {
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
      'diagnosis': 'Diterima: 7 Jun 2025',
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
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Container(
                color: AppColors.background,
                child: Column(
                  children: [
                    _buildTabs(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          selectedTab == 0
                              ? 'KONEKSI MENUNGGU - ${data.length}'
                              : selectedTab == 1
                              ? 'KONEKSI DITERIMA - ${data.length}'
                              : 'KONEKSI DITOLAK - ${data.length}',
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: data.isEmpty
                          ? _emptyState()
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                18,
                                0,
                                18,
                                120,
                              ),
                              itemCount: data.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 14),
                              itemBuilder: (context, index) {
                                final item = data[index];

                                return _RequestCard(
                                  initial: item['initial']!,
                                  name: item['name']!,
                                  info: item['info']!,
                                  diagnosis: item['diagnosis']!,
                                  time: item['time']!,
                                  status: selectedTab,
                                  onDetail: selectedTab == 2
                                      ? null
                                      : () {
                                          if (selectedTab == 1) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const PatientDetailPage(
                                                      patientId: 1,
                                                    ),
                                              ),
                                            );
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    RequestDetailPage(
                                                      status: selectedTab,
                                                    ),
                                              ),
                                            );
                                          }
                                        },
                                );
                              },
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

  Widget _buildHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPad + 22, 20, 26),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: const Center(
        child: Text(
          'Permintaan Koneksi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final selected = selectedTab == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedTab = index),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primaryBlue : AppColors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: selected ? AppColors.primaryBlue : AppColors.light1,
                  ),
                ),
                child: Text(
                  tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 44),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 38,
              backgroundColor: AppColors.veryLightBlue,
              child: Icon(
                Icons.person_add_alt_1_rounded,
                size: 42,
                color: AppColors.primaryBlue,
              ),
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
            Text(
              'Pasien yang ingin terhubung denganmu akan muncul di sini untuk kamu terima atau tolak.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.primaryBlue, fontSize: 12),
            ),
          ],
        ),
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
  final VoidCallback? onDetail;

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
    final isPending = status == 0;
    final isAccepted = status == 1;
    final isRejected = status == 2;

    final statusColor = isRejected ? AppColors.red : AppColors.primaryBlue;
    final statusBg = isRejected ? AppColors.lightRed : AppColors.veryLightBlue;

    return InkWell(
      onTap: onDetail,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.light1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
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
                  radius: 25,
                  backgroundColor: isRejected
                      ? AppColors.lightRed
                      : AppColors.lightBlue,
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: isRejected ? AppColors.red : AppColors.primaryBlue,
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
                          fontSize: 14,
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
                Text(time, style: TextStyle(color: statusColor, fontSize: 11)),
                if (!isRejected) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.dark3,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(
                    isAccepted
                        ? Icons.check_circle_outline
                        : isRejected
                        ? Icons.cancel_outlined
                        : Icons.calendar_today_outlined,
                    size: 13,
                    color: statusColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    diagnosis,
                    style: TextStyle(color: statusColor, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (isPending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Terima'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Tolak'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.red,
                          side: const BorderSide(color: AppColors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
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
  final int status;
  final String initial;
  final String name;
  final String info;
  final String diagnosis;
  final String time;

  const RequestDetailPage({
    super.key,
    required this.status,
    this.initial = 'WP',
    this.name = 'Wahyu Prasetyo',
    this.info = 'DM Tipe 2 • 47 tahun • Laki-laki',
    this.diagnosis = '2019',
    this.time = '08:15',
  });

  @override
  Widget build(BuildContext context) {
    final isPending = status == 0;
    final isRejected = status == 2;

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(context, isRejected),
            Expanded(
              child: Container(
                color: AppColors.background,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _dataPatientCard(),
                      if (isPending) ...[
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
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
                          height: 44,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.red,
                              side: const BorderSide(color: AppColors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text('Tolak permintaan'),
                          ),
                        ),
                      ] else if (isRejected) ...[
                        const SizedBox(height: 18),
                        _infoBox(
                          icon: Icons.cancel_outlined,
                          text:
                              'Permintaan koneksi ini telah ditolak. Pasien tidak memiliki akses pemantauan dengan dokter.',
                          color: AppColors.red,
                          bg: AppColors.lightRed,
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

  Widget _buildHeader(BuildContext context, bool isRejected) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
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
              Expanded(
                child: Text(
                  isRejected ? 'Koneksi Ditolak' : 'Permintaan Koneksi',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: isRejected
                      ? AppColors.lightRed
                      : AppColors.lightBlue,
                  child: Icon(
                    isRejected ? Icons.cancel_outlined : Icons.person_add_alt_1,
                    color: isRejected ? AppColors.red : AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isRejected
                        ? 'Permintaan koneksi ditolak\n7 Jun 2025\n08:15'
                        : 'Permintaan koneksi baru\n7 Jun 2025\n08:15',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dataPatientCard() {
    return Container(
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
            'Data Pasien',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          _DetailRow(label: 'Nama', value: name),
          _DetailRow(label: 'Informasi', value: info),
          _DetailRow(label: 'Tahun diagnosis', value: diagnosis),
        ],
      ),
    );
  }

  Widget _infoBox({
    required IconData icon,
    required String text,
    required Color color,
    required Color bg,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontSize: 12, height: 1.35),
            ),
          ),
        ],
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
