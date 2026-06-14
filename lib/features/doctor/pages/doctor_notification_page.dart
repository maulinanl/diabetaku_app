import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'patient_detail_page.dart';
import 'clinical_note_detail_page.dart';
import 'doctor_connection_page.dart';

class DoctorNotificationPage extends StatefulWidget {
  const DoctorNotificationPage({super.key});

  @override
  State<DoctorNotificationPage> createState() => _DoctorNotificationPageState();
}

class _DoctorNotificationPageState extends State<DoctorNotificationPage> {
  int selectedTab = 0;
  final searchController = TextEditingController();

  final notifications = [
    {
      'section': 'Hari Ini',
      'title': 'Glukosa abnormal - Angelica Sabi Gita',
      'message': 'Glukosa postprandial 187 mg/dL melebihi batas normal.',
      'time': '09:41 • Baru saja',
      'type': 'abnormal',
      'read': false,
    },
    {
      'section': 'Hari Ini',
      'title': 'Permintaan koneksi baru',
      'message':
          'Wahyu Prasetyo mengajukan permintaan untuk terhubung denganmu.',
      'time': '08:15 • 1 jam lalu',
      'type': 'connection',
      'read': false,
    },
    {
      'section': 'Kemarin',
      'title': 'Catatan klinis tersimpan',
      'message': 'Catatan klinis Ahmad Barik berhasil disimpan.',
      'time': '6 Jun • 09:41',
      'type': 'note',
      'read': true,
    },
    {
      'section': 'Kemarin',
      'title': 'Relasi pasien terputus',
      'message':
          'Relasi dengan Hendra Gunawan telah terputus. Data lama masih dapat dilihat.',
      'time': '6 Jun • 09:00',
      'type': 'disconnected',
      'read': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _openNotificationDetail(Map<String, Object> item) {
    final type = item['type'] as String;

    if (type == 'abnormal') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AbnormalNotificationDetailPage(),
        ),
      );
    } else if (type == 'connection') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const RequestDetailPage(
            status: 0,
            initial: 'WP',
            name: 'Wahyu Prasetyo',
            info: 'DM Tipe 2 • 47 tahun • Laki-laki',
            diagnosis: '2019',
            time: '08:15',
          ),
        ),
      );
    } else if (type == 'note') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ClinicalNoteDetailPage()),
      );
    } else if (type == 'disconnected') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const DisconnectedNotificationDetailPage(),
        ),
      );
    }
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
                child: ListView(
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

  List<Map<String, Object>> _filteredNotifications() {
    final keyword = searchController.text.trim().toLowerCase();

    final tabFiltered = selectedTab == 0
        ? notifications
        : notifications.where((item) => item['read'] == false).toList();

    if (keyword.isEmpty) return tabFiltered;

    return tabFiltered.where((item) {
      final title = item['title'].toString().toLowerCase();
      final message = item['message'].toString().toLowerCase();
      final time = item['time'].toString().toLowerCase();
      final type = item['type'].toString().toLowerCase();
      final section = item['section'].toString().toLowerCase();

      return title.contains(keyword) ||
          message.contains(keyword) ||
          time.contains(keyword) ||
          type.contains(keyword) ||
          section.contains(keyword);
    }).toList();
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

  List<Widget> _groupedNotifications(List<Map<String, Object>> data) {
    final widgets = <Widget>[];
    String? lastSection;

    for (final item in data) {
      final section = item['section'] as String;

      if (section != lastSection) {
        widgets.add(_sectionHeader(section));
        lastSection = section;
      }

      widgets.add(
        _NotificationTile(
          title: item['title'] as String,
          message: item['message'] as String,
          time: item['time'] as String,
          type: item['type'] as String,
          read: item['read'] as bool,
          onTap: () => _openNotificationDetail(item),
        ),
      );
    }

    return widgets;
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
    final isAbnormal = type == 'abnormal';
    final isConnection = type == 'connection';
    final isDisconnected = type == 'disconnected';

    final icon = isAbnormal
        ? Icons.warning_amber_rounded
        : isConnection
        ? Icons.person_add_alt_1_rounded
        : isDisconnected
        ? Icons.link_off_rounded
        : Icons.description_outlined;

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
  const AbnormalNotificationDetailPage({super.key});

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
            _detailPatientLink(context, 'Lihat Detail Pasien'),
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
  const DisconnectedNotificationDetailPage({super.key});

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
            _detailPatientLink(context, 'Lihat Data Lama Pasien'),
          ],
        ),
        const SizedBox(height: 14),
        _whiteCard(
          title: 'Keterangan',
          children: const [
            Text(
              'Relasi dengan pasien ini telah terputus. Dokter masih dapat melihat data lama sebelum relasi berakhir, tetapi tidak dapat mengakses pembaruan data terbaru atau mengirim rekomendasi baru.',
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

Widget _detailPatientLink(BuildContext context, String text) {
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PatientDetailPage()),
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
