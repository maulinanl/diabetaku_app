import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PatientNotificationPage extends StatefulWidget {
  const PatientNotificationPage({super.key});

  @override
  State<PatientNotificationPage> createState() =>
      _PatientNotificationPageState();
}

class _PatientNotificationPageState extends State<PatientNotificationPage> {
  int selectedTab = 0;

  final TextEditingController searchController = TextEditingController();

  final notifications = [
    {
      'section': 'Hari Ini',
      'title': 'Catatan klinis baru dari dokter',
      'desc':
          'dr. Agus Setiawan, Sp.PD telah membuat catatan klinis beserta rekomendasi untukmu.',
      'time': '09:41 · Baru saja',
      'icon': Icons.description_outlined,
      'bg': Color(0xFFE3F1FF),
      'color': AppColors.primaryBlue,
      'unread': true,
    },
    {
      'section': 'Hari Ini',
      'title': 'Data dari keluarga perlu validasi',
      'desc':
          'Aditya Yoga Saputra menginput data glukosa 165 mg/dL atas namamu. Konfirmasi atau tolak.',
      'time': '08:30 · 1 jam lalu',
      'icon': Icons.assignment_outlined,
      'bg': Color(0xFFFFF4DA),
      'color': Color(0xFFFF8A00),
      'unread': true,
    },
    {
      'section': 'Hari Ini',
      'title': 'Permintaan koneksi dari keluarga',
      'desc': 'Maya Putri Sari ingin terhubung sebagai pendamping (Anak).',
      'time': '07:15 · 2 jam lalu',
      'icon': Icons.person_outline,
      'bg': Color(0xFFEAFBF3),
      'color': Color(0xFF10C878),
      'unread': true,
    },
    {
      'section': 'Kemarin',
      'title': 'Permintaan koneksi dokter diterima',
      'desc': 'dr. Rina Wulandari menerima permintaan koneksimu.',
      'time': '6 Jun · 09:41',
      'icon': Icons.person_outline,
      'bg': Color(0xFFEAFBF3),
      'color': Color(0xFF10C878),
      'unread': false,
    },
    {
      'section': 'Kemarin',
      'title': 'Dokter memutus relasi',
      'desc':
          'dr. Hendra Gunawan telah memutus relasi denganmu sebagai pasien.',
      'time': '6 Jun · 09:00',
      'icon': Icons.link_off_rounded,
      'bg': Color(0xFFFFF1F1),
      'color': AppColors.red,
      'unread': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
        : notifications.where((e) => e['unread'] == true).toList();

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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
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
    final unread = item['unread'] as bool;

    return Container(
      color: unread ? const Color(0xFFF3F8FF) : AppColors.white,
      padding: const EdgeInsets.fromLTRB(18, 16, 22, 16),
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
        ],
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