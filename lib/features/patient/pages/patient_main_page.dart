import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'patient_notification_page.dart';
import 'patient_connection_page.dart';
import '../widgets/patient_bottom_nav.dart';
import 'patient_add_data_page.dart';
import 'patient_history_page.dart';
import 'patient_profile_page.dart';
import 'patient_validation_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/medication_reminder_service.dart';

class PatientMainPage extends StatefulWidget {
  const PatientMainPage({super.key});

  @override
  State<PatientMainPage> createState() => _PatientMainPageState();
}

class _PatientMainPageState extends State<PatientMainPage> {
  int currentIndex = 0;
  bool isAddPage = false;

  @override
  void initState() {
    super.initState();
    _syncMedicationRemindersSafely();
  }

  Future<void> _syncMedicationRemindersSafely() async {
    try {
      await MedicationReminderService.syncMedicationReminders();
    } catch (e) {
      debugPrint('SYNC MEDICATION REMINDER SAAT MAIN PASIEN ERROR: $e');
    }
  }

  final pages = const [
    PatientHomePage(),
    PatientConnectionPage(),
    SizedBox(),
    PatientHistoryPage(),
    PatientProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: isAddPage ? const PatientAddDataPage() : pages[currentIndex],
      bottomNavigationBar: PatientBottomNavBar(
        currentIndex: currentIndex,
        isAddSelected: isAddPage,
        onTap: (index) {
          setState(() {
            currentIndex = index;
            isAddPage = false;
          });
        },
        onAddTap: () {
          setState(() {
            isAddPage = true;
          });
        },
      ),
    );
  }
}

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  bool hasPendingValidation = true;
  int pendingValidationCount = 2;
  String patientName = '-';
  int? patientId;
  bool isLoading = true;

  Map<String, dynamic>? profileData;
  Map<String, dynamic>? dashboardData;
  Map<String, dynamic>? homeSummary;
  Map<String, dynamic> healthHistories = {};

  List<Map<String, dynamic>> notifications = [];

  DateTime currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime selectedDate = DateTime.now();

  Map<String, dynamic>? get latestGlucose =>
      dashboardData?['latest_glucose'] as Map<String, dynamic>?;

  Map<String, dynamic>? get latestPhysiological =>
      dashboardData?['latest_physiological'] as Map<String, dynamic>?;

  String get glucoseValue {
    return latestGlucose?['glucose_value']?.toString() ?? '-';
  }

  String get glucoseStatus {
    if (latestGlucose == null) return '-';
    return 'Tercatat';
  }

  String get bloodPressureValue {
    final systolic = latestPhysiological?['systolic']?.toString();
    final diastolic = latestPhysiological?['diastolic']?.toString();

    if (systolic == null || diastolic == null) return '-';

    return '$systolic/$diastolic';
  }

  String get bloodPressureStatus {
    if (latestPhysiological == null) return '-';
    return 'Tercatat';
  }

  String get weightValue {
    return latestPhysiological?['weight_kg']?.toString() ?? '-';
  }

  String get weightStatus {
    if (latestPhysiological == null) return '-';
    return 'Tercatat';
  }

  bool get hasUnreadNotification {
    return notifications.any((n) {
      final isRead = n['is_read'];
      return isRead == false || isRead == 0 || isRead?.toString() == '0';
    });
  }

  String get greeting {
    final hour = DateTime.now().hour;

    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';

    return 'Selamat Malam';
  }

  List<List<Object>> get dailyChecks {
    final items =
        homeSummary?['daily_checklist']?['items'] as Map<String, dynamic>? ??
        {};

    return [
      ['Glukosa', Icons.opacity, items['glucose'] == true],
      ['Fisiologis', Icons.favorite_border, items['physiological'] == true],
      ['Resep Obat', Icons.medication_outlined, items['medication'] == true],
      ['Aktivitas', Icons.directions_run, items['activity'] == true],
      ['Makan', Icons.restaurant_outlined, items['meal'] == true],
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final storedPatientId = prefs.getInt('patient_id');
      final storedUserId = prefs.getInt('user_id');
      final storedName =
          prefs.getString('full_name') ??
          prefs.getString('name') ??
          prefs.getString('user_name') ??
          '-';

      if (storedPatientId == null) {
        if (!mounted) return;

        setState(() {
          patientName = storedName;
          isLoading = false;
        });
        return;
      }

      final results = await Future.wait([
        ApiService.getPatientProfile(storedPatientId),
        ApiService.getPatientDashboard(storedPatientId),
        ApiService.getPatientHomeSummary(storedPatientId),
        ApiService.getPatientHealthHistory(storedPatientId),
        if (storedUserId != null)
          ApiService.getNotifications(storedUserId)
        else
          Future.value(<Map<String, dynamic>>[]),
      ]);

      final loadedProfile = results[0] as Map<String, dynamic>;
      final loadedDashboard = results[1] as Map<String, dynamic>;
      final loadedHomeSummary = results[2] as Map<String, dynamic>;
      final loadedHealthHistories = Map<String, dynamic>.from(
        results[3] as Map,
      );
      final loadedNotifications = List<Map<String, dynamic>>.from(
        results[4] as List,
      );

      if (!mounted) return;

      setState(() {
        patientId = storedPatientId;

        patientName =
            loadedProfile['full_name']?.toString() ??
            loadedProfile['data']?['full_name']?.toString() ??
            loadedProfile['profile']?['full_name']?.toString() ??
            loadedProfile['user']?['full_name']?.toString() ??
            loadedProfile['patient']?['full_name']?.toString() ??
            storedName;

        profileData = loadedProfile;
        dashboardData = loadedDashboard;
        homeSummary = loadedHomeSummary;
        healthHistories = loadedHealthHistories;
        notifications = loadedNotifications;

        hasPendingValidation =
            loadedHomeSummary['has_pending_validation'] == true;
        pendingValidationCount =
            int.tryParse(
              loadedHomeSummary['pending_validation_count']?.toString() ?? '0',
            ) ??
            0;

        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  String _dateFieldByType(String type) {
    if (type == 'glucose') return 'measured_at';
    if (type == 'physiological') return 'measured_at';
    if (type == 'activity') return 'activity_date';
    if (type == 'meal') return 'meal_date';
    if (type == 'medication') return 'log_date';
    return 'created_at';
  }

  Map<String, String> _buildConsistencyStatus() {
    final result = <String, Set<String>>{};

    for (final type in ['glucose', 'physiological', 'medication', 'activity', 'meal']) {
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
      if (value.length >= 5) return MapEntry(key, 'lengkap');
      if (value.isNotEmpty) return MapEntry(key, 'sebagian');
      return MapEntry(key, 'tidak');
    });
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

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  int _daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: AppColors.primaryBlue,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Container(
                color: AppColors.background,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
                  child: Column(
                    children: [
                      if (hasPendingValidation) ...[
                        _validationCard(),
                        const SizedBox(height: 14),
                      ],
                      _dailyChecklistCard(),
                      const SizedBox(height: 14),
                      _calendarCard(),
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
                  '$greeting\n$patientName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PatientNotificationPage(),
                    ),
                  ).then((_) => _loadData());
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
                    if (hasUnreadNotification || hasPendingValidation)
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
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _HealthSummaryCard(
                  title: 'Glukosa',
                  value: glucoseValue,
                  unit: 'mg/dL',
                  status: glucoseStatus,
                  color: glucoseValue == '-'
                      ? AppColors.dark4
                      : const Color(0xFF10C878),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HealthSummaryCard(
                  title: 'Tekanan Darah',
                  value: bloodPressureValue,
                  unit: 'mmHg',
                  status: bloodPressureStatus,
                  color: bloodPressureValue == '-'
                      ? AppColors.dark4
                      : const Color(0xFF10C878),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HealthSummaryCard(
                  title: 'Berat Badan',
                  value: weightValue,
                  unit: 'kg',
                  status: weightStatus,
                  color: weightValue == '-'
                      ? AppColors.dark4
                      : const Color(0xFFFFC542),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _validationCard() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PatientValidationPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4DA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.fact_check_outlined,
                color: Colors.orange,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$pendingValidationCount data menunggu validasi',
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Data ditambahkan oleh anggota keluarga',
                    style: TextStyle(color: AppColors.dark2, fontSize: 11),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4DA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$pendingValidationCount',
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: AppColors.dark3),
          ],
        ),
      ),
    );
  }

  Widget _dailyChecklistCard() {
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
                    'Checklist harian — Hari ini',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${homeSummary?['daily_checklist']?['completed'] ?? 0} / ${homeSummary?['daily_checklist']?['total'] ?? 5} selesai',
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
              widthFactor:
                  ((homeSummary?['daily_checklist']?['completed'] ?? 0) /
                          (homeSummary?['daily_checklist']?['total'] ?? 5))
                      .clamp(0.0, 1.0),
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

  Widget _calendarCard() {
    final statusMap = _buildConsistencyStatus();

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
                final date = DateTime(prevMonth.year, prevMonth.month, prevDay);
                final status = statusMap[_dateKey(date)]?.toLowerCase();
                final prevStatus = statusMap[
                  _dateKey(date.subtract(const Duration(days: 1)))
                ];
                final nextStatus = statusMap[
                  _dateKey(date.add(const Duration(days: 1)))
                ];

                if (status == 'lengkap' ||
                    status == 'sebagian' ||
                    status == 'tidak') {
                  return _calendarStreakDay(
                    text: '$prevDay',
                    status: status!,
                    selected: false,
                    connectLeft: prevStatus == status,
                    connectRight: nextStatus == status,
                  );
                }

                return _calendarTextDay('$prevDay', color: AppColors.dark4);
              }

              if (dayNumber > totalDays) {
                final nextDay = dayNumber - totalDays;
                final date = DateTime(year, month + 1, nextDay);
                final status = statusMap[_dateKey(date)]?.toLowerCase();
                final prevStatus = statusMap[
                  _dateKey(date.subtract(const Duration(days: 1)))
                ];
                final nextStatus = statusMap[
                  _dateKey(date.add(const Duration(days: 1)))
                ];

                if (status == 'lengkap' ||
                    status == 'sebagian' ||
                    status == 'tidak') {
                  return _calendarStreakDay(
                    text: '$nextDay',
                    status: status!,
                    selected: false,
                    connectLeft: prevStatus == status,
                    connectRight: nextStatus == status,
                  );
                }

                return _calendarTextDay('$nextDay', color: AppColors.dark4);
              }

              final date = DateTime(year, month, dayNumber);
              final status = statusMap[_dateKey(date)]?.toLowerCase();

              final isSelected =
                  date.year == selectedDate.year &&
                  date.month == selectedDate.month &&
                  date.day == selectedDate.day;

              final prevStatus =
                  statusMap[_dateKey(date.subtract(const Duration(days: 1)))];

              final nextStatus =
                  statusMap[_dateKey(date.add(const Duration(days: 1)))];

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
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
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