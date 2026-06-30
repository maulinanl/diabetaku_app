import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'patient_doctor_detail_page.dart';
import 'patient_caregiver_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/services/api_service.dart';

class PatientConnectionPage extends StatefulWidget {
  const PatientConnectionPage({super.key});

  @override
  State<PatientConnectionPage> createState() => _PatientConnectionPageState();
}

class _PatientConnectionPageState extends State<PatientConnectionPage> {
  int selectedTab = 0;
  bool isSearchMode = false;

  final searchCtr = TextEditingController();
  final tabs = ['Dokter', 'Pendamping', 'Permintaan'];

  bool isLoading = true;
  bool isSearching = false;
  String? errorMessage;

  List<Map<String, dynamic>> doctors = [];
  List<Map<String, dynamic>> caregivers = [];
  List<Map<String, dynamic>> requests = [];
  List<Map<String, dynamic>> searchedDoctors = [];

  String formatDate(String? value) {
    if (value == null || value.isEmpty) return '-';

    final date = DateTime.tryParse(value);

    if (date == null) return value;

    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void initState() {
    super.initState();
    _loadConnections();

    searchCtr.addListener(() {
      setState(() {});
      _searchDoctors();
    });
  }

  @override
  void dispose() {
    searchCtr.dispose();
    super.dispose();
  }

  String _initialFromName(String name) {
    final parts = name.trim().split(' ').where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '-';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Future<void> _loadConnections() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final patientId = prefs.getInt('patient_id');

      if (patientId == null) {
        throw Exception('Patient ID tidak ditemukan');
      }

      final doctorData = await ApiService.getConnectedDoctors(patientId);
      final caregiverData = await ApiService.getConnectedCaregivers(patientId);
      final requestData = await ApiService.getIncomingCaregiverRequests(patientId);

      if (!mounted) return;

      setState(() {
        doctors = doctorData;
        caregivers = caregiverData;
        requests = requestData;
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

  Future<void> _searchDoctors() async {
    final keyword = searchCtr.text.trim();

    if (keyword.isEmpty) {
      setState(() => searchedDoctors = []);
      return;
    }

    setState(() => isSearching = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final patientId = prefs.getInt('patient_id');

      if (patientId == null) {
        throw Exception('Patient ID tidak ditemukan');
      }

      final data = await ApiService.searchDoctors(
        patientId: patientId,
        keyword: keyword,
      );

      if (!mounted) return;

      setState(() {
        searchedDoctors = data;
        isSearching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isSearching = false);
    }
  }

  Future<bool> _showConfirmAction({
    required int caregiverId,
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
              ? 'Apakah kamu yakin ingin menerima $name sebagai pendamping?'
              : 'Apakah kamu yakin ingin menolak permintaan koneksi dari $name?',
          primaryText: isAccept ? 'Terima' : 'Tolak',
          primaryColor: isAccept ? AppColors.primaryBlue : AppColors.red,
          onPrimaryTap: () => Navigator.pop(context, true),
        );
      },
    );

    if (result != true) return false;

    final prefs = await SharedPreferences.getInstance();
    final patientId = prefs.getInt('patient_id')!;

    try {
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

      await _loadConnections();

      if (!mounted) return false;

      await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return _SuccessBottomSheet(
            title: isAccept ? 'Berhasil Diterima' : 'Berhasil Ditolak',
            message: isAccept
                ? '$name berhasil ditambahkan sebagai pendamping.'
                : 'Permintaan koneksi dari $name berhasil ditolak.',
          );
        },
      );

      return true;
    } catch (e) {
      if (!mounted) return false;
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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

  Widget _content() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

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
        title: 'PENDAMPING SAYA - ${caregivers.length} TERHUBUNG',
        data: caregivers,
        isDoctor: false,
      );
    }

    return _requestList();
  }

  Widget _header(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPad + 18, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: const Center(
        child: Text(
          'Koneksi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
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

  Widget _connectionList({
    required String title,
    required List<Map<String, dynamic>> data,
    required bool isDoctor,
  }) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          isDoctor
              ? 'Belum ada dokter yang terhubung'
              : 'Belum ada pendamping yang terhubung',
          style: const TextStyle(color: AppColors.dark2, fontSize: 13),
        ),
      );
    }

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
        ...data.map((item) {
          final name = isDoctor
              ? (item['doctor_name'] ?? item['full_name'] ?? '-').toString()
              : (item['caregiver_name'] ?? item['full_name'] ?? '-').toString();

          final info = isDoctor
              ? '${item['specialization_name'] ?? '-'} • ${item['institution'] ?? '-'}'
              : (item['relation_name'] ?? '-').toString();

          final initial = item['initial']?.toString() ?? _initialFromName(name);
          final rawStatus = item['status']?.toString() ?? 'Diterima';

          final status = rawStatus == 'Diterima' ? 'Terhubung' : rawStatus;
          final date = formatDate(
            item['connected_since']?.toString() ??
                item['connected_at']?.toString(),
          );

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _ConnectionCard(
              initial: initial,
              name: name,
              info: info,
              status: status,
              date: date,
              showVerified: isDoctor,
              onTap: () async {
                final changed = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => isDoctor
                        ? PatientDoctorDetailPage(
                            doctorId: int.parse(item['doctor_id'].toString()),
                            initial: initial,
                            name: name,
                            info: info,
                            status: status,
                            date: date,
                          )
                        : PatientCaregiverDetailPage(
                            caregiverId: int.parse(item['caregiver_id'].toString()),
                            initial: initial,
                            name: name,
                            relation: info,
                            date: date,
                          ),
                  ),
                );

                if (changed == true) {
                  await _loadConnections();
                  if (isSearchMode) await _searchDoctors();
                }
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _requestList() {
    if (requests.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada permintaan koneksi',
          style: TextStyle(color: AppColors.dark2, fontSize: 13),
        ),
      );
    }

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
        ...requests.map((item) {
          final caregiverId = int.tryParse(item['caregiver_id'].toString());

          if (caregiverId == null) {
            return const SizedBox();
          }

          final name = (item['caregiver_name'] ?? item['full_name'] ?? '-')
              .toString();

          final relation = (item['relation_name'] ?? '-').toString();
          final initial = item['initial']?.toString() ?? _initialFromName(name);
          final date = formatDate(item['requested_at']?.toString());
          final status = item['status']?.toString() ?? 'Menunggu';

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _RequestCard(
              initial: initial,
              name: name,
              info: 'Ingin terhubung sebagai $relation',
              time: date,
              onTap: () async {
                final changed = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PatientRequestDetailPage(
                      initial: initial,
                      name: name,
                      relation: relation,
                      time: '',
                      date: date,
                      initialStatus: status,
                      onAccept: () => _showConfirmAction(
                        caregiverId: caregiverId,
                        name: name,
                        isAccept: true,
                      ),
                      onReject: () => _showConfirmAction(
                        caregiverId: caregiverId,
                        name: name,
                        isAccept: false,
                      ),
                    ),
                  ),
                );

                if (changed == true) {
                  await _loadConnections();
                }
              },
              onAccept: () => _showConfirmAction(
                caregiverId: caregiverId,
                name: name,
                isAccept: true,
              ),
              onReject: () => _showConfirmAction(
                caregiverId: caregiverId,
                name: name,
                isAccept: false,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _searchDoctorContent() {
    final keyword = searchCtr.text.trim();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 120),
      children: [
        _searchBox(),
        const SizedBox(height: 24),

        if (keyword.isEmpty)
          _emptySearchDoctor()
        else if (isSearching)
          const Center(child: CircularProgressIndicator())
        else if (searchedDoctors.isEmpty)
          _doctorNotFound()
        else ...[
          Text(
            'HASIL PENCARIAN - ${searchedDoctors.length} DOKTER',
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          ...searchedDoctors.map((item) {
            final name = (item['doctor_name'] ?? item['full_name'] ?? '-')
                .toString();

            final info =
                '${item['specialization_name'] ?? '-'} • ${item['institution'] ?? '-'}';

            final initial =
                item['initial']?.toString() ?? _initialFromName(name);

            final rawStatus =
                item['connection_status']?.toString() ??
                item['status']?.toString() ??
                'Belum Terhubung';

            final status = rawStatus == 'Diterima' ? 'Terhubung' : rawStatus;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _SearchDoctorCard(
                initial: initial,
                name: name,
                info: info,
                status: status,
                date: '',
                onTap: () async {
                  final changed = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PatientDoctorDetailPage(
                        doctorId: int.parse(item['doctor_id'].toString()),
                        initial: initial,
                        name: name,
                        info: info,
                        status: status,
                        date: '',
                      ),
                    ),
                  );

                  if (changed == true) {
                    await _searchDoctors();
                    await _loadConnections();
                  }
                },
              ),
            );
          }),
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
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _emptySearchDoctor() {
    return const Column(
      children: [
        SizedBox(height: 70),
        Icon(Icons.search, size: 64, color: AppColors.dark3),
        SizedBox(height: 16),
        Text(
          'Cari Dokter',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue,
          ),
        ),
        SizedBox(height: 8),
        Text(
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                  borderRadius: BorderRadius.circular(12),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                  borderRadius: BorderRadius.circular(12),
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


class PatientRequestDetailPage extends StatefulWidget {
  final String initial;
  final String name;
  final String relation;
  final String time;
  final String date;
  final String initialStatus;
  final Future<bool> Function()? onAccept;
  final Future<bool> Function()? onReject;

  const PatientRequestDetailPage({
    super.key,
    required this.initial,
    required this.name,
    required this.relation,
    required this.time,
    required this.date,
    this.initialStatus = 'Menunggu',
    this.onAccept,
    this.onReject,
  });

  @override
  State<PatientRequestDetailPage> createState() => _PatientRequestDetailPageState();
}

class _PatientRequestDetailPageState extends State<PatientRequestDetailPage> {
  late String currentStatus;
  bool isProcessing = false;
  bool hasChanged = false;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.initialStatus;
  }

  String get _normalizedStatus => currentStatus.toLowerCase().trim();

  bool get isPending {
    return _normalizedStatus == 'menunggu' ||
        _normalizedStatus.contains('menunggu persetujuan');
  }

  bool get isAccepted {
    return _normalizedStatus == 'diterima' ||
        _normalizedStatus == 'terhubung' ||
        _normalizedStatus == 'disetujui';
  }

  bool get isRejected => _normalizedStatus == 'ditolak';

  String get statusLabel {
    if (isAccepted) return 'Diterima';
    if (isRejected) return 'Ditolak';
    return 'Menunggu persetujuan';
  }

  Color get statusColor {
    if (isRejected) return AppColors.red;
    return AppColors.primaryBlue;
  }

  Color get statusBg {
    if (isRejected) return AppColors.lightRed;
    return AppColors.lightBlue;
  }

  IconData get statusIcon {
    if (isAccepted) return Icons.check_circle_outline;
    if (isRejected) return Icons.cancel_outlined;
    return Icons.person_add_alt_1_rounded;
  }

  IconData get headerIcon {
    if (isAccepted) return Icons.check_circle_outline;
    if (isRejected) return Icons.cancel_outlined;
    return Icons.person_add_alt_1_rounded;
  }

  String get headerTitle {
    if (isAccepted) return 'Koneksi Pendamping Diterima';
    if (isRejected) return 'Koneksi Pendamping Ditolak';
    return 'Permintaan Koneksi';
  }

  String get headerDescription {
    if (isAccepted) return 'Permintaan koneksi diterima';
    if (isRejected) return 'Permintaan koneksi ditolak';
    return 'Permintaan koneksi baru';
  }

  String get _requestTimeText {
    final date = widget.date.trim();
    final time = widget.time.trim();

    if (date.isEmpty || date == '-') {
      return time.isEmpty ? '-' : time;
    }

    if (time.isEmpty || time == '-' || time == date || date.contains('•')) {
      return date;
    }

    return '$date • $time';
  }

  Future<void> _handleAction(bool accept) async {
    if (isProcessing) return;

    final action = accept ? widget.onAccept : widget.onReject;
    if (action == null) return;

    setState(() => isProcessing = true);

    final success = await action();

    if (!mounted) return;

    setState(() {
      isProcessing = false;

      if (success) {
        currentStatus = accept ? 'Diterima' : 'Ditolak';
        hasChanged = true;
      }
    });
  }

  void _closePage() {
    Navigator.pop(context, hasChanged);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _closePage();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _dataCaregiverCard(),
                      const SizedBox(height: 24),
                      if (isPending) ...[
                        _primaryButton(),
                        const SizedBox(height: 12),
                        _outlineButton(),
                      ] else
                        _processedStatusCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, topPad + 14, 16, 24),
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
                onPressed: isProcessing ? null : _closePage,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: Text(
                  headerTitle,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  radius: 24,
                  backgroundColor: statusBg,
                  child: Icon(headerIcon, color: statusColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        headerDescription,
                        style: const TextStyle(
                          color: AppColors.dark1,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _requestTimeText,
                        style: const TextStyle(
                          color: AppColors.dark2,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dataCaregiverCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          const Text(
            'Data Pendamping',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 14),
          _DetailRow(label: 'Nama', value: widget.name),
          _DetailRow(label: 'Hubungan', value: widget.relation),
          _DetailRow(label: 'Status', value: statusLabel),
          const _DetailRow(label: 'Akses', value: 'Pendamping pasien'),
          _DetailRow(label: 'Waktu Permintaan', value: _requestTimeText),
        ],
      ),
    );
  }

  Widget _processedStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: statusBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(statusIcon, color: statusColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isAccepted
                  ? 'Permintaan koneksi pendamping ini sudah diterima. Pendamping sudah menjadi pendamping pasien.'
                  : 'Permintaan koneksi pendamping ini sudah ditolak.',
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _primaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton.icon(
        onPressed: isProcessing ? null : () => _handleAction(true),
        icon: const Icon(Icons.check, size: 16),
        label: Text(isProcessing ? 'Memproses...' : 'Terima permintaan'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          disabledBackgroundColor: const Color(0xFFAFCBEA),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _outlineButton() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton.icon(
        onPressed: isProcessing ? null : () => _handleAction(false),
        icon: const Icon(Icons.close, size: 16),
        label: const Text('Tolak permintaan'),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.red,
          side: const BorderSide(color: AppColors.red),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
    final isConnected = status == 'Diterima' || status == 'Terhubung';
    final isWaiting = status == 'Menunggu' || status == 'Menunggu Persetujuan';

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
                            : isWaiting
                            ? const Color(0xFFFFF4C7)
                            : AppColors.veryLightBlue,
                        textColor: isConnected
                            ? const Color(0xFF10C878)
                            : isWaiting
                            ? Colors.orange
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
    final isConnected = status == 'Diterima' || status == 'Terhubung';
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
                            : isWaiting
                            ? Colors.orange
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
