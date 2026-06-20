import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';
import '../widgets/family_bottom_nav.dart';
import 'family_add_data_page.dart';
import 'family_connection_page.dart';
import 'family_history_page.dart';
import 'family_notification_page.dart';
import 'family_profile_page.dart';

class FamilyMainPage extends StatefulWidget {
  const FamilyMainPage({super.key});

  @override
  State<FamilyMainPage> createState() => _FamilyMainPageState();
}

class _FamilyMainPageState extends State<FamilyMainPage> {
  int currentIndex = 0;
  int selectedPatientIndex = 0;

  bool isLoading = true;
  bool hasUnreadNotification = false;
  String? errorMessage;

  int? familyId;
  String familyName = '-';

  List<Map<String, dynamic>> patients = [];
  Map<String, dynamic>? dashboardData;
  List<Map<String, dynamic>> recommendations = [];

  final dailyChecks = const [
    ['Glukosa', Icons.opacity, true],
    ['Obat', Icons.medication_outlined, true],
    ['Aktivitas', Icons.directions_run, false],
    ['Makan', Icons.restaurant_outlined, false],
  ];

  DateTime currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime selectedDate = DateTime.now();

  final Map<String, String> consistencyStatus = {
    '2025-06-01': 'lengkap',
    '2025-06-02': 'lengkap',
    '2025-06-03': 'lengkap',
    '2025-06-04': 'lengkap',
    '2025-06-05': 'sebagian',
    '2025-06-06': 'lengkap',
    '2025-06-07': 'lengkap',
  };

  @override
  void initState() {
    super.initState();
    _loadFamilyHome();
  }

  List<Map<String, dynamic>> _acceptedPatientsOnly(
    List<Map<String, dynamic>> data,
  ) {
    return data.where((item) {
      final status = item['status']?.toString();
      return status == 'Diterima' || status == 'Terhubung';
    }).toList();
  }

  Future<void> _loadFamilyHome() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedFamilyId = prefs.getInt('family_id');
      final storedUserId = prefs.getInt('user_id');
      final storedName = prefs.getString('full_name') ?? '-';

      if (storedFamilyId == null) {
        throw Exception('Family ID tidak ditemukan. Coba login ulang.');
      }

      final profile = await ApiService.getFamilyProfile(storedFamilyId);
      final rawPatients = await ApiService.getFamilyPatients(storedFamilyId);
      final acceptedPatients = _acceptedPatientsOnly(rawPatients);

      Map<String, dynamic>? dashboard;
      List<Map<String, dynamic>> loadedRecommendations = [];
      List<Map<String, dynamic>> loadedNotifications = [];

      if (acceptedPatients.isNotEmpty) {
        final firstPatientId = int.parse(
          acceptedPatients.first['patient_id'].toString(),
        );

        dashboard = await ApiService.getFamilyPatientDashboard(firstPatientId);

        loadedRecommendations =
            await ApiService.getFamilyPatientRecommendations(firstPatientId);
      }

      if (storedUserId != null) {
        loadedNotifications = await ApiService.getNotifications(storedUserId);
      }

      if (!mounted) return;

      setState(() {
        familyId = storedFamilyId;
        familyName = profile['full_name']?.toString() ?? storedName;
        patients = acceptedPatients;
        dashboardData = dashboard;
        recommendations = loadedRecommendations;
        selectedPatientIndex = 0;

        hasUnreadNotification = loadedNotifications.any((n) {
          final isRead = n['is_read'];
          return isRead == false || isRead == 0 || isRead?.toString() == '0';
        });

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

  Future<void> _loadSelectedPatientDashboard(int index) async {
    final patientId = int.parse(patients[index]['patient_id'].toString());

    final dashboard = await ApiService.getFamilyPatientDashboard(patientId);

    final loadedRecommendations =
        await ApiService.getFamilyPatientRecommendations(patientId);

    if (!mounted) return;

    setState(() {
      selectedPatientIndex = index;
      dashboardData = dashboard;
      recommendations = loadedRecommendations;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: _buildPage(),
      bottomNavigationBar: FamilyBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
        onAddTap: () {
          setState(() => currentIndex = 4);
        },
      ),
    );
  }

  Widget _buildPage() {
    if (currentIndex == 0) return _familyHomeContent();
    if (currentIndex == 1) return const FamilyConnectionPage();
    if (currentIndex == 2) return const FamilyHistoryPage();
    if (currentIndex == 3) return const FamilyProfilePage();

    return FamilyAddDataPage(
      showBackButton: false,
      onGoConnection: () {
        setState(() => currentIndex = 1);
      },
    );
  }

  Widget _familyHomeContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return _errorState();
    }

    if (patients.isEmpty) {
      return _emptyPatientState();
    }

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
                child: RefreshIndicator(
                  onRefresh: _loadFamilyHome,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
                    child: Column(
                      children: [
                        _recommendationCard(),
                        const SizedBox(height: 12),
                        _validationCard(),
                        const SizedBox(height: 14),
                        _summaryCards(),
                        const SizedBox(height: 14),
                        _dailyChecklistCard(),
                        const SizedBox(height: 14),
                        _calendarCard(),
                      ],
                    ),
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
              errorMessage ?? 'Gagal memuat data keluarga',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.dark2, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFamilyHome,
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

  Widget _emptyPatientState() {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _emptyHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 42, 24, 120),
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: AppColors.veryLightBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 56,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 26),
                    const Text(
                      'Belum Ada Pasien Terhubung',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Hubungkan akun keluarga dengan pasien agar kamu bisa membantu memantau data kesehatannya.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.dark2,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() => currentIndex = 1);
                        },
                        icon: const Icon(Icons.person_add_alt_1_rounded),
                        label: const Text(
                          'Ajukan Koneksi Pasien',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
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

  Widget _emptyHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(22, topPad + 24, 22, 22),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$greeting\n$familyName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _notificationButton(),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.family_restroom_rounded,
                    color: AppColors.primaryBlue,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Akun Keluarga',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Belum ada pasien yang terhubung',
                        style: TextStyle(color: Colors.white, fontSize: 11),
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

  Widget _notificationButton() {
    return GestureDetector(
      onTap: () {
        setState(() => hasUnreadNotification = false);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FamilyNotificationPage()),
        ).then((_) => _loadFamilyHome());
      },
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
    );
  }

  String get greeting {
    final hour = DateTime.now().hour;

    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';

    return 'Selamat Malam';
  }

  String _initial(String name) {
    final parts = name.trim().split(' ').where((e) => e.isNotEmpty).toList();

    if (parts.isEmpty) return '-';
    if (parts.length == 1) return parts.first[0].toUpperCase();

    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String _patientName(Map<String, dynamic> patient) {
    return patient['full_name']?.toString() ??
        patient['name']?.toString() ??
        '-';
  }

  String _patientRelation(Map<String, dynamic> patient) {
    return patient['relation_name']?.toString() ??
        patient['relation']?.toString() ??
        '-';
  }

  String _patientDm(Map<String, dynamic> patient) {
    return patient['diabetes_type']?.toString() ?? '-';
  }

  Widget _header(BuildContext context) {
    final patient = patients[selectedPatientIndex];
    final patientName = _patientName(patient);
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(22, topPad + 24, 22, 22),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$greeting\n$familyName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _notificationButton(),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.lightBlue,
                  child: Text(
                    _initial(patientName),
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${_patientRelation(patient)} • ${_patientDm(patient)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (patients.length > 1)
                  OutlinedButton.icon(
                    onPressed: _showPatientSelector,
                    icon: const Icon(Icons.swap_horiz, size: 15),
                    label: const Text('Ganti'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.dark1,
                      backgroundColor: AppColors.lightBlue,
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPatientSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.light1,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Pilih pasien yang ingin dilihat',
                style: TextStyle(
                  color: AppColors.dark1,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(patients.length, (index) {
                final patient = patients[index];
                final name = _patientName(patient);
                final selected = selectedPatientIndex == index;

                return InkWell(
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _loadSelectedPatientDashboard(index);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: selected
                              ? AppColors.primaryBlue
                              : AppColors.lightBlue,
                          child: Text(
                            _initial(name),
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  color: AppColors.dark1,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${_patientRelation(patient)} • ${_patientDm(patient)}',
                                style: const TextStyle(
                                  color: AppColors.dark2,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: AppColors.primaryBlue,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _recommendationCard() {
    if (recommendations.isEmpty) {
      return _smallInfoCard(
        icon: Icons.description_outlined,
        title: 'Belum ada rekomendasi',
        subtitle: 'Dokter belum memberikan rekomendasi',
        onTap: () {},
      );
    }

    final latest = recommendations.first;

    return _smallInfoCard(
      icon: Icons.description_outlined,
      title: latest['category']?.toString() ?? 'Rekomendasi',
      subtitle: latest['recommendation_text']?.toString() ?? '-',
      onTap: () {},
    );
  }

  Widget _validationCard() {
    return _smallInfoCard(
      icon: Icons.assignment_outlined,
      title: 'Validasi data pasien',
      subtitle: 'Data yang kamu input menunggu konfirmasi pasien',
      onTap: () {},
    );
  }

  Widget _smallInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.veryLightBlue,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: AppColors.primaryBlue, size: 19),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.dark2,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.dark3),
          ],
        ),
      ),
    );
  }

  Widget _summaryCards() {
    final latestGlucose =
        dashboardData?['latest_glucose'] as Map<String, dynamic>?;

    final latestPhysiological =
        dashboardData?['latest_physiological'] as Map<String, dynamic>?;

    final glucoseValue = latestGlucose?['glucose_value']?.toString() ?? '-';

    final systolic = latestPhysiological?['systolic']?.toString();
    final diastolic = latestPhysiological?['diastolic']?.toString();

    final bloodPressureValue = systolic != null && diastolic != null
        ? '$systolic/$diastolic'
        : '-';

    final weightValue = latestPhysiological?['weight_kg']?.toString() ?? '-';

    return Row(
      children: [
        Expanded(
          child: _HealthSummaryCard(
            title: 'Glukosa',
            value: glucoseValue,
            unit: 'mg/dL',
            status: _glucoseStatus(glucoseValue),
            color: _glucoseColor(glucoseValue),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _HealthSummaryCard(
            title: 'Tekanan Darah',
            value: bloodPressureValue,
            unit: 'mmHg',
            status: bloodPressureValue == '-' ? '-' : 'Normal',
            color: const Color(0xFF10C878),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _HealthSummaryCard(
            title: 'Berat Badan',
            value: weightValue,
            unit: 'kg',
            status: weightValue == '-' ? '-' : 'Stabil',
            color: const Color(0xFFFFC542),
          ),
        ),
      ],
    );
  }

  String _glucoseStatus(String value) {
    final glucose = double.tryParse(value);

    if (glucose == null) return '-';
    if (glucose > 180) return 'Tinggi';
    if (glucose < 70) return 'Rendah';

    return 'Normal';
  }

  Color _glucoseColor(String value) {
    final status = _glucoseStatus(value);

    if (status == 'Normal') return const Color(0xFF10C878);
    if (status == '-') return AppColors.dark3;

    return AppColors.red;
  }

  Widget _dailyChecklistCard() {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Kepatuhan pasien — Hari ini',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '2 / 4 selesai',
                  style: TextStyle(color: AppColors.primaryBlue, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            height: 3,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.light1,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dailyChecks.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 3.2,
            ),
            itemBuilder: (context, index) {
              final item = dailyChecks[index];
              final isDone = item[2] as bool;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.light1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.veryLightBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        item[1] as IconData,
                        color: AppColors.primaryBlue,
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item[0] as String,
                        style: const TextStyle(
                          color: AppColors.dark1,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      isDone
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isDone ? AppColors.primaryBlue : AppColors.dark4,
                      size: 18,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  int _daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  String _monthName(int month) {
    const names = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return names[month - 1];
  }

  Widget _calendarCard() {
    final year = currentMonth.year;
    final month = currentMonth.month;
    final totalDays = _daysInMonth(currentMonth);
    final firstDay = DateTime(year, month, 1);
    final startOffset = firstDay.weekday - 1;
    final totalCells = startOffset + totalDays;
    final rowCount = (totalCells / 7).ceil();
    final cellCount = rowCount * 7;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Konsistensi Pelaporan — ${_monthName(month)} $year',
                  style: const TextStyle(
                    color: AppColors.dark1,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() => currentMonth = DateTime(year, month - 1));
                },
                child: _smallArrow(Icons.chevron_left),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  setState(() => currentMonth = DateTime(year, month + 1));
                },
                child: _smallArrow(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 26),
          const Row(
            children: [
              _WeekLabel('Sen'),
              _WeekLabel('Sel'),
              _WeekLabel('Rab'),
              _WeekLabel('Kam'),
              _WeekLabel('Jum'),
              _WeekLabel('Sab'),
              _WeekLabel('Min'),
            ],
          ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cellCount,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 14,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final dayNumber = index - startOffset + 1;

              if (dayNumber < 1 || dayNumber > totalDays) {
                return const SizedBox();
              }

              final date = DateTime(year, month, dayNumber);
              final status = consistencyStatus[_dateKey(date)];

              final isSelected =
                  date.year == selectedDate.year &&
                  date.month == selectedDate.month &&
                  date.day == selectedDate.day;

              if (status == 'lengkap') {
                final prevStatus =
                    consistencyStatus[_dateKey(
                      date.subtract(const Duration(days: 1)),
                    )];

                final nextStatus =
                    consistencyStatus[_dateKey(
                      date.add(const Duration(days: 1)),
                    )];

                final baseDay = _calendarRangeDay(
                  text: '$dayNumber',
                  color: const Color(0xFFEAFBF3),
                  textColor: AppColors.primaryBlue,
                  connectLeft: prevStatus == 'lengkap',
                  connectRight: nextStatus == 'lengkap',
                );

                if (isSelected) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      baseDay,
                      _calendarOutlineDay(text: '$dayNumber'),
                    ],
                  );
                }

                return baseDay;
              }

              if (status == 'sebagian') {
                return _calendarCircle(
                  text: '$dayNumber',
                  color: const Color(0xFFFFF4C7),
                  textColor: AppColors.primaryBlue,
                );
              }

              if (status == 'tidak') {
                return _calendarCircle(
                  text: '$dayNumber',
                  color: const Color(0xFFFFF3F3),
                  textColor: AppColors.red,
                );
              }

              if (isSelected) return _calendarOutlineDay(text: '$dayNumber');

              return Center(
                child: Text(
                  '$dayNumber',
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 22),
          const Row(
            children: [
              _Legend(color: Color(0xFFEAFBF3), label: 'Lengkap'),
              SizedBox(width: 18),
              _Legend(color: Color(0xFFFFF4C7), label: 'Sebagian'),
              SizedBox(width: 18),
              _Legend(color: Color(0xFFFFF3F3), label: 'Tidak ada'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _calendarRangeDay({
    required String text,
    required Color color,
    required Color textColor,
    required bool connectLeft,
    required bool connectRight,
  }) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.horizontal(
          left: connectLeft ? Radius.zero : const Radius.circular(28),
          right: connectRight ? Radius.zero : const Radius.circular(28),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _calendarOutlineDay({required String text}) {
    return Center(
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primaryBlue, width: 2),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _calendarCircle({
    required String text,
    required Color color,
    required Color textColor,
  }) {
    return Center(
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _smallArrow(IconData icon) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.light1),
      ),
      child: Icon(icon, color: AppColors.dark2, size: 18),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.light1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}

class _HealthSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final String status;
  final Color color;

  const _HealthSummaryCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 9)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(unit, style: const TextStyle(color: Colors.white, fontSize: 9)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.circle, color: color, size: 7),
              const SizedBox(width: 4),
              Text(
                status,
                style: const TextStyle(color: Colors.white, fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekLabel extends StatelessWidget {
  final String text;

  const _WeekLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: AppColors.dark1, fontSize: 11),
        ),
      ],
    );
  }
}
