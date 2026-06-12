import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FamilyConnectionPage extends StatefulWidget {
  const FamilyConnectionPage({super.key});

  @override
  State<FamilyConnectionPage> createState() => _FamilyConnectionPageState();
}

class _FamilyConnectionPageState extends State<FamilyConnectionPage> {
  int selectedTab = 0;
  final searchCtr = TextEditingController();

  final patients = [
    {
      'initial': 'WP',
      'name': 'Wahyu Prasetyo',
      'info': 'DM Tipe 2 • 47 tahun • Laki-laki',
      'relation': 'Suami',
      'status': 'Terhubung',
      'date': 'Sejak 1 Jan 2025',
    },
    {
      'initial': 'DT',
      'name': 'Diah Tri Puspita',
      'info': 'DM Tipe 2 • 55 tahun • Perempuan',
      'relation': 'Ibu',
      'status': 'Terhubung',
      'date': 'Sejak 24 Mei 2025',
    },
  ];

  final searchPatients = [
    {
      'initial': 'WP',
      'name': 'Wahyu Prasetyo',
      'info': 'DM Tipe 2 • 47 tahun • Laki-laki',
      'relation': 'Suami',
      'status': 'Terhubung',
      'date': 'Sejak 1 Jan 2025',
    },
    {
      'initial': 'WK',
      'name': 'Wati Kusuma Dewi',
      'info': 'DM Tipe 1 • 42 tahun • Perempuan',
      'relation': 'Adik',
      'status': 'Menunggu',
      'date': '',
    },
    {
      'initial': 'SK',
      'name': 'Wasika Yurid',
      'info': 'DM Tipe 1 • 52 tahun • Laki-laki',
      'relation': 'Saudara',
      'status': 'Belum Terhubung',
      'date': '',
    },
  ];

  @override
  void initState() {
    super.initState();
    searchCtr.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    searchCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryBlue,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: Container(
                color: AppColors.background,
                child: Column(
                  children: [
                    _tabs(),
                    Expanded(
                      child: selectedTab == 0
                          ? _patientContent()
                          : _searchPatientContent(),
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

  Widget _header(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPad + 14, 20, 18),
      color: AppColors.primaryBlue,
      child: const Center(
        child: Text(
          'Koneksi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _tabs() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.light1),
        ),
        child: Row(
          children: [
            _tabItem('Pasien', 0),
            _tabItem('Cari Pasien', 1),
          ],
        ),
      ),
    );
  }

  Widget _tabItem(String title, int index) {
    final selected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
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
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _patientContent() {
    if (patients.isEmpty) return _emptyPatient();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
      children: [
        Text(
          'PASIEN SAYA - ${patients.length} TERHUBUNG',
          style: const TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...patients.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _PatientCard(
              initial: item['initial']!,
              name: item['name']!,
              info: item['info']!,
              relation: item['relation']!,
              status: item['status']!,
              date: item['date']!,
              showButton: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _searchPatientContent() {
    final keyword = searchCtr.text.trim().toLowerCase();

    final filteredPatients = keyword.isEmpty
        ? <Map<String, String>>[]
        : searchPatients.where((patient) {
            final name = patient['name']!.toLowerCase();
            final info = patient['info']!.toLowerCase();
            final relation = patient['relation']!.toLowerCase();
            final status = patient['status']!.toLowerCase();

            return name.contains(keyword) ||
                info.contains(keyword) ||
                relation.contains(keyword) ||
                status.contains(keyword);
          }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
      children: [
        _searchBox(),
        const SizedBox(height: 16),
        if (keyword.isEmpty) ...[
          const SizedBox(height: 70),
          Icon(
            Icons.person_search_outlined,
            size: 64,
            color: AppColors.primaryBlue.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          const Text(
            'Cari Pasien',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Masukkan nama pasien untuk mengajukan permintaan koneksi.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.dark2, fontSize: 12),
          ),
        ] else if (filteredPatients.isEmpty) ...[
          const SizedBox(height: 70),
          const Icon(
            Icons.person_search_outlined,
            size: 64,
            color: AppColors.dark3,
          ),
          const SizedBox(height: 12),
          const Text(
            'Pasien tidak ditemukan',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.dark1,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ] else ...[
          Text(
            'HASIL PENCARIAN - ${filteredPatients.length} PASIEN',
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...filteredPatients.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _PatientCard(
                initial: item['initial']!,
                name: item['name']!,
                info: item['info']!,
                relation: item['relation']!,
                status: item['status']!,
                date: item['date']!,
                showButton: item['status'] == 'Belum Terhubung',
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _searchBox() {
    final keyword = searchCtr.text.trim();

    return TextField(
      controller: searchCtr,
      decoration: InputDecoration(
        hintText: 'Cari nama pasien',
        hintStyle: const TextStyle(color: AppColors.dark3, fontSize: 12),
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.primaryBlue,
          size: 18,
        ),
        suffixIcon: keyword.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close, size: 18),
                color: AppColors.dark3,
                onPressed: () => searchCtr.clear(),
              )
            : null,
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _emptyPatient() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 38),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 38,
              backgroundColor: AppColors.lightBlue,
              child: Icon(
                Icons.person_search_outlined,
                color: AppColors.primaryBlue,
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Belum ada pasien terhubung',
              style: TextStyle(
                color: AppColors.dark1,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cari pasien dan ajukan permintaan koneksi agar pasien bisa menerima bantuan input data kesehatan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () => setState(() => selectedTab = 1),
              icon: const Icon(Icons.search, size: 16),
              label: const Text('Cari Pasien'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final String initial;
  final String name;
  final String info;
  final String relation;
  final String status;
  final String date;
  final bool showButton;

  const _PatientCard({
    required this.initial,
    required this.name,
    required this.info,
    required this.relation,
    required this.status,
    required this.date,
    required this.showButton,
  });

  @override
  Widget build(BuildContext context) {
    final isConnected = status == 'Terhubung';
    final isWaiting = status == 'Menunggu';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.light1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.lightBlue,
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: AppColors.dark1,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      info,
                      style: const TextStyle(
                        color: AppColors.dark2,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: [
                        _badge(
                          relation,
                          AppColors.veryLightBlue,
                          AppColors.primaryBlue,
                        ),
                        _badge(
                          status,
                          isConnected
                              ? const Color(0xFFEAFBF3)
                              : AppColors.veryLightBlue,
                          isConnected
                              ? const Color(0xFF10C878)
                              : AppColors.primaryBlue,
                          icon: isWaiting
                              ? Icons.access_time
                              : Icons.check_circle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.dark3),
            ],
          ),
          if (date.isNotEmpty) ...[
            const SizedBox(height: 10),
            _dateBox(date),
          ],
          if (showButton) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 140,
                height: 36,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Ajukan', style: TextStyle(fontSize: 12)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dateBox(String date) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            size: 12,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(width: 5),
          Text(
            date,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(
    String text,
    Color bg,
    Color textColor, {
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: textColor),
            const SizedBox(width: 3),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}