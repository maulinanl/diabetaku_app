import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'patient_recommendation_detail_page.dart';
import 'patient_validation_detail_page.dart';
import 'patient_connection_page.dart';
import 'patient_doctor_detail_page.dart';

class PatientNotificationPage extends StatefulWidget {
  const PatientNotificationPage({super.key});

  @override
  State<PatientNotificationPage> createState() =>
      _PatientNotificationPageState();
}

class _PatientNotificationPageState extends State<PatientNotificationPage> {
  int selectedTab = 0;
  final searchController = TextEditingController();

  final List<Map<String, Object>> notifications = [
    {
      'section': 'Hari Ini',
      'title': 'Rekomendasi baru dari dokter',
      'desc': 'dr. Agus Setiawan, Sp.PD telah mengirim rekomendasi untukmu.',
      'time': '09:41 • Baru saja',
      'type': 'recommendation',
      'icon': Icons.send_outlined,
      'bg': AppColors.veryLightBlue,
      'color': AppColors.primaryBlue,
      'read': false,
    },
    {
      'section': 'Hari Ini',
      'title': 'Data dari keluarga perlu validasi',
      'desc':
          'Aditya Yoga Saputra menginput data glukosa 165 mg/dL atas namamu.',
      'time': '08:30 • 1 jam lalu',
      'type': 'validation',
      'icon': Icons.assignment_outlined,
      'bg': Color(0xFFFFF4DA),
      'color': Color(0xFFFF8A00),
      'read': false,
    },
    {
      'section': 'Hari Ini',
      'title': 'Permintaan koneksi dari keluarga',
      'desc': 'Maya Putri Sari ingin terhubung sebagai pendamping (Anak).',
      'time': '07:15 · 2 jam lalu',
      'type': 'family_request',
      'icon': Icons.person_outline,
      'bg': Color(0xFFEAFBF3),
      'color': Color(0xFF10C878),
      'read': false,
    },
    {
      'section': 'Kemarin',
      'title': 'Permintaan koneksi dokter diterima',
      'desc': 'dr. Rina Wulandari menerima permintaan koneksimu.',
      'time': '6 Jun • 09:41',
      'type': 'doctor_connection',
      'icon': Icons.person_outline,
      'bg': Color(0xFFEAFBF3),
      'color': Color(0xFF10C878),
      'read': true,
    },
    {
      'section': 'Kemarin',
      'title': 'Dokter memutus relasi',
      'desc':
          'dr. Hendra Gunawan telah memutus relasi denganmu sebagai pasien.',
      'time': '6 Jun • 09:00',
      'type': 'disconnected',
      'icon': Icons.link_off_rounded,
      'bg': AppColors.lightRed,
      'color': AppColors.red,
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

  Future<void> _openNotification(Map<String, Object> item) async {
    setState(() {
      item['read'] = true;
    });

    final type = item['type'] as String;

    if (type == 'recommendation') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const PatientRecommendationDetailPage(),
        ),
      );
    } else if (type == 'validation') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const PatientValidationDetailPage(
            name: 'Aditya Yoga Saputra',
            relation: 'Anak',
            type: 'Glukosa Darah',
            value: '165 mg/dL',
            time: '7 Jun 2025 • 08:30',
            note: 'Diinput oleh keluarga dan menunggu validasi pasien.',
            icon: Icons.opacity,
          ),
        ),
      );
    } else if (type == 'family_request') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PatientRequestDetailPage(
            initial: 'MP',
            name: 'Maya Putri Sari',
            relation: 'Anak',
            time: '2 jam lalu',
            date: '7 Jun 2025 • 07:15',
            onAccept: () {
              Navigator.pop(context);
            },
            onReject: () {
              Navigator.pop(context);
            },
          ),
        ),
      );
    } else if (type == 'doctor_connection') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const DoctorConnectionAcceptedDetailPage(),
        ),
      );
    } else if (type == 'disconnected') {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DoctorDisconnectedDetailPage()),
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
            _header(context),
            Expanded(
              child: Container(
                color: AppColors.background,
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
      final desc = item['desc'].toString().toLowerCase();
      final time = item['time'].toString().toLowerCase();
      final section = item['section'].toString().toLowerCase();

      return title.contains(keyword) ||
          desc.contains(keyword) ||
          time.contains(keyword) ||
          section.contains(keyword);
    }).toList();
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

  List<Widget> _groupedNotifications(List<Map<String, Object>> data) {
    final widgets = <Widget>[];
    String? lastSection;

    for (final item in data) {
      final section = item['section'] as String;

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

  Widget _notificationTile(Map<String, Object> item) {
    final read = item['read'] as bool? ?? false;

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
                color: item['bg'] as Color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                item['icon'] as IconData,
                color: item['color'] as Color,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] as String,
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['desc'] as String,
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
                        item['time'] as String,
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
  const DoctorConnectionAcceptedDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _NotificationDetailScaffold(
      title: 'Koneksi Dokter Diterima',
      icon: Icons.check_circle_outline,
      headerText: 'Permintaan koneksi diterima\ndr. Rina Wulandari\n6 Jun 2025',
      children: [
        _whiteCard(
          title: 'Data Dokter',
          children: [
            const _InfoRow(label: 'Nama', value: 'dr. Rina Wulandari'),
            const _InfoRow(label: 'Spesialisasi', value: 'Sp.PD'),
            const _InfoRow(label: 'Status relasi', value: 'Terhubung'),
            const _InfoRow(label: 'Terhubung sejak', value: '6 Jun 2025'),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PatientDoctorDetailPage(
                      initial: 'RW',
                      name: 'dr. Rina Wulandari',
                      info: 'Penyakit Dalam • RSUD Surabaya',
                      status: 'Terhubung',
                      date: 'Sejak 6 Jun 2025',
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
        const SizedBox(height: 14),
        _whiteCard(
          title: 'Keterangan',
          children: const [
            Text(
              'Dokter telah menerima permintaan koneksimu. Data kesehatanmu dapat dipantau oleh dokter terkait selama relasi masih aktif.',
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
  const DoctorDisconnectedDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _NotificationDetailScaffold(
      title: 'Relasi Terputus',
      icon: Icons.link_off_rounded,
      headerText: 'Relasi dokter terputus\ndr. Hendra Gunawan\n6 Jun 2025',
      children: [
        _whiteCard(
          title: 'Data Dokter',
          children: [
            const _InfoRow(label: 'Nama', value: 'dr. Hendra Gunawan'),
            const _InfoRow(label: 'Spesialisasi', value: 'Sp.PD'),
            const _InfoRow(label: 'Status relasi', value: 'Tidak Terhubung'),
            const _InfoRow(label: 'Relasi berakhir', value: '6 Jun 2025'),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PatientDoctorDetailPage(
                      initial: 'HG',
                      name: 'dr. Hendra Gunawan',
                      info: 'Penyakit Dalam • RSUD Surabaya',
                      status: 'Tidak Terhubung',
                      date: 'Berakhir 6 Jun 2025',
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
        const SizedBox(height: 14),
        _whiteCard(
          title: 'Keterangan',
          children: const [
            Text(
              'Relasi dengan dokter ini telah terputus. Dokter tidak dapat melihat pembaruan data terbaru setelah relasi berakhir.',
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