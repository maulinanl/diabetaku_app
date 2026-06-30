import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';

class CaregiverNotificationPage extends StatefulWidget {
  final int? initialNotificationId;

  const CaregiverNotificationPage({
    super.key,
    this.initialNotificationId,
  });

  @override
  State<CaregiverNotificationPage> createState() => _CaregiverNotificationPageState();
}

class _CaregiverNotificationPageState extends State<CaregiverNotificationPage> {
  final searchController = TextEditingController();

  int selectedTab = 0;
  bool isLoading = true;
  bool isMarkingAll = false;
  bool hasOpenedInitialNotification = false;
  String? errorMessage;

  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    searchController.addListener(() => setState(() {}));
    _loadNotifications();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _openInitialNotificationIfNeeded() {
    final initialId = widget.initialNotificationId;

    if (initialId == null || hasOpenedInitialNotification) return;

    hasOpenedInitialNotification = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      Map<String, dynamic>? item;

      for (final notification in notifications) {
        final id = int.tryParse(
          (notification['notification_id'] ?? notification['id'] ?? '')
              .toString(),
        );

        if (id == initialId) {
          item = notification;
          break;
        }
      }

      item ??= await ApiService.getNotificationDetail(initialId);

      if (!mounted) return;

      await _openNotification(item);
    });
  }

  Future<void> _loadNotifications() async {
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

      _openInitialNotificationIfNeeded();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  bool _isUnread(Map<String, dynamic> item) {
    final value = item['is_read'] ?? item['read'];

    return value == false ||
        value == 0 ||
        value == '0' ||
        value?.toString().toLowerCase() == 'false';
  }


  bool get hasUnreadNotification {
    return notifications.any(_isUnread);
  }

  Future<void> _markAllAsRead() async {
    if (isMarkingAll || !hasUnreadNotification) return;

    setState(() => isMarkingAll = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User ID tidak ditemukan. Coba login ulang.');
      }

      await ApiService.markAllNotificationsAsRead(userId);

      if (!mounted) return;

      setState(() {
        for (final item in notifications) {
          item['is_read'] = true;
          item['read'] = true;
        }
        isMarkingAll = false;
      });

      _showSnackBar('Semua notifikasi sudah ditandai dibaca', isError: false);
    } catch (e) {
      if (!mounted) return;
      setState(() => isMarkingAll = false);
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    }
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

  String _section(Map<String, dynamic> item) {
    final raw = _rawTime(item);
    final date = DateTime.tryParse(raw);

    if (date == null) return 'Notifikasi';

    final local = date.toLocal();
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(local.year, local.month, local.day);

    if (target == today) return 'Hari Ini';
    if (target == today.subtract(const Duration(days: 1))) return 'Kemarin';

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
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
        type.contains('caregiver_data')) {
      return Icons.assignment_outlined;
    }

    if (type.contains('medication') ||
        type.contains('obat') ||
        type.contains('pengingat')) {
      return Icons.medication_outlined;
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
        type.contains('caregiver_data')) {
      return const Color(0xFFFFF4DA);
    }

    if (type.contains('medication') ||
        type.contains('obat') ||
        type.contains('pengingat')) {
      return AppColors.veryLightBlue;
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
        type.contains('caregiver_data')) {
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

  String _categoryLabel(String type) {
    if (type.contains('validation') || type.contains('validasi')) {
      return 'Validasi Data';
    }

    if (type.contains('medication') ||
        type.contains('obat') ||
        type.contains('pengingat')) {
      return 'Kepatuhan Obat';
    }

    if (type.contains('recommendation') || type.contains('rekomendasi')) {
      return 'Rekomendasi';
    }

    if (type.contains('disconnect') || type.contains('putus')) {
      return 'Relasi Terputus';
    }

    if (type.contains('connection') ||
        type.contains('koneksi') ||
        type.contains('relasi')) {
      return 'Koneksi';
    }

    return 'Informasi';
  }

  List<Map<String, dynamic>> _filteredNotifications() {
    final keyword = searchController.text.trim().toLowerCase();

    final tabFiltered = selectedTab == 0
        ? notifications
        : notifications.where(_isUnread).toList();

    if (keyword.isEmpty) return tabFiltered;

    return tabFiltered.where((item) {
      return _title(item).toLowerCase().contains(keyword) ||
          _message(item).toLowerCase().contains(keyword) ||
          _formatTime(_rawTime(item)).toLowerCase().contains(keyword) ||
          _section(item).toLowerCase().contains(keyword);
    }).toList();
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
          item['read'] = true;
        });
      } catch (_) {}
    }

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CaregiverNotificationDetailPage(item: item),
      ),
    );
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
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.light1,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 24),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: iconBg,
                  child: Icon(icon, color: iconColor, size: 38),
                ),
                const SizedBox(height: 18),
                Text(
                  _title(item),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _smallBadge(_categoryLabel(type)),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.veryLightBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _message(item),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.dark1,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _detailRow(
                  icon: Icons.access_time,
                  label: 'Waktu',
                  value: _formatTime(_rawTime(item)),
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
                        borderRadius: BorderRadius.circular(6),
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

  Widget _smallBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.light1),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.dark2,
                fontSize: 12,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? AppColors.red : AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Row(
          children: [
            Icon(
              isError ? Icons.info_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = _filteredNotifications();

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: Container(
                color: AppColors.background,
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage != null
                        ? _errorState()
                        : RefreshIndicator(
                            onRefresh: _loadNotifications,
                            child: _body(filteredNotifications),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(List<Map<String, dynamic>> data) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        _tabs(),
        if (data.isEmpty)
          _emptyNotification()
        else ...[
          ..._groupedNotifications(data),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  List<Widget> _groupedNotifications(List<Map<String, dynamic>> data) {
    final widgets = <Widget>[];
    String? lastSection;

    for (final item in data) {
      final section = _section(item);

      if (section != lastSection) {
        widgets.add(_sectionHeader(section));
        lastSection = section;
      }

      final type = _type(item);

      widgets.add(
        _CaregiverNotificationItem(
          icon: _iconFromType(type),
          iconBg: _iconBgFromType(type),
          iconColor: _iconColorFromType(type),
          title: _title(item),
          message: _message(item),
          time: _formatTime(_rawTime(item)),
          unread: _isUnread(item),
          onTap: () => _openNotification(item),
        ),
      );
    }

    return widgets;
  }

  Widget _header(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14, topPad + 12, 20, 22),
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
              IconButton(
                onPressed: hasUnreadNotification && !isMarkingAll
                    ? _markAllAsRead
                    : null,
                tooltip: 'Tandai semua dibaca',
                icon: isMarkingAll
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        Icons.done_all_rounded,
                        color: hasUnreadNotification
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.45),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _searchBox(),
        ],
      ),
    );
  }

  Widget _searchBox() {
    final keyword = searchController.text.trim();

    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        hintText: 'Cari notifikasi',
        hintStyle: const TextStyle(color: AppColors.dark3, fontSize: 12),
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.primaryBlue,
          size: 18,
        ),
        suffixIcon: keyword.isNotEmpty
            ? IconButton(
                onPressed: () => searchController.clear(),
                icon: const Icon(Icons.close, color: AppColors.dark3, size: 18),
              )
            : null,
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
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
    final isSearching = searchController.text.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(top: 120),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.lightBlue,
            child: Icon(
              isSearching
                  ? Icons.search_off_rounded
                  : Icons.notifications_none_rounded,
              color: AppColors.primaryBlue,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'Notifikasi tidak ditemukan' : 'Tidak ada notifikasi',
            style: const TextStyle(
              color: AppColors.dark1,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isSearching
                ? 'Coba gunakan kata kunci lain.'
                : 'Notifikasi terbaru akan muncul di sini.',
            style: const TextStyle(color: AppColors.dark2, fontSize: 12),
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


class CaregiverNotificationDetailPage extends StatelessWidget {
  final Map<String, dynamic> item;

  const CaregiverNotificationDetailPage({
    super.key,
    required this.item,
  });

  String get title => item['title']?.toString() ??
      item['notification_title']?.toString() ??
      'Notifikasi';

  String get message => item['message']?.toString() ??
      item['notification_message']?.toString() ??
      '-';

  String get type {
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

  String get categoryLabel {
    if (type.contains('validation') || type.contains('validasi')) {
      return 'Validasi Data';
    }
    if (type.contains('medication') || type.contains('obat')) {
      return 'Kepatuhan Obat';
    }
    if (type.contains('recommendation') || type.contains('rekomendasi')) {
      return 'Rekomendasi';
    }
    if (type.contains('disconnect') || type.contains('putus')) {
      return 'Relasi Terputus';
    }
    if (type.contains('connection') || type.contains('koneksi')) {
      return 'Koneksi';
    }
    return 'Informasi';
  }

  IconData get icon {
    if (type.contains('validation') || type.contains('validasi')) {
      return Icons.assignment_outlined;
    }
    if (type.contains('medication') || type.contains('obat')) {
      return Icons.medication_outlined;
    }
    if (type.contains('recommendation') || type.contains('rekomendasi')) {
      return Icons.medical_information_outlined;
    }
    if (type.contains('disconnect') || type.contains('putus')) {
      return Icons.link_off_rounded;
    }
    if (type.contains('connection') || type.contains('koneksi')) {
      return Icons.person_outline;
    }
    return Icons.notifications_none_outlined;
  }

  Color get iconBg {
    if (type.contains('validation') || type.contains('validasi')) {
      return const Color(0xFFFFF4DA);
    }
    if (type.contains('disconnect') || type.contains('putus')) {
      return AppColors.lightRed;
    }
    if (type.contains('connection') || type.contains('koneksi')) {
      return const Color(0xFFEAFBF3);
    }
    return AppColors.veryLightBlue;
  }

  Color get iconColor {
    if (type.contains('validation') || type.contains('validasi')) {
      return Colors.orange;
    }
    if (type.contains('disconnect') || type.contains('putus')) {
      return AppColors.red;
    }
    if (type.contains('connection') || type.contains('koneksi')) {
      return const Color(0xFF10C878);
    }
    return AppColors.primaryBlue;
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

  String get time => _formatTime(
        item['created_at'] ?? item['notification_date'] ?? item['time'],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                child: Column(
                  children: [
                    _messageCard(),
                    const SizedBox(height: 14),
                    _infoCard(),
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
      padding: EdgeInsets.fromLTRB(14, topPad + 12, 20, 24),
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
                  'Detail Notifikasi',
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
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 29,
                  backgroundColor: iconBg,
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.dark1,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        time,
                        style: const TextStyle(
                          color: AppColors.dark2,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 7),
                      _badge(categoryLabel),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Isi Notifikasi',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.dark1,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _infoRow('Kategori', categoryLabel),
          _infoRow('Waktu', time),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.dark2, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
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

class _CaregiverNotificationItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String message;
  final String time;
  final bool unread;
  final VoidCallback onTap;

  const _CaregiverNotificationItem({
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