import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/diabetes_type_badge.dart';
import 'patient_threshold_page.dart';
import 'clinical_note_form_page.dart';
import 'doctor_prescription_page.dart';
import '../../../data/services/api_service.dart';
import 'doctor_patient_health_history_page.dart';

class PatientDetailPage extends StatefulWidget {
  final int patientId;
  final bool isConnected;

  const PatientDetailPage({
    super.key,
    required this.patientId,
    this.isConnected = true,
  });

  @override
  State<PatientDetailPage> createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends State<PatientDetailPage> {
  bool isLoading = true;
  String? errorMessage;

  Map<String, dynamic>? dashboardData;

  List<Map<String, dynamic>> glucoseRecords = [];
  List<Map<String, dynamic>> physiologicalRecords = [];
  List<Map<String, dynamic>> activityRecords = [];
  List<Map<String, dynamic>> mealRecords = [];
  List<Map<String, dynamic>> medicationRecords = [];
  List<Map<String, dynamic>> thresholdRecords = [];

  Map<String, dynamic> get profile => dashboardData?['profile'] ?? {};

  Map<String, dynamic>? get latestGlucose => dashboardData?['latest_glucose'];

  Map<String, dynamic>? get latestPhysiological =>
      dashboardData?['latest_physiological'];

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || name.trim().isEmpty) return '-';

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
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

  int selectedTab = 0;
  int selectedPeriod = 0;
  int selectedBehaviorTab = 0;

  final tabs = ['Glukosa', 'Fisiologis', 'Perilaku', 'Resep'];
  final periods = ['7 Hari', '30 Hari', '3 Bulan', 'Kustom'];
  final behaviorTabs = ['Aktivitas', 'Pola Makan', 'Obat'];

  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    _fetchDashboard();
  }

  Future<void> _fetchDashboard() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final results = await Future.wait([
        ApiService.getPatientDashboard(widget.patientId),
        ApiService.getPatientGlucoseRecords(widget.patientId),
        ApiService.getPatientPhysiologicalRecords(widget.patientId),
        ApiService.getPatientBehavioralRecords(widget.patientId),
        ApiService.getPatientMedicationRecords(widget.patientId),
        ApiService.getPatientThresholds(widget.patientId),
      ]);

      if (!mounted) return;

      final dashboard = results[0] as Map<String, dynamic>;
      final glucose = List<Map<String, dynamic>>.from(results[1] as List);
      final physiological = List<Map<String, dynamic>>.from(results[2] as List);
      final behavioral = Map<String, dynamic>.from(results[3] as Map);
      final medication = List<Map<String, dynamic>>.from(results[4] as List);
      final thresholds = List<Map<String, dynamic>>.from(results[5] as List);

      setState(() {
        dashboardData = dashboard;
        glucoseRecords = glucose;
        physiologicalRecords = physiological;
        activityRecords = List<Map<String, dynamic>>.from(
          behavioral['activities'] ?? [],
        );
        mealRecords = List<Map<String, dynamic>>.from(
          behavioral['meals'] ?? [],
        );
        medicationRecords = medication;
        thresholdRecords = thresholds;
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text(errorMessage!)),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.background,
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

                      if (!widget.isConnected) ...[
                        _disconnectedBanner(),
                        const SizedBox(height: 20),
                      ],

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

                      if (selectedTab != 3 && widget.isConnected) ...[
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

    final name = profile['full_name']?.toString() ?? '-';
    final gender = profile['gender']?.toString() ?? '-';
    final diabetesType = profile['diabetes_type']?.toString() ?? '-';
    final age = _calculateAge(profile['date_of_birth']?.toString());
    final initials = _getInitials(name);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 24),
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
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Expanded(
                child: Text(
                  'Detail Pasien',
                  textAlign: TextAlign.center,
                  style: TextStyle(
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.lightBlue,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
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
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$age tahun • $gender',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.dark2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              DiabetesTypeBadge(value: diabetesType, inactive: !widget.isConnected),
                              if (!widget.isConnected)
                                _badge(
                                  text: 'Tidak Terhubung',
                                  bg: AppColors.light4,
                                  color: AppColors.dark2,
                                  icon: Icons.link_off_rounded,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (widget.isConnected) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ClinicalNoteFormPage(
                              patientId: widget.patientId,
                              patientProfile: profile,
                            ),
                          ),
                        );

                        if (mounted) {
                          _fetchDashboard();
                        }
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _disconnectedBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.light1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.light4.withValues(alpha: 0.18)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.dark4, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Pasien ini sudah tidak terhubung. Dokter hanya dapat melihat data lama sebelum relasi terputus.',
              style: TextStyle(
                color: AppColors.dark4,
                fontSize: 12,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }


  double? _asDouble(dynamic value) {
    if (value == null) return null;

    return double.tryParse(value.toString().replaceAll(',', '.'));
  }

  String _calculatedBmi(Map<String, dynamic>? physiological) {
    final existing = _asDouble(physiological?['bmi']);

    if (existing != null && existing > 0) {
      return existing.toStringAsFixed(1);
    }

    final weight = _asDouble(physiological?['weight_kg']);
    final heightCm = _asDouble(profile['height_cm']);

    if (weight == null || heightCm == null || heightCm <= 0) {
      return '-';
    }

    final heightMeter = heightCm / 100;
    final bmi = weight / (heightMeter * heightMeter);

    return bmi.toStringAsFixed(1);
  }

  Widget _buildSummaryCards() {
    final glucoseValue = latestGlucose?['glucose_value']?.toString() ?? '-';

    final systolic = latestPhysiological?['systolic']?.toString() ?? '-';
    final diastolic = latestPhysiological?['diastolic']?.toString() ?? '-';
    final bmi = _calculatedBmi(latestPhysiological);

    final items = [
      [
        'Glukosa',
        glucoseValue,
        'mg/dL',
        glucoseValue == '-' ? 'Belum ada' : 'Tercatat',
        AppColors.primaryBlue,
      ],
      [
        'Tekanan Darah',
        '$systolic/$diastolic',
        'mmHg',
        systolic == '-' ? 'Belum ada' : 'Tercatat',
        Colors.orange,
      ],
      ['BMI', bmi, '', bmi == '-' ? 'Belum ada' : 'Tercatat', Colors.blue],
      [
        'Kepatuhan Obat',
        medicationRecords.isEmpty
            ? '-'
            : '${_medicationAdherencePercent().toStringAsFixed(0)}',
        medicationRecords.isEmpty ? '' : '%',
        _latestMedicationStatus(),
        const Color(0xFF10C878),
      ],
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
    final rows = thresholdRecords.map((item) {
      final name = item['parameter_name']?.toString() ?? '-';
      final min =
          double.tryParse(
            (item['custom_min'] ?? item['default_min'] ?? '').toString(),
          )?.toStringAsFixed(2) ??
          '-';
      final max =
          double.tryParse(
            (item['custom_max'] ?? item['default_max'] ?? '').toString(),
          )?.toStringAsFixed(2) ??
          '-';
      final unit = item['unit']?.toString() ?? '';

      return [name, '$min - $max', unit.isEmpty ? '' : '($unit)'];
    }).toList();

    if (rows.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.light1),
        ),
        child: const Text(
          'Batas normal belum tersedia',
          style: TextStyle(color: AppColors.dark2),
        ),
      );
    }

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
              if (widget.isConnected)
                OutlinedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PatientThresholdPage(
                          patientId: widget.patientId,
                          patientProfile: profile,
                          onThresholdChanged: _fetchThresholdOnly,
                        ),
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

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  String _periodLabel() {
    if (selectedPeriod == 0) return '7 Hari Terakhir';
    if (selectedPeriod == 1) return '30 Hari Terakhir';
    if (selectedPeriod == 2) return '3 Bulan Terakhir';

    if (selectedDateRange != null) {
      return '${_formatDate(selectedDateRange!.start)} - ${_formatDate(selectedDateRange!.end)}';
    }

    return 'Kustom';
  }

  List<Map<String, dynamic>> _filterRecordsByPeriod(
    List<Map<String, dynamic>> records,
    String dateKey,
  ) {
    final now = DateTime.now();
    DateTime startDate;

    if (selectedPeriod == 0) {
      startDate = now.subtract(const Duration(days: 7));
    } else if (selectedPeriod == 1) {
      startDate = now.subtract(const Duration(days: 30));
    } else if (selectedPeriod == 2) {
      startDate = now.subtract(const Duration(days: 90));
    } else {
      startDate =
          selectedDateRange?.start ?? now.subtract(const Duration(days: 7));
    }

    final endDate = selectedPeriod == 3 && selectedDateRange != null
        ? selectedDateRange!.end.add(const Duration(days: 1))
        : now.add(const Duration(days: 1));

    return records.where((item) {
      final date = _parseDate(item[dateKey]);
      if (date == null) return false;

      return !date.isBefore(startDate) && date.isBefore(endDate);
    }).toList();
  }

  List<FlSpot> _buildSpotsFromRecords({
    required List<Map<String, dynamic>> records,
    required String valueKey,
    required String dateKey,
  }) {
    if (records.isEmpty) return const [FlSpot(0, 0), FlSpot(1, 0)];

    final Map<String, List<double>> grouped = {};

    for (final item in records) {
      final date = _parseDate(item[dateKey]);
      final value = double.tryParse(item[valueKey]?.toString() ?? '');

      if (date == null || value == null) continue;

      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(value);
    }

    final sortedKeys = grouped.keys.toList()..sort();

    if (sortedKeys.isEmpty) return const [FlSpot(0, 0), FlSpot(1, 0)];

    return List.generate(sortedKeys.length, (index) {
      final values = grouped[sortedKeys[index]]!;
      final average = values.reduce((a, b) => a + b) / values.length;

      return FlSpot(index.toDouble(), average);
    });
  }

  String _activeHistoryCategory() {
    if (selectedTab == 0) return 'Glukosa';
    if (selectedTab == 1) return 'Fisiologis';

    if (selectedTab == 2) {
      if (selectedBehaviorTab == 0) return 'Aktivitas';
      if (selectedBehaviorTab == 1) return 'Makan';
      return 'Obat';
    }

    return 'Glukosa';
  }

  void _openFullHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorPatientHealthHistoryPage(
          patientId: widget.patientId,
          initialCategory: _activeHistoryCategory(),
        ),
      ),
    );
  }

  List<List<String>> _latestFiveHistory({
    required List<Map<String, dynamic>> records,
    required String titleKey,
    required String dateKey,
    required String valueKey,
    required String unit,
  }) {
    final sorted = [...records]
      ..sort((a, b) {
        final dateA = _parseDate(a[dateKey]) ?? DateTime(2000);
        final dateB = _parseDate(b[dateKey]) ?? DateTime(2000);
        return dateB.compareTo(dateA);
      });

    return sorted.take(5).map((item) {
      return [
        item[titleKey]?.toString() ?? '-',
        item[dateKey]?.toString() ?? '-',
        '${item[valueKey]?.toString() ?? '-'} $unit',
      ];
    }).toList();
  }

  Widget _buildDynamicContent() {
    if (selectedTab == 3) {
      return DoctorPrescriptionPage(
        patientId: widget.patientId,
        isConnected: widget.isConnected,
      );
    }

    if (selectedTab == 0) {
      final filteredGlucose = _filterRecordsByPeriod(
        glucoseRecords,
        'measured_at',
      );

      final history = _latestFiveHistory(
        records: filteredGlucose,
        titleKey: 'measurement_type',
        dateKey: 'measured_at',
        valueKey: 'glucose_value',
        unit: 'mg/dL',
      );

      return _buildTrendAndHistory(
        title: 'Tren Glukosa',
        unitLabel: 'mg/dL',
        lineColor: AppColors.red,
        spots: _buildSpotsFromRecords(
          records: filteredGlucose,
          valueKey: 'glucose_value',
          dateKey: 'measured_at',
        ),
        history: history.isEmpty
            ? [
                ['Belum ada data', '-', '-'],
              ]
            : history,
      );
    }

    if (selectedTab == 1) {
      final filteredPhysiological = _filterRecordsByPeriod(
        physiologicalRecords,
        'measured_at',
      );

      final sortedPhysiological = [...filteredPhysiological]
        ..sort((a, b) {
          final dateA = _parseDate(a['measured_at']) ?? DateTime(2000);
          final dateB = _parseDate(b['measured_at']) ?? DateTime(2000);
          return dateB.compareTo(dateA);
        });

      final history = sortedPhysiological.take(5).map((item) {
        final date = item['measured_at']?.toString() ?? '-';
        final systolic = item['systolic']?.toString() ?? '-';
        final diastolic = item['diastolic']?.toString() ?? '-';
        final bmi = _calculatedBmi(item);

        return [
          'Data Fisiologis',
          date,
          '$systolic/$diastolic mmHg • BMI $bmi',
        ];
      }).toList();

      return _buildPhysiologicalContent(
        records: filteredPhysiological,
        history: history.isEmpty
            ? [
                ['Belum ada data', '-', '-'],
              ]
            : history,
      );
    }

    return _buildBehaviorContent();
  }

  List<FlSpot> _buildMedicationSpots(List<Map<String, dynamic>> records) {
    if (records.isEmpty) return const [FlSpot(0, 0), FlSpot(1, 0)];

    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final item in records) {
      final date = _parseDate(item['log_date']);
      if (date == null) continue;

      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(item);
    }

    final sortedKeys = grouped.keys.toList()..sort();

    if (sortedKeys.isEmpty) return const [FlSpot(0, 0), FlSpot(1, 0)];

    return List.generate(sortedKeys.length, (index) {
      final items = grouped[sortedKeys[index]]!;
      final taken = items.where((item) {
        return item['status']?.toString() == 'Diminum';
      }).length;

      final percent = (taken / items.length) * 100;

      return FlSpot(index.toDouble(), percent);
    });
  }

  Widget _buildBehaviorContent() {
    final filteredActivity = _filterRecordsByPeriod(
      activityRecords,
      'activity_date',
    );

    final filteredMeal = _filterRecordsByPeriod(mealRecords, 'meal_date');

    final activityHistory = _latestFiveHistory(
      records: filteredActivity,
      titleKey: 'activity_name',
      dateKey: 'activity_date',
      valueKey: 'duration_minutes',
      unit: 'menit',
    );

    final mealHistory = _latestFiveHistory(
      records: filteredMeal,
      titleKey: 'meal_type_name',
      dateKey: 'meal_date',
      valueKey: 'carbohydrate_estimate',
      unit: 'gr',
    );

    if (selectedBehaviorTab == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBehaviorTabs(),
          const SizedBox(height: 18),
          _buildTrendAndHistory(
            title: 'Tren Aktivitas Fisik',
            unitLabel: 'menit',
            lineColor: AppColors.primaryBlue,
            spots: _buildSpotsFromRecords(
              records: filteredActivity,
              valueKey: 'duration_minutes',
              dateKey: 'activity_date',
            ),
            history: activityHistory.isEmpty
                ? [
                    ['Belum ada data', '-', '-'],
                  ]
                : activityHistory,
          ),
        ],
      );
    }

    if (selectedBehaviorTab == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBehaviorTabs(),
          const SizedBox(height: 18),
          _buildTrendAndHistory(
            title: 'Tren Estimasi Karbohidrat',
            unitLabel: 'gram',
            lineColor: AppColors.primaryBlue,
            spots: _buildSpotsFromRecords(
              records: filteredMeal,
              valueKey: 'carbohydrate_estimate',
              dateKey: 'meal_date',
            ),
            history: mealHistory.isEmpty
                ? [
                    ['Belum ada data', '-', '-'],
                  ]
                : mealHistory,
          ),
        ],
      );
    }

    final filteredMedication = _filterRecordsByPeriod(
      medicationRecords,
      'log_date',
    );

    final medicationHistory = filteredMedication.take(5).map((item) {
      final drugName = item['medication_name']?.toString() ?? 'Obat';
      final session = item['session_name']?.toString() ?? '-';
      final dose = item['dose_per_session']?.toString() ?? '-';
      final date = item['log_date']?.toString() ?? '-';
      final status = item['status']?.toString() ?? '-';

      return ['$drugName • $session', date, '$status • $dose'];
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBehaviorTabs(),
        const SizedBox(height: 18),
        _buildTrendAndHistory(
          title: 'Tren Kepatuhan Obat',
          unitLabel: '%',
          lineColor: AppColors.primaryBlue,
          spots: _buildMedicationSpots(filteredMedication),
          history: medicationHistory.isEmpty
              ? [
                  ['Belum ada data', '-', '-'],
                ]
              : medicationHistory,
        ),
      ],
    );
  }

  double _medicationAdherencePercent() {
    if (medicationRecords.isEmpty) return 0;

    final taken = medicationRecords.where((item) {
      return item['status']?.toString() == 'Diminum';
    }).length;

    return (taken / medicationRecords.length) * 100;
  }

  String _latestMedicationStatus() {
    if (medicationRecords.isEmpty) return 'Belum ada';

    final latest = [...medicationRecords]
      ..sort((a, b) {
        final dateA = _parseDate(a['log_date']) ?? DateTime(2000);
        final dateB = _parseDate(b['log_date']) ?? DateTime(2000);
        return dateB.compareTo(dateA);
      });

    return latest.first['status']?.toString() ?? 'Belum ada';
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

  Future<void> _fetchThresholdOnly() async {
    try {
      final thresholds = await ApiService.getPatientThresholds(
        widget.patientId,
      );

      if (!mounted) return;

      setState(() {
        thresholdRecords = thresholds;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Widget _buildPhysiologicalContent({
    required List<Map<String, dynamic>> records,
    required List<List<String>> history,
  }) {
    final systolicSpots = _buildSpotsFromRecords(
      records: records,
      valueKey: 'systolic',
      dateKey: 'measured_at',
    );

    final diastolicSpots = _buildSpotsFromRecords(
      records: records,
      valueKey: 'diastolic',
      dateKey: 'measured_at',
    );

    final bmiSpots = _buildSpotsFromRecords(
      records: records,
      valueKey: 'bmi',
      dateKey: 'measured_at',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMultiLineTrendCard(
          title: 'Tren Tekanan Darah',
          unitLabel: 'mmHg',
          firstLabel: 'Sistolik',
          firstColor: AppColors.primaryBlue,
          firstSpots: systolicSpots,
          secondLabel: 'Diastolik',
          secondColor: Colors.orange,
          secondSpots: diastolicSpots,
        ),
        const SizedBox(height: 18),
        _buildSingleLineTrendCard(
          title: 'Tren BMI',
          unitLabel: 'BMI',
          lineColor: const Color(0xFF10C878),
          spots: bmiSpots,
        ),
        const SizedBox(height: 18),
        _buildHistorySection(history),
      ],
    );
  }

  Widget _buildHistorySection(List<List<String>> history) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              borderRadius: BorderRadius.circular(10),
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
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            onPressed: _openFullHistory,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Lihat Semua Riwayat',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleLineTrendCard({
    required String title,
    required String unitLabel,
    required Color lineColor,
    required List<FlSpot> spots,
  }) {
    final safeSpots = spots.isEmpty
        ? const [FlSpot(0, 0), FlSpot(1, 0)]
        : spots;

    final values = safeSpots.map((e) => e.y).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);

    final paddingY = maxValue <= 10 ? 2 : 20;
    final minY = (minValue - paddingY).clamp(0, double.infinity).toDouble();
    final maxY = maxValue + paddingY;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _trendTitle(title),
        const SizedBox(height: 12),
        Container(
          height: 230,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          decoration: _trendCardDecoration(),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.show_chart, color: lineColor, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Trend $unitLabel',
                      style: const TextStyle(
                        color: AppColors.dark2,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
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
              const SizedBox(height: 12),
              Expanded(
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: safeSpots.length > 1
                        ? (safeSpots.length - 1).toDouble()
                        : 1,
                    minY: minY,
                    maxY: maxY,
                    gridData: _chartGridData(maxY),
                    titlesData: _chartTitlesData(maxY, safeSpots),
                    borderData: FlBorderData(show: false),
                    lineTouchData: _chartTouchData(unitLabel),
                    lineBarsData: [
                      _lineBarData(
                        spots: safeSpots,
                        color: lineColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMultiLineTrendCard({
    required String title,
    required String unitLabel,
    required String firstLabel,
    required Color firstColor,
    required List<FlSpot> firstSpots,
    required String secondLabel,
    required Color secondColor,
    required List<FlSpot> secondSpots,
  }) {
    final safeFirst = firstSpots.isEmpty
        ? const [FlSpot(0, 0), FlSpot(1, 0)]
        : firstSpots;
    final safeSecond = secondSpots.isEmpty
        ? const [FlSpot(0, 0), FlSpot(1, 0)]
        : secondSpots;

    final values = [...safeFirst, ...safeSecond].map((e) => e.y).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);

    final paddingY = maxValue <= 10 ? 2 : 20;
    final minY = (minValue - paddingY).clamp(0, double.infinity).toDouble();
    final maxY = maxValue + paddingY;
    final longestSpots = safeFirst.length >= safeSecond.length
        ? safeFirst
        : safeSecond;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _trendTitle(title),
        const SizedBox(height: 12),
        Container(
          height: 250,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          decoration: _trendCardDecoration(),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.monitor_heart_outlined,
                    color: AppColors.primaryBlue,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Trend mmHg',
                      style: TextStyle(
                        color: AppColors.dark2,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  _chartLegend(firstLabel, firstColor),
                  const SizedBox(width: 8),
                  _chartLegend(secondLabel, secondColor),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: longestSpots.length > 1
                        ? (longestSpots.length - 1).toDouble()
                        : 1,
                    minY: minY,
                    maxY: maxY,
                    gridData: _chartGridData(maxY),
                    titlesData: _chartTitlesData(maxY, longestSpots),
                    borderData: FlBorderData(show: false),
                    lineTouchData: _chartTouchData(unitLabel),
                    lineBarsData: [
                      _lineBarData(spots: safeFirst, color: firstColor),
                      _lineBarData(spots: safeSecond, color: secondColor),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _trendTitle(String title) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.dark1,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.veryLightBlue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.isConnected ? _periodLabel() : 'Data Lama',
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _chartLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.dark2,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  BoxDecoration _trendCardDecoration() {
    return BoxDecoration(
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
    );
  }

  FlGridData _chartGridData(double maxY) {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: _getInterval(maxY),
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: AppColors.light1.withValues(alpha: 0.7),
          strokeWidth: 1,
        );
      },
    );
  }

  FlTitlesData _chartTitlesData(double maxY, List<FlSpot> spots) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 36,
          interval: _getInterval(maxY),
          getTitlesWidget: (value, meta) {
            return Text(
              value.toInt().toString(),
              style: const TextStyle(
                color: AppColors.dark3,
                fontSize: 10,
              ),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 26,
          interval: 1,
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _bottomLabel(value.toInt(), spots),
                style: const TextStyle(
                  color: AppColors.dark3,
                  fontSize: 10,
                ),
              ),
            );
          },
        ),
      ),
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    );
  }

  LineTouchData _chartTouchData(String unitLabel) {
    return LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        getTooltipItems: (spots) {
          return spots.map((spot) {
            return LineTooltipItem(
              '${spot.y.toStringAsFixed(0)} $unitLabel',
              const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            );
          }).toList();
        },
      ),
    );
  }

  LineChartBarData _lineBarData({
    required List<FlSpot> spots,
    required Color color,
  }) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.32,
      barWidth: 3,
      color: color,
      isStrokeCapRound: true,
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: 0.10),
      ),
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          final isLast = index == spots.length - 1;

          return FlDotCirclePainter(
            radius: isLast ? 4 : 2.6,
            color: isLast ? color : AppColors.white,
            strokeWidth: 2,
            strokeColor: color,
          );
        },
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
    final safeSpots = spots.isEmpty
        ? const [FlSpot(0, 0), FlSpot(1, 0)]
        : spots;

    final values = safeSpots.map((e) => e.y).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);

    final paddingY = maxValue <= 10 ? 2 : 20;
    final minY = (minValue - paddingY).clamp(0, double.infinity).toDouble();
    final maxY = maxValue + paddingY;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.dark1,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.veryLightBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.isConnected ? _periodLabel() : 'Data Lama',
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Container(
          height: 230,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
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
            children: [
              Row(
                children: [
                  Icon(Icons.show_chart, color: lineColor, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Trend $unitLabel',
                      style: const TextStyle(
                        color: AppColors.dark2,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
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
              const SizedBox(height: 12),

              Expanded(
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: safeSpots.length > 1
                        ? (safeSpots.length - 1).toDouble()
                        : 1,
                    minY: minY,
                    maxY: maxY,

                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: _getInterval(maxY),
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: AppColors.light1.withValues(alpha: 0.7),
                          strokeWidth: 1,
                        );
                      },
                    ),

                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 36,
                          interval: _getInterval(maxY),
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                color: AppColors.dark3,
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 26,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _bottomLabel(value.toInt(), safeSpots),
                                style: const TextStyle(
                                  color: AppColors.dark3,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),

                    borderData: FlBorderData(show: false),

                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (spots) {
                          return spots.map((spot) {
                            return LineTooltipItem(
                              '${spot.y.toStringAsFixed(0)} $unitLabel',
                              const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),

                    lineBarsData: [
                      LineChartBarData(
                        spots: safeSpots,
                        isCurved: true,
                        curveSmoothness: 0.32,
                        barWidth: 3,
                        color: lineColor,
                        isStrokeCapRound: true,
                        belowBarData: BarAreaData(
                          show: true,
                          color: lineColor.withValues(alpha: 0.12),
                        ),
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            final isLast = index == safeSpots.length - 1;

                            return FlDotCirclePainter(
                              radius: isLast ? 4 : 2.6,
                              color: isLast ? lineColor : AppColors.white,
                              strokeWidth: 2,
                              strokeColor: lineColor,
                            );
                          },
                        ),
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
              borderRadius: BorderRadius.circular(10),
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            onPressed: _openFullHistory,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Lihat Semua Riwayat',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  double _getInterval(double maxY) {
    if (maxY <= 10) return 2;
    if (maxY <= 50) return 10;
    if (maxY <= 120) return 20;
    if (maxY <= 250) return 50;
    return 100;
  }

  String _bottomLabel(int index, List<FlSpot> spots) {
    if (spots.length > 7) {
      if (index % 2 != 0) return '';
    }

    return (index + 1).toString();
  }

  Future<void> _pickCustomRange() async {
    final picked = await _showCompactDateRangePicker();

    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
        selectedPeriod = 3;
      });
    }
  }

  Future<DateTimeRange?> _showCompactDateRangePicker() async {
    DateTime? startDate = selectedDateRange?.start;
    DateTime? endDate = selectedDateRange?.end;
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
                                : _formatDate(startDate!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _rangeBox(
                            label: 'Selesai',
                            value: endDate == null
                                ? '-'
                                : _formatDate(endDate!),
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
                          lastDate: DateTime(2035),
                          onDateChanged: (date) {
                            setDialogState(() {
                              if (startDate == null || endDate != null) {
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildDisconnectButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _showDisconnectConfirmationSheet,
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

  void _showDisconnectConfirmationSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 28),

                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: AppColors.lightRed,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.link_off_rounded,
                      color: AppColors.red,
                      size: 58,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Yakin ingin putus relasi?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Dokter tidak akan lagi terhubung dengan pasien ini. Data lama tetap dapat dilihat sesuai riwayat.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.dark2,
                    ),
                  ),

                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(sheetContext);
                        await _disconnectPatient();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Putus Relasi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _disconnectPatient() async {
    try {
      await ApiService.disconnectDoctorPatient(widget.patientId);

      if (!mounted) return;

      await _showDisconnectSuccessSheet();

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _showDisconnectSuccessSheet() async {
    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      color: AppColors.veryLightBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.primaryBlue,
                      size: 54,
                    ),
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'Relasi Berhasil Diputus',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Pasien telah dihapus dari daftar pasien aktif dokter.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.dark2,
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
