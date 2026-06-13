import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'patient_doctor_detail_page.dart';
import 'patient_family_detail_page.dart';

class PatientConnectionPage extends StatefulWidget {
  const PatientConnectionPage({super.key});

  @override
  State<PatientConnectionPage> createState() => _PatientConnectionPageState();
}

class _PatientConnectionPageState extends State<PatientConnectionPage> {
  int selectedTab = 0;
  bool isSearchMode = false;

  final searchCtr = TextEditingController();

  final tabs = ['Dokter', 'Keluarga', 'Permintaan'];

  final doctors = [
    {
      'initial': 'AS',
      'name': 'dr. Agus Setiawan, Sp.PD',
      'info': 'Penyakit Dalam • RS Cipto Mangunkusumo',
      'status': 'Terhubung',
      'date': 'Sejak 1 Jan 2025',
    },
    {
      'initial': 'SK',
      'name': 'dr. Sarah Kumalasari, Sp.PD',
      'info': 'Endokrinologi • RS Fatmawati',
      'status': 'Terhubung',
      'date': 'Sejak 5 Mar 2025',
    },
  ];

  final families = [
    {
      'initial': 'KP',
      'name': 'Kartika Putri Citra',
      'info': 'Istri',
      'status': 'Terhubung',
      'date': 'Sejak 10 Jun 2025',
    },
    {
      'initial': 'AY',
      'name': 'Aditya Yoga Saputra',
      'info': 'Anak',
      'status': 'Terhubung',
      'date': 'Sejak 7 Jun 2025',
    },
  ];

  final requests = [
    {
      'initial': 'YT',
      'name': 'Yoanda Tri Setyani',
      'info': 'Ingin terhubung sebagai Kakak',
      'relation': 'Kakak',
      'time': '30 menit lalu',
      'date': '7 Jun 2025 • 08:30',
    },
    {
      'initial': 'MP',
      'name': 'Maya Putri Sari',
      'info': 'Ingin terhubung sebagai Adik',
      'relation': 'Adik',
      'time': '2 jam lalu',
      'date': '7 Jun 2025 • 07:15',
    },
  ];

  final searchDoctors = [
    {
      'initial': 'SP',
      'name': 'dr. Sarwo Puja, Sp.PD',
      'info': 'Penyakit Dalam • RS Cipto Mangunkusumo',
      'status': 'Terhubung',
      'date': 'Sejak 1 Jan 2025',
    },
    {
      'initial': 'SD',
      'name': 'dr. Santika Dwi Astuti',
      'info': 'Endokrinologi • RS Fatmawati',
      'status': 'Menunggu',
      'date': '',
    },
    {
      'initial': 'SK',
      'name': 'dr. Sarah Kumalasari, Sp.PD',
      'info': 'Endokrinologi • RS Fatmawati',
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

  Future<void> _showConfirmAction({
    required String name,
    required bool isAccept,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ActionBottomSheet(
          title: isAccept ? 'Terima Permintaan?' : 'Tolak Permintaan?',
          message: isAccept
              ? 'Apakah kamu yakin ingin menerima $name sebagai keluarga pendamping?'
              : 'Apakah kamu yakin ingin menolak permintaan koneksi dari $name?',
          primaryText: isAccept ? 'Terima' : 'Tolak',
          primaryColor: isAccept ? AppColors.primaryBlue : AppColors.red,
          onPrimaryTap: () => Navigator.pop(context, true),
        );
      },
    );

    if (result == true && mounted) {
      await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return _SuccessBottomSheet(
            title: isAccept ? 'Berhasil Diterima' : 'Berhasil Ditolak',
            message: isAccept
                ? '$name berhasil ditambahkan sebagai keluarga pendamping.'
                : 'Permintaan koneksi dari $name berhasil ditolak.',
          );
        },
      );
    }
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
                    Expanded(child: _content()),
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
      child: Row(
        children: [
          ...List.generate(tabs.length, (index) {
            final selected = !isSearchMode && selectedTab == index;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTab = index;
                    isSearchMode = false;
                  });
                },
                child: Container(
                  height: 34,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryBlue : AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected
                          ? AppColors.primaryBlue
                          : AppColors.light1,
                    ),
                  ),
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.primaryBlue,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => setState(() => isSearchMode = true),
            child: Container(
              width: 30,
              height: 34,
              decoration: BoxDecoration(
                color: isSearchMode ? AppColors.primaryBlue : AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSearchMode
                      ? AppColors.primaryBlue
                      : AppColors.light1,
                ),
              ),
              child: Icon(
                Icons.search,
                size: 16,
                color: isSearchMode ? Colors.white : AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content() {
    if (isSearchMode) return _searchDoctorContent();

    if (selectedTab == 0) {
      return _connectionList(
        title: 'DOKTER SAYA - ${doctors.length} TERHUBUNG',
        data: doctors,
        isDoctor: true,
      );
    }

    if (selectedTab == 1) {
      return _connectionList(
        title: 'KELUARGA SAYA - ${families.length} TERHUBUNG',
        data: families,
        isDoctor: false,
      );
    }

    return _requestList();
  }

  Widget _connectionList({
    required String title,
    required List<Map<String, String>> data,
    required bool isDoctor,
  }) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 120),
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...data.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _ConnectionCard(
              initial: item['initial']!,
              name: item['name']!,
              info: item['info']!,
              status: item['status']!,
              date: item['date']!,
              showVerified: isDoctor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => isDoctor
                        ? PatientDoctorDetailPage(
                            initial: item['initial']!,
                            name: item['name']!,
                            info: item['info']!,
                            status: item['status']!,
                            date: item['date']!,
                          )
                        : PatientFamilyDetailPage(
                            initial: item['initial']!,
                            name: item['name']!,
                            relation: item['info']!,
                            date: item['date']!,
                          ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _requestList() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 120),
      children: [
        Text(
          'PERMINTAAN MASUK - ${requests.length}',
          style: const TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...requests.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _RequestCard(
              initial: item['initial']!,
              name: item['name']!,
              info: item['info']!,
              time: item['time']!,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PatientRequestDetailPage(
                      initial: item['initial']!,
                      name: item['name']!,
                      relation: item['relation']!,
                      time: item['time']!,
                      date: item['date']!,
                      onAccept: () => _showConfirmAction(
                        name: item['name']!,
                        isAccept: true,
                      ),
                      onReject: () => _showConfirmAction(
                        name: item['name']!,
                        isAccept: false,
                      ),
                    ),
                  ),
                );
              },
              onAccept: () =>
                  _showConfirmAction(name: item['name']!, isAccept: true),
              onReject: () =>
                  _showConfirmAction(name: item['name']!, isAccept: false),
            ),
          ),
        ),
      ],
    );
  }

  Widget _searchDoctorContent() {
    final keyword = searchCtr.text.trim().toLowerCase();

    final filteredDoctors = keyword.isEmpty
        ? <Map<String, String>>[]
        : searchDoctors.where((doctor) {
            return doctor['name']!.toLowerCase().contains(keyword) ||
                doctor['info']!.toLowerCase().contains(keyword) ||
                doctor['status']!.toLowerCase().contains(keyword);
          }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 120),
      children: [
        _searchBox(),
        const SizedBox(height: 24),
        if (keyword.isEmpty)
          _emptySearchDoctor()
        else if (filteredDoctors.isEmpty)
          _doctorNotFound()
        else ...[
          Text(
            'HASIL PENCARIAN - ${filteredDoctors.length} DOKTER',
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...filteredDoctors.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _SearchDoctorCard(
                initial: item['initial']!,
                name: item['name']!,
                info: item['info']!,
                status: item['status']!,
                date: item['date']!,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PatientDoctorDetailPage(
                        initial: item['initial']!,
                        name: item['name']!,
                        info: item['info']!,
                        status: item['status']!,
                        date: item['date']!,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _searchBox() {
    return TextField(
      controller: searchCtr,
      decoration: InputDecoration(
        hintText: 'Cari nama dokter',
        hintStyle: const TextStyle(color: AppColors.dark3, fontSize: 12),
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.primaryBlue,
          size: 18,
        ),
        suffixIcon: searchCtr.text.trim().isNotEmpty
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

  Widget _emptySearchDoctor() {
    return Column(
      children: [
        const SizedBox(height: 70),
        Icon(
          Icons.search,
          size: 64,
          color: AppColors.primaryBlue.withOpacity(0.4),
        ),
        const SizedBox(height: 16),
        const Text(
          'Cari Dokter',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Masukkan nama dokter, spesialisasi, atau rumah sakit untuk mencari dokter.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: AppColors.dark2),
        ),
      ],
    );
  }

  Widget _doctorNotFound() {
    return const Column(
      children: [
        SizedBox(height: 60),
        Icon(Icons.person_search_outlined, size: 64, color: AppColors.dark3),
        SizedBox(height: 12),
        Text(
          'Dokter tidak ditemukan',
          style: TextStyle(
            color: AppColors.dark1,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ActionBottomSheet extends StatelessWidget {
  final String title;
  final String message;
  final String primaryText;
  final Color primaryColor;
  final VoidCallback onPrimaryTap;

  const _ActionBottomSheet({
    required this.title,
    required this.message,
    required this.primaryText,
    required this.primaryColor,
    required this.onPrimaryTap,
  });

  @override
  Widget build(BuildContext context) {
    final isReject = primaryColor == AppColors.red;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: isReject
                ? AppColors.lightRed
                : AppColors.lightBlue,
            child: Icon(
              isReject ? Icons.close_rounded : Icons.check_rounded,
              color: isReject ? AppColors.red : AppColors.primaryBlue,
              size: 34,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.dark2,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: onPrimaryTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(primaryText),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessBottomSheet extends StatelessWidget {
  final String title;
  final String message;

  const _SuccessBottomSheet({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    final isReject = title.toLowerCase().contains('ditolak');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: isReject
                ? AppColors.lightRed
                : const Color(0xFFEAFBF3),
            child: Icon(
              isReject ? Icons.close_rounded : Icons.check_circle_rounded,
              color: isReject ? AppColors.red : const Color(0xFF10C878),
              size: 34,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.dark2,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final String initial;
  final String name;
  final String info;
  final String time;
  final VoidCallback onTap;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _RequestCard({
    required this.initial,
    required this.name,
    required this.info,
    required this.time,
    required this.onTap,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: _cardDecoration(),
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
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        info,
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: AppColors.dark3),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: ElevatedButton.icon(
                      onPressed: onAccept,
                      icon: const Icon(Icons.check, size: 14),
                      label: const Text('Terima'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: OutlinedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close, size: 14),
                      label: const Text('Tolak'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.red,
                        side: const BorderSide(color: AppColors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
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
    );
  }
}

class PatientRequestDetailPage extends StatelessWidget {
  final String initial;
  final String name;
  final String relation;
  final String time;
  final String date;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const PatientRequestDetailPage({
    super.key,
    required this.initial,
    required this.name,
    required this.relation,
    required this.time,
    required this.date,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _dataFamilyCard(),
                      const SizedBox(height: 24),
                      _primaryButton(),
                      const SizedBox(height: 12),
                      _outlineButton(),
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

  Widget _buildHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 24),
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
                  'Permintaan Koneksi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 14),
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
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Permintaan koneksi keluarga\n$date\n$time',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dataFamilyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.light1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Data Keluarga',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          _DetailRow(label: 'Nama', value: name),
          _DetailRow(label: 'Hubungan', value: relation),
          const _DetailRow(label: 'Status', value: 'Menunggu persetujuan'),
          const _DetailRow(label: 'Akses', value: 'Pendamping pasien'),
        ],
      ),
    );
  }

  Widget _primaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton.icon(
        onPressed: onAccept,
        icon: const Icon(Icons.check, size: 16),
        label: const Text('Terima permintaan'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  Widget _outlineButton() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton.icon(
        onPressed: onReject,
        icon: const Icon(Icons.close, size: 16),
        label: const Text('Tolak permintaan'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.red,
          side: const BorderSide(color: AppColors.red),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  final String initial;
  final String name;
  final String info;
  final String status;
  final String date;
  final bool showVerified;
  final VoidCallback? onTap;

  const _ConnectionCard({
    required this.initial,
    required this.name,
    required this.info,
    required this.status,
    required this.date,
    required this.showVerified,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isConnected = status == 'Terhubung';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: _cardDecoration(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
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
                    runSpacing: 6,
                    children: [
                      if (showVerified)
                        _statusBadge(
                          text: 'Terverifikasi',
                          bg: AppColors.veryLightBlue,
                          textColor: AppColors.primaryBlue,
                          icon: Icons.verified,
                        ),
                      _statusBadge(
                        text: status,
                        bg: isConnected
                            ? const Color(0xFFEAFBF3)
                            : AppColors.veryLightBlue,
                        textColor: isConnected
                            ? const Color(0xFF10C878)
                            : AppColors.primaryBlue,
                        icon: isConnected
                            ? Icons.check_circle
                            : Icons.access_time,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _dateBox(date),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Padding(
              padding: EdgeInsets.only(top: 30),
              child: Icon(Icons.chevron_right, color: AppColors.dark3),
            ),
          ],
        ),
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

  Widget _statusBadge({
    required String text,
    required Color bg,
    required Color textColor,
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
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
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
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
          Text(
            value,
            style: const TextStyle(color: AppColors.dark1, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SearchDoctorCard extends StatelessWidget {
  final String initial;
  final String name;
  final String info;
  final String status;
  final String date;
  final VoidCallback onTap;

  const _SearchDoctorCard({
    required this.initial,
    required this.name,
    required this.info,
    required this.status,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isConnected = status == 'Terhubung';
    final isWaiting = status == 'Menunggu';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
        child: Row(
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
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
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
                    runSpacing: 6,
                    children: [
                      _statusBadge(
                        text: 'Terverifikasi',
                        bg: AppColors.veryLightBlue,
                        textColor: AppColors.primaryBlue,
                        icon: Icons.verified,
                      ),
                      _statusBadge(
                        text: status,
                        bg: isConnected
                            ? const Color(0xFFEAFBF3)
                            : isWaiting
                            ? const Color(0xFFFFF4C7)
                            : AppColors.veryLightBlue,
                        textColor: isConnected
                            ? const Color(0xFF10C878)
                            : AppColors.primaryBlue,
                        icon: isConnected
                            ? Icons.check_circle
                            : Icons.access_time,
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

  Widget _statusBadge({
    required String text,
    required Color bg,
    required Color textColor,
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
