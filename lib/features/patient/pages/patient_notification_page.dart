import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';
import 'patient_connection_page.dart';
import 'patient_doctor_detail_page.dart';
import 'patient_recommendation_detail_page.dart';
import 'patient_validation_page.dart';

class PatientNotificationPage extends StatefulWidget {
  const PatientNotificationPage({super.key});

  @override
  State<PatientNotificationPage> createState() =>
      _PatientNotificationPageState();
}

class _PatientNotificationPageState extends State<PatientNotificationPage> {
  int selectedTab = 0;
  bool isLoading = true;
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

  IconData _iconByType(String type) {
    if (type.contains('recommendation')) return Icons.send_outlined;
    if (type.contains('validation')) return Icons.assignment_outlined;
    if (type.contains('family')) return Icons.person_outline;
    if (type.contains('doctor')) return Icons.person_outline;
    if (type.contains('disconnect')) return Icons.link_off_rounded;

    return Icons.notifications_none_rounded;
  }

  Color _bgByType(String type) {
    if (type.contains('validation')) return const Color(0xFFFFF4DA);
    if (type.contains('family') || type.contains('doctor')) {
      return const Color(0xFFEAFBF3);
    }
    if (type.contains('disconnect')) return AppColors.lightRed;

    return AppColors.veryLightBlue;
  }

  Color _colorByType(String type) {
    if (type.contains('validation')) return Colors.orange;
    if (type.contains('family') || type.contains('doctor')) {
      return const Color(0xFF10C878);
    }
    if (type.contains('disconnect')) return AppColors.red;

    return AppColors.primaryBlue;
  }

  Future<void> _openNotification(Map<String, dynamic> item) async {
    final notificationId = item['notification_id'] ?? item['id'];

    if (!_isRead(item) && notificationId != null) {
      try {
        await ApiService.markNotificationAsRead(
          int.parse(notificationId.toString()),
        );

        setState(() {
          item['is_read'] = true;
          item['read'] = true;
        });
      } catch (_) {}
    }

    final type = _type(item);
    final refType = item['reference_type']?.toString().toLowerCase() ?? '';

    if (type.contains('recommendation') ||
        type.contains('rekomendasi') ||
        refType.contains('recommendation')) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PatientRecommendationDetailPage(
            item: {
              'doctor': item['doctor_name']?.toString() ?? 'Dokter',
              'date': _time(item),
              'status': item['category']?.toString() ?? 'Rekomendasi',
              'description':
                  item['recommendation_text']?.toString() ??
                  item['content']?.toString() ??
                  _desc(item),
            },
          ),
        ),
      );
    } else if (type.contains('validation') ||
        type.contains('validasi') ||
        refType.contains('validation')) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PatientValidationPage()),
      );
    } else if (type.contains('doctor') ||
        type.contains('dokter') ||
        refType.contains('doctor')) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DoctorConnectionAcceptedDetailPage(
            doctorId: int.tryParse(item['reference_id']?.toString() ?? '') ?? 0,
            initial: item['initial']?.toString() ?? 'D',
            name: item['doctor_name']?.toString() ?? 'Dokter',
            info: item['info']?.toString() ?? '-',
            status: item['status']?.toString() ?? 'Terhubung',
            date: _time(item),
          ),
        ),
      );
    } else if (type.contains('family') ||
        type.contains('keluarga') ||
        refType.contains('family')) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PatientRequestDetailPage(
            initial: item['initial']?.toString() ?? 'K',
            name: item['family_name']?.toString().isNotEmpty == true
                ? item['family_name'].toString()
                : _title(item),
            relation: item['relation']?.toString().isNotEmpty == true
                ? item['relation'].toString()
                : _desc(item),
            time: _time(item),
            date: _time(item),
            onAccept: () => Navigator.pop(context),
            onReject: () => Navigator.pop(context),
          ),
        ),
      );
    } else if (type.contains('doctor_connection')) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DoctorConnectionAcceptedDetailPage(
            doctorId: int.tryParse(item['doctor_id']?.toString() ?? '') ?? 0,
            initial: item['initial']?.toString() ?? 'D',
            name: item['doctor_name']?.toString() ?? 'Dokter',
            info: item['info']?.toString() ?? '-',
            status: item['status']?.toString() ?? 'Terhubung',
            date: _time(item),
          ),
        ),
      );
    } else if (type.contains('disconnect')) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DoctorDisconnectedDetailPage(
            doctorId: int.tryParse(item['doctor_id']?.toString() ?? '') ?? 0,
            initial: item['initial']?.toString() ?? 'D',
            name: item['doctor_name']?.toString() ?? 'Dokter',
            info: item['info']?.toString() ?? '-',
            status: item['status']?.toString() ?? 'Tidak Terhubung',
            date: _time(item),
          ),
        ),
      );
    }

    _loadNotifications();
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
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            _tabBar(),
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
                color: _bgByType(type),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _iconByType(type),
                color: _colorByType(type),
                size: 22,
              ),
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
    return _NotificationDetailScaffold(
      title: 'Koneksi Dokter Diterima',
      icon: Icons.check_circle_outline,
      headerText: 'Permintaan koneksi diterima\n$name\n$date',
      children: [
        _whiteCard(
          title: 'Data Dokter',
          children: [
            _InfoRow(label: 'Nama', value: name),
            _InfoRow(
              label: 'Spesialisasi',
              value: info.split('•').first.trim(),
            ),
            const _InfoRow(label: 'Status relasi', value: 'Terhubung'),
            _InfoRow(label: 'Terhubung sejak', value: date),
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
                      date: date,
                    ),
                  ),
                );
              },
              child: const Row(
                children: [
                  Expanded(
                    child: Text(
                      'Lihat Detail Dokter',
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

class _NotificationDetailScaffold extends StatelessWidget {
  final String title;
  final IconData icon;
  final String headerText;
  final List<Widget> children;

  const _NotificationDetailScaffold({
    required this.title,
    required this.icon,
    required this.headerText,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(14, topPad + 12, 18, 24),
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
                      Expanded(
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
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
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.lightBlue,
                          child: Icon(icon, color: AppColors.primaryBlue),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            headerText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
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
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.light1),
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
      headerText: 'Relasi dokter terputus\n$name\n$date',
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
