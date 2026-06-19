import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'patient_notification_page.dart';
import 'patient_connection_page.dart';
import '../widgets/patient_bottom_nav.dart';
import 'patient_add_data_page.dart';
import 'patient_history_page.dart';
import 'patient_profile_page.dart';
import 'patient_recommendation_detail_page.dart';
import 'patient_validation_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/services/api_service.dart';

class PatientMainPage extends StatefulWidget {
  const PatientMainPage({super.key});

  @override
  State<PatientMainPage> createState() => _PatientMainPageState();
}

class _PatientMainPageState extends State<PatientMainPage> {
  int currentIndex = 0;
  bool isAddPage = false;

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
  Map<String, dynamic>? latestRecommendation;
  List<Map<String, dynamic>> notifications = [];

  Map<String, dynamic> get glucose =>
      dashboardData?['glucose'] as Map<String, dynamic>? ?? {};

  Map<String, dynamic> get bloodPressure =>
      dashboardData?['blood_pressure'] as Map<String, dynamic>? ?? {};

  Map<String, dynamic> get weight =>
      dashboardData?['weight'] as Map<String, dynamic>? ?? {};

  bool get hasUnreadNotification {
    return notifications.any((n) {
      final isRead = n['is_read'];
      return isRead == false || isRead == 0 || isRead?.toString() == '0';
    });
  }

  String get greeting {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Selamat Pagi';
    } else if (hour < 15) {
      return 'Selamat Siang';
    } else if (hour < 18) {
      return 'Selamat Sore';
    }

    return 'Selamat Malam';
  }

  Color getGlucoseColor() {
    final status = glucose['status']?.toString().toLowerCase();

    if (status == 'normal') {
      return const Color(0xFF10C878);
    }

    return AppColors.red;
  }

  List<List<Object>> get dailyChecks {
    final items =
        homeSummary?['daily_checklist']?['items'] as Map<String, dynamic>? ??
        {};

    return [
      ['Glukosa', Icons.opacity, items['glucose'] == true],
      ['Resep Obat', Icons.medication_outlined, items['medication'] == true],
      ['Aktivitas', Icons.directions_run, items['activity'] == true],
      ['Makan', Icons.restaurant_outlined, items['meal'] == true],
    ];
  }

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

      if (mounted) {
        setState(() {
          patientName = storedName;
        });
      }

      Map<String, dynamic>? loadedProfile;
      List<Map<String, dynamic>> loadedNotifications = [];
      Map<String, dynamic>? loadedDashboard;
      Map<String, dynamic>? loadedHomeSummary;

      if (storedPatientId != null) {
        loadedProfile = await ApiService.getPatientProfile(storedPatientId);

        loadedDashboard = await ApiService.getPatientDashboard(storedPatientId);

        loadedHomeSummary = await ApiService.getPatientHomeSummary(
          storedPatientId,
        );
      }

      if (storedUserId != null) {
        loadedNotifications = await ApiService.getNotifications(storedUserId);
      }

      if (!mounted) return;

      setState(() {
        patientId = storedPatientId;
        patientName =
            loadedProfile?['full_name']?.toString() ??
            loadedProfile?['data']?['full_name']?.toString() ??
            loadedProfile?['profile']?['full_name']?.toString() ??
            loadedProfile?['user']?['full_name']?.toString() ??
            loadedProfile?['patient']?['full_name']?.toString() ??
            storedName;

        profileData = loadedProfile;
        dashboardData = loadedDashboard;

        notifications = loadedNotifications;

        isLoading = false;

        homeSummary = loadedHomeSummary;
        latestRecommendation = loadedHomeSummary?['latest_recommendation'];
        hasPendingValidation =
            loadedHomeSummary?['has_pending_validation'] == true;
        pendingValidationCount =
            loadedHomeSummary?['pending_validation_count'] ?? 0;
      });
    } catch (e) {
      debugPrint(e.toString());

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
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
                      _doctorNoteCard(),

                      if (hasPendingValidation) ...[
                        const SizedBox(height: 14),
                        _validationCard(),
                      ],

                      const SizedBox(height: 14),
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
                  style: TextStyle(
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
                  ).then((_) {
                    _loadData();
                  });
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
                  value: glucose['value']?.toString() ?? '-',
                  unit: 'mg/dL',
                  status: glucose['status']?.toString() ?? '-',
                  color: getGlucoseColor(),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _HealthSummaryCard(
                  title: 'Tekanan Darah',
                  value: bloodPressure['value']?.toString() ?? '-',
                  unit: 'mmHg',
                  status: bloodPressure['status']?.toString() ?? '-',
                  color: Color(0xFF10C878),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _HealthSummaryCard(
                  title: 'Berat Badan',
                  value: weight['value']?.toString() ?? '-',
                  unit: 'kg',
                  status: weight['status']?.toString() ?? '-',
                  color: Color(0xFFFFC542),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _doctorNoteCard() {
    if (latestRecommendation == null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(),
        child: const Row(
          children: [
            Icon(Icons.description_outlined, color: AppColors.primaryBlue),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Belum ada rekomendasi dari dokter',
                style: TextStyle(color: AppColors.dark2, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    final doctorName = latestRecommendation?['doctor_name']?.toString() ?? '-';

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PatientRecommendationDetailPage(
              item: {
                'doctor':
                    latestRecommendation?['doctor_name']?.toString() ??
                    'Dokter',
                'date': latestRecommendation?['created_at']?.toString() ?? '-',
                'status':
                    latestRecommendation?['category']?.toString() ??
                    'Rekomendasi',
                'description':
                    latestRecommendation?['recommendation_text']?.toString() ??
                    latestRecommendation?['content']?.toString() ??
                    '-',
              },
            ),
          ),
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
                color: AppColors.veryLightBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.description_outlined,
                color: AppColors.primaryBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rekomendasi baru dari dokter',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '$doctorName',
                    style: TextStyle(color: AppColors.dark2, fontSize: 11),
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
                  '${homeSummary?['daily_checklist']?['completed'] ?? 0} / ${homeSummary?['daily_checklist']?['total'] ?? 4} selesai',
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
                          (homeSummary?['daily_checklist']?['total'] ?? 4))
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
    final year = currentMonth.year;
    final month = currentMonth.month;
    final totalDays = _daysInMonth(currentMonth);
    final firstDay = DateTime(year, month, 1);

    // weekday: Senin = 1, Minggu = 7
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
                  'Konsistensi — ${_monthName(month)} $year',
                  style: const TextStyle(
                    color: AppColors.dark1,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentMonth = DateTime(year, month - 1);
                  });
                },
                child: _smallArrow(Icons.chevron_left),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentMonth = DateTime(year, month + 1);
                  });
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
              crossAxisSpacing: 0,
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
                final prevDate = date.subtract(const Duration(days: 1));
                final nextDate = date.add(const Duration(days: 1));

                final prevStatus = consistencyStatus[_dateKey(prevDate)];
                final nextStatus = consistencyStatus[_dateKey(nextDate)];

                final connectLeft = prevStatus == 'lengkap';
                final connectRight = nextStatus == 'lengkap';

                final baseDay = _calendarRangeDay(
                  text: '$dayNumber',
                  color: const Color(0xFFEAFBF3),
                  textColor: AppColors.primaryBlue,
                  connectLeft: connectLeft,
                  connectRight: connectRight,
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

              if (isSelected) {
                return _calendarOutlineDay(text: '$dayNumber');
              }

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
            mainAxisAlignment: MainAxisAlignment.start,
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
