import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';
import 'patient_connection_page.dart';
import 'patient_doctor_detail_page.dart';
import 'patient_recommendation_detail_page.dart';
import 'patient_history_page.dart';
import 'patient_validation_detail_page.dart';
import 'patient_validation_page.dart';

class PatientNotificationPage extends StatefulWidget {
  final int? initialNotificationId;

  const PatientNotificationPage({
    super.key,
    this.initialNotificationId,
  });

  @override
  State<PatientNotificationPage> createState() =>
      _PatientNotificationPageState();
}

class _PatientNotificationPageState extends State<PatientNotificationPage> {
  int selectedTab = 0;
  bool isLoading = true;
  bool isMarkingAll = false;
  bool hasOpenedInitialNotification = false;
  String? errorMessage;

  final searchController = TextEditingController();
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

      if (!mounted) return;

      setState(() {
        notifications = data;
        isLoading = false;
      });

      _openInitialNotificationIfNeeded();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString().replaceAll('Exception: ', '');
        isLoading = false;
      });
    }
  }

  bool _isRead(Map<String, dynamic> item) {
    final value = item['is_read'] ?? item['read'];
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

  String _desc(Map<String, dynamic> item) {
    return item['message']?.toString() ??
        item['desc']?.toString() ??
        item['description']?.toString() ??
        '-';
  }

  String _type(Map<String, dynamic> item) {
    final rawType =
        item['type_code'] ??
        item['reference_type'] ??
        item['type'] ??
        item['notification_type'] ??
        '';

    return rawType
        .toString()
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('-', '_');
  }

  String _time(Map<String, dynamic> item) {
    final raw = item['created_at'] ?? item['time'];
    if (raw == null) return '-';

    final date = DateTime.tryParse(raw.toString());
    if (date == null) return raw.toString();

    return '${date.day}/${date.month}/${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _section(Map<String, dynamic> item) {
    final raw = item['created_at'];
    final date = raw == null ? null : DateTime.tryParse(raw.toString());

    if (date == null) return 'Notifikasi';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) return 'Hari Ini';
    if (target == today.subtract(const Duration(days: 1))) return 'Kemarin';

    return '${date.day}/${date.month}/${date.year}';
  }

  int? _asInt(dynamic value) {
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  String _formatDateTime(dynamic raw) {
    if (raw == null) return '-';

    final date = DateTime.tryParse(raw.toString());
    if (date == null) return raw.toString();

    return '${date.day}/${date.month}/${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _doctorFromMessage(String message) {
    final match = RegExp(
      r'Dr\.\s+(.+?)\s+(?:mengirim|menerima|menolak|memutus|mengakhiri|telah)',
      caseSensitive: false,
    ).firstMatch(message);

    if (match != null) {
      return 'Dr. ${match.group(1)?.trim() ?? 'Dokter'}';
    }

    return 'Dokter';
  }

  String _caregiverFromMessage(String message) {
    final cleaned = message.trim();

    if (cleaned.isEmpty || cleaned == '-') {
      return 'Keluarga';
    }

    final match = RegExp(
      r'^(.+?)\s+(?:mengajukan|meminta|ingin|telah|menerima|menolak|memutus|mengakhiri)',
      caseSensitive: false,
    ).firstMatch(cleaned);

    if (match != null) {
      final name = match.group(1)?.trim();
      if (name != null && name.isNotEmpty) return name;
    }

    return 'Keluarga';
  }

  String _safeText(dynamic value, {String fallback = '-'}) {
    if (value == null) return fallback;

    final text = value.toString().trim();
    if (text.isEmpty || text == '-') return fallback;

    return text;
  }

  String _caregiverRelation(Map<String, dynamic> item) {
    return _safeText(
      item['relation'] ?? item['relation_name'] ?? item['caregiver_relation'],
      fallback: 'Keluarga',
    );
  }

  String _initialFromName(String name) {
    final cleaned = name.replaceFirst(RegExp(r'^Dr\.\s*', caseSensitive: false), '').trim();
    final parts = cleaned.split(' ').where((part) => part.isNotEmpty).toList();

    if (parts.isEmpty) return 'D';
    if (parts.length == 1) return parts.first[0].toUpperCase();

    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String _doctorInfo(Map<String, dynamic> item) {
    final info = item['info']?.toString();

    if (info != null && info.isNotEmpty && info != '-') {
      return info;
    }

    final specialization = item['specialization_name']?.toString() ?? '-';
    final institution = item['institution']?.toString() ?? '-';

    if (specialization == '-' && institution == '-') return '-';

    return '$specialization • $institution';
  }

  String _doctorRelationStatus(Map<String, dynamic> item, {String fallback = 'Terhubung'}) {
    final raw = item['current_relation_status'] ??
        item['relation_status'] ??
        item['connection_status'] ??
        item['status'] ??
        fallback;

    final normalized = raw.toString().toLowerCase().trim();

    if (normalized == 'diterima' || normalized == 'disetujui' || normalized == 'terhubung') {
      return 'Terhubung';
    }

    if (normalized == 'menunggu' || normalized.contains('menunggu')) {
      return 'Menunggu';
    }

    if (normalized == 'ditolak') {
      return 'Ditolak';
    }

    if (normalized == 'diputus' ||
        normalized == 'tidak terhubung' ||
        normalized.contains('terputus')) {
      return 'Tidak Terhubung';
    }

    return raw.toString().isEmpty ? fallback : raw.toString();
  }

  Future<Map<String, dynamic>> _loadNotificationDetail(
    Map<String, dynamic> item,
  ) async {
    final notificationId = _asInt(item['notification_id'] ?? item['id']);

    if (notificationId == null) return Map<String, dynamic>.from(item);

    try {
      final detail = await ApiService.getNotificationDetail(notificationId);
      return {
        ...item,
        ...detail,
      };
    } catch (_) {
      return Map<String, dynamic>.from(item);
    }
  }

  Future<Map<String, dynamic>> _buildRecommendationPayload(
    Map<String, dynamic> item,
  ) async {
    final clinicalNoteId = _asInt(
      item['clinical_note_id'] ?? item['reference_id'],
    );

    final fallback = <String, dynamic>{
      ...item,
      'doctor': item['doctor_name']?.toString() ?? _doctorFromMessage(_desc(item)),
      'date': _formatDateTime(item['created_at'] ?? item['time']),
      'category': item['category']?.toString() ?? 'Rekomendasi',
      'description': item['recommendation_text']?.toString() ??
          item['content']?.toString() ??
          _desc(item),
    };

    if (clinicalNoteId == null || clinicalNoteId == 0) {
      return fallback;
    }

    try {
      final detail = await ApiService.getRecommendationDetail(clinicalNoteId);
      final recommendations = List<Map<String, dynamic>>.from(
        detail['recommendations'] ?? [],
      );

      if (recommendations.isEmpty) return fallback;

      final first = recommendations.first;
      final description = recommendations.length == 1
          ? first['recommendation_text']?.toString() ?? _desc(item)
          : recommendations.map((recommendation) {
              final category = recommendation['category']?.toString() ?? 'Rekomendasi';
              final text = recommendation['recommendation_text']?.toString() ?? '-';
              return '• $category: $text';
            }).join('\n\n');

      return {
        ...fallback,
        ...detail,
        'clinical_note_id': clinicalNoteId,
        'recommendations': recommendations,
        'doctor': item['doctor_name']?.toString() ?? _doctorFromMessage(_desc(item)),
        'date': _formatDateTime(
          first['created_at'] ?? detail['created_at'] ?? item['created_at'],
        ),
        'category': recommendations.length == 1
            ? first['category']?.toString() ?? 'Rekomendasi'
            : '${recommendations.length} Rekomendasi',
        'description': description,
      };
    } catch (_) {
      return fallback;
    }
  }

  Future<bool> _handleCaregiverRequestFromNotification({
    required int caregiverId,
    required String name,
    required bool isAccept,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final patientId = prefs.getInt('patient_id');

      if (patientId == null) {
        throw Exception('Patient ID tidak ditemukan. Coba login ulang.');
      }

      if (isAccept) {
        await ApiService.acceptCaregiverRequest(
          patientId: patientId,
          caregiverId: caregiverId,
        );
      } else {
        await ApiService.rejectCaregiverRequest(
          patientId: patientId,
          caregiverId: caregiverId,
        );
      }

      if (!mounted) return false;

      _showSnackBar(
        isAccept
            ? '$name berhasil diterima sebagai keluarga pendamping.'
            : 'Permintaan koneksi dari $name berhasil ditolak.',
        isError: false,
      );

      await _loadNotifications();
      return true;
    } catch (e) {
      if (!mounted) return false;

      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? AppColors.red : AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  bool _isPrescriptionRoute(String routeKey) {
    return routeKey.contains('prescription') ||
        routeKey.contains('resep') ||
        routeKey.contains('obat') ||
        routeKey.contains('pengingat_obat');
  }


  bool _isCaregiverRoute(String routeKey) {
    return routeKey.contains('caregiver') ||
        routeKey.contains('keluarga');
  }

  bool _isCaregiverDisconnectedRoute(String routeKey) {
    return _isCaregiverRoute(routeKey) &&
        (routeKey.contains('disconnect') ||
            routeKey.contains('disconnected') ||
            routeKey.contains('diputus') ||
            routeKey.contains('terputus'));
  }

  Future<void> _openNotification(Map<String, dynamic> item) async {
    final notificationId = _asInt(item['notification_id'] ?? item['id']);

    if (!_isRead(item) && notificationId != null) {
      try {
        await ApiService.markNotificationAsRead(notificationId);

        setState(() {
          item['is_read'] = true;
          item['read'] = true;
        });
      } catch (_) {}
    }

    final detail = await _loadNotificationDetail(item);

    final type = _type(detail);
    final refType = detail['reference_type']?.toString().toLowerCase() ?? '';
    final title = _title(detail).toLowerCase();
    final desc = _desc(detail).toLowerCase();

    final routeKey = '$type $refType $title $desc';

    if (routeKey.contains('recommendation') ||
        routeKey.contains('rekomendasi')) {
      final recommendationPayload = await _buildRecommendationPayload(detail);

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PatientRecommendationDetailPage(
            item: recommendationPayload,
          ),
        ),
      );
    } else if (routeKey.contains('validation') ||
        routeKey.contains('validasi')) {
      await _openValidationNotification(detail);
    } else if (_isPrescriptionRoute(routeKey)) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PatientPrescriptionNotificationDetailPage(item: detail),
        ),
      );
    } else if (_isCaregiverDisconnectedRoute(routeKey)) {
      final caregiverName = _safeText(
        detail['caregiver_name'] ?? detail['full_name'] ?? detail['name'],
        fallback: _caregiverFromMessage(_desc(detail)),
      );
      final relation = _caregiverRelation(detail);
      final endedAt = _formatDateTime(
        detail['relation_updated_at'] ??
            detail['responded_at'] ??
            detail['connected_at'] ??
            detail['updated_at'] ??
            detail['created_at'] ??
            detail['time'],
      );
      final initial = _safeText(
        detail['initial'],
        fallback: _initialFromName(caregiverName),
      );

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CaregiverDisconnectedDetailPage(
            initial: initial,
            name: caregiverName,
            relation: relation,
            date: endedAt,
            message: _desc(detail),
          ),
        ),
      );
    } else if (routeKey.contains('rejected') ||
        routeKey.contains('ditolak') ||
        routeKey.contains('tolak')) {
      final doctorName = detail['doctor_name']?.toString().isNotEmpty == true
          ? detail['doctor_name'].toString()
          : _doctorFromMessage(_desc(detail));

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DoctorConnectionRejectedDetailPage(
            name: doctorName,
            info: _doctorInfo(detail),
            date: _formatDateTime(detail['created_at'] ?? detail['time']),
            message: _desc(detail),
          ),
        ),
      );
    } else if (routeKey.contains('disconnect') ||
        routeKey.contains('diputus') ||
        routeKey.contains('terputus')) {
      final doctorName = detail['doctor_name']?.toString().isNotEmpty == true
          ? detail['doctor_name'].toString()
          : _doctorFromMessage(_desc(detail));

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DoctorDisconnectedDetailPage(
            doctorId:
                _asInt(detail['doctor_id']) ?? _asInt(detail['reference_id']) ?? 0,
            initial: detail['initial']?.toString() ?? _initialFromName(doctorName),
            name: doctorName,
            info: _doctorInfo(detail),
            status: detail['status']?.toString() ?? 'Tidak Terhubung',
            date: _formatDateTime(detail['created_at'] ?? detail['time']),
          ),
        ),
      );
    } else if (routeKey.contains('accepted') ||
        routeKey.contains('diterima') ||
        routeKey.contains('terhubung')) {
      final doctorName = detail['doctor_name']?.toString().isNotEmpty == true
          ? detail['doctor_name'].toString()
          : _doctorFromMessage(_desc(detail));
      final relationStatus = _doctorRelationStatus(detail);

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DoctorConnectionAcceptedDetailPage(
            doctorId:
                _asInt(detail['doctor_id']) ?? _asInt(detail['reference_id']) ?? 0,
            initial: detail['initial']?.toString() ?? _initialFromName(doctorName),
            name: doctorName,
            info: _doctorInfo(detail),
            status: relationStatus,
            date: _formatDateTime(
              detail['connected_since'] ?? detail['created_at'] ?? detail['time'],
            ),
          ),
        ),
      );
    } else if (routeKey.contains('caregiver') || routeKey.contains('keluarga')) {
      final caregiverId = _asInt(detail['caregiver_id'] ?? detail['reference_id']);
      final caregiverName = _safeText(
        detail['caregiver_name'] ?? detail['full_name'] ?? detail['name'],
        fallback: _caregiverFromMessage(_desc(detail)),
      );
      final relation = _caregiverRelation(detail);
      final requestedAt = _formatDateTime(
        detail['requested_at'] ?? detail['created_at'] ?? detail['time'],
      );
      final status = _safeText(detail['status'], fallback: 'Menunggu');
      final initial = _safeText(
        detail['initial'],
        fallback: _initialFromName(caregiverName),
      );

      final changed = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PatientRequestDetailPage(
            initial: initial,
            name: caregiverName,
            relation: relation,
            time: '',
            date: requestedAt,
            initialStatus: status,
            onAccept: caregiverId == null
                ? () async {
                    _showSnackBar('Caregiver ID tidak ditemukan');
                    return false;
                  }
                : () => _handleCaregiverRequestFromNotification(
                      caregiverId: caregiverId,
                      name: caregiverName,
                      isAccept: true,
                    ),
            onReject: caregiverId == null
                ? () async {
                    _showSnackBar('Caregiver ID tidak ditemukan');
                    return false;
                  }
                : () => _handleCaregiverRequestFromNotification(
                      caregiverId: caregiverId,
                      name: caregiverName,
                      isAccept: false,
                    ),
          ),
        ),
      );

      if (changed == true && mounted) {
        await _loadNotifications();
      }
    }

    if (mounted) {
      _loadNotifications();
    }
  }


  Future<void> _openValidationNotification(Map<String, dynamic> detail) async {
    final recordType = detail['record_type']?.toString() ?? '';
    final recordId = _asInt(detail['record_id']);
    final status = detail['validation_status']?.toString().toLowerCase() ?? '';

    if (recordType.isEmpty || recordId == null) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PatientValidationPage()),
      );
      return;
    }

    if (status == 'menunggu') {
      final changed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => PatientValidationDetailPage(item: detail),
        ),
      );

      if (changed == true) {
        await _loadNotifications();
      }
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientHealthDetailPage(
          type: _historyTypeFromRecordType(recordType),
          item: detail,
        ),
      ),
    );
  }

  String _historyTypeFromRecordType(String recordType) {
    switch (recordType) {
      case 'glucose':
        return 'Glukosa';
      case 'physiological':
        return 'Fisiologis';
      case 'activity':
        return 'Aktivitas';
      case 'meal':
        return 'Makan';
      case 'medication':
        return 'Obat';
      default:
        return 'Glukosa';
    }
  }

  List<Map<String, dynamic>> _filteredNotifications() {
    final keyword = searchController.text.trim().toLowerCase();

    final tabFiltered = selectedTab == 0
        ? notifications
        : notifications.where((item) => !_isRead(item)).toList();

    if (keyword.isEmpty) return tabFiltered;

    return tabFiltered.where((item) {
      return _title(item).toLowerCase().contains(keyword) ||
          _desc(item).toLowerCase().contains(keyword) ||
          _time(item).toLowerCase().contains(keyword) ||
          _section(item).toLowerCase().contains(keyword);
    }).toList();
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
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            _tabBar(),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.red, size: 42),
            const SizedBox(height: 12),
            Text(
              errorMessage ?? 'Gagal memuat notifikasi',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.dark2, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNotifications,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Coba lagi'),
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
      padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 24),
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

  Widget _tabBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
      color: AppColors.background,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.light1),
        ),
        child: Row(
          children: [_tabItem('Semua', 0), _tabItem('Belum Dibaca', 1)],
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

  Widget _tabItem(String label, int index) {
    final selected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.lightBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
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
      final section = _section(item);

      if (section != lastSection) {
        widgets.add(_sectionHeader(section));
        lastSection = section;
      }

      widgets.add(_notificationTile(item));
    }

    return widgets;
  }

  Widget _sectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      color: AppColors.lightBlue,
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _notificationTile(Map<String, dynamic> item) {
    final read = _isRead(item);
    final type = _type(item);
    final refType = item['reference_type']?.toString().toLowerCase() ?? '';
    final routeKey = '$type $refType ${_title(item).toLowerCase()} ${_desc(item).toLowerCase()}';
    final visual = _notificationVisual(routeKey);

    return InkWell(
      onTap: () => _openNotification(item),
      child: Container(
        color: read ? AppColors.white : const Color(0xFFF3F8FF),
        padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!read)
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
                color: visual.bg,
                shape: BoxShape.circle,
              ),
              child: Icon(visual.icon, color: visual.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title(item),
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _desc(item),
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
                        _time(item),
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


_NotificationVisual _notificationVisual(String routeKey) {
  if (routeKey.contains('validation') || routeKey.contains('validasi')) {
    return const _NotificationVisual(
      icon: Icons.assignment_turned_in_outlined,
      bg: Color(0xFFFFF4DA),
      color: Colors.orange,
    );
  }

  if (routeKey.contains('rejected') ||
      routeKey.contains('ditolak') ||
      routeKey.contains('tolak')) {
    return const _NotificationVisual(
      icon: Icons.cancel_outlined,
      bg: AppColors.lightRed,
      color: AppColors.red,
    );
  }

  if (routeKey.contains('disconnect') ||
      routeKey.contains('diputus') ||
      routeKey.contains('terputus')) {
    return const _NotificationVisual(
      icon: Icons.link_off_rounded,
      bg: AppColors.lightRed,
      color: AppColors.red,
    );
  }

  if (routeKey.contains('accepted') ||
      routeKey.contains('diterima') ||
      routeKey.contains('terhubung')) {
    return const _NotificationVisual(
      icon: Icons.check_circle_outline,
      bg: Color(0xFFEAFBF3),
      color: Color(0xFF10C878),
    );
  }

  if (routeKey.contains('caregiver') || routeKey.contains('keluarga')) {
    return const _NotificationVisual(
      icon: Icons.person_add_alt_1_rounded,
      bg: Color(0xFFEAFBF3),
      color: Color(0xFF10C878),
    );
  }

  if (routeKey.contains('doctor') || routeKey.contains('connection')) {
    return const _NotificationVisual(
      icon: Icons.person_add_alt_1_rounded,
      bg: Color(0xFFEAFBF3),
      color: Color(0xFF10C878),
    );
  }

  if (routeKey.contains('prescription') ||
      routeKey.contains('resep') ||
      routeKey.contains('obat') ||
      routeKey.contains('pengingat_obat')) {
    return const _NotificationVisual(
      icon: Icons.medication_outlined,
      bg: AppColors.veryLightBlue,
      color: AppColors.primaryBlue,
    );
  }

  if (routeKey.contains('recommendation') || routeKey.contains('rekomendasi')) {
    return const _NotificationVisual(
      icon: Icons.medical_information_outlined,
      bg: AppColors.veryLightBlue,
      color: AppColors.primaryBlue,
    );
  }

  return const _NotificationVisual(
    icon: Icons.notifications_none_rounded,
    bg: AppColors.veryLightBlue,
    color: AppColors.primaryBlue,
  );
}

class _NotificationVisual {
  final IconData icon;
  final Color bg;
  final Color color;

  const _NotificationVisual({
    required this.icon,
    required this.bg,
    required this.color,
  });
}


class PatientPrescriptionNotificationDetailPage extends StatelessWidget {
  final Map<String, dynamic> item;

  const PatientPrescriptionNotificationDetailPage({
    super.key,
    required this.item,
  });

  String _text(dynamic value, {String fallback = '-'}) {
    if (value == null || value.toString().trim().isEmpty) return fallback;
    return value.toString();
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

  bool get _isStopped {
    final title = _text(item['title']).toLowerCase();
    final type = _text(item['reference_type']).toLowerCase();
    final status = _text(item['status']).toLowerCase();

    return title.contains('dihentikan') ||
        type.contains('stopped') ||
        status.contains('selesai');
  }

  bool get _isUpdated {
    final title = _text(item['title']).toLowerCase();
    final type = _text(item['reference_type']).toLowerCase();

    return title.contains('diperbarui') || type.contains('updated');
  }

  @override
  Widget build(BuildContext context) {
    final medicationName = _text(item['medication_name'], fallback: 'Resep Obat');
    final doctorName = _text(item['doctor_name'], fallback: 'Dokter');
    final dosage = _text(item['dosage']);
    final form = _text(item['form']);
    final mealRule = _text(item['meal_rule']);
    final status = _text(item['status'], fallback: _isStopped ? 'Selesai' : 'Aktif');
    final validFrom = _date(item['valid_from']);
    final validUntil = _date(item['valid_until']);
    final schedules = _schedules();
    final icon = _isStopped ? Icons.cancel_outlined : Icons.medication_outlined;
    final iconBg = _isStopped ? AppColors.lightRed : AppColors.veryLightBlue;
    final iconColor = _isStopped ? AppColors.red : AppColors.primaryBlue;
    final title = _isUpdated
        ? 'Resep Obat Diperbarui'
        : _isStopped
            ? 'Resep Obat Dihentikan'
            : 'Detail Resep Obat';

    return _NotificationDetailScaffold(
      title: title,
      icon: icon,
      iconBg: iconBg,
      iconColor: iconColor,
      headerText: '$medicationName\n${_date(item['created_at'])}',
      children: [
        _whiteCard(
          title: 'Informasi Resep',
          children: [
            _InfoRow(label: 'Obat', value: medicationName),
            _InfoRow(label: 'Dokter', value: doctorName),
            _InfoRow(label: 'Dosis', value: dosage),
            _InfoRow(label: 'Bentuk', value: form),
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
                        '$session • $dose • $reminder',
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
            }).toList(),
          ),
        ],
        if (_text(item['message']).isNotEmpty && _text(item['message']) != '-') ...[
          const SizedBox(height: 14),
          _whiteCard(
            title: 'Keterangan',
            children: [
              Text(
                _text(item['message']),
                style: const TextStyle(
                  color: AppColors.dark1,
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class DoctorConnectionAcceptedDetailPage extends StatelessWidget {
  final int doctorId;
  final String initial;
  final String name;
  final String info;
  final String status;
  final String date;

  const DoctorConnectionAcceptedDetailPage({
    super.key,
    required this.doctorId,
    required this.initial,
    required this.name,
    required this.info,
    required this.status,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = status.toLowerCase().trim();
    final isStillConnected = normalizedStatus == 'terhubung' ||
        normalizedStatus == 'diterima' ||
        normalizedStatus == 'disetujui';
    final displayedStatus = isStillConnected ? 'Terhubung' : status;

    return _NotificationDetailScaffold(
      title: 'Koneksi Dokter Diterima',
      icon: Icons.check_circle_outline,
      iconBg: const Color(0xFFEAFBF3),
      iconColor: const Color(0xFF10C878),
      headerText: 'Permintaan koneksi diterima\n$date',
      children: [
        _whiteCard(
          title: 'Data Dokter',
          children: [
            _InfoRow(label: 'Nama', value: name),
            _InfoRow(
              label: 'Spesialisasi',
              value: info.split('•').first.trim(),
            ),
            _InfoRow(label: 'Status relasi saat ini', value: displayedStatus),
            _InfoRow(
              label: isStillConnected ? 'Terhubung sejak' : 'Waktu notifikasi',
              value: date,
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PatientDoctorDetailPage(
                      doctorId: doctorId,
                      initial: initial,
                      name: name,
                      info: info,
                      status: displayedStatus,
                      date: isStillConnected ? date : '',
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isStillConnected ? 'Lihat Detail Dokter' : 'Lihat Data Dokter',
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.primaryBlue),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

}

class DoctorConnectionRejectedDetailPage extends StatelessWidget {
  final String name;
  final String info;
  final String date;
  final String message;

  const DoctorConnectionRejectedDetailPage({
    super.key,
    required this.name,
    required this.info,
    required this.date,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return _NotificationDetailScaffold(
      title: 'Koneksi Dokter Ditolak',
      icon: Icons.cancel_outlined,
      iconBg: AppColors.lightRed,
      iconColor: AppColors.red,
      headerText: 'Permintaan koneksi ditolak\n$date',
      children: [
        _whiteCard(
          title: 'Status Permintaan',
          children: [
            _InfoRow(label: 'Nama Dokter', value: name),
            _InfoRow(
              label: 'Spesialisasi',
              value: info == '-' ? '-' : info.split('•').first.trim(),
            ),
            const _InfoRow(label: 'Status', value: 'Ditolak'),
            _InfoRow(label: 'Tanggal', value: date),
          ],
        ),
      ],
    );
  }
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

class CaregiverDisconnectedDetailPage extends StatelessWidget {
  final String initial;
  final String name;
  final String relation;
  final String date;
  final String message;

  const CaregiverDisconnectedDetailPage({
    super.key,
    required this.initial,
    required this.name,
    required this.relation,
    required this.date,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return _NotificationDetailScaffold(
      title: 'Relasi Keluarga Terputus',
      icon: Icons.link_off_rounded,
      iconBg: AppColors.lightRed,
      iconColor: AppColors.red,
      headerText: 'Relasi keluarga terputus\n$date',
      children: [
        _whiteCard(
          title: 'Data Keluarga',
          children: [
            _InfoRow(label: 'Nama', value: name),
            _InfoRow(label: 'Hubungan', value: relation),
            const _InfoRow(label: 'Status relasi', value: 'Tidak Terhubung'),
            _InfoRow(label: 'Relasi berakhir', value: date),
          ],
        ),
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
      ],
    );
  }
}

class DoctorDisconnectedDetailPage extends StatelessWidget {
  final int doctorId;
  final String initial;
  final String name;
  final String info;
  final String status;
  final String date;

  const DoctorDisconnectedDetailPage({
    super.key,
    required this.doctorId,
    required this.initial,
    required this.name,
    required this.info,
    required this.status,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return _NotificationDetailScaffold(
      title: 'Relasi Terputus',
      icon: Icons.link_off_rounded,
      iconBg: AppColors.lightRed,
      iconColor: AppColors.red,
      headerText: 'Relasi dokter terputus\n$date',
      children: [
        _whiteCard(
          title: 'Data Dokter',
          children: [
            _InfoRow(label: 'Nama', value: name),
            _InfoRow(
              label: 'Spesialisasi',
              value: info.split('•').first.trim(),
            ),
            const _InfoRow(label: 'Status relasi', value: 'Tidak Terhubung'),
            _InfoRow(label: 'Relasi berakhir', value: date),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PatientDoctorDetailPage(
                      doctorId: doctorId,
                      initial: initial,
                      name: name,
                      info: info,
                      status: status,
                      date: '',
                    ),
                  ),
                );
              },
              child: const Row(
                children: [
                  Expanded(
                    child: Text(
                      'Lihat Data Lama Dokter',
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
        ),
      ],
    );
  }
}
