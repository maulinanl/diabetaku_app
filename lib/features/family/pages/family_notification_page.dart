import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';

class FamilyNotificationPage extends StatefulWidget {
  const FamilyNotificationPage({super.key});

  @override
  State<FamilyNotificationPage> createState() => _FamilyNotificationPageState();
}

class _FamilyNotificationPageState extends State<FamilyNotificationPage> {
  int selectedTab = 0;

  bool isLoading = true;
  String? errorMessage;

  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User ID tidak ditemukan. Coba login ulang.');
      }

      final data = await ApiService.getNotifications(userId);

      if (!mounted) return;

      setState(() {
        notifications = data;
        isLoading = false;
      });

      await ApiService.markAllNotificationsAsRead(userId);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString().replaceAll('Exception: ', '');
        isLoading = false;
      });
    }
  }

  bool _isUnread(Map<String, dynamic> item) {
    final isRead = item['is_read'];

    return isRead == false || isRead == 0 || isRead?.toString() == '0';
  }

  String _title(Map<String, dynamic> item) {
    return item['title']?.toString() ??
        item['notification_title']?.toString() ??
        'Notifikasi';
  }

  String _message(Map<String, dynamic> item) {
    return item['message']?.toString() ??
        item['notification_message']?.toString() ??
        '-';
  }

  String _time(Map<String, dynamic> item) {
    return item['created_at']?.toString() ??
        item['notification_date']?.toString() ??
        '';
  }

  String _type(Map<String, dynamic> item) {
    return item['notification_type']?.toString() ??
        item['type']?.toString() ??
        '';
  }

  IconData _iconFromType(String type) {
    final lowerType = type.toLowerCase();

    if (lowerType.contains('recommendation') ||
        lowerType.contains('rekomendasi')) {
      return Icons.description_outlined;
    }

    if (lowerType.contains('validation') ||
        lowerType.contains('validasi') ||
        lowerType.contains('data')) {
      return Icons.assignment_outlined;
    }

    if (lowerType.contains('connection') ||
        lowerType.contains('koneksi') ||
        lowerType.contains('relation')) {
      return Icons.person_outline;
    }

    if (lowerType.contains('disconnect') ||
        lowerType.contains('putus')) {
      return Icons.link_off_rounded;
    }

    return Icons.notifications_none_outlined;
  }

  Color _iconBgFromType(String type) {
    final lowerType = type.toLowerCase();

    if (lowerType.contains('validation') ||
        lowerType.contains('validasi') ||
        lowerType.contains('data')) {
      return const Color(0xFFFFF4DA);
    }

    if (lowerType.contains('connection') ||
        lowerType.contains('koneksi') ||
        lowerType.contains('relation')) {
      return const Color(0xFFEAFBF3);
    }

    if (lowerType.contains('disconnect') ||
        lowerType.contains('putus')) {
      return AppColors.lightRed;
    }

    return AppColors.lightBlue;
  }

  Color _iconColorFromType(String type) {
    final lowerType = type.toLowerCase();

    if (lowerType.contains('validation') ||
        lowerType.contains('validasi') ||
        lowerType.contains('data')) {
      return Colors.orange;
    }

    if (lowerType.contains('connection') ||
        lowerType.contains('koneksi') ||
        lowerType.contains('relation')) {
      return const Color(0xFF10C878);
    }

    if (lowerType.contains('disconnect') ||
        lowerType.contains('putus')) {
      return AppColors.red;
    }

    return AppColors.primaryBlue;
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = selectedTab == 0
        ? notifications
        : notifications.where(_isUnread).toList();

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
                  child: RefreshIndicator(
                    onRefresh: _loadNotifications,
                    child: _body(filteredNotifications),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(List<Map<String, dynamic>> data) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return _errorState();
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        _tabs(),
        if (data.isEmpty)
          _emptyNotification()
        else ...[
          _sectionHeader(selectedTab == 0 ? 'Semua Notifikasi' : 'Belum Dibaca'),
          ...data.map((item) {
            final type = _type(item);

            return _FamilyNotificationItem(
              icon: _iconFromType(type),
              iconBg: _iconBgFromType(type),
              iconColor: _iconColorFromType(type),
              title: _title(item),
              message: _message(item),
              time: _time(item),
              unread: _isUnread(item),
            );
          }),
          const SizedBox(height: 24),
        ],
      ],
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
            onPressed: () => Navigator.pop(context, true),
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
    return const Padding(
      padding: EdgeInsets.only(top: 120),
      child: Column(
        children: [
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
            style: TextStyle(color: AppColors.dark2, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _errorState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
      children: [
        const Icon(Icons.error_outline, color: AppColors.red, size: 42),
        const SizedBox(height: 12),
        Text(
          errorMessage ?? 'Gagal memuat notifikasi',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.dark2, fontSize: 13),
        ),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton(
            onPressed: _loadNotifications,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Coba lagi'),
          ),
        ),
      ],
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

  String _formatTime(String raw) {
    if (raw.isEmpty) return '-';

    try {
      final dt = DateTime.parse(raw).toLocal();

      return '${dt.day}/${dt.month}/${dt.year} • '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        color: unread ? const Color(0xFFF3F8FF) : AppColors.white,
        padding: const EdgeInsets.fromLTRB(22, 14, 14, 14),
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
                        _formatTime(time),
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
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: AppColors.dark3),
          ],
        ),
      ),
    );
  }
}