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
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User ID tidak ditemukan. Coba login ulang.');
      }

      final data = await ApiService.getNotifications(userId);

      data.sort((a, b) {
        final dateA =
            DateTime.tryParse(a['created_at']?.toString() ?? '') ??
                DateTime(2000);
        final dateB =
            DateTime.tryParse(b['created_at']?.toString() ?? '') ??
                DateTime(2000);
        return dateB.compareTo(dateA);
      });

      if (!mounted) return;

      setState(() {
        notifications = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  Future<void> _openNotification(Map<String, dynamic> item) async {
    final notificationId = int.tryParse(
      (item['notification_id'] ?? item['id'] ?? '').toString(),
    );

    if (_isUnread(item) && notificationId != null) {
      try {
        await ApiService.markNotificationAsRead(notificationId);

        if (!mounted) return;

        setState(() {
          item['is_read'] = true;
        });
      } catch (_) {}
    }

    if (!mounted) return;

    _showNotificationDetail(item);
  }

  bool _isUnread(Map<String, dynamic> item) {
    final value = item['is_read'] ?? item['read'];

    return value == false ||
        value == 0 ||
        value == '0' ||
        value?.toString().toLowerCase() == 'false';
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

  String _rawTime(Map<String, dynamic> item) {
    return item['created_at']?.toString() ??
        item['notification_date']?.toString() ??
        '';
  }

  String _formatTime(dynamic raw) {
    final value = raw?.toString() ?? '';
    if (value.isEmpty) return '-';

    final dt = DateTime.tryParse(value);
    if (dt == null) return value;

    final local = dt.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year} • '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  String _type(Map<String, dynamic> item) {
    final rawType = item['type_code'] ??
        item['reference_type'] ??
        item['type'] ??
        item['notification_type_name'] ??
        item['notification_type'] ??
        '';

    return rawType
        .toString()
        .toLowerCase()
        .trim()
        .replaceAll(' ', '_')
        .replaceAll('-', '_');
  }

  IconData _iconFromType(String type) {
    if (type.contains('recommendation') ||
        type.contains('rekomendasi') ||
        type.contains('doctor_recommendation')) {
      return Icons.medical_information_outlined;
    }

    if (type.contains('validation') ||
        type.contains('validasi') ||
        type.contains('family_data')) {
      return Icons.assignment_outlined;
    }

    if (type.contains('disconnect') ||
        type.contains('disconnected') ||
        type.contains('putus')) {
      return Icons.link_off_rounded;
    }

    if (type.contains('connection') ||
        type.contains('koneksi') ||
        type.contains('relation') ||
        type.contains('relasi')) {
      return Icons.person_outline;
    }

    return Icons.notifications_none_outlined;
  }

  Color _iconBgFromType(String type) {
    if (type.contains('validation') ||
        type.contains('validasi') ||
        type.contains('family_data')) {
      return const Color(0xFFFFF4DA);
    }

    if (type.contains('disconnect') ||
        type.contains('disconnected') ||
        type.contains('putus')) {
      return AppColors.lightRed;
    }

    if (type.contains('connection') ||
        type.contains('koneksi') ||
        type.contains('relation') ||
        type.contains('relasi')) {
      return const Color(0xFFEAFBF3);
    }

    return AppColors.veryLightBlue;
  }

  Color _iconColorFromType(String type) {
    if (type.contains('validation') ||
        type.contains('validasi') ||
        type.contains('family_data')) {
      return Colors.orange;
    }

    if (type.contains('disconnect') ||
        type.contains('disconnected') ||
        type.contains('putus')) {
      return AppColors.red;
    }

    if (type.contains('connection') ||
        type.contains('koneksi') ||
        type.contains('relation') ||
        type.contains('relasi')) {
      return const Color(0xFF10C878);
    }

    return AppColors.primaryBlue;
  }

  void _showNotificationDetail(Map<String, dynamic> item) {
    final type = _type(item);
    final icon = _iconFromType(type);
    final iconBg = _iconBgFromType(type);
    final iconColor = _iconColorFromType(type);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 26),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.light1,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 22),
                CircleAvatar(
                  radius: 42,
                  backgroundColor: iconBg,
                  child: Icon(icon, color: iconColor, size: 42),
                ),
                const SizedBox(height: 18),
                Text(
                  _title(item),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatTime(_rawTime(item)),
                  style: const TextStyle(
                    color: AppColors.dark2,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _message(item),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.dark1,
                    fontSize: 13,
                    height: 1.45,
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Mengerti'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
              time: _formatTime(_rawTime(item)),
              unread: _isUnread(item),
              onTap: () => _openNotification(item),
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
        onTap: () => setState(() => selectedTab = index),
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
  final VoidCallback onTap;

  const _FamilyNotificationItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.time,
    required this.unread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: AppColors.dark3),
          ],
        ),
      ),
    );
  }
}