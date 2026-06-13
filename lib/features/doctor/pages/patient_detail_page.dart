import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'patient_threshold_page.dart';
import 'clinical_note_form_page.dart';
import 'doctor_prescription_page.dart';

class PatientDetailPage extends StatefulWidget {
  const PatientDetailPage({super.key});

  @override
  State<PatientDetailPage> createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends State<PatientDetailPage> {
  int selectedTab = 0;
  int selectedPeriod = 0;
  int selectedBehaviorTab = 0;

  final tabs = ['Glukosa', 'Fisiologis', 'Perilaku', 'Resep'];
  final periods = ['7 Hari', '30 Hari', '3 Bulan', 'Kustom'];
  final behaviorTabs = ['Aktivitas', 'Pola Makan', 'Obat'];

  DateTimeRange? selectedDateRange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Container(
                color: AppColors.background,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      if (selectedTab != 3) ...[
                        _buildSummaryCards(),
                        const SizedBox(height: 20),
                        _buildThresholdSection(),
                        const SizedBox(height: 20),
                      ],

                      _buildTabs(),

                      if (selectedTab != 3) ...[
                        const SizedBox(height: 14),
                        _buildPeriods(),
                        const SizedBox(height: 20),
                      ] else
                        const SizedBox(height: 20),

                      _buildDynamicContent(),

                      if (selectedTab != 3) ...[
                        const SizedBox(height: 24),
                        _buildDisconnectButton(),
                      ],

                      const SizedBox(height: 24),
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

  Widget _buildHeader() {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 18),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
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
                  'Detail Pasien',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.veryLightBlue,
                          width: 4,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'AS',
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Angelica Sabi Gita',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '32 tahun • Perempuan',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.dark2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.veryLightBlue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'DM Tipe 2',
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ClinicalNoteFormPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Buat Catatan Klinis',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildSummaryCards() {
    final items = [
      ['Glukosa', '215', 'mg/dL', 'Abnormal', AppColors.red],
      ['Tekanan Darah', '140/90', 'mmHg', 'Tinggi', Colors.orange],
      ['BMI', '27.5', '', 'Overweight', Colors.blue],
      ['Kepatuhan Obat', '78%', '', 'Baik', const Color(0xFF10C878)],
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.45,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final color = item[4] as Color;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.light1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item[0] as String,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              RichText(
                text: TextSpan(
                  text: item[1] as String,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  children: [
                    TextSpan(
                      text: ' ${item[2]}',
                      style: const TextStyle(
                        color: AppColors.dark2,
                        fontSize: 11,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                item[3] as String,
                style: TextStyle(color: color, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThresholdSection() {
    final rows = [
      ['Glukosa Puasa', '70 - 130', '(mg/dL)'],
      ['Glukosa Postprandial', '70 - 180', '(mg/dL)'],
      ['Tekanan Darah Sistolik', '90 - 130', '(mmHg)'],
      ['Tekanan Darah Diastolik', '60 - 85', '(mmHg)'],
      ['BMI', '18.5 - 25.0', ''],
    ];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.veryLightBlue,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: AppColors.light1),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Batas Normal Pasien',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PatientThresholdPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Ubah'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  side: const BorderSide(color: AppColors.primaryBlue),
                  foregroundColor: AppColors.primaryBlue,
                  backgroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(12),
            ),
            border: Border.all(color: AppColors.light1),
          ),
          child: Column(
            children: List.generate(rows.length, (i) {
              final item = rows[i];
              final isLast = i == rows.length - 1;

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : const Border(
                          bottom: BorderSide(color: AppColors.light1),
                        ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item[0],
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.dark1,
                        ),
                      ),
                    ),
                    Text(
                      item[1],
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item[2].isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(
                          item[2],
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.dark2,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.light1),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final selected = selectedTab == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedTab = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.lightBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? AppColors.primaryBlue : AppColors.dark1,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPeriods() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(periods.length, (index) {
        final selected = selectedPeriod == index;
        final isCustom = index == periods.length - 1;

        final label = isCustom && selectedDateRange != null
            ? '${_formatDate(selectedDateRange!.start)} - ${_formatDate(selectedDateRange!.end)}'
            : periods[index];

        return GestureDetector(
          onTap: () async {
            if (isCustom) {
              await _pickCustomRange();
            } else {
              setState(() => selectedPeriod = index);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? AppColors.lightBlue : AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.light1),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primaryBlue : AppColors.dark2,
                fontSize: 13,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDynamicContent() {
    if (selectedTab == 3) {
      return const DoctorPrescriptionPage();
    }

    if (selectedTab == 0) {
      return _buildTrendAndHistory(
        title: 'Tren Glukosa',
        unitLabel: 'mg/dL',
        lineColor: AppColors.red,
        spots: const [
          FlSpot(0, 200),
          FlSpot(1, 160),
          FlSpot(2, 80),
          FlSpot(3, 110),
          FlSpot(4, 145),
          FlSpot(5, 150),
          FlSpot(6, 187),
        ],
        history: [
          ['Postprandial', '7 Jun 2026 • 13:04', '187 mg/dL'],
          ['Puasa', '7 Jun 2026 • 07:10', '110 mg/dL'],
          ['Postprandial', '6 Jun 2026 • 12:55', '162 mg/dL'],
        ],
      );
    }

    if (selectedTab == 1) {
      return _buildTrendAndHistory(
        title: 'Tren Tekanan Darah Sistolik',
        unitLabel: 'mmHg',
        lineColor: Colors.orange,
        spots: const [
          FlSpot(0, 120),
          FlSpot(1, 122),
          FlSpot(2, 130),
          FlSpot(3, 128),
          FlSpot(4, 140),
          FlSpot(5, 135),
          FlSpot(6, 132),
        ],
        history: [
          ['Tekanan Darah', '7 Jun 2026 • 08:00', '140/90 mmHg'],
          ['Berat Badan', '7 Jun 2026 • 08:00', '72 kg'],
          ['BMI', '7 Jun 2026 • 08:00', '27.5'],
        ],
      );
    }

    return _buildBehaviorContent();
  }

  Widget _buildBehaviorContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBehaviorTabs(),
        const SizedBox(height: 18),

        if (selectedBehaviorTab == 0)
          _buildTrendAndHistory(
            title: 'Tren Aktivitas Fisik',
            unitLabel: 'menit',
            lineColor: AppColors.primaryBlue,
            spots: const [
              FlSpot(0, 30),
              FlSpot(1, 45),
              FlSpot(2, 20),
              FlSpot(3, 60),
              FlSpot(4, 35),
              FlSpot(5, 50),
              FlSpot(6, 40),
            ],
            history: [
              ['Jalan kaki', '7 Jun 2026 • 06:30', '30 menit'],
              ['Senam ringan', '6 Jun 2026 • 07:00', '45 menit'],
              ['Bersepeda', '5 Jun 2026 • 16:20', '20 menit'],
            ],
          )
        else if (selectedBehaviorTab == 1)
          _buildTrendAndHistory(
            title: 'Tren Estimasi Karbohidrat',
            unitLabel: 'gram',
            lineColor: Colors.orange,
            spots: const [
              FlSpot(0, 180),
              FlSpot(1, 200),
              FlSpot(2, 170),
              FlSpot(3, 220),
              FlSpot(4, 190),
              FlSpot(5, 210),
              FlSpot(6, 185),
            ],
            history: [
              ['Sarapan', 'Nasi merah, telur, sayur', '45 gr'],
              ['Makan siang', 'Nasi putih, ayam, tempe', '70 gr'],
              ['Makan malam', 'Sup ayam dan kentang', '55 gr'],
            ],
          )
        else
          _buildTrendAndHistory(
            title: 'Tren Kepatuhan Obat',
            unitLabel: 'dosis',
            lineColor: const Color(0xFF10C878),
            spots: const [
              FlSpot(0, 3),
              FlSpot(1, 2),
              FlSpot(2, 3),
              FlSpot(3, 3),
              FlSpot(4, 1),
              FlSpot(5, 3),
              FlSpot(6, 3),
            ],
            history: [
              ['Metformin 500 mg', '7 Jun 2026 • 07:00', 'Diminum'],
              ['Metformin 500 mg', '6 Jun 2026 • 19:00', 'Diminum'],
              ['Metformin 500 mg', '5 Jun 2026 • 07:00', 'Terlambat'],
            ],
          ),
      ],
    );
  }

  Widget _buildBehaviorTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.light1),
      ),
      child: Row(
        children: List.generate(behaviorTabs.length, (index) {
          final selected = selectedBehaviorTab == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedBehaviorTab = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: selected ? AppColors.lightBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  behaviorTabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? AppColors.primaryBlue : AppColors.dark1,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTrendAndHistory({
    required String title,
    required String unitLabel,
    required Color lineColor,
    required List<FlSpot> spots,
    required List<List<String>> history,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.dark1,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 180,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.light1),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '7 Hari Terakhir',
                      style: TextStyle(color: AppColors.dark2, fontSize: 12),
                    ),
                  ),
                  Text(
                    unitLabel,
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(
                      show: true,
                      drawVerticalLine: false,
                    ),
                    titlesData: const FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        barWidth: 2,
                        color: lineColor,
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'RIWAYAT DATA',
          style: TextStyle(
            color: AppColors.dark1,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ...history.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.light1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item[0],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item[1],
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.dark2,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  item[2],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();

    final initial =
        selectedDateRange ??
        DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
        selectedPeriod = periods.length - 1;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildDisconnectButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.red,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: const Text('Putus Relasi'),
      ),
    );
  }
}
