import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'patient_detail_page.dart';

class DoctorNotificationPage extends StatefulWidget {
  const DoctorNotificationPage({super.key});

  @override
  State<DoctorNotificationPage> createState() => _DoctorNotificationPageState();
}

class _DoctorNotificationPageState extends State<DoctorNotificationPage> {
  int selectedTab = 0;

  final notifications = [
    {
      'title': 'Glukosa abnormal - Angelica Sabi Gita',
      'message': 'Glukosa postprandial 187 mg/dL melebihi batas normal.',
      'time': '09:41',
      'type': 'abnormal',
      'read': false,
    },
    {
      'title': 'Permintaan koneksi baru',
      'message':
          'Wahyu Prasetyo mengajukan permintaan untuk terhubung denganmu.',
      'time': '08:15',
      'type': 'connection',
      'read': false,
    },
    {
      'title': 'Catatan klinis tersimpan',
      'message': 'Catatan klinis Ahmad Barik berhasil disimpan.',
      'time': 'Kemarin',
      'type': 'note',
      'read': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = selectedTab == 0
        ? notifications
        : notifications.where((item) => item['read'] == false).toList();

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
                    Expanded(
                      child: filtered.isEmpty
                          ? _emptyState()
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                18,
                                14,
                                18,
                                24,
                              ),
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = filtered[index];

                                return _NotificationTile(
                                  title: item['title'] as String,
                                  message: item['message'] as String,
                                  time: item['time'] as String,
                                  type: item['type'] as String,
                                  read: item['read'] as bool,
                                  onTap: () {
                                    if (item['type'] == 'abnormal') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const AbnormalNotificationDetailPage(),
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
      padding: EdgeInsets.fromLTRB(12, topPad + 12, 20, 20),
      decoration: const BoxDecoration(color: AppColors.primaryBlue),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              'Notifikasi',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.light1),
        ),
        child: Row(
          children: [_tabButton('Semua', 0), _tabButton('Belum Dibaca', 1)],
        ),
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    final selected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppColors.lightBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? AppColors.primaryBlue : AppColors.dark2,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 46),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: AppColors.lightBlue,
              child: Icon(
                Icons.notifications_off_outlined,
                color: AppColors.primaryBlue,
                size: 42,
              ),
            ),
            SizedBox(height: 18),
            Text(
              'Belum ada notifikasi',
              style: TextStyle(
                color: AppColors.dark1,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Notifikasi glukosa abnormal, permintaan koneksi, dan aktivitas pasien akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.primaryBlue, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final String type;
  final bool read;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    required this.read,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAbnormal = type == 'abnormal';
    final isConnection = type == 'connection';

    final icon = isAbnormal
        ? Icons.warning_amber_rounded
        : isConnection
        ? Icons.person_add_alt_1_rounded
        : Icons.description_outlined;

    final color = isAbnormal
        ? AppColors.red
        : isConnection
        ? const Color(0xFF10C878)
        : AppColors.primaryBlue;

    final bg = isAbnormal
        ? AppColors.lightRed
        : isConnection
        ? const Color(0xFFEAFBF3)
        : AppColors.veryLightBlue;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: read ? AppColors.white : AppColors.veryLightBlue,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.light1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: bg,
              child: Icon(icon, color: color, size: 20),
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
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(
                      color: AppColors.dark2,
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    time,
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            if (!read)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AbnormalNotificationDetailPage extends StatelessWidget {
  const AbnormalNotificationDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _dataPatientCard(context),
                      const SizedBox(height: 14),
                      _detailCard(),
                      const SizedBox(height: 14),
                      _detectedCard(),
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

  Widget _buildHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(12, topPad + 12, 18, 24),
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
              const Expanded(
                child: Text(
                  'Notifikasi Abnormal',
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.lightBlue,
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.primaryBlue,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Glukosa abnormal terdeteksi\n7 Jun 2025\n09:41',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dataPatientCard(BuildContext context) {
    return _whiteCard(
      title: 'Data Pasien',
      children: [
        const _InfoRow(label: 'Nama', value: 'Wahyu Tri Utomo'),
        const _InfoRow(label: 'Tipe DM', value: 'DM Tipe 2'),
        const _InfoRow(label: 'Usia', value: '47 tahun'),
        const _InfoRow(label: 'Tahun diagnosis', value: '2019'),

        const SizedBox(height: 8),

        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PatientDetailPage()),
            );
          },
          child: const Row(
            children: [
              Expanded(
                child: Text(
                  'Lihat Detail Pasien',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.primaryBlue),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detailCard() {
    return _whiteCard(
      title: 'Detail Notifikasi',
      children: const [
        Text(
          'Nilai glukosa postprandial pasien terdeteksi di luar batas normal yang telah ditetapkan. Segera tinjau data klinis pasien untuk tindak lanjut.',
          style: TextStyle(color: AppColors.dark2, fontSize: 12, height: 1.45),
        ),
      ],
    );
  }

  Widget _detectedCard() {
    return _whiteCard(
      title: 'Data Terdeteksi',
      children: [
        Row(
          children: const [
            Expanded(
              child: _DetectedValue(
                label: 'Tipe pengukuran',
                value: 'Postprandial',
                color: AppColors.dark1,
              ),
            ),
            Expanded(
              child: _DetectedValue(
                label: 'Nilai',
                value: '187',
                color: AppColors.red,
              ),
            ),
            Expanded(
              child: _DetectedValue(
                label: 'Batas Normal',
                value: '80 - 160',
                color: AppColors.dark1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _whiteCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.light1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
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

class _DetectedValue extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DetectedValue({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.dark2, fontSize: 10),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
