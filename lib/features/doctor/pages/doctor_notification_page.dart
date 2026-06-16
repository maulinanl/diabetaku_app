import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'patient_detail_page.dart';
import 'recommendation_detail_page.dart';
import 'doctor_connection_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/services/api_service.dart';

class DoctorNotificationPage extends StatefulWidget {
  const DoctorNotificationPage({super.key});

  @override
  State<DoctorNotificationPage> createState() => _DoctorNotificationPageState();
}

class _DoctorNotificationPageState extends State<DoctorNotificationPage> {
  int selectedTab = 0;
  final searchController = TextEditingController();

  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;
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
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  Future<void> _openNotificationDetail(Map<String, dynamic> item) async {
    final notificationId = int.tryParse(item['notification_id'].toString());
    final referenceId = int.tryParse(item['reference_id']?.toString() ?? '');

    if (notificationId != null) {
      await ApiService.markNotificationAsRead(notificationId);
    }

    if (!mounted) return;

    setState(() {
      item['is_read'] = true;
    });

    final type =
        item['notification_type_name']?.toString().toLowerCase().trim() ?? '';

    if (type == 'data abnormal') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AbnormalNotificationDetailPage(patientId: referenceId ?? 1),
        ),
      );
    } else if (type == 'permintaan koneksi') {
      if (referenceId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Data pasien pada permintaan koneksi tidak ditemukan',
            ),
          ),
        );
        return;
      }

      try {
        final connection = await ApiService.getDoctorPatientConnectionStatus(
          patientId: referenceId,
        );

        final statusId = int.tryParse(connection['status_id'].toString()) ?? 0;

        final statusText = statusId == 1
            ? 'Koneksi aktif'
            : statusId == 2
            ? 'Koneksi ditolak'
            : 'Menunggu persetujuan dokter';

        if (!mounted) return;

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RequestDetailPage(
              patientId: referenceId,
              status: statusId,
              name:
                  connection['full_name']?.toString() ??
                  _extractPatientName(item['message']?.toString() ?? ''),
              age: _calculateAge(connection['date_of_birth']?.toString()),
              gender: connection['gender']?.toString() ?? '-',
              diabetesType: connection['diabetes_type']?.toString() ?? '-',
              connectionStatus: statusText,
              time: _formatNotificationTime(item['created_at']),
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } else if (type == 'rekomendasi dokter') {
      if (referenceId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data rekomendasi tidak ditemukan')),
        );
        return;
      }

      try {
        final detail = await ApiService.getRecommendationDetail(referenceId);

        final patient = Map<String, dynamic>.from(detail['patient']);
        final recommendations = List<Map<String, dynamic>>.from(
          detail['recommendations'],
        );
        final recipients = List<Map<String, dynamic>>.from(
          detail['recipients'],
        );

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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } else if (type == 'putus relasi') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              DisconnectedNotificationDetailPage(patientId: referenceId ?? 1),
        ),
      );
    }

    if (mounted) {
      _loadNotifications();
    }
  }

  String _extractPatientName(String message) {
    if (message.contains(' mengajukan')) {
      return message.split(' mengajukan').first.trim();
    }

    return '-';
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

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredNotifications();

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Container(
                color: AppColors.background,
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage != null
                    ? Center(child: Text(errorMessage!))
                    : ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          _buildTabs(),
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
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _filteredNotifications() {
    final keyword = searchController.text.trim().toLowerCase();

    final tabFiltered = selectedTab == 0
        ? notifications
        : notifications.where((item) {
            final isRead = item['is_read'];
            return isRead == false || isRead == 0 || isRead.toString() == '0';
          }).toList();

    if (keyword.isEmpty) {
      tabFiltered.sort((a, b) {
        final dateA =
            DateTime.tryParse(a['created_at']?.toString() ?? '') ??
            DateTime(2000);

        final dateB =
            DateTime.tryParse(b['created_at']?.toString() ?? '') ??
            DateTime(2000);

        return dateB.compareTo(dateA);
      });

      return tabFiltered;
    }

    final result = tabFiltered.where((item) {
      final title = item['title']?.toString().toLowerCase() ?? '';
      final message = item['message']?.toString().toLowerCase() ?? '';
      final type =
          item['notification_type_name']?.toString().toLowerCase() ?? '';

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

  Widget _buildHeader(BuildContext context) {
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

      final isRead =
          item['is_read'] == true ||
          item['is_read'] == 1 ||
          item['is_read'].toString() == '1';

      widgets.add(
        _NotificationTile(
          title: item['title']?.toString() ?? '-',
          message: item['message']?.toString() ?? '-',
          time: _formatNotificationTime(item['created_at']),
          type: item['notification_type_name']?.toString() ?? '',
          read: isRead,
          onTap: () => _openNotificationDetail(item),
        ),
      );
    }

    return widgets;
  }

  String _getSection(dynamic value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');

    if (parsed == null) {
      return 'Sebelumnya';
    }

    final date = parsed.toLocal();

    final now = DateTime.now();

    final difference = DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(date.year, date.month, date.day)).inDays;

    if (difference == 0) {
      return 'Hari Ini';
    }

    if (difference == 1) {
      return 'Kemarin';
    }

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
  final bool read;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    required this.read,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedType = type.toLowerCase().trim();

    final isAbnormal = normalizedType == 'data abnormal';
    final isConnection = normalizedType == 'permintaan koneksi';
    final isRecommendation = normalizedType == 'rekomendasi dokter';
    final isMedicineReminder = normalizedType == 'pengingat obat';
    final isVerification = normalizedType == 'status verifikasi';
    final isDisconnected = normalizedType == 'putus relasi';

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
  final int patientId;

  const AbnormalNotificationDetailPage({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return _NotificationDetailScaffold(
      title: 'Notifikasi Abnormal',
      icon: Icons.warning_amber_rounded,
      headerText: 'Glukosa abnormal terdeteksi\nAngelica Sabi Gita\n09:41',
      children: [
        _whiteCard(
          title: 'Data Pasien',
          children: [
            const _InfoRow(label: 'Nama', value: 'Angelica Sabi Gita'),
            const _InfoRow(label: 'Tipe DM', value: 'DM Tipe 2'),
            const _InfoRow(label: 'Usia', value: '32 tahun'),
            const _InfoRow(label: 'Tahun diagnosis', value: '2018'),
            const SizedBox(height: 8),
            _detailPatientLink(context, 'Lihat Detail Pasien', patientId, true),
          ],
        ),
        const SizedBox(height: 14),
        _whiteCard(
          title: 'Data Terdeteksi',
          children: const [
            _InfoRow(label: 'Tipe pengukuran', value: 'Postprandial'),
            _InfoRow(label: 'Nilai', value: '187 mg/dL'),
            _InfoRow(label: 'Batas normal', value: '80 - 160 mg/dL'),
            _InfoRow(label: 'Status', value: 'Abnormal'),
          ],
        ),
        const SizedBox(height: 14),
        _whiteCard(
          title: 'Detail Notifikasi',
          children: const [
            Text(
              'Nilai glukosa pasien terdeteksi berada di luar batas normal. Dokter dapat meninjau detail pasien untuk memberikan catatan klinis atau rekomendasi jika diperlukan.',
              style: TextStyle(
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
  final int patientId;

  const DisconnectedNotificationDetailPage({
    super.key,
    required this.patientId,
  });

  @override
  Widget build(BuildContext context) {
    return _NotificationDetailScaffold(
      title: 'Relasi Terputus',
      icon: Icons.link_off_rounded,
      headerText: 'Relasi pasien terputus\nHendra Gunawan\n6 Jun 2025',
      children: [
        _whiteCard(
          title: 'Data Pasien',
          children: [
            const _InfoRow(label: 'Nama', value: 'Hendra Gunawan'),
            const _InfoRow(label: 'Tipe DM', value: 'DM Tipe 2'),
            const _InfoRow(label: 'Status relasi', value: 'Tidak Terhubung'),
            const _InfoRow(label: 'Relasi berakhir', value: '6 Jun 2025'),
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
          children: const [
            Text(
              'Relasi dengan pasien ini telah terputus. Dokter masih dapat melihat data lama sebelum relasi berakhir, tetapi tidak dapat mengakses pembaruan data terbaru atau mengirim rekomendasi baru.',
              style: TextStyle(
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
              padding: EdgeInsets.fromLTRB(12, topPad + 12, 18, 24),
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
                            fontSize: 18,
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
            fontWeight: FontWeight.bold,
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
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              PatientDetailPage(patientId: patientId, isConnected: isConnected),
        ),
      );
    },
    child: Row(
      children: [
        Expanded(
          child: Text(
            text,
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
