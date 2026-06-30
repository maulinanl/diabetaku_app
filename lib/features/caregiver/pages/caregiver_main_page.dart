import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';
import '../widgets/caregiver_bottom_nav.dart';
import 'caregiver_add_data_page.dart';
import 'caregiver_connection_page.dart';
import 'caregiver_history_page.dart';
import 'caregiver_notification_page.dart';
import 'caregiver_profile_page.dart';

class CaregiverMainPage extends StatefulWidget {
  const CaregiverMainPage({super.key});

  @override
  State<CaregiverMainPage> createState() => _CaregiverMainPageState();
}

class _CaregiverMainPageState extends State<CaregiverMainPage> {
  int currentIndex = 0;
  int selectedPatientIndex = 0;

  bool isLoading = true;
  bool hasUnreadNotification = false;
  String? errorMessage;

  int? caregiverId;
  String caregiverName = '-';

  List<Map<String, dynamic>> patients = [];
  Map<String, dynamic>? dashboardData;
  List<Map<String, dynamic>> recommendations = [];
  List<Map<String, dynamic>> selectedPatientPrescriptions = [];
  int allPatientsActivePrescriptionCount = 0;
  Map<String, dynamic> healthHistories = {};
  List<Map<String, dynamic>> pendingValidations = [];

  DateTime currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime selectedDate = DateTime.now();

  final healthChecklistTypes = const [
    ['Glukosa', Icons.opacity, 'glucose'],
    ['Fisiologis', Icons.monitor_heart_outlined, 'physiological'],
    ['Aktivitas', Icons.directions_run, 'activity'],
    ['Makan', Icons.restaurant_outlined, 'meal'],
  ];

  @override
  void initState() {
    super.initState();
    _loadCaregiverHome();
  }

  List<Map<String, dynamic>> _acceptedPatientsOnly(
    List<Map<String, dynamic>> data,
  ) {
    return data.where((item) {
      final status = item['status']?.toString();
      return status == 'Diterima' || status == 'Terhubung';
    }).toList();
  }

  Future<void> _loadCaregiverHome() async {
  setState(() {
    isLoading = true;
    errorMessage = null;
  });

  try {
    final prefs = await SharedPreferences.getInstance();
    final storedCaregiverId = prefs.getInt('caregiver_id');
    final storedUserId = prefs.getInt('user_id');
    final storedName = prefs.getString('full_name') ?? '-';

    if (storedCaregiverId == null) {
      throw Exception('Caregiver ID tidak ditemukan. Coba login ulang.');
    }

    final baseResults = await Future.wait([
      ApiService.getCaregiverProfile(storedCaregiverId),
      ApiService.getCaregiverPatients(storedCaregiverId),
      if (storedUserId != null) ApiService.getNotifications(storedUserId),
    ]);

    final profile = baseResults[0] as Map<String, dynamic>;
    final rawPatients = List<Map<String, dynamic>>.from(baseResults[1] as List);
    final acceptedPatients = _acceptedPatientsOnly(rawPatients);

    Map<String, dynamic>? loadedDashboard;
    List<Map<String, dynamic>> loadedRecommendations = [];
    Map<String, dynamic> loadedHealthHistories = {};
    List<Map<String, dynamic>> loadedSelectedPrescriptions = [];
    int loadedAllPatientsPrescriptionCount = 0;
    List<Map<String, dynamic>> loadedNotifications = storedUserId != null
        ? List<Map<String, dynamic>>.from(baseResults[2] as List)
        : [];

    if (acceptedPatients.isNotEmpty) {
      final firstPatientId = int.parse(
        acceptedPatients.first['patient_id'].toString(),
      );

      final patientResults = await Future.wait([
        ApiService.getCaregiverPatientDashboard(firstPatientId),
        ApiService.getCaregiverPatientRecommendations(firstPatientId),
        ApiService.getCaregiverPatientHistories(firstPatientId),
        ApiService.getCaregiverPatientActivePrescriptions(firstPatientId),
      ]);

      loadedDashboard = patientResults[0] as Map<String, dynamic>;
      loadedRecommendations = List<Map<String, dynamic>>.from(
        patientResults[1] as List,
      );
      loadedHealthHistories = Map<String, dynamic>.from(
        patientResults[2] as Map,
      );
      loadedSelectedPrescriptions = List<Map<String, dynamic>>.from(
        patientResults[3] as List,
      );

      final activePrescriptionIds = <String>{};
      for (final patient in acceptedPatients) {
        final id = int.tryParse(patient['patient_id'].toString());
        if (id == null) continue;

        try {
          final prescriptions = await ApiService.getCaregiverPatientActivePrescriptions(id);
          for (final item in prescriptions) {
            final prescriptionId = item['prescription_id']?.toString();
            if (prescriptionId != null && prescriptionId.isNotEmpty) {
              activePrescriptionIds.add(prescriptionId);
            }
          }
        } catch (_) {}
      }

      loadedAllPatientsPrescriptionCount = activePrescriptionIds.length;
    }

    if (!mounted) return;

    setState(() {
      caregiverId = storedCaregiverId;
      caregiverName = profile['full_name']?.toString() ?? storedName;
      patients = acceptedPatients;
      dashboardData = loadedDashboard;
      recommendations = loadedRecommendations;
      healthHistories = loadedHealthHistories;
      selectedPatientPrescriptions = loadedSelectedPrescriptions;
      allPatientsActivePrescriptionCount = loadedAllPatientsPrescriptionCount;
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
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      isLoading = false;
    });
  }
}

Future<void> _loadSelectedPatientDashboard(int index) async {
  final patientId = int.parse(patients[index]['patient_id'].toString());

  final patientResults = await Future.wait([
    ApiService.getCaregiverPatientDashboard(patientId),
    ApiService.getCaregiverPatientRecommendations(patientId),
    ApiService.getCaregiverPatientHistories(patientId),
    ApiService.getCaregiverPatientActivePrescriptions(patientId),
  ]);

  if (!mounted) return;

  setState(() {
    selectedPatientIndex = index;
    dashboardData = patientResults[0] as Map<String, dynamic>;
    recommendations = List<Map<String, dynamic>>.from(patientResults[1] as List);
    healthHistories = Map<String, dynamic>.from(patientResults[2] as Map);
    selectedPatientPrescriptions = List<Map<String, dynamic>>.from(patientResults[3] as List);
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: _buildPage(),
      bottomNavigationBar: CaregiverBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        onAddTap: () => setState(() => currentIndex = 4),
      ),
    );
  }

  Widget _buildPage() {
    if (currentIndex == 0) return _CaregiverHomeContent();
    if (currentIndex == 1) return const CaregiverConnectionPage();
    if (currentIndex == 2) return const CaregiverHistoryPage();
    if (currentIndex == 3) return const CaregiverProfilePage();

    return CaregiverAddDataPage(
      showBackButton: false,
      onGoConnection: () => setState(() => currentIndex = 1),
    );
  }

  Widget _CaregiverHomeContent() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (errorMessage != null) return _errorState();
    if (patients.isEmpty) return _emptyPatientState();

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
                child: RefreshIndicator(
                  onRefresh: _loadCaregiverHome,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
                    child: Column(
                      children: [
                        _nextMedicationCard(),
                        const SizedBox(height: 12),
                        _medicationOverviewCard(),
                        const SizedBox(height: 12),
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

  bool _hasRecordToday(String type) {
    final todayKey = _dateKey(DateTime.now());
    final records = List<Map<String, dynamic>>.from(
      healthHistories[type] ?? [],
    );

    final dateField = _dateFieldByType(type);

    return records.any((item) {
      final parsed = DateTime.tryParse(item[dateField]?.toString() ?? '');
      if (parsed == null) return false;
      return _dateKey(parsed) == todayKey;
    });
  }

  String _dateFieldByType(String type) {
    if (type == 'glucose') return 'measured_at';
    if (type == 'physiological') return 'measured_at';
    if (type == 'activity') return 'activity_date';
    if (type == 'meal') return 'meal_date';
    if (type == 'medication') return 'log_date';
    return 'created_at';
  }

  Widget _dailyChecklistCard() {
    final checks = healthChecklistTypes.map((item) {
      final type = item[2] as String;

      return {'label': item[0], 'icon': item[1], 'done': _hasRecordToday(type)};
    }).toList();

    final doneCount = checks.where((item) => item['done'] == true).length;

    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Kelengkapan data pasien — Hari ini',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '$doneCount / ${checks.length} selesai',
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 11,
                  ),
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
              widthFactor: checks.isEmpty ? 0 : doneCount / checks.length,
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
            itemCount: checks.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 3.2,
            ),
            itemBuilder: (context, index) {
              final item = checks[index];
              final isDone = item['done'] == true;

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
                        item['icon'] as IconData,
                        color: AppColors.primaryBlue,
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item['label'].toString(),
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

  Map<String, String> _buildConsistencyStatus() {
    final result = <String, Set<String>>{};

    for (final type in ['glucose', 'physiological', 'activity', 'meal']) {
      final records = List<Map<String, dynamic>>.from(
        healthHistories[type] ?? [],
      );

      final dateField = _dateFieldByType(type);

      for (final item in records) {
        final parsed = DateTime.tryParse(item[dateField]?.toString() ?? '');
        if (parsed == null) continue;

        final key = _dateKey(parsed);
        result.putIfAbsent(key, () => <String>{});
        result[key]!.add(type);
      }
    }

    return result.map((key, value) {
      if (value.length >= 4) return MapEntry(key, 'lengkap');
      if (value.isNotEmpty) return MapEntry(key, 'sebagian');
      return MapEntry(key, 'tidak');
    });
  }

  Widget _calendarCard() {
    final consistencyStatus = _buildConsistencyStatus();

    final year = currentMonth.year;
    final month = currentMonth.month;
    final totalDays = _daysInMonth(currentMonth);

    final firstDay = DateTime(year, month, 1);
    final startOffset = firstDay.weekday - 1;

    final prevMonth = DateTime(year, month - 1);
    final prevMonthDays = _daysInMonth(prevMonth);

    const totalCells = 35;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Konsistensi — ${_monthName(month)} $year',
                  style: const TextStyle(
                    color: AppColors.dark1,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentMonth = DateTime(year, month - 1);
                  });
                },
                child: _calendarNavButton(Icons.chevron_left),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentMonth = DateTime(year, month + 1);
                  });
                },
                child: _calendarNavButton(Icons.chevron_right),
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
            itemCount: totalCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 18,
              crossAxisSpacing: 0,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              final dayNumber = index - startOffset + 1;

              if (dayNumber < 1) {
                final prevDay = prevMonthDays + dayNumber;
                return _calendarTextDay('$prevDay', color: AppColors.dark4);
              }

              if (dayNumber > totalDays) {
                final nextDay = dayNumber - totalDays;
                return _calendarTextDay('$nextDay', color: AppColors.dark4);
              }

              final date = DateTime(year, month, dayNumber);
              final status = consistencyStatus[_dateKey(date)];

              final isSelected =
                  date.year == selectedDate.year &&
                  date.month == selectedDate.month &&
                  date.day == selectedDate.day;

              final prevStatus =
                  consistencyStatus[_dateKey(
                    date.subtract(const Duration(days: 1)),
                  )];

              final nextStatus =
                  consistencyStatus[_dateKey(
                    date.add(const Duration(days: 1)),
                  )];

              if (status == 'lengkap' ||
                  status == 'sebagian' ||
                  status == 'tidak') {
                return _calendarStreakDay(
                  text: '$dayNumber',
                  status: status!,
                  selected: isSelected,
                  connectLeft: prevStatus == status,
                  connectRight: nextStatus == status,
                );
              }

              if (isSelected) {
                return _calendarSelectedDay('$dayNumber');
              }

              return _calendarTextDay(
                '$dayNumber',
                color: AppColors.primaryBlue,
              );
            },
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              _Legend(color: Color(0xFFEAF7F1), label: 'Lengkap'),
              SizedBox(width: 18),
              _Legend(color: Color(0xFFFFF3BA), label: 'Sebagian'),
              SizedBox(width: 18),
              _Legend(color: Color(0xFFFFEAEA), label: 'Tidak ada'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _calendarStreakDay({
    required String text,
    required String status,
    required bool selected,
    required bool connectLeft,
    required bool connectRight,
  }) {
    Color bg;
    Color textColor;

    if (status == 'lengkap') {
      bg = const Color(0xFFEAF7F1);
      textColor = AppColors.primaryBlue;
    } else if (status == 'sebagian') {
      bg = const Color(0xFFFFF3BA);
      textColor = AppColors.primaryBlue;
    } else {
      bg = const Color(0xFFFFEAEA);
      textColor = AppColors.red;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          top: 5,
          bottom: 5,
          left: connectLeft ? 0 : 4,
          right: connectRight ? 0 : 4,
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.horizontal(
                left: connectLeft ? Radius.zero : const Radius.circular(30),
                right: connectRight ? Radius.zero : const Radius.circular(30),
              ),
            ),
          ),
        ),
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryBlue : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : textColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _calendarNavButton(IconData icon) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.light1),
      ),
      child: Icon(icon, color: AppColors.dark3, size: 24),
    );
  }

  Widget _calendarTextDay(String text, {required Color color}) {
    return Center(
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _calendarSelectedDay(String text) {
    return Center(
      child: Container(
        width: 46,
        height: 46,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.primaryBlue,
          shape: BoxShape.circle,
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> get _sortedSelectedPrescriptions {
    final data = List<Map<String, dynamic>>.from(selectedPatientPrescriptions);
    data.sort((a, b) {
      final timeA = _reminderTimeValue(a);
      final timeB = _reminderTimeValue(b);
      return timeA.compareTo(timeB);
    });
    return data;
  }

  int _reminderTimeValue(Map<String, dynamic> item) {
    final raw = (item['reminder_time'] ?? item['default_reminder_time'] ?? '').toString();
    final parts = raw.split(':');
    if (parts.length < 2) return 9999;
    final hour = int.tryParse(parts[0]) ?? 99;
    final minute = int.tryParse(parts[1]) ?? 99;
    return hour * 60 + minute;
  }

  String _formatMedicationTime(dynamic raw) {
    final value = raw?.toString() ?? '';
    if (value.isEmpty || value == 'null') return '-';
    final parts = value.split(':');
    if (parts.length >= 2) return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    return value;
  }

  Widget _nextMedicationCard() {
    final prescriptions = _sortedSelectedPrescriptions;

    if (prescriptions.isEmpty) {
      return _smallInfoCard(
        icon: Icons.medication_outlined,
        title: 'Belum ada jadwal obat aktif',
        subtitle: 'Jadwal obat pasien akan muncul dari resep aktif dokter.',
        onTap: () {},
      );
    }

    final nowMinutes = DateTime.now().hour * 60 + DateTime.now().minute;
    Map<String, dynamic> next = prescriptions.first;

    for (final item in prescriptions) {
      if (_reminderTimeValue(item) >= nowMinutes) {
        next = item;
        break;
      }
    }

    final medName = next['medication_name']?.toString() ?? 'Obat';
    final session = next['session_name']?.toString() ?? 'Sesi minum';
    final time = _formatMedicationTime(
      next['reminder_time'] ?? next['default_reminder_time'],
    );
    final dose = next['dose_per_session']?.toString() ?? next['dosage']?.toString() ?? '-';

    return _smallInfoCard(
      icon: Icons.alarm_rounded,
      title: 'Jadwal obat terdekat',
      subtitle: '$medName • $session • $time • $dose',
      onTap: () => setState(() => currentIndex = 4),
    );
  }

  Widget _medicationOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.veryLightBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.medication_liquid_outlined,
              color: AppColors.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Akumulasi resep obat',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Total resep aktif dari semua pasien dampingan',
                  style: TextStyle(color: AppColors.dark2, fontSize: 10),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$allPatientsActivePrescriptionCount resep',
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
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
            status: bloodPressureValue == '-' ? '-' : 'Tercatat',
            color: const Color(0xFF10C878),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _HealthSummaryCard(
            title: 'Berat Badan',
            value: weightValue,
            unit: 'kg',
            status: weightValue == '-' ? '-' : 'Tercatat',
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
              errorMessage ?? 'Gagal memuat data pendamping',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.dark2, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCaregiverHome,
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
                      'Hubungkan akun pendamping dengan pasien agar kamu bisa membantu memantau data kesehatannya.',
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
                        onPressed: () => setState(() => currentIndex = 1),
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
      padding: EdgeInsets.fromLTRB(24, topPad + 28, 24, 32),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$greeting\n$caregiverName',
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
    );
  }

  Widget _notificationButton() {
    return GestureDetector(
      onTap: () {
        setState(() => hasUnreadNotification = false);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CaregiverNotificationPage()),
        ).then((_) => _loadCaregiverHome());
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
                child: Text(
                  '$greeting\n$caregiverName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    height: 1.3,
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
                  child: Text(
                    '$patientName\n${_patientRelation(patient)} • ${_patientDm(patient)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
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
            children: List.generate(patients.length, (index) {
              final patient = patients[index];
              final name = _patientName(patient);
              final selected = selectedPatientIndex == index;

              return ListTile(
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _loadSelectedPatientDashboard(index);
                },
                leading: CircleAvatar(
                  backgroundColor: selected
                      ? AppColors.primaryBlue
                      : AppColors.lightBlue,
                  child: Text(
                    _initial(name),
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(name),
                subtitle: Text(
                  '${_patientRelation(patient)} • ${_patientDm(patient)}',
                ),
                trailing: Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: AppColors.primaryBlue,
                ),
              );
            }),
          ),
        );
      },
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
