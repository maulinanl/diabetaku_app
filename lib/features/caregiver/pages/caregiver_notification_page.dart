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

    if (type.contains('prescription') || type.contains('resep')) {
      return 'Resep Obat';
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

    Map<String, dynamic> detail = item;

    if (notificationId != null) {
      try {
        detail = await ApiService.getNotificationDetail(notificationId);
      } catch (_) {}
    }

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CaregiverNotificationDetailPage(item: detail),
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
                child: Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: _loadNotifications,
                      child: _body(filteredNotifications),
                    ),
                    if (errorMessage != null && notifications.isEmpty)
                      Positioned.fill(child: _errorState()),
                    if (isLoading)
                      const Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: LinearProgressIndicator(minHeight: 2),
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

  Widget _body(List<Map<String, dynamic>> data) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        _tabs(),
        if (hasUnreadNotification) _markAllReadButton(),
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
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
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
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 48),
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

  Widget _markAllReadButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
      child: Align(
        alignment: Alignment.centerRight,
        child: OutlinedButton.icon(
          onPressed: isMarkingAll ? null : _markAllAsRead,
          icon: isMarkingAll
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.done_all, size: 15),
          label: Text(
            isMarkingAll ? 'Menandai...' : 'Tandai semua dibaca',
            style: const TextStyle(fontSize: 11),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryBlue,
            backgroundColor: AppColors.white,
            side: const BorderSide(color: AppColors.primaryBlue),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            minimumSize: const Size(0, 34),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
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
    if (_isValidation) return 'Validasi Data';
    if (_isPrescription) return 'Resep Obat';
    if (_isMedication) return 'Kepatuhan Obat';
    if (_isRecommendation) return 'Rekomendasi';
    if (_isDisconnected) return 'Relasi Terputus';
    if (_isConnection) return 'Koneksi';
    return 'Informasi';
  }

  IconData get icon {
    if (_isValidation) return Icons.assignment_outlined;
    if (_isPrescription || _isMedication) return Icons.medication_outlined;
    if (_isRecommendation) return Icons.medical_information_outlined;
    if (_isDisconnected) return Icons.link_off_rounded;
    if (_isConnection) return Icons.person_outline;
    return Icons.notifications_none_outlined;
  }

  Color get iconBg {
    if (_isValidation) return const Color(0xFFFFF4DA);
    if (_isDisconnected) return AppColors.lightRed;
    if (_isConnection) return const Color(0xFFEAFBF3);
    return AppColors.veryLightBlue;
  }

  Color get iconColor {
    if (_isValidation) return Colors.orange;
    if (_isDisconnected) return AppColors.red;
    if (_isConnection) return const Color(0xFF10C878);
    return AppColors.primaryBlue;
  }

  bool get _isValidation {
    return type.contains('validation') ||
        type.contains('validasi') ||
        type.contains('caregiver_data') ||
        item['record_type'] != null;
  }

  bool get _isPrescription {
    return type.contains('prescription') ||
        type.contains('resep') ||
        item['prescription_id'] != null ||
        item['schedules'] is List;
  }

  bool get _isMedication {
    return type.contains('medication') ||
        type.contains('obat') ||
        type.contains('pengingat') ||
        item['log_id'] != null;
  }

  bool get _isRecommendation {
    return type.contains('recommendation') ||
        type.contains('rekomendasi') ||
        item['recommendation_text'] != null ||
        item['recommendations'] is List;
  }

  bool get _isDisconnected {
    return type.contains('disconnect') ||
        type.contains('disconnected') ||
        type.contains('putus');
  }

  bool get _isConnection {
    return type.contains('connection') ||
        type.contains('koneksi') ||
        type.contains('relation') ||
        type.contains('relasi') ||
        item['relation_name'] != null ||
        item['relation'] != null;
  }

  bool get _isStoppedPrescription {
    final combined = '${title.toLowerCase()} ${type.toLowerCase()} ${_text(item['status']).toLowerCase()}';
    return combined.contains('dihentikan') ||
        combined.contains('stopped') ||
        combined.contains('selesai');
  }

  bool get _isUpdatedPrescription {
    final combined = '${title.toLowerCase()} ${type.toLowerCase()}';
    return combined.contains('diperbarui') || combined.contains('updated');
  }

  String get _pageTitle {
    if (_isPrescription) {
      if (_isStoppedPrescription) return 'Resep Obat Dihentikan';
      if (_isUpdatedPrescription) return 'Resep Obat Diperbarui';
      return 'Detail Resep Obat';
    }
    if (_isValidation) return 'Detail Validasi Data';
    if (_isRecommendation) return 'Detail Rekomendasi';
    if (_isDisconnected) return 'Detail Relasi Terputus';
    if (_isConnection) return 'Detail Koneksi';
    if (_isMedication) return 'Detail Kepatuhan Obat';
    return 'Detail Notifikasi';
  }

  String get _headerText {
    if (_isPrescription) {
      return '${_text(item['medication_name'], fallback: 'Resep Obat')}\n$time';
    }
    if (_isValidation) {
      return '${_text(item['title'], fallback: 'Data kesehatan')}\n$time';
    }
    if (_isRecommendation) {
      return '${_text(item['doctor_name'], fallback: 'Dokter')}\n$time';
    }
    if (_isConnection || _isDisconnected) {
      final name = _text(
        item['patient_name'] ?? item['caregiver_name'] ?? item['full_name'] ?? item['name'],
        fallback: categoryLabel,
      );
      return '$name\n$time';
    }
    return '$title\n$time';
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

  String _text(dynamic value, {String fallback = '-'}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    if (text.isEmpty || text == '-') return fallback;
    return text;
  }

  String _date(dynamic value) {
    if (value == null) return '-';
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return value.toString();
    return '${parsed.day.toString().padLeft(2, '0')}/'
        '${parsed.month.toString().padLeft(2, '0')}/'
        '${parsed.year}';
  }

  List<Map<String, dynamic>> _schedules() {
    final raw = item['schedules'];
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList();
  }

  List<Map<String, dynamic>> _recommendations() {
    final raw = item['recommendations'];
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final relatedCards = _relatedCards();

    return _NotificationDetailScaffold(
      title: _pageTitle,
      icon: icon,
      iconBg: iconBg,
      iconColor: iconColor,
      headerText: _headerText,
      children: [
        _whiteCard(
          title: 'Isi Notifikasi',
          children: [
            Text(
              message,
              style: const TextStyle(
                color: AppColors.dark1,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ],
        ),
        if (relatedCards.isNotEmpty) ...[
          const SizedBox(height: 14),
          ...relatedCards,
        ],
        const SizedBox(height: 14),
        _whiteCard(
          title: 'Informasi Notifikasi',
          children: [
            _InfoRow(label: 'Kategori', value: categoryLabel),
            _InfoRow(label: 'Waktu', value: time),
            if (_text(item['status']).isNotEmpty && _text(item['status']) != '-')
              _InfoRow(label: 'Status', value: _text(item['status'])),
          ],
        ),
      ],
    );
  }

  List<Widget> _relatedCards() {
    if (_isPrescription) return _prescriptionCards();
    if (_isRecommendation) return _recommendationCards();
    if (_isValidation) return [_validationCard()];
    if (_isMedication) return [_medicationCard()];
    if (_isConnection || _isDisconnected) return [_connectionCard()];
    return [];
  }

  List<Widget> _prescriptionCards() {
    final medicationName = _text(item['medication_name'], fallback: 'Resep Obat');
    final patientName = _text(item['patient_name'], fallback: 'Pasien');
    final doctorName = _text(item['doctor_name'], fallback: 'Dokter');
    final dosage = _text(item['dosage']);
    final form = _text(item['form']);
    final mealRule = _text(item['meal_rule']);
    final notes = _text(item['notes']);
    final status = _text(
      item['status'],
      fallback: _isStoppedPrescription ? 'Selesai' : 'Aktif',
    );
    final validFrom = _date(item['valid_from']);
    final validUntil = _date(item['valid_until']);
    final schedules = _schedules();

    return [
      _whiteCard(
        title: 'Informasi Resep',
        children: [
          _InfoRow(label: 'Obat', value: medicationName),
          _InfoRow(label: 'Pasien', value: patientName),
          _InfoRow(label: 'Dokter', value: doctorName),
          _InfoRow(label: 'Dosis', value: dosage),
          if (form != '-') _InfoRow(label: 'Bentuk', value: form),
          _InfoRow(label: 'Aturan minum', value: mealRule),
          _InfoRow(label: 'Status', value: status),
          _InfoRow(label: 'Berlaku', value: '$validFrom - $validUntil'),
          if (notes != '-') _InfoRow(label: 'Catatan', value: notes),
        ],
      ),
      if (schedules.isNotEmpty) ...[
        const SizedBox(height: 14),
        _whiteCard(
          title: 'Jadwal Minum',
          children: schedules.map((schedule) {
            final session = _text(schedule['session_name'], fallback: 'Jadwal');
            final reminder = _text(
              schedule['reminder_time'] ?? schedule['default_reminder_time'],
            );

            return _ScheduleRow(session: session, reminder: reminder);
          }).toList(),
        ),
      ],
    ];
  }

  List<Widget> _recommendationCards() {
    final patientName = _text(item['patient_name'], fallback: 'Pasien');
    final doctorName = _text(item['doctor_name'], fallback: 'Dokter');
    final category = _text(item['category'], fallback: 'Rekomendasi');
    final singleText = _text(item['recommendation_text']);
    final recommendations = _recommendations();

    final children = <Widget>[
      _InfoRow(label: 'Pasien', value: patientName),
      _InfoRow(label: 'Dokter', value: doctorName),
      _InfoRow(label: 'Kategori', value: category),
    ];

    if (recommendations.isNotEmpty) {
      for (var i = 0; i < recommendations.length; i++) {
        final recommendation = recommendations[i];
        final itemCategory = _text(recommendation['category'], fallback: 'Rekomendasi ${i + 1}');
        final itemText = _text(recommendation['recommendation_text']);

        children.add(
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 6 : 12),
            child: Text(
              '$itemCategory\n$itemText',
              style: const TextStyle(
                color: AppColors.dark1,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ),
        );
      }
    } else if (singleText != '-') {
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            singleText,
            style: const TextStyle(
              color: AppColors.dark1,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ),
      );
    }

    return [
      _whiteCard(
        title: 'Detail Rekomendasi',
        children: children,
      ),
    ];
  }

  Widget _validationCard() {
    final patientName = _text(item['patient_name'], fallback: 'Pasien');
    final recordTitle = _text(item['title'], fallback: 'Data kesehatan');
    final inputBy = _text(item['input_by_name'] ?? item['input_by']);
    final inputRole = _text(item['input_by_role'] ?? item['relation']);
    final date = _formatTime(item['date'] ?? item['measured_at'] ?? item['checked_at']);
    final value = _text(item['value']);
    final unit = _text(item['unit'], fallback: '');
    final status = _text(item['validation_status'] ?? item['status']);
    final valueText = unit.isEmpty ? value : '$value $unit';

    return _whiteCard(
      title: 'Detail Data Validasi',
      children: [
        _InfoRow(label: 'Pasien', value: patientName),
        _InfoRow(label: 'Jenis Data', value: recordTitle),
        if (inputBy != '-') _InfoRow(label: 'Diinput oleh', value: inputBy),
        if (inputRole != '-') _InfoRow(label: 'Peran', value: inputRole),
        if (date != '-') _InfoRow(label: 'Tanggal', value: date),
        if (value != '-') _InfoRow(label: 'Nilai', value: valueText),
        if (status != '-') _InfoRow(label: 'Status', value: status),
      ],
    );
  }

  Widget _medicationCard() {
    final patientName = _text(item['patient_name'], fallback: 'Pasien');
    final medicationName = _text(item['medication_name'], fallback: 'Obat');
    final sessionName = _text(item['session_name'] ?? item['session']);
    final status = _text(item['value'] ?? item['status']);
    final date = _date(item['date'] ?? item['log_date']);
    final inputBy = _text(item['input_by_name'] ?? item['input_by']);

    return _whiteCard(
      title: 'Detail Kepatuhan Obat',
      children: [
        _InfoRow(label: 'Pasien', value: patientName),
        _InfoRow(label: 'Obat', value: medicationName),
        if (sessionName != '-') _InfoRow(label: 'Sesi', value: sessionName),
        if (status != '-') _InfoRow(label: 'Status', value: status),
        if (date != '-') _InfoRow(label: 'Tanggal', value: date),
        if (inputBy != '-') _InfoRow(label: 'Diinput oleh', value: inputBy),
      ],
    );
  }

  Widget _connectionCard() {
    final patientName = _text(item['patient_name'], fallback: '-');
    final caregiverName = _text(item['caregiver_name'], fallback: '-');
    final relation = _text(item['relation_name'] ?? item['relation'], fallback: 'Pendamping');
    final status = _text(item['status']);
    final requestedAt = _formatTime(item['requested_at']);
    final respondedAt = _formatTime(item['responded_at']);
    final connectedAt = _formatTime(item['connected_at']);
    final disconnectedAt = _formatTime(item['disconnected_at']);
    final updatedAt = _formatTime(item['relation_updated_at']);

    return _whiteCard(
      title: _isDisconnected ? 'Detail Relasi' : 'Detail Koneksi',
      children: [
        if (patientName != '-') _InfoRow(label: 'Pasien', value: patientName),
        if (caregiverName != '-') _InfoRow(label: 'Pendamping', value: caregiverName),
        _InfoRow(label: 'Hubungan', value: relation),
        if (status != '-') _InfoRow(label: 'Status', value: status),
        if (requestedAt != '-') _InfoRow(label: 'Diajukan', value: requestedAt),
        if (respondedAt != '-') _InfoRow(label: 'Direspons', value: respondedAt),
        if (connectedAt != '-') _InfoRow(label: 'Terhubung sejak', value: connectedAt),
        if (disconnectedAt != '-') _InfoRow(label: 'Diputus pada', value: disconnectedAt),
        if (updatedAt != '-') _InfoRow(label: 'Diperbarui', value: updatedAt),
      ],
    );
  }
}

class _NotificationDetailScaffold extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String headerText;
  final List<Widget> children;

  const _NotificationDetailScaffold({
    required this.title,
    required this.icon,
    this.iconBg = AppColors.lightBlue,
    this.iconColor = AppColors.primaryBlue,
    required this.headerText,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(14, topPad + 12, 18, 24),
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
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
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
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
                          backgroundColor: iconBg,
                          child: Icon(icon, color: iconColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _HeaderInfoText(text: headerText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: AppColors.background,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Column(children: children),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _whiteCard({required String title, required List<Widget> children}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.light1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.dark1,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final String session;
  final String reminder;

  const _ScheduleRow({
    required this.session,
    required this.reminder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.schedule_rounded,
            color: AppColors.primaryBlue,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$session • Reminder $reminder',
              style: const TextStyle(
                color: AppColors.dark1,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderInfoText extends StatelessWidget {
  final String text;

  const _HeaderInfoText({required this.text});

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    final main = lines.isNotEmpty ? lines.first : text;
    final sub = lines.length > 1 ? lines.sublist(1).join('\n') : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          main,
          style: const TextStyle(
            color: AppColors.dark1,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (sub.trim().isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(
            sub,
            style: const TextStyle(
              color: AppColors.dark2,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
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
        padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (unread)
              Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.only(top: 5, right: 8),
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(width: 15),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(
                      color: AppColors.dark1,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: AppColors.primaryBlue,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 11,
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
