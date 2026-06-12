import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'patient_notification_page.dart';
import 'patient_connection_page.dart';
import '../widgets/patient_bottom_nav.dart';
import 'patient_add_data_page.dart';
import 'patient_history_page.dart';

class PatientMainPage extends StatefulWidget {
  const PatientMainPage({super.key});

  @override
  State<PatientMainPage> createState() => _PatientMainPageState();
}

class _PatientMainPageState extends State<PatientMainPage> {
  int currentIndex = 0;

  final pages = const [
    PatientHomePage(),
    PatientConnectionPage(),
    PatientHistoryPage(),
    Center(child: Text('Profil')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: pages[currentIndex],
      bottomNavigationBar: PatientBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        onAddTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PatientAddDataPage()),
          );
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
  final dailyChecks = [
    ['Glukosa', Icons.opacity, true],
    ['Obat', Icons.medication_outlined, true],
    ['Aktivitas', Icons.directions_run, false],
    ['Makan', Icons.restaurant_outlined, false],
  ];

  DateTime currentMonth = DateTime(2025, 6);
  DateTime selectedDate = DateTime(2025, 6, 7);

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
  Widget build(BuildContext context) {
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
              const Expanded(
                child: Text(
                  'Selamat Pagi\nAngelica Sabi Gita',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PatientNotificationPage(),
                    ),
                  );
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: const [
              Expanded(
                child: _HealthSummaryCard(
                  title: 'Glukosa',
                  value: '187',
                  unit: 'mg/dL',
                  status: 'Tinggi',
                  color: AppColors.red,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _HealthSummaryCard(
                  title: 'Tekanan Darah',
                  value: '128/82',
                  unit: 'mmHg',
                  status: 'Normal',
                  color: Color(0xFF10C878),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _HealthSummaryCard(
                  title: 'Berat Badan',
                  value: '78.5',
                  unit: 'kg',
                  status: 'Overweight',
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
    return Container(
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catatan klinis baru dari dokter',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'dr. Agus Setiawan, S.PD • 7 Jun 2025',
                  style: TextStyle(color: AppColors.dark2, fontSize: 11),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.dark3),
        ],
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
              children: const [
                Expanded(
                  child: Text(
                    'Checklist harian — 7 Jun',
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
