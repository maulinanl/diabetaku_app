import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';
import 'package:diabetaku_app/core/theme/app_button_styles.dart';

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

    Map<String, dynamic> detail = Map<String, dynamic>.from(item);

    if (notificationId != null) {
      try {
        final fetchedDetail = await ApiService.getNotificationDetail(notificationId);
        detail = _mergeNotificationSummaryAndDetail(item, fetchedDetail);
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

  Map<String, dynamic> _mergeNotificationSummaryAndDetail(
    Map<String, dynamic> summary,
    Map<String, dynamic> detail,
  ) {
    bool isGenericPatientName(dynamic value) {
      final text = value?.toString().trim().toLowerCase() ?? '';
      return text.isEmpty ||
          text == '-' ||
          text == 'null' ||
          text == 'pasien' ||
          text == 'nama pasien tidak tersedia';
    }

    String nameFromSource(dynamic source) {
      if (source == null) return '';

      if (source is Map) {
        return nameFromSource(
          source['patient_name'] ??
              source['patient_full_name'] ??
              source['patientName'] ??
              source['patient_user_name'] ??
              source['full_name'] ??
              source['name'],
        );
      }

      final text = source.toString().trim();
      if (isGenericPatientName(text)) return '';
      return text;
    }

    String patientNameFromText(dynamic rawText) {
      final text = rawText?.toString().trim() ?? '';
      if (text.isEmpty) return '';

      final patterns = [
        RegExp(r'^(.+?)\s+(?:menerima|menolak)\s+data\b', caseSensitive: false),
        RegExp(r'^(.+?)\s+(?:menerima|menolak)\s+[^.,\n]+\s+yang\s+anda\s+tambahkan', caseSensitive: false),
        RegExp(r'untuk pasien\s+([^.,\n]+)', caseSensitive: false),
        RegExp(r'nama pasien\s*:?\s*([^.,\n]+)', caseSensitive: false),
        RegExp(r'pasien\s*:?\s*([^.,\n]+)', caseSensitive: false),
        RegExp(r'data\s+[^.,\n]*?\s+dari\s+([^.,\n]+)', caseSensitive: false),
        RegExp(r'milik\s+([^.,\n]+)', caseSensitive: false),
        RegExp(r'untuk\s+([^.,\n]+)', caseSensitive: false),
      ];

      for (final pattern in patterns) {
        final match = pattern.firstMatch(text);
        final name = match?.group(1)?.trim() ?? '';
        if (!isGenericPatientName(name)) return name;
      }

      return '';
    }

    String patientNameFromMap(Map<String, dynamic> source) {
      final directSources = [
        source['summary_patient_name'],
        source['patient_name'],
        source['patient_full_name'],
        source['patientName'],
        source['patient_user_name'],
        source['patient'],
        source['patient_data'],
        source['record_patient'],
        source['record'],
        source['data'],
        source['payload'],
        source['notification_data'],
        source['reference_data'],
        source['full_name'],
        source['name'],
      ];

      for (final sourceValue in directSources) {
        final name = nameFromSource(sourceValue);
        if (name.isNotEmpty) return name;
      }

      final textSources = [
        source['message'],
        source['notification_message'],
        source['description'],
        source['body'],
        source['title'],
        source['notification_title'],
      ];

      for (final sourceValue in textSources) {
        final name = patientNameFromText(sourceValue);
        if (name.isNotEmpty) return name;
      }

      return '';
    }

    final merged = Map<String, dynamic>.from(summary);
    final summaryPatientName = patientNameFromMap(summary);

    detail.forEach((key, value) {
      if (value == null) return;

      final textValue = value.toString().trim();
      if (textValue.isEmpty || textValue.toLowerCase() == 'null') return;

      final normalizedKey = key.toLowerCase();
      final isPatientNameKey = normalizedKey.contains('patient') ||
          normalizedKey == 'full_name' ||
          normalizedKey == 'name';

      if (isPatientNameKey &&
          summaryPatientName.isNotEmpty &&
          isGenericPatientName(value)) {
        return;
      }

      merged[key] = value;
    });

    final detailPatientName = patientNameFromMap(merged);
    final finalPatientName = detailPatientName.isNotEmpty
        ? detailPatientName
        : summaryPatientName;

    if (finalPatientName.isNotEmpty) {
      merged['summary_patient_name'] = finalPatientName;

      if (isGenericPatientName(merged['patient_name'])) {
        merged['patient_name'] = finalPatientName;
      }
    }

    return merged;
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
                    style: AppButtonStyles.primary,
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
          style: AppButtonStyles.outlined,
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
            style: AppButtonStyles.primary,
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
    if (_isDoctorPatientRelation) return 'Relasi Dokter';
    if (_isDisconnected) return 'Relasi Terputus';
    if (_isConnection) return 'Koneksi';
    return 'Informasi';
  }

  IconData get icon {
    if (_isValidationAccepted) return Icons.check_circle_outline;
    if (_isValidationRejected) return Icons.cancel_outlined;
    if (_isValidation) return Icons.assignment_outlined;
    if (_isPrescription || _isMedication) {
      return _isStoppedPrescription ? Icons.cancel_outlined : Icons.medication_outlined;
    }
    if (_isRecommendation) return Icons.send_outlined;
    if (_isDisconnected) return Icons.link_off_rounded;
    if (_isRejectedConnection) return Icons.cancel_outlined;
    if (_isAcceptedConnection) return Icons.check_circle_outline;
    if (_isConnection) return Icons.person_outline;
    return Icons.notifications_none_outlined;
  }

  Color get iconBg {
    if (_isValidationAccepted) return const Color(0xFFEAFBF3);
    if (_isValidationRejected) return AppColors.lightRed;
    if (_isValidation) return const Color(0xFFFFF4DA);
    if (_isStoppedPrescription || _isDisconnected || _isRejectedConnection) {
      return AppColors.lightRed;
    }
    if (_isAcceptedConnection || _isConnection) return const Color(0xFFEAFBF3);
    return AppColors.veryLightBlue;
  }

  Color get iconColor {
    if (_isValidationAccepted) return const Color(0xFF10C878);
    if (_isValidationRejected) return AppColors.red;
    if (_isValidation) return Colors.orange;
    if (_isStoppedPrescription || _isDisconnected || _isRejectedConnection) {
      return AppColors.red;
    }
    if (_isAcceptedConnection || _isConnection) return const Color(0xFF10C878);
    return AppColors.primaryBlue;
  }

  bool get _isValidation {
    return type.contains('validation') ||
        type.contains('validasi') ||
        type.contains('caregiver_data') ||
        item['record_type'] != null;
  }

  bool get _isValidationAccepted {
    final status = _text(
      item['validation_status'] ?? item['status'] ?? item['validation_result'],
    ).toLowerCase();

    return _isValidation &&
        (status.contains('diterima') ||
            status.contains('disetujui') ||
            status.contains('approved') ||
            status == 'valid');
  }

  bool get _isValidationRejected {
    final status = _text(
      item['validation_status'] ?? item['status'] ?? item['validation_result'],
    ).toLowerCase();

    return _isValidation &&
        (status.contains('ditolak') ||
            status.contains('rejected') ||
            status == 'tidak valid');
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
        item['recommendations'] is List ||
        item['items'] is List;
  }

  bool get _isDisconnected {
    return type.contains('disconnect') ||
        type.contains('disconnected') ||
        type.contains('putus') ||
        _combinedText.contains('terputus');
  }

  bool get _isConnection {
    return type.contains('connection') ||
        type.contains('koneksi') ||
        type.contains('relation') ||
        type.contains('relasi') ||
        item['relation_name'] != null ||
        item['relation'] != null;
  }

  bool get _isDoctorPatientRelation {
    return type.contains('doctor_patient') ||
        type.contains('doctor_connection') ||
        (_combinedText.contains('dokter') && (_isDisconnected || _isConnection));
  }

  String get _combinedText =>
      '${title.toLowerCase()} ${type.toLowerCase()} ${_text(item['status']).toLowerCase()} ${message.toLowerCase()}';

  bool get _isRejectedConnection {
    return _isConnection &&
        (_combinedText.contains('ditolak') ||
            _combinedText.contains('tolak') ||
            _combinedText.contains('rejected'));
  }

  bool get _isAcceptedConnection {
    return _isConnection &&
        (_combinedText.contains('diterima') ||
            _combinedText.contains('terhubung') ||
            _combinedText.contains('accepted') ||
            _combinedText.contains('disetujui'));
  }

  bool get _isStoppedPrescription {
    return _combinedText.contains('dihentikan') ||
        _combinedText.contains('stopped') ||
        _combinedText.contains('selesai');
  }

  bool get _isUpdatedPrescription {
    return _combinedText.contains('diperbarui') || _combinedText.contains('updated');
  }

  String get _pageTitle {
    if (_isPrescription) {
      if (_isStoppedPrescription) return 'Resep Obat Dihentikan';
      if (_isUpdatedPrescription) return 'Resep Obat Diperbarui';
      return 'Detail Resep Obat';
    }
    if (_isValidationAccepted) return 'Data Diterima';
    if (_isValidationRejected) return 'Data Ditolak';
    if (_isValidation) return 'Detail Validasi Data';
    if (_isRecommendation) return 'Detail Rekomendasi';
    if (_isDoctorPatientRelation && _isDisconnected) return 'Relasi Dokter Terputus';
    if (_isDisconnected) return 'Relasi Pendamping Terputus';
    if (_isRejectedConnection) return 'Koneksi Ditolak';
    if (_isAcceptedConnection) return 'Koneksi Diterima';
    if (_isConnection) return 'Detail Koneksi';
    if (_isMedication) return 'Detail Kepatuhan Obat';
    return 'Detail Notifikasi';
  }

  String get _headerText {
    if (_isPrescription) {
      return '${_text(item['medication_name'], fallback: 'Resep Obat')}\n${_dateTime(item['created_at'] ?? item['time'])}';
    }
    if (_isValidation) {
      return '${_text(item['title'], fallback: 'Data kesehatan')}\n${_dateTime(item['created_at'] ?? item['time'])}';
    }
    if (_isRecommendation) {
      return '${_text(item['doctor_name'] ?? item['doctor'] ?? item['sender_name'], fallback: 'Dokter')}\n${_dateTime(item['created_at'] ?? item['date'] ?? item['time'])}';
    }
    if (_isDoctorPatientRelation && _isDisconnected) {
      final patientName = _resolvedPatientName(fallback: 'Pasien');
      final doctorName = _text(item['doctor_name'] ?? item['doctor'], fallback: 'Dokter');
      return '$patientName\n$doctorName • ${_dateTime(item['disconnected_at'] ?? item['relation_updated_at'] ?? item['created_at'] ?? item['time'])}';
    }
    if (_isConnection || _isDisconnected) {
      final name = _text(
        item['patient_name'] ?? item['caregiver_name'] ?? item['full_name'] ?? item['name'],
        fallback: categoryLabel,
      );
      return '$name\n${_dateTime(item['created_at'] ?? item['time'])}';
    }
    return '$title\n${_dateTime(item['created_at'] ?? item['time'])}';
  }

  String _dateTime(dynamic raw) {
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

  String get time => _dateTime(
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
    final rawRecommendations = item['recommendations'];
    if (rawRecommendations is List && rawRecommendations.isNotEmpty) {
      return rawRecommendations
          .whereType<Map>()
          .map((entry) => Map<String, dynamic>.from(entry))
          .toList();
    }

    final rawItems = item['items'];
    if (rawItems is List && rawItems.isNotEmpty) {
      return rawItems
          .whereType<Map>()
          .map((entry) => Map<String, dynamic>.from(entry))
          .toList();
    }

    final singleText = _text(
      item['recommendation_text'] ?? item['description'] ?? item['content'] ?? item['message'],
    );

    if (singleText == '-') return [];

    return [
      {
        'category': item['category'] ?? item['status'] ?? 'Rekomendasi',
        'recommendation_text': singleText,
      }
    ];
  }

  String _categorySummary(List<Map<String, dynamic>> recommendations) {
    final values = recommendations
        .map((entry) => _text(entry['category'], fallback: 'Rekomendasi'))
        .where((value) => value != '-')
        .toSet()
        .toList();

    if (values.isEmpty) return _text(item['category'] ?? item['status'], fallback: 'Rekomendasi');
    return values.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final children = _detailChildren();

    return _NotificationDetailScaffold(
      title: _pageTitle,
      icon: icon,
      iconBg: iconBg,
      iconColor: iconColor,
      headerText: _headerText,
      children: children,
    );
  }

  List<Widget> _detailChildren() {
    if (_isPrescription) return _prescriptionCards();
    if (_isRecommendation) return _recommendationCards();
    if (_isDoctorPatientRelation && _isDisconnected) return [_doctorPatientRelationCard()];
    if (_isConnection || _isDisconnected) return [_connectionCard()];
    if (_isValidation) {
      return [
        _validationCard(),
        if (message.trim().isNotEmpty && message != '-') ...[
          const SizedBox(height: 14),
          _whiteCard(
            title: 'Keterangan',
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
        ],
        const SizedBox(height: 14),
        _notificationInfoCard(),
      ];
    }
    if (_isMedication) {
      return [
        _genericMessageCard(),
        const SizedBox(height: 14),
        _medicationCard(),
        const SizedBox(height: 14),
        _notificationInfoCard(),
      ];
    }

    return [
      _genericMessageCard(),
      const SizedBox(height: 14),
      _notificationInfoCard(),
    ];
  }

  Widget _genericMessageCard() {
    return _whiteCard(
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
    );
  }

  Widget _notificationInfoCard() {
    return _whiteCard(
      title: 'Informasi Notifikasi',
      children: [
        _InfoRow(label: 'Kategori', value: categoryLabel),
        _InfoRow(label: 'Waktu', value: time),
        if (_text(item['status']) != '-') _InfoRow(label: 'Status', value: _text(item['status'])),
      ],
    );
  }

  List<Widget> _prescriptionCards() {
    final medicationName = _text(item['medication_name'], fallback: 'Resep Obat');
    final patientName = _resolvedPatientName(fallback: 'Pasien');
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
          _InfoRow(label: 'Nama Pasien', value: patientName),
          _InfoRow(label: 'Nama Dokter', value: doctorName),
          _InfoRow(label: 'Dosis', value: dosage),
          if (form != '-') _InfoRow(label: 'Bentuk', value: form),
          _InfoRow(label: 'Aturan minum', value: mealRule),
          _InfoRow(label: 'Status', value: status),
          _InfoRow(label: 'Berlaku', value: '$validFrom - $validUntil'),
        ],
      ),
      if (schedules.isNotEmpty) ...[
        const SizedBox(height: 14),
        _whiteCard(
          title: 'Jadwal Minum',
          children: schedules.map((schedule) {
            final session = _text(schedule['session_name'], fallback: 'Jadwal');
            final dose = _text(schedule['dose_per_session']);
            final reminder = _text(
              schedule['reminder_time'] ?? schedule['default_reminder_time'],
            );

            return _ScheduleRow(
              session: session,
              dose: dose,
              reminder: reminder,
            );
          }).toList(),
        ),
      ],
      if (notes != '-' || (message.trim().isNotEmpty && message != '-')) ...[
        const SizedBox(height: 14),
        _whiteCard(
          title: 'Keterangan',
          children: [
            Text(
              notes != '-' ? notes : message,
              style: const TextStyle(
                color: AppColors.dark1,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ],
        ),
      ],
    ];
  }

  String _resolvedPatientName({String fallback = 'Nama pasien tidak tersedia'}) {
    final sources = [
      item['summary_patient_name'],
      item['patient_name'],
      item['patient_full_name'],
      item['patientName'],
      item['patient_user_name'],
      item['patient'],
      item['patient_data'],
      item['record_patient'],
      item['record'],
      item['data'],
      item['payload'],
      item['notification_data'],
      item['reference_data'],
      item['full_name'],
      item['name'],
      _patientNameFromMessage(item['message'] ?? item['notification_message']),
      _patientNameFromMessage(item['description'] ?? item['body']),
      _patientNameFromMessage(item['title'] ?? item['notification_title']),
    ];

    for (final source in sources) {
      final name = _nameFromSource(source);
      if (name.isNotEmpty && !_isGenericPatientName(name)) return name;
    }

    return fallback;
  }

  String _recommendationPatientName(List<Map<String, dynamic>> recommendations) {
    final directSources = [
      item['patient_name'],
      item['patient_full_name'],
      item['patientName'],
      item['patient_user_name'],
      item['patient'],
      item['full_name'],
      item['name'],
      _patientNameFromMessage(item['message'] ?? item['notification_message']),
    ];

    for (final source in directSources) {
      final name = _nameFromSource(source);
      if (name.isNotEmpty && name.toLowerCase() != 'pasien') return name;
    }

    for (final recommendation in recommendations) {
      final recommendationSources = [
        recommendation['patient_name'],
        recommendation['patient_full_name'],
        recommendation['patientName'],
        recommendation['patient_user_name'],
        recommendation['patient'],
        recommendation['full_name'],
        recommendation['name'],
        _patientNameFromMessage(
          recommendation['message'] ?? recommendation['notification_message'],
        ),
      ];

      for (final source in recommendationSources) {
        final name = _nameFromSource(source);
        if (name.isNotEmpty && name.toLowerCase() != 'pasien') return name;
      }
    }

    return 'Nama pasien tidak tersedia';
  }

  bool _isGenericPatientName(dynamic value) {
    final text = value?.toString().trim().toLowerCase() ?? '';
    return text.isEmpty ||
        text == '-' ||
        text == 'null' ||
        text == 'pasien' ||
        text == 'nama pasien tidak tersedia';
  }

  String _nameFromSource(dynamic source) {
    if (source == null) return '';

    if (source is Map) {
      return _nameFromSource(
        source['summary_patient_name'] ??
            source['patient_name'] ??
            source['patient_full_name'] ??
            source['patientName'] ??
            source['patient_user_name'] ??
            source['patient'] ??
            source['patient_data'] ??
            source['full_name'] ??
            source['name'],
      );
    }

    final text = source.toString().trim();
    if (_isGenericPatientName(text)) return '';

    return text;
  }

  String _patientNameFromMessage(dynamic rawMessage) {
    final text = rawMessage?.toString().trim() ?? '';
    if (text.isEmpty) return '';

    final patterns = [
      RegExp(r'^(.+?)\s+(?:menerima|menolak)\s+data\b', caseSensitive: false),
      RegExp(r'^(.+?)\s+(?:menerima|menolak)\s+[^.,\n]+\s+yang\s+anda\s+tambahkan', caseSensitive: false),
      RegExp(r'untuk pasien\s+([^.,\n]+)', caseSensitive: false),
      RegExp(r'nama pasien\s*:?\s*([^.,\n]+)', caseSensitive: false),
      RegExp(r'pasien\s*:?\s*([^.,\n]+)', caseSensitive: false),
      RegExp(r'data\s+[^.,\n]*?\s+dari\s+([^.,\n]+)', caseSensitive: false),
      RegExp(r'milik\s+([^.,\n]+)', caseSensitive: false),
      RegExp(r'atas nama\s+([^.,\n]+)', caseSensitive: false),
      RegExp(r'untuk\s+([^.,\n]+)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      final name = match?.group(1)?.trim() ?? '';
      if (!_isGenericPatientName(name)) return name;
    }

    return '';
  }

  String _validationTypeFromMessage(dynamic rawMessage) {
    final text = rawMessage?.toString().toLowerCase() ?? '';

    if (text.contains('glukosa')) return 'Glukosa';
    if (text.contains('fisiologis') || text.contains('tekanan darah')) {
      return 'Fisiologis';
    }
    if (text.contains('aktivitas') || text.contains('olahraga')) return 'Aktivitas';
    if (text.contains('makan') || text.contains('pola makan')) return 'Makan';
    if (text.contains('obat') || text.contains('kepatuhan')) return 'Obat';

    return '';
  }

  String _validationTypeLabel() {
    final recordType = _text(item['record_type']).toLowerCase();
    final title = _text(item['record_title'] ?? item['data_title'] ?? item['title']);

    if (recordType.contains('glucose')) return title != '-' ? title : 'Glukosa';
    if (recordType.contains('physiological')) return title != '-' ? title : 'Fisiologis';
    if (recordType.contains('activity')) return title != '-' ? title : 'Aktivitas';
    if (recordType.contains('meal')) return title != '-' ? title : 'Makan';
    if (recordType.contains('medication')) return title != '-' ? title : 'Obat';

    final fromMessage = _validationTypeFromMessage(item['message'] ?? item['notification_message']);
    if (fromMessage.isNotEmpty) return fromMessage;

    if (title != '-' &&
        !title.toLowerCase().contains('data diterima') &&
        !title.toLowerCase().contains('data ditolak')) {
      return title;
    }

    return 'Data kesehatan';
  }

  String _validationDataSummary() {
    final recordType = _text(item['record_type']).toLowerCase();
    final title = _validationTypeLabel();
    final parts = <String>[title];

    if (recordType.contains('meal')) {
      final carbohydrate = _text(item['carbohydrate_estimate']);
      final calories = _text(item['calories']);

      if (carbohydrate != '-') parts.add('Karbohidrat $carbohydrate gram');
      if (calories != '-') parts.add('Kalori $calories kkal');
    } else if (recordType.contains('medication')) {
      final medicationName = _text(item['medication_name']);
      final session = _text(item['session_name'] ?? item['session']);
      final dose = _text(item['dose_per_session']);
      final value = _text(item['value']);

      if (medicationName != '-') parts.add(medicationName);
      if (session != '-') parts.add(session);
      if (dose != '-') parts.add(dose);
      if (value != '-') parts.add(value);
    } else {
      final value = _text(item['value']);
      final unit = _text(item['unit'], fallback: '');

      if (value != '-') {
        parts.add(unit.isEmpty ? value : '$value $unit');
      }
    }

    return parts.where((part) => part.trim().isNotEmpty && part != '-').join(' • ');
  }

  String _validationDataOwner() {
    final inputBy = _text(item['input_by_name'] ?? item['input_by']);
    final inputRole = _text(item['input_by_role'] ?? item['relation']);

    if (inputBy != '-' && inputRole != '-') return '$inputBy • $inputRole';
    if (inputBy != '-') return inputBy;
    if (inputRole != '-') return inputRole;

    final msg = message.toLowerCase();
    if (msg.contains('anda tambahkan') || msg.contains('kamu tambahkan')) {
      return 'Data yang Anda tambahkan';
    }

    return 'Pendamping';
  }

  List<Widget> _recommendationCards() {
    final recommendations = _recommendations();
    final patientName = _recommendationPatientName(recommendations);
    final doctorName = _text(
      item['doctor_name'] ?? item['doctor'] ?? item['sender_name'],
      fallback: 'Dokter',
    );
    final category = recommendations.length == 1
        ? _text(recommendations.first['category'], fallback: 'Rekomendasi')
        : _categorySummary(recommendations);
    final date = _dateTime(item['created_at'] ?? item['date'] ?? item['time']);

    return [
      _whiteCard(
        title: 'Informasi Rekomendasi',
        children: [
          _InfoRow(label: 'Dokter', value: doctorName),
          _InfoRow(label: 'Tanggal', value: date),
          _InfoRow(label: 'Kategori', value: category),
          _InfoRow(label: 'Untuk Pasien', value: patientName),
        ],
      ),
      const SizedBox(height: 14),
      _whiteCard(
        title: 'Rekomendasi untuk Pasien',
        children: recommendations.isEmpty
            ? [
                const Text(
                  'Belum ada detail rekomendasi.',
                  style: TextStyle(
                    color: AppColors.dark2,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ]
            : recommendations.asMap().entries.map((entry) {
                final recommendation = entry.value;
                final itemCategory = _text(
                  recommendation['category'],
                  fallback: 'Rekomendasi',
                );
                final itemText = _text(
                  recommendation['recommendation_text'] ??
                      recommendation['description'] ??
                      recommendation['content'],
                );

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: entry.key == recommendations.length - 1 ? 0 : 10,
                  ),
                  child: _RecommendationItem(
                    category: itemCategory,
                    description: itemText,
                  ),
                );
              }).toList(),
      ),
    ];
  }

  Widget _validationCard() {
    final patientName = _resolvedPatientName();
    final dataDate = _dateTime(
      item['date'] ?? item['measured_at'] ?? item['checked_at'] ?? item['log_date'],
    );
    final validatedAt = _dateTime(
      item['validated_at'] ?? item['responded_at'] ?? item['updated_at'] ?? item['created_at'],
    );
    final rawStatus = _text(
      item['validation_status'] ?? item['status'] ?? item['validation_result'],
      fallback: _isValidationAccepted
          ? 'Diterima'
          : _isValidationRejected
              ? 'Ditolak'
              : 'Menunggu',
    );
    final normalizedStatus = rawStatus.toLowerCase();
    final status = normalizedStatus == 'valid'
        ? 'Diterima'
        : normalizedStatus == 'tidak valid'
            ? 'Ditolak'
            : rawStatus;
    final dataSummary = _validationDataSummary();
    final dataOwner = _validationDataOwner();

    return _whiteCard(
      title: 'Data Pendamping yang Divalidasi',
      children: [
        _InfoRow(label: 'Nama Pasien', value: patientName),
        _InfoRow(label: 'Data yang Divalidasi', value: dataSummary),
        if (dataDate != '-') _InfoRow(label: 'Waktu Data', value: dataDate),
        _InfoRow(label: 'Diinput oleh', value: dataOwner),
        _InfoRow(label: 'Hasil Validasi', value: status),
        if (validatedAt != '-') _InfoRow(label: 'Waktu Validasi', value: validatedAt),
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

  Widget _doctorPatientRelationCard() {
    final patientName = _resolvedPatientName(fallback: 'Pasien');
    final doctorName = _text(item['doctor_name'] ?? item['doctor'], fallback: 'Dokter');
    final specialization = _text(item['specialization_name']);
    final institution = _text(item['institution']);
    final doctorInfo = _text(item['doctor_info']);
    final connectedAt = _dateTime(item['connected_at'] ?? item['connected_since']);
    final disconnectedAt = _dateTime(
      item['disconnected_at'] ??
          item['relation_updated_at'] ??
          item['created_at'] ??
          item['time'],
    );

    final infoParts = <String>[];
    if (specialization != '-') infoParts.add(specialization);
    if (institution != '-') infoParts.add(institution);
    if (infoParts.isEmpty && doctorInfo != '-') infoParts.add(doctorInfo);

    return _whiteCard(
      title: 'Informasi Relasi Dokter',
      children: [
        _InfoRow(label: 'Nama Pasien', value: patientName),
        _InfoRow(label: 'Nama Dokter', value: doctorName),
        if (infoParts.isNotEmpty)
          _InfoRow(label: 'Informasi Dokter', value: infoParts.join(' • ')),
        const _InfoRow(label: 'Status Relasi', value: 'Tidak Terhubung'),
        if (connectedAt != '-') _InfoRow(label: 'Terhubung Sejak', value: connectedAt),
        if (disconnectedAt != '-') _InfoRow(label: 'Relasi Berakhir', value: disconnectedAt),
        if (message.trim().isNotEmpty && message != '-') ...[
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.dark1,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ],
    );
  }

  Widget _connectionCard() {
    final patientName = _resolvedPatientName();
    final relation = _text(
      item['relation_name'] ?? item['relation'],
      fallback: 'Pendamping',
    );
    final statusRaw = _text(item['status']);
    final status = _isDisconnected
        ? 'Tidak Terhubung'
        : _isRejectedConnection
            ? 'Ditolak'
            : _isAcceptedConnection
                ? 'Terhubung'
                : statusRaw;
    final requestedAt = _dateTime(item['requested_at'] ?? item['created_at'] ?? item['time']);
    final respondedAt = _dateTime(item['responded_at'] ?? item['relation_updated_at'] ?? item['created_at'] ?? item['time']);
    final connectedAt = _dateTime(item['connected_at'] ?? item['connected_since'] ?? item['responded_at'] ?? item['created_at'] ?? item['time']);
    final disconnectedAt = _dateTime(item['disconnected_at'] ?? item['relation_updated_at'] ?? item['created_at'] ?? item['time']);
    final updatedAt = _dateTime(item['relation_updated_at']);

    final title = _isDisconnected
        ? 'Informasi Relasi'
        : _isRejectedConnection
            ? 'Status Permintaan'
            : _isAcceptedConnection
                ? 'Informasi Koneksi'
                : 'Detail Permintaan Koneksi';

    return _whiteCard(
      title: title,
      children: [
        _InfoRow(label: 'Nama Pasien', value: patientName),
        _InfoRow(label: 'Hubungan', value: relation),
        if (status != '-')
          _InfoRow(
            label: _isDisconnected || _isAcceptedConnection
                ? 'Status Relasi'
                : 'Status Permintaan',
            value: status,
          ),
        if (_isAcceptedConnection && connectedAt != '-')
          _InfoRow(label: 'Terhubung Sejak', value: connectedAt),
        if (_isRejectedConnection && respondedAt != '-')
          _InfoRow(label: 'Tanggal Ditolak', value: respondedAt),
        if (_isDisconnected && disconnectedAt != '-')
          _InfoRow(label: 'Relasi Berakhir', value: disconnectedAt),
        if (!_isDisconnected && !_isAcceptedConnection && !_isRejectedConnection && requestedAt != '-')
          _InfoRow(label: 'Diajukan', value: requestedAt),
        if (!_isDisconnected && !_isAcceptedConnection && !_isRejectedConnection && respondedAt != '-')
          _InfoRow(label: 'Direspons', value: respondedAt),
        if (!_isDisconnected && !_isAcceptedConnection && updatedAt != '-')
          _InfoRow(label: 'Diperbarui', value: updatedAt),
        if (_isDisconnected && message.trim().isNotEmpty && message != '-') ...[
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.dark1,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
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
  final String dose;
  final String reminder;

  const _ScheduleRow({
    required this.session,
    this.dose = '-',
    required this.reminder,
  });

  @override
  Widget build(BuildContext context) {
    final parts = <String>[session];

    if (dose.trim().isNotEmpty && dose != '-') {
      parts.add(dose);
    }

    if (reminder.trim().isNotEmpty && reminder != '-') {
      parts.add(reminder);
    }

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
              parts.join(' • '),
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

class _RecommendationItem extends StatelessWidget {
  final String category;
  final String description;

  const _RecommendationItem({
    required this.category,
    required this.description,
  });

  IconData _categoryIcon(String category) {
    final normalized = category.toLowerCase().replaceAll('_', ' ').trim();

    if (normalized.contains('obat')) return Icons.medication_outlined;
    if (normalized.contains('makan')) return Icons.restaurant_outlined;
    if (normalized.contains('aktivitas') ||
        normalized.contains('gaya hidup') ||
        normalized.contains('olahraga')) {
      return Icons.directions_run;
    }

    return Icons.assignment_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.light1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InlineBadge(
            text: category,
            icon: _categoryIcon(category),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.dark1,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineBadge extends StatelessWidget {
  final String text;
  final IconData? icon;

  const _InlineBadge({
    required this.text,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.primaryBlue, size: 12),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 10,
                fontWeight: FontWeight.w600,
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
