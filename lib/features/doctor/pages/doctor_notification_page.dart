import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../widgets/diabetes_type_badge.dart';
import '../../../data/services/api_service.dart';
import 'doctor_connection_page.dart';
import 'patient_detail_page.dart';
import 'recommendation_detail_page.dart';

class DoctorNotificationPage extends StatefulWidget {
  final int? initialNotificationId;

  const DoctorNotificationPage({
    super.key,
    this.initialNotificationId,
  });

  @override
  State<DoctorNotificationPage> createState() => _DoctorNotificationPageState();
}

class _DoctorNotificationPageState extends State<DoctorNotificationPage> {
  int selectedTab = 0;
  final searchController = TextEditingController();

  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;
  bool isMarkingAll = false;
  bool hasOpenedInitialNotification = false;
  String? errorMessage;

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

      await _openNotificationDetail(item);
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
        throw Exception('User belum login');
      }

      final data = await ApiService.getNotifications(userId);

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

  String _type(Map<String, dynamic> item) {
    final raw =
        item['type_code'] ??
        item['type'] ??
        item['notification_type_name'] ??
        '';

    return raw
        .toString()
        .toLowerCase()
        .trim()
        .replaceAll(' ', '_')
        .replaceAll('-', '_');
  }

  String _referenceType(Map<String, dynamic> item) {
    return (item['reference_type'] ?? '')
        .toString()
        .toLowerCase()
        .trim()
        .replaceAll(' ', '_')
        .replaceAll('-', '_');
  }

  bool _isRead(Map<String, dynamic> item) {
    final value = item['is_read'];
    return value == true || value == 1 || value.toString() == '1';
  }

  bool get hasUnreadNotification {
    return notifications.any((item) => !_isRead(item));
  }

  Future<void> _markAllAsRead() async {
    if (isMarkingAll || !hasUnreadNotification) return;

    setState(() => isMarkingAll = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User belum login');
      }

      await ApiService.markAllNotificationsAsRead(userId);

      if (!mounted) return;

      setState(() {
        for (final item in notifications) {
          item['is_read'] = true;
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

  Future<void> _openNotificationDetail(Map<String, dynamic> item) async {
    final notificationId = int.tryParse(
      (item['notification_id'] ?? '').toString(),
    );

    final referenceId = int.tryParse((item['reference_id'] ?? '').toString());

    final type = _type(item);
    final refType = _referenceType(item);

    if (notificationId != null && !_isRead(item)) {
      try {
        await ApiService.markNotificationAsRead(notificationId);

        if (!mounted) return;

        setState(() {
          item['is_read'] = true;
        });
      } catch (_) {}
    }

    if (!mounted) return;

    if (type == 'data_abnormal' || refType == 'abnormal') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AbnormalNotificationDetailPage(
            item: item,
            patientId: referenceId ?? 0,
          ),
        ),
      );
    } else if (type == 'permintaan_koneksi' ||
        refType == 'connection' ||
        refType == 'connection_request' ||
        refType == 'doctor_connection_request') {
      if (referenceId == null) {
        _showSnackBar('Data pasien tidak ditemukan');
        return;
      }

      await _openConnectionRequest(item, referenceId);
    } else if (type == 'rekomendasi_dokter' ||
        refType == 'clinical_note' ||
        refType == 'recommendation') {
      if (referenceId == null) {
        _showSnackBar('Data rekomendasi tidak ditemukan');
        return;
      }

      await _openRecommendationDetail(item, referenceId);
    } else if (type == 'putus_relasi' ||
        refType == 'disconnected' ||
        refType == 'patient' ||
        refType == 'doctor_connection_disconnected') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DisconnectedNotificationDetailPage(
            item: item,
            patientId: referenceId ?? 0,
          ),
        ),
      );
    }

    if (mounted) {
      await _loadNotifications();
    }
  }

  int _calculateAge(String? birthDate) {
    if (birthDate == null) return 0;

    final date = DateTime.tryParse(birthDate);
    if (date == null) return 0;

    final now = DateTime.now();
    int age = now.year - date.year;

    if (now.month < date.month ||
        (now.month == date.month && now.day < date.day)) {
      age--;
    }

    return age;
  }

  String _formatDiabetesType(dynamic value) {
    return formatDiabetesType(value);
  }

  int _connectionStatusCode(String status) {
    final normalized = status.toLowerCase().trim();

    if (normalized == 'menunggu') return 0;
    if (normalized == 'diterima' || normalized == 'disetujui') return 1;
    if (normalized == 'ditolak') return 2;
    if (normalized == 'diputus') return 3;

    return 0;
  }

  String _connectionStatusLabel(String status) {
    final normalized = status.toLowerCase().trim();

    if (normalized == 'menunggu') {
      return 'Menunggu persetujuan dokter';
    }

    if (normalized == 'diterima' || normalized == 'disetujui') {
      return 'Permintaan koneksi disetujui';
    }

    if (normalized == 'ditolak') {
      return 'Permintaan koneksi ditolak';
    }

    if (normalized == 'diputus') {
      return 'Relasi sudah diputus';
    }

    return status.isEmpty ? 'Status tidak diketahui' : status;
  }

  Future<void> _openConnectionRequest(
    Map<String, dynamic> notification,
    int patientId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final doctorId = prefs.getInt('doctor_id');

      if (doctorId == null) {
        throw Exception('Doctor ID tidak ditemukan. Coba login ulang.');
      }

      final connection = await ApiService.getDoctorPatientConnectionStatus(
        patientId: patientId,
      );

      if (!mounted) return;

      final statusText = connection['status']?.toString() ?? 'Menunggu';
      final status = _connectionStatusCode(statusText);

      final name = connection['full_name']?.toString() ?? '-';
      final gender = connection['gender']?.toString() ?? '-';
      final age = _calculateAge(connection['date_of_birth']?.toString());
      final diabetesType = _formatDiabetesType(connection['diabetes_type']);
      final time = _formatNotificationTime(notification['created_at']);

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RequestDetailPage(
            patientId: patientId,
            status: status,
            name: name,
            age: age,
            gender: gender,
            diabetesType: diabetesType,
            connectionStatus: _connectionStatusLabel(statusText),
            time: time,
            onAccept: status == 0
                ? () async {
                    await ApiService.acceptConnectionRequest(
                      doctorId: doctorId,
                      patientId: patientId,
                    );
                  }
                : null,
            onReject: status == 0
                ? () async {
                    await ApiService.rejectConnectionRequest(
                      doctorId: doctorId,
                      patientId: patientId,
                    );
                  }
                : null,
          ),
        ),
      );

      if (result == true && mounted) {
        await _loadNotifications();
      }
    } catch (e) {
      if (!mounted) return;

      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _openRecommendationDetail(
    Map<String, dynamic> item,
    int clinicalNoteId,
  ) async {
    try {
      final detail = await ApiService.getRecommendationDetail(clinicalNoteId);

      final patient = Map<String, dynamic>.from(detail['patient']);
      final recommendations = List<Map<String, dynamic>>.from(
        detail['recommendations'],
      );
      final recipients = List<Map<String, dynamic>>.from(detail['recipients']);

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecommendationDetailPage.fromApi(
            patient: patient,
            recommendationsData: recommendations,
            recipientsData: recipients,
            time: _formatNotificationTime(item['created_at']),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: isError ? AppColors.red : AppColors.primaryBlue,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      );
  }

  List<Map<String, dynamic>> _filteredNotifications() {
    final keyword = searchController.text.trim().toLowerCase();

    final tabFiltered = selectedTab == 0
        ? [...notifications]
        : notifications.where((item) => !_isRead(item)).toList();

    final result = keyword.isEmpty
        ? tabFiltered
        : tabFiltered.where((item) {
            final title = item['title']?.toString().toLowerCase() ?? '';
            final message = item['message']?.toString().toLowerCase() ?? '';
            final type = _type(item);

            return title.contains(keyword) ||
                message.contains(keyword) ||
                type.contains(keyword);
          }).toList();

    result.sort((a, b) {
      final dateA =
          DateTime.tryParse(a['created_at']?.toString() ?? '') ??
          DateTime(2000);
      final dateB =
          DateTime.tryParse(b['created_at']?.toString() ?? '') ??
          DateTime(2000);

      return dateB.compareTo(dateA);
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredNotifications();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Container(
                color: AppColors.background,
                child: Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: _loadNotifications,
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          _buildTabs(),
                          if (hasUnreadNotification) _markAllReadButton(),
                          if (filtered.isEmpty)
                            _emptyState()
                          else ...[
                            ..._groupedNotifications(filtered),
                            const SizedBox(height: 24),
                          ],
                        ],
                      ),
                    ),
                    if (errorMessage != null && notifications.isEmpty)
                      Positioned.fill(
                        child: Center(child: Text(errorMessage!)),
                      ),
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

  Widget _buildHeader(BuildContext context) {
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
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildTabs() {
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
          children: [_tabButton('Semua', 0), _tabButton('Belum Dibaca', 1)],
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

  Widget _tabButton(String label, int index) {
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
            label,
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

  List<Widget> _groupedNotifications(List<Map<String, dynamic>> data) {
    final widgets = <Widget>[];
    String? lastSection;

    for (final item in data) {
      final section = _getSection(item['created_at']);

      if (section != lastSection) {
        widgets.add(_sectionHeader(section));
        lastSection = section;
      }

      widgets.add(
        _NotificationTile(
          title: item['title']?.toString() ?? '-',
          message: item['message']?.toString() ?? '-',
          time: _formatNotificationTime(item['created_at']),
          type: _type(item),
          referenceType: _referenceType(item),
          read: _isRead(item),
          onTap: () => _openNotificationDetail(item),
        ),
      );
    }

    return widgets;
  }

  String _getSection(dynamic value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');

    if (parsed == null) return 'Sebelumnya';

    final date = parsed.toLocal();
    final now = DateTime.now();

    final difference = DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(date.year, date.month, date.day)).inDays;

    if (difference == 0) return 'Hari Ini';
    if (difference == 1) return 'Kemarin';

    return 'Sebelumnya';
  }

  String _formatNotificationTime(dynamic value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');

    if (parsed == null) return '-';

    final date = parsed.toLocal();

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} • '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
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

  Widget _emptyState() {
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
}

class _NotificationTile extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final String type;
  final String referenceType;
  final bool read;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    required this.referenceType,
    required this.read,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAbnormal =
        type == 'data_abnormal' ||
        type == 'abnormal' ||
        referenceType == 'abnormal';

    final isConnection =
        type == 'permintaan_koneksi' ||
        referenceType == 'connection' ||
        referenceType == 'connection_request' ||
        referenceType == 'doctor_connection_request';

    final isRecommendation =
        type == 'rekomendasi_dokter' ||
        referenceType == 'clinical_note' ||
        referenceType == 'recommendation';

    final isMedicineReminder = type == 'pengingat_obat';
    final isVerification = type == 'status_verifikasi';

    final isDisconnected =
        type == 'putus_relasi' ||
        referenceType == 'disconnected' ||
        referenceType == 'doctor_connection_disconnected';

    final icon = isAbnormal
        ? Icons.warning_amber_rounded
        : isConnection
        ? Icons.person_add_alt_1_rounded
        : isRecommendation
        ? Icons.medical_information_outlined
        : isMedicineReminder
        ? Icons.medication_outlined
        : isVerification
        ? Icons.verified_user_outlined
        : isDisconnected
        ? Icons.link_off_rounded
        : Icons.notifications_outlined;

    final color = isAbnormal || isDisconnected
        ? AppColors.red
        : isConnection
        ? const Color(0xFF10C878)
        : AppColors.primaryBlue;

    final bg = isAbnormal || isDisconnected
        ? AppColors.lightRed
        : isConnection
        ? const Color(0xFFEAFBF3)
        : AppColors.veryLightBlue;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: read ? AppColors.white : const Color(0xFFF3F8FF),
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
                    backgroundColor: bg,
                    child: Icon(icon, color: color, size: 21),
                  ),
                  if (!read)
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

class AbnormalNotificationDetailPage extends StatelessWidget {
  final Map<String, dynamic> item;
  final int patientId;

  const AbnormalNotificationDetailPage({
    super.key,
    required this.item,
    required this.patientId,
  });

  @override
  Widget build(BuildContext context) {
    final title = item['title']?.toString() ?? 'Data Abnormal';
    final message = item['message']?.toString() ?? '-';
    final date = _formatTime(item['created_at']);

    return _NotificationDetailScaffold(
      title: 'Notifikasi Abnormal',
      icon: Icons.warning_amber_rounded,
      iconBg: AppColors.lightRed,
      iconColor: AppColors.red,
      headerText: '$title\n$date',
      children: [
        _whiteCard(
          title: 'Data Notifikasi',
          children: [
            _InfoRow(label: 'Judul', value: title),
            _InfoRow(label: 'Waktu', value: date),
            const _InfoRow(label: 'Status', value: 'Abnormal'),
            const SizedBox(height: 8),
            _detailPatientLink(context, 'Lihat Detail Pasien', patientId, true),
          ],
        ),
        const SizedBox(height: 14),
        _whiteCard(
          title: 'Detail Notifikasi',
          children: [
            Text(
              message,
              style: const TextStyle(
                color: AppColors.dark2,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DisconnectedNotificationDetailPage extends StatelessWidget {
  final Map<String, dynamic> item;
  final int patientId;

  const DisconnectedNotificationDetailPage({
    super.key,
    required this.item,
    required this.patientId,
  });

  @override
  Widget build(BuildContext context) {
    final title = item['title']?.toString() ?? 'Relasi Terputus';
    final message = item['message']?.toString() ?? '-';
    final date = _formatTime(item['created_at']);

    return _NotificationDetailScaffold(
      title: 'Relasi Terputus',
      icon: Icons.link_off_rounded,
      iconBg: AppColors.lightRed,
      iconColor: AppColors.red,
      headerText: '$title\n$date',
      children: [
        _whiteCard(
          title: 'Data Relasi',
          children: [
            _InfoRow(label: 'Judul', value: title),
            const _InfoRow(label: 'Status relasi', value: 'Tidak Terhubung'),
            _InfoRow(label: 'Waktu', value: date),
            const SizedBox(height: 8),
            _detailPatientLink(
              context,
              'Lihat Data Lama Pasien',
              patientId,
              false,
            ),
          ],
        ),
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
    );
  }
}

String _formatTime(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '');

  if (date == null) return '-';

  final local = date.toLocal();

  return '${local.day.toString().padLeft(2, '0')}/'
      '${local.month.toString().padLeft(2, '0')}/'
      '${local.year} • '
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}


class _HeaderInfoText extends StatelessWidget {
  final String text;

  const _HeaderInfoText({required this.text});

  @override
  Widget build(BuildContext context) {
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return const Text(
        '-',
        style: TextStyle(
          color: AppColors.dark2,
          fontSize: 12,
          height: 1.35,
        ),
      );
    }

    final title = lines.first;
    final subtitles = lines.skip(1).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.dark1,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),
        if (subtitles.isNotEmpty) ...[
          const SizedBox(height: 4),
          ...subtitles.map(
            (subtitle) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.dark2,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                ),
              ),
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
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );
}

Widget _detailPatientLink(
  BuildContext context,
  String text,
  int patientId,
  bool isConnected,
) {
  final disabled = patientId == 0;

  return InkWell(
    onTap: disabled
        ? null
        : () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PatientDetailPage(
                  patientId: patientId,
                  isConnected: isConnected,
                ),
              ),
            );
          },
    child: Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: disabled ? AppColors.dark3 : AppColors.primaryBlue,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Icon(
          Icons.chevron_right,
          color: disabled ? AppColors.dark3 : AppColors.primaryBlue,
        ),
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
