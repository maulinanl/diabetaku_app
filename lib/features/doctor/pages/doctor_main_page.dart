import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'doctor_connection_page.dart';
import 'doctor_history_page.dart';
import 'doctor_profile_page.dart';
import 'doctor_notification_page.dart';
import 'patient_detail_page.dart';

import '../widgets/doctor_bottom_nav.dart';

class DoctorMainPage extends StatefulWidget {
  const DoctorMainPage({super.key});

  @override
  State<DoctorMainPage> createState() => _DoctorMainPageState();
}

class _DoctorMainPageState extends State<DoctorMainPage> {
  int currentIndex = 0;

  final pages = const [
    DoctorHomeContent(),
    DoctorConnectionPage(),
    DoctorHistoryPage(),
    DoctorProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: false,
      body: pages[currentIndex],
      bottomNavigationBar: DoctorBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}

class DoctorHomeContent extends StatefulWidget {
  const DoctorHomeContent({super.key});

  @override
  State<DoctorHomeContent> createState() => _DoctorHomeContentState();
}

class _DoctorHomeContentState extends State<DoctorHomeContent> {
  final TextEditingController _searchController = TextEditingController();

  String searchQuery = '';
  bool hasUnreadNotification = true;

  final patients = [
    {
      'initial': 'AS',
      'name': 'Angelica Sabi Gita',
      'info': '32 tahun • Perempuan',
      'type': 'DM Tipe 2',
      'glucose': '187',
      'status': 'Abnormal',
      'isNormal': false,
      'lastUpdate': 'Update terakhir: 7 Jun 2025 • 13:04',
    },
    {
      'initial': 'RY',
      'name': 'Restu Yuda Eka',
      'info': '55 tahun • Laki-laki',
      'type': 'DM Tipe 1',
      'glucose': '185',
      'status': 'Abnormal',
      'isNormal': false,
      'lastUpdate': 'Update terakhir: 7 Jun 2025 • 12:30',
    },
    {
      'initial': 'DH',
      'name': 'Dayat Heru S.',
      'info': '45 tahun • Laki-laki',
      'type': 'DM Tipe 1',
      'glucose': '112',
      'status': 'Normal',
      'isNormal': true,
      'lastUpdate': 'Update terakhir: 7 Jun 2025 • 08:10',
    },
    {
      'initial': 'SP',
      'name': 'Suryo Prasta',
      'info': '40 tahun • Laki-laki',
      'type': 'DM Tipe 2',
      'glucose': '118',
      'status': 'Normal',
      'isNormal': true,
      'lastUpdate': 'Update terakhir: 6 Jun 2025 • 19:45',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredPatients = patients.where((patient) {
      final name = patient['name']!.toString().toLowerCase();
      final type = patient['type']!.toString().toLowerCase();

      return name.contains(searchQuery.toLowerCase()) ||
          type.contains(searchQuery.toLowerCase());
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
                child: filteredPatients.isEmpty
                    ? _emptySearch()
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
                        children: [
                          Text(
                            'DAFTAR PASIEN - ${filteredPatients.length} AKTIF',
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...filteredPatients.map(
                            (patient) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _PatientCard(
                                initials: patient['initial'] as String,
                                name: patient['name'] as String,
                                info: patient['info'] as String,
                                type: patient['type'] as String,
                                glucose: patient['glucose'] as String,
                                status: patient['status'] as String,
                                isNormal: patient['isNormal'] as bool,
                                lastUpdate: patient['lastUpdate'] as String,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const PatientDetailPage(),
                                    ),
                                  );
                                },
                              ),
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

  Widget _header(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(24, topPad + 28, 24, 32),
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Pagi, semangat hari ini!',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'dr. Agus Setiawan, Sp.PD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() => hasUnreadNotification = false);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DoctorNotificationPage(),
                    ),
                  );
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    if (hasUnreadNotification)
                      Positioned(
                        top: 9,
                        right: 9,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: AppColors.red,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Cari nama pasien',
              hintStyle: const TextStyle(color: AppColors.dark3, fontSize: 12),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.primaryBlue,
                size: 18,
              ),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => searchQuery = '');
                      },
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.dark3,
                        size: 18,
                      ),
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptySearch() {
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
                Icons.search_off,
                size: 42,
                color: AppColors.primaryBlue,
              ),
            ),
            SizedBox(height: 18),
            Text(
              'Pasien tidak ditemukan',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.dark1,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Coba gunakan nama pasien atau tipe diabetes lain.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.primaryBlue, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final String initials;
  final String name;
  final String info;
  final String type;
  final String glucose;
  final String status;
  final bool isNormal;
  final String lastUpdate;
  final VoidCallback onTap;

  const _PatientCard({
    required this.initials,
    required this.name,
    required this.info,
    required this.type,
    required this.glucose,
    required this.status,
    required this.isNormal,
    required this.lastUpdate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isNormal ? const Color(0xFF10C878) : AppColors.red;
    final statusBg = isNormal ? const Color(0xFFEAFBF3) : AppColors.lightRed;

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
                initials,
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
                      _statusBadge(
                        text: type,
                        bg: AppColors.veryLightBlue,
                        textColor: AppColors.primaryBlue,
                        icon: Icons.opacity,
                      ),
                      _statusBadge(
                        text: status,
                        bg: statusBg,
                        textColor: statusColor,
                        icon: isNormal
                            ? Icons.check_circle
                            : Icons.warning_amber_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _glucoseBox(
                    glucose: glucose,
                    statusColor: statusColor,
                    lastUpdate: lastUpdate,
                  ),
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

  Widget _glucoseBox({
    required String glucose,
    required Color statusColor,
    required String lastUpdate,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.monitor_heart_outlined, size: 13, color: statusColor),
          const SizedBox(width: 6),
          RichText(
            text: TextSpan(
              text: glucose,
              style: TextStyle(
                color: statusColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              children: const [
                TextSpan(
                  text: ' mg/dL',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              lastUpdate,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
              ),
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