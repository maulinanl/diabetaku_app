import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/diabetes_type_badge.dart';
import 'doctor_connection_page.dart';
import 'doctor_history_page.dart';
import 'doctor_profile_page.dart';
import 'doctor_notification_page.dart';
import 'patient_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/services/api_service.dart';
import '../../../core/widgets/lazy_indexed_stack.dart';
import '../widgets/doctor_bottom_nav.dart';

class DoctorMainPage extends StatefulWidget {
  const DoctorMainPage({super.key});

  @override
  State<DoctorMainPage> createState() => _DoctorMainPageState();
}

class _DoctorMainPageState extends State<DoctorMainPage> {
  int currentIndex = 0;
  int? connectionInitialPatientId;
  int connectionPageRefreshKey = 0;

  void _openConnectionRequestFromNotification(int patientId) {
    setState(() {
      currentIndex = 1;
      connectionInitialPatientId = patientId;
      connectionPageRefreshKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DoctorHomeContent(
        onOpenConnectionRequest: _openConnectionRequestFromNotification,
      ),
      DoctorConnectionPage(
        key: ValueKey('doctor_connection_$connectionPageRefreshKey'),
        initialTab: 0,
        initialPatientId: connectionInitialPatientId,
        onInitialPatientHandled: () {
          connectionInitialPatientId = null;
        },
      ),
      const DoctorHistoryPage(),
      const DoctorProfilePage(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: false,
      body: LazyIndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: DoctorBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (currentIndex == index) return;
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}

class DoctorHomeContent extends StatefulWidget {
  final void Function(int patientId)? onOpenConnectionRequest;

  const DoctorHomeContent({
    super.key,
    this.onOpenConnectionRequest,
  });

  @override
  State<DoctorHomeContent> createState() => _DoctorHomeContentState();
}

class _DoctorHomeContentState extends State<DoctorHomeContent> {
  final TextEditingController _searchController = TextEditingController();

  String searchQuery = '';
  bool hasUnreadNotification = false;

  List<Map<String, dynamic>> patients = [];
  bool isLoading = true;
  String? errorMessage;

  String doctorName = '-';

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '-';

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
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

  String? _getBirthDate(Map<String, dynamic> patient) {
    return patient['date_of_birth']?.toString();
  }

  String _formatDiabetesType(dynamic value) {
    return formatDiabetesType(value);
  }

  bool _isPatientAbnormal(Map<String, dynamic> patient) {
    final abnormal = patient['is_abnormal'];
    final status = patient['status']?.toString().toLowerCase();

    return abnormal == true ||
        abnormal == 1 ||
        abnormal?.toString() == '1' ||
        abnormal?.toString().toLowerCase() == 'true' ||
        status == 'abnormal';
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => searchQuery = _searchController.text);
    });
    _loadDoctorName();
    _fetchPatients();
    _loadUnreadNotificationStatus();
  }

  bool _isReadNotification(Map<String, dynamic> item) {
    final value = item['is_read'];
    return value == true || value == 1 || value.toString() == '1';
  }

  Future<void> _loadUnreadNotificationStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) return;

      final data = await ApiService.getNotifications(userId);
      final hasUnread = data.any((item) => !_isReadNotification(item));

      if (!mounted) return;

      setState(() {
        hasUnreadNotification = hasUnread;
      });
    } catch (e) {
      debugPrint('GAGAL CEK NOTIFIKASI DOKTER: $e');
    }
  }

  Future<void> _openNotificationPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DoctorNotificationPage()),
    );

    if (!mounted) return;

    await _loadUnreadNotificationStatus();

    if (result is Map && result['action'] == 'open_connection_request') {
      final patientId = int.tryParse(result['patient_id'].toString());

      if (patientId != null) {
        widget.onOpenConnectionRequest?.call(patientId);
      }
    }
  }

  Future<void> _loadDoctorName() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      doctorName = prefs.getString('full_name') ?? '-';
    });
  }

  Future<void> _fetchPatients() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // sementara pakai doctor_id = 1 dulu
      // nanti kita rapikan supaya doctor_id disimpan dari login
      final doctorId = prefs.getInt('doctor_id') ?? 1;

      final data = await ApiService.getDoctorPatients(doctorId);

      setState(() {
        patients = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        color: AppColors.background,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

    final filteredPatients = patients.where((patient) {
      final name = (patient['full_name'] ?? '').toString().toLowerCase();
      final type = (patient['diabetes_type'] ?? '').toString().toLowerCase();

      return name.contains(searchQuery.toLowerCase()) ||
          type.contains(searchQuery.toLowerCase());
    }).toList();

    filteredPatients.sort((a, b) {
      final aStatus =
          a['relation_status']?.toString().toLowerCase() ?? 'diterima';
      final bStatus =
          b['relation_status']?.toString().toLowerCase() ?? 'diterima';

      final aConnected = aStatus == 'diterima';
      final bConnected = bStatus == 'diterima';

      if (aConnected != bConnected) {
        return aConnected ? -1 : 1;
      }

      final aAbnormal = _isPatientAbnormal(a);
      final bAbnormal = _isPatientAbnormal(b);

      if (aAbnormal != bAbnormal) {
        return aAbnormal ? -1 : 1;
      }

      final nameA = (a['full_name'] ?? '').toString().toLowerCase();
      final nameB = (b['full_name'] ?? '').toString().toLowerCase();

      return nameA.compareTo(nameB);
    });

    return Container(
      color: AppColors.background,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: Container(
                color: AppColors.background,
                child: patients.isEmpty
                    ? _emptyPatient()
                    : filteredPatients.isEmpty
                    ? _emptySearch()
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                        children: [
                          Text(
                            'DAFTAR PASIEN - ${filteredPatients.length} DATA',
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...filteredPatients.map((patient) {
                            final name =
                                patient['full_name']?.toString() ?? '-';
                            final gender = patient['gender']?.toString() ?? '-';
                            final birthDate = _getBirthDate(patient);
                            final age = _calculateAge(birthDate);
                            final type = _formatDiabetesType(
                              patient['diabetes_type'],
                            );
                            final initials = _getInitials(name);

                            final isAbnormal = _isPatientAbnormal(patient);
                            final status = isAbnormal ? 'Abnormal' : 'Normal';

                            final relationStatus =
                                patient['relation_status']
                                    ?.toString()
                                    .toLowerCase() ??
                                'diterima';

                            final isConnected = relationStatus == 'diterima';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _PatientCard(
                                initials: initials,
                                name: name,
                                info: '$age tahun • $gender',
                                type: type,
                                status: isConnected
                                    ? status
                                    : 'Tidak Terhubung',
                                isNormal: !isAbnormal,
                                isConnected: isConnected,
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PatientDetailPage(
                                        patientId: int.parse(
                                          patient['patient_id'].toString(),
                                        ),
                                        isConnected: isConnected,
                                      ),
                                    ),
                                  );

                                  if (result == true) {
                                    _fetchPatients();
                                  }
                                },
                              ),
                            );
                          }),
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
      padding: EdgeInsets.fromLTRB(24, topPad + 28, 24, 32),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selamat Pagi, semangat hari ini!',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      doctorName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _openNotificationPage,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    if (hasUnreadNotification)
                      Positioned(
                        top: 9,
                        right: 9,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: AppColors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Cari nama pasien',
              hintStyle: const TextStyle(color: AppColors.dark3, fontSize: 12),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.primaryBlue,
                size: 18,
              ),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => searchQuery = '');
                      },
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.dark3,
                        size: 18,
                      ),
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptySearch() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 38),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 38,
              backgroundColor: AppColors.veryLightBlue,
              child: Icon(
                Icons.search_off,
                size: 42,
                color: AppColors.primaryBlue,
              ),
            ),
            SizedBox(height: 18),
            Text(
              'Pasien tidak ditemukan',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.dark1,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Coba gunakan nama pasien atau tipe diabetes lain.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.primaryBlue, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyPatient() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 38),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 38,
              backgroundColor: AppColors.veryLightBlue,
              child: Icon(
                Icons.people_alt_outlined,
                size: 42,
                color: AppColors.primaryBlue,
              ),
            ),
            SizedBox(height: 18),
            Text(
              'Belum Ada Pasien',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.dark1,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Pasien yang sudah terhubung akan muncul di halaman ini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.primaryBlue, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final String initials;
  final String name;
  final String info;
  final String type;
  final String status;
  final bool isNormal;
  final VoidCallback onTap;
  final bool isConnected;

  const _PatientCard({
    required this.initials,
    required this.name,
    required this.info,
    required this.type,
    required this.status,
    required this.isNormal,
    required this.onTap,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isNormal ? const Color(0xFF10C878) : AppColors.red;
    final statusBg = isNormal ? const Color(0xFFEAFBF3) : const Color(0xFFFFF4F4);

    final mainTextColor = isConnected ? AppColors.dark1 : AppColors.dark4;
    final subTextColor = isConnected ? AppColors.dark2 : AppColors.dark4;
    final avatarBg = isConnected ? AppColors.lightBlue : AppColors.light4;
    final avatarTextColor = isConnected
        ? AppColors.primaryBlue
        : AppColors.dark4;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: _cardDecoration(isNormal, isConnected),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: avatarBg,
              child: Text(
                initials,
                style: TextStyle(
                  color: avatarTextColor,
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
                    style: TextStyle(
                      color: mainTextColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    info,
                    style: TextStyle(color: subTextColor, fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      DiabetesTypeBadge(value: type, dense: true, inactive: !isConnected),
                      if (isConnected)
                        _statusBadge(
                          text: status,
                          bg: statusBg,
                          textColor: statusColor,
                          icon: isNormal
                              ? Icons.check_circle
                              : Icons.warning_amber_rounded,
                        )
                      else
                        _statusBadge(
                          text: 'Tidak Terhubung',
                          bg: AppColors.light4,
                          textColor: AppColors.dark4,
                          icon: Icons.link_off_rounded,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Padding(
              padding: EdgeInsets.only(top: 30),
              child: Icon(
                Icons.chevron_right,
                color: AppColors.dark4,
                size: 24,
              ),
            ),
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

  BoxDecoration _cardDecoration(bool isNormal, bool isConnected) {
    return BoxDecoration(
      color: !isConnected
          ? const Color(0xFFF1F3F5)
          : isNormal
              ? AppColors.white
              : const Color(0xFFFFFBFB),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: !isConnected
            ? AppColors.dark4.withValues(alpha: 0.22)
            : isNormal
                ? AppColors.light1
                : AppColors.red.withValues(alpha: 0.18),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: isConnected && !isNormal
              ? AppColors.red.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: isConnected ? 0.06 : 0.03),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

}
