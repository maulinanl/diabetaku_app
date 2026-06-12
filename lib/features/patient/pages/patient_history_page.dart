import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'patient_recommendation_detail_page.dart';

class PatientHistoryPage extends StatefulWidget {
  const PatientHistoryPage({super.key});

  @override
  State<PatientHistoryPage> createState() => _PatientHistoryPageState();
}

class _PatientHistoryPageState extends State<PatientHistoryPage> {
  int mainTab = 0;
  int healthFilter = 0;
  DateTimeRange? selectedRange;

  final healthFilters = [
    'Semua',
    'Glukosa',
    'Fisiologis',
    'Aktivitas',
    'Makan',
    'Obat',
  ];

  final List<Map<String, Object>> healthHistories = [
    {
      'type': 'Glukosa',
      'title': 'Glukosa Postprandial',
      'time': '7 Jun • 13:04',
      'value': '187',
      'unit': 'mg/dL',
      'badge': 'Abnormal',
      'icon': Icons.opacity,
      'color': AppColors.red,
    },
    {
      'type': 'Obat',
      'title': 'Kepatuhan Obat',
      'time': '7 Jun • 07:00',
      'value': '',
      'unit': '',
      'badge': 'Diminum',
      'icon': Icons.medication_outlined,
      'color': AppColors.primaryBlue,
    },
    {
      'type': 'Aktivitas',
      'title': 'Aktivitas Fisik',
      'time': '7 Jun • 06:30',
      'value': '',
      'unit': '',
      'badge': 'Jalan kaki',
      'icon': Icons.directions_run,
      'color': AppColors.primaryBlue,
    },
    {
      'type': 'Fisiologis',
      'title': 'Tekanan Darah',
      'time': '7 Jun • 06:15',
      'value': '128/82',
      'unit': 'mmHg',
      'badge': 'Normal',
      'icon': Icons.bar_chart_rounded,
      'color': Colors.orange,
    },
    {
      'type': 'Makan',
      'title': 'Pola Makan',
      'time': '7 Jun • 12:20',
      'value': '60',
      'unit': 'gram',
      'badge': 'Sarapan',
      'icon': Icons.restaurant_outlined,
      'color': AppColors.primaryBlue,
    },
    {
      'type': 'Glukosa',
      'title': 'Glukosa Postprandial',
      'time': '6 Jun • 12:55',
      'value': '162',
      'unit': 'mg/dL',
      'badge': 'Normal',
      'icon': Icons.opacity,
      'color': Colors.orange,
    },
  ];

  final List<Map<String, String>> recommendationHistories = [
    {
      'doctor': 'dr. Agus Setiawan, Sp.PD',
      'date': '7 Jun 2025 • 09:41',
      'status': 'Tidak Stabil',
      'description':
          'Glukosa postprandial 187 mg/dL, melebihi batas normal. Penyesuaian dosis Metformin diperlukan...',
      'initial': 'AS',
    },
    {
      'doctor': 'dr. Sarah Puspita, Sp.PD',
      'date': '1 Jun 2025 • 11:00',
      'status': 'Stabil',
      'description':
          'Kondisi pasien stabil. Glukosa puasa dalam batas normal dan tekanan darah terkontrol baik.',
      'initial': 'SP',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredHealth = healthHistories.where((item) {
      if (healthFilter == 0) return true;
      return item['type'] == healthFilters[healthFilter];
    }).toList();

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
                child: mainTab == 0
                    ? _healthContent(filteredHealth)
                    : _recommendationContent(recommendationHistories),
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
      padding: EdgeInsets.fromLTRB(24, topPad + 30, 24, 26),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Riwayat',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 28),
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.light1),
            ),
            child: Row(
              children: [
                _mainTabItem('Data Kesehatan', 0),
                _mainTabItem('Rekomendasi', 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mainTabItem(String title, int index) {
    final selected = mainTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => mainTab = index),
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
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _filterChips({
    required List<String> filters,
    required int selectedIndex,
    required ValueChanged<int> onTap,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Row(
        children: List.generate(filters.length, (index) {
          final selected = selectedIndex == index;

          return GestureDetector(
            onTap: () => onTap(index),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? AppColors.primaryBlue : AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected ? AppColors.primaryBlue : AppColors.light1,
                ),
              ),
              child: Text(
                filters[index],
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.primaryBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _healthContent(List<Map<String, Object>> data) {
    return Column(
      children: [
        _filterChips(
          filters: healthFilters,
          selectedIndex: healthFilter,
          onTap: (index) => setState(() => healthFilter = index),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '7 JUN 2025',
                      style: TextStyle(
                        color: AppColors.dark2,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _dateRangeButton(),
                ],
              ),
              const SizedBox(height: 14),
              ...data.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _HealthHistoryCard(
                    title: item['title'] as String,
                    time: item['time'] as String,
                    value: item['value'] as String,
                    unit: item['unit'] as String,
                    badge: item['badge'] as String,
                    icon: item['icon'] as IconData,
                    color: item['color'] as Color,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PatientHealthDetailPage(
                            type: item['type'] as String,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _recommendationContent(List<Map<String, String>> data) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 4),
          child: Row(
            children: [
              const Text(
                'Dokter:',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.light1),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Semua Dokter',
                          style: TextStyle(
                            color: AppColors.dark3,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: AppColors.dark2),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
            children: data.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PatientRecommendationDetailPage(),
                      ),
                    );
                  },
                  child: _ClinicalHistoryCard(
                    initial: item['initial']!,
                    doctor: item['doctor']!,
                    date: item['date']!,
                    status: item['status']!,
                    description: item['description']!,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _dateRangeButton() {
    return GestureDetector(
      onTap: () async {
        final picked = await _showCompactDateRangePicker();

        if (picked != null) {
          setState(() {
            selectedRange = picked;
          });
        }
      },
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.light1),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month,
              size: 15,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(width: 8),
            Text(
              selectedRange == null
                  ? 'Rentang tanggal'
                  : '${selectedRange!.start.day}/${selectedRange!.start.month} - ${selectedRange!.end.day}/${selectedRange!.end.month}',
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<DateTimeRange?> _showCompactDateRangePicker() async {
    DateTime? startDate = selectedRange?.start;
    DateTime? endDate = selectedRange?.end;
    final now = DateTime.now();

    return showDialog<DateTimeRange>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 360,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Pilih Rentang Tanggal',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _rangeBox(
                            label: 'Mulai',
                            value: startDate == null
                                ? '-'
                                : '${startDate!.day}/${startDate!.month}/${startDate!.year}',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _rangeBox(
                            label: 'Selesai',
                            value: endDate == null
                                ? '-'
                                : '${endDate!.day}/${endDate!.month}/${endDate!.year}',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      height: 330,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppColors.primaryBlue,
                            onPrimary: Colors.white,
                            surface: Colors.white,
                            onSurface: AppColors.dark1,
                          ),
                        ),
                        child: CalendarDatePicker(
                          initialDate: startDate ?? now,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                          onDateChanged: (date) {
                            setDialogState(() {
                              if (startDate == null ||
                                  (startDate != null && endDate != null)) {
                                startDate = date;
                                endDate = null;
                              } else if (date.isBefore(startDate!)) {
                                endDate = startDate;
                                startDate = date;
                              } else {
                                endDate = date;
                              }
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.dark2,
                              side: const BorderSide(color: AppColors.light1),
                            ),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: startDate != null && endDate != null
                                ? () {
                                    Navigator.pop(
                                      dialogContext,
                                      DateTimeRange(
                                        start: startDate!,
                                        end: endDate!,
                                      ),
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                            ),
                            child: const Text('Terapkan'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _rangeBox({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.light1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.dark2, fontSize: 10),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthHistoryCard extends StatelessWidget {
  final String title;
  final String time;
  final String value;
  final String unit;
  final String badge;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HealthHistoryCard({
    required this.title,
    required this.time,
    required this.value,
    required this.unit,
    required this.badge,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.veryLightBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primaryBlue, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.dark1,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    time,
                    style: const TextStyle(
                      color: AppColors.dark2,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (hasValue)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    unit,
                    style: const TextStyle(
                      color: AppColors.dark2,
                      fontSize: 10,
                    ),
                  ),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.veryLightBlue,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.lightBlue),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}

class _ClinicalHistoryCard extends StatelessWidget {
  final String initial;
  final String doctor;
  final String date;
  final String status;
  final String description;

  const _ClinicalHistoryCard({
    required this.initial,
    required this.doctor,
    required this.date,
    required this.status,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isStable = status == 'Stabil';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.lightBlue,
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor,
                      style: const TextStyle(
                        color: AppColors.dark1,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: const TextStyle(
                        color: AppColors.dark2,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _badge(
                text: 'Rekomendasi',
                bg: AppColors.veryLightBlue,
                color: AppColors.primaryBlue,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _badge(
            text: status,
            bg: isStable ? const Color(0xFFEAFBF3) : const Color(0xFFFFF4DA),
            color: isStable ? const Color(0xFF10C878) : Colors.orange,
            icon: isStable ? Icons.check_rounded : Icons.warning_amber_rounded,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.send_outlined, color: AppColors.primaryBlue, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Rekomendasi dikirim',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.dark3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge({
    required String text,
    required Color bg,
    required Color color,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
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
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.light1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.07),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

class PatientHealthDetailPage extends StatelessWidget {
  final String type;

  const PatientHealthDetailPage({super.key, required this.type});

  String _getDetailTitle(String title) {
    if (title == 'Data Glukosa') return 'Informasi pengukuran';
    if (title == 'Data Fisiologis') return 'Data fisiologis';
    if (title == 'Aktivitas Fisik') return 'Detail aktivitas';
    if (title == 'Pola Makan') return 'Detail konsumsi';
    if (title == 'Kepatuhan Obat') return 'Detail obat';
    return 'Detail data';
  }

  @override
  Widget build(BuildContext context) {
    final data = _getDetailData(type);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _header(context, data),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                child: Column(
                  children: [
                    _detailSection(data),
                    const SizedBox(height: 14),
                    _noteSection(data),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () => _showDeleteSheet(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text('Hapus data ini'),
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

  Map<String, dynamic> _getDetailData(String type) {
    if (type == 'Aktivitas') {
      return {
        'title': 'Aktivitas Fisik',
        'icon': Icons.directions_run,
        'value': '45',
        'unit': 'menit',
        'date': '7 Juni 2025 • 08:20',
        'status': 'Tinggi',
        'sections': [
          ['Jenis aktivitas', 'Jalan kaki'],
          ['Durasi', '45 menit'],
          ['Intensitas', 'Sedang'],
        ],
        'note': 'Jalan pagi keliling kompleks, cuaca cerah',
      };
    }

    if (type == 'Obat') {
      return {
        'title': 'Kepatuhan Obat',
        'icon': Icons.medication_outlined,
        'value': 'Metformin 850mg',
        'unit': 'Dosis malam',
        'date': '7 Juni 2025 • 08:20',
        'status': 'Diminum',
        'sections': [
          ['Nama Obat', 'Metformin'],
          ['Dosis', '850 mg'],
          ['Jadwal', 'Pagi'],
          ['Status konsumsi', 'Diminum'],
          ['Waktu aktual minum', '08:00'],
        ],
        'note': 'Tidak ada catatan',
      };
    }

    if (type == 'Makan') {
      return {
        'title': 'Pola Makan',
        'icon': Icons.restaurant_outlined,
        'value': '60',
        'unit': 'gram',
        'date': '7 Juni 2025 • 12:20',
        'status': '',
        'sections': [
          ['Tipe makan', 'Sarapan'],
          ['Estimasi karbohidrat', '60 gram'],
        ],
        'note': 'Nasi putih 1 porsi, ayam goreng, sayur bayam, tempe goreng',
      };
    }

    if (type == 'Fisiologis') {
      return {
        'title': 'Data Fisiologis',
        'icon': Icons.bar_chart_rounded,
        'value': '128/82',
        'unit': 'mmHg',
        'date': '7 Juni 2025 • 08:20',
        'status': 'Normal',
        'sections': [
          ['Sistolik', '128 mmHg'],
          ['Diastolik', '82 mmHg'],
          ['Batas normal', '90–140 / 60–90 mmHg'],
          ['Status', 'Normal'],
          ['Berat Badan', '78.5 kg'],
          ['Tinggi Badan', '168 cm'],
          ['BMI', '27.4 kg/m²'],
        ],
        'note': '',
      };
    }

    return {
      'title': 'Data Glukosa',
      'icon': Icons.opacity,
      'value': '187',
      'unit': 'mg/dL',
      'date': '7 Juni 2025 • 13:04',
      'status': 'Abnormal',
      'sections': [
        ['Tipe pengukuran', 'Postprandial'],
        ['Nilai', '187 mg/dL'],
        ['Batas normal', '80–160 mg/dL'],
        ['Status', 'Abnormal'],
        ['Notif ke dokter', 'Terkirim'],
      ],
      'note': 'Setelah makan nasi padang',
    };
  }

  Widget _header(BuildContext context, Map<String, dynamic> data) {
    final topPad = MediaQuery.of(context).padding.top;
    final isBad = data['status'] == 'Abnormal';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 24),
      color: AppColors.primaryBlue,
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
                  'Riwayat',
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
          const SizedBox(height: 8),
          Text(
            data['title'],
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(height: 10),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white.withValues(alpha: 0.18),
            child: Icon(data['icon'], color: Colors.white, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            data['value'],
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            data['unit'],
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            data['date'],
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
          if ((data['status'] as String).isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isBad ? AppColors.lightRed : const Color(0xFFEAFBF3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                data['status'],
                style: TextStyle(
                  color: isBad ? AppColors.red : const Color(0xFF10C878),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailSection(Map<String, dynamic> data) {
    final sections = data['sections'] as List<List<String>>;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getDetailTitle(data['title']),
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...sections.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      row[0],
                      style: const TextStyle(
                        color: AppColors.dark2,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    row[1],
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _noteSection(Map<String, dynamic> data) {
    final note = data['note'] as String;

    if (note.isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Catatan',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.veryLightBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              note,
              style: const TextStyle(color: AppColors.dark1, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.lightRed,
                child: Icon(
                  Icons.delete_outline,
                  color: AppColors.red,
                  size: 36,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Hapus data ini?',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Data yang dihapus tidak dapat dikembalikan. Pastikan Anda yakin sebelum melanjutkan.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.dark2, fontSize: 13),
              ),
              const SizedBox(height: 22),
              TextButton(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  _showDeletedSuccess(context);
                },
                child: const Text(
                  'Hapus',
                  style: TextStyle(color: AppColors.primaryBlue),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text('Batal'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeletedSuccess(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: Color(0xFFEAFBF3),
                child: Icon(Icons.check, color: Color(0xFF10C878), size: 36),
              ),
              const SizedBox(height: 18),
              const Text(
                'Data berhasil dihapus',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Data yang dipilih telah dihapus dari riwayatmu.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.dark2, fontSize: 13),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text('Kembali ke riwayat'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.light1),
    );
  }
}
