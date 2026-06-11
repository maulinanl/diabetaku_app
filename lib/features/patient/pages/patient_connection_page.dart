import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'patient_doctor_detail_page.dart';

class PatientConnectionPage extends StatefulWidget {
  const PatientConnectionPage({super.key});

  @override
  State<PatientConnectionPage> createState() => _PatientConnectionPageState();
}

class _PatientConnectionPageState extends State<PatientConnectionPage> {
  int selectedTab = 0;

  final tabs = ['Dokter', 'Keluarga', 'Permintaan'];

  final doctors = [
    {
      'initial': 'AS',
      'name': 'dr. Agus Setiawan, Sp.PD',
      'info': 'Penyakit Dalam • RS Cipto Mangunkusumo',
      'status': 'Terhubung',
      'date': 'Sejak 1 Jan 2025',
    },
    {
      'initial': 'SK',
      'name': 'dr. Sarah Kumalasari, Sp.PD',
      'info': 'Endokrinologi • RS Fatmawati',
      'status': 'Terhubung',
      'date': 'Sejak 5 Mar 2025',
    },
  ];

  final families = [
    {
      'initial': 'KP',
      'name': 'Kartika Putri Citra',
      'info': 'Istri',
      'status': 'Terhubung',
      'date': 'Sejak 10 Jun 2025',
    },
    {
      'initial': 'AY',
      'name': 'Aditya Yoga Saputra',
      'info': 'Anak',
      'status': 'Terhubung',
      'date': 'Sejak 7 Jun 2025',
    },
  ];

  final requests = [
    {
      'initial': 'YT',
      'name': 'Yoanda Tri Setyani',
      'info': 'Ingin terhubung sebagai Kakak',
      'time': '30 menit lalu',
    },
    {
      'initial': 'MP',
      'name': 'Maya Putri Sari',
      'info': 'Ingin terhubung sebagai Adik',
      'time': '2 jam lalu',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                    _tabs(),
                    Expanded(child: _content()),
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
      padding: EdgeInsets.fromLTRB(20, topPad + 14, 20, 18),
      color: AppColors.primaryBlue,
      child: const Center(
        child: Text(
          'Koneksi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _tabs() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final selected = selectedTab == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedTab = index),
              child: Container(
                height: 34,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primaryBlue : AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected ? AppColors.primaryBlue : AppColors.light1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  tabs[index],
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
    );
  }

  Widget _content() {
    if (selectedTab == 0) {
      return doctors.isEmpty
          ? _emptyDoctor()
          : _connectionList(
              title: 'DOKTER SAYA - ${doctors.length} TERHUBUNG',
              data: doctors,
              isDoctor: true,
            );
    }

    if (selectedTab == 1) {
      return _connectionList(
        title: 'KELUARGA SAYA - ${families.length} TERHUBUNG',
        data: families,
        isDoctor: false,
      );
    }

    return _requestList();
  }

  Widget _connectionList({
    required String title,
    required List<Map<String, String>> data,
    required bool isDoctor,
  }) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 120),
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 12),
        ...data.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _ConnectionCard(
              initial: item['initial']!,
              name: item['name']!,
              info: item['info']!,
              status: item['status']!,
              date: item['date']!,
              showVerified: isDoctor,
              onTap: isDoctor
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PatientDoctorDetailPage(),
                        ),
                      );
                    }
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _requestList() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 120),
      children: [
        const Text(
          'PERMINTAAN MASUK - 2',
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 12),
        ...requests.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _RequestCard(
              initial: item['initial']!,
              name: item['name']!,
              info: item['info']!,
              time: item['time']!,
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyDoctor() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 38),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 38,
              backgroundColor: AppColors.veryLightBlue,
              child: Icon(
                Icons.person_search_outlined,
                color: AppColors.primaryBlue,
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Belum ada dokter terhubung',
              style: TextStyle(
                color: AppColors.dark1,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cari dokter dan ajukan permintaan koneksi agar dokter bisa memantau data kesehatanmu.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 38,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.search, size: 16),
                label: const Text('Cari Dokter'),
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
          ],
        ),
      ),
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  final String initial;
  final String name;
  final String info;
  final String status;
  final String date;
  final bool showVerified;
  final VoidCallback? onTap;

  const _ConnectionCard({
    required this.initial,
    required this.name,
    required this.info,
    required this.status,
    required this.date,
    required this.showVerified,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isConnected = status == 'Terhubung';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: _cardDecoration(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.lightBlue,
              child: Text(
                initial,
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: AppColors.dark1,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    info,
                    style: const TextStyle(
                      color: AppColors.dark2,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (showVerified)
                        _statusBadge(
                          text: 'Terverifikasi',
                          bg: AppColors.veryLightBlue,
                          textColor: AppColors.primaryBlue,
                          icon: Icons.verified,
                        ),
                      _statusBadge(
                        text: status,
                        bg: isConnected
                            ? const Color(0xFFEAFBF3)
                            : AppColors.veryLightBlue,
                        textColor: isConnected
                            ? const Color(0xFF10C878)
                            : AppColors.primaryBlue,
                        icon: isConnected
                            ? Icons.check_circle
                            : Icons.access_time,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _dateBox(date),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Padding(
              padding: EdgeInsets.only(top: 30),
              child: Icon(
                Icons.chevron_right,
                color: AppColors.dark3,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateBox(String date) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            size: 12,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(width: 5),
          Text(
            date,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge({
    required String text,
    required Color bg,
    required Color textColor,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: textColor),
            const SizedBox(width: 3),
          ],
          Text(
            text,
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.light1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

class _RequestCard extends StatelessWidget {
  final String initial;
  final String name;
  final String info;
  final String time;

  const _RequestCard({
    required this.initial,
    required this.name,
    required this.info,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.light1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.lightBlue,
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: AppColors.dark1,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      info,
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.check, size: 14),
                    label: const Text('Terima'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.close, size: 14),
                    label: const Text('Tolak'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.red,
                      side: const BorderSide(color: AppColors.red),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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
