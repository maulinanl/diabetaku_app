import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FamilyNotificationPage extends StatefulWidget {
  const FamilyNotificationPage({super.key});

  @override
  State<FamilyNotificationPage> createState() => _FamilyNotificationPageState();
}

class _FamilyNotificationPageState extends State<FamilyNotificationPage> {
  int selectedTab = 0;

  final todayNotifications = const [
    _FamilyNotificationItem(
      icon: Icons.description_outlined,
      iconBg: AppColors.lightBlue,
      iconColor: AppColors.primaryBlue,
      title: 'Rekomendasi baru dari dokter',
      message: 'dr. Agus Setiawan, Sp.PD telah membuat rekomendasi untukmu.',
      time: '09:41 • Baru saja',
      unread: true,
    ),
    _FamilyNotificationItem(
      icon: Icons.assignment_outlined,
      iconBg: Color(0xFFFFF4DA),
      iconColor: Colors.orange,
      title: 'Data dari Anda dikonfirmasi pasien',
      message:
          'Angelica Sabi Gita mengonfirmasi data glukosa yang Anda input.',
      time: '08:30 • 1 jam lalu',
      unread: true,
    ),
    _FamilyNotificationItem(
      icon: Icons.person_outline,
      iconBg: Color(0xFFEAFBF3),
      iconColor: Color(0xFF10C878),
      title: 'Permintaan koneksi diterima',
      message:
          'Maya Putri Sari menyetujui permintaan koneksi Anda sebagai pendamping.',
      time: '07:15 • 2 jam lalu',
      unread: true,
    ),
  ];

  final yesterdayNotifications = const [
    _FamilyNotificationItem(
      icon: Icons.person_outline,
      iconBg: Color(0xFFEAFBF3),
      iconColor: Color(0xFF10C878),
      title: 'Permintaan koneksi dokter diterima',
      message: 'dr. Rina Wulandari menerima permintaan koneksimu.',
      time: '6 Jun • 09:41',
      unread: false,
    ),
    _FamilyNotificationItem(
      icon: Icons.assignment_outlined,
      iconBg: Color(0xFFFFF4DA),
      iconColor: Colors.orange,
      title: 'Data dari Anda ditolak pasien',
      message:
          'Angelica Sabi Gita menolak data tekanan darah yang kamu input kemarin.',
      time: '6 Jun • 09:30',
      unread: false,
    ),
    _FamilyNotificationItem(
      icon: Icons.link_off_rounded,
      iconBg: AppColors.lightRed,
      iconColor: AppColors.red,
      title: 'Pasien memutus relasi',
      message: 'Hendra Gunawan memutus relasi denganmu sebagai pendamping.',
      time: '6 Jun • 09:00',
      unread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final todayData = selectedTab == 0
        ? todayNotifications
        : todayNotifications.where((item) => item.unread).toList();

    final yesterdayData = selectedTab == 0
        ? yesterdayNotifications
        : yesterdayNotifications.where((item) => item.unread).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        color: AppColors.primaryBlue,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              _header(context),
              Expanded(
                child: Container(
                  color: AppColors.background,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _tabs(),
                      if (todayData.isEmpty && yesterdayData.isEmpty)
                        _emptyNotification()
                      else ...[
                        if (todayData.isNotEmpty) ...[
                          _sectionHeader('Hari Ini'),
                          ...todayData,
                        ],
                        if (yesterdayData.isNotEmpty) ...[
                          _sectionHeader('Kemarin'),
                          ...yesterdayData,
                        ],
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14, topPad + 12, 20, 18),
      color: AppColors.primaryBlue,
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

  Widget _tabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.light1),
        ),
        child: Row(
          children: [
            _tabItem('Semua', 0),
            _tabItem('Belum Dibaca', 1),
          ],
        ),
      ),
    );
  }

  Widget _tabItem(String title, int index) {
    final selected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => selectedTab = index);
        },
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

  Widget _sectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
      color: AppColors.lightBlue,
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _emptyNotification() {
    return Padding(
      padding: const EdgeInsets.only(top: 120),
      child: Column(
        children: const [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.lightBlue,
            child: Icon(
              Icons.notifications_none_rounded,
              color: AppColors.primaryBlue,
              size: 34,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Tidak ada notifikasi',
            style: TextStyle(
              color: AppColors.dark1,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Notifikasi terbaru akan muncul di sini.',
            style: TextStyle(
              color: AppColors.dark2,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _FamilyNotificationItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String message;
  final String time;
  final bool unread;

  const _FamilyNotificationItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.time,
    required this.unread,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: unread ? Colors.white.withValues(alpha: 0.55) : Colors.white,
      padding: const EdgeInsets.fromLTRB(22, 14, 18, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 42,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: iconBg,
                  child: Icon(icon, color: iconColor, size: 21),
                ),
                if (unread)
                  Positioned(
                    left: -2,
                    top: -3,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.dark1,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 12,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}