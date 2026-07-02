import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';

class DoctorPatientHealthHistoryPage extends StatefulWidget {
  final int patientId;
  final String initialCategory;

  const DoctorPatientHealthHistoryPage({
    super.key,
    required this.patientId,
    this.initialCategory = 'Glukosa',
  });

  @override
  State<DoctorPatientHealthHistoryPage> createState() =>
      _DoctorPatientHealthHistoryPageState();
}

class _DoctorPatientHealthHistoryPageState
    extends State<DoctorPatientHealthHistoryPage> {
  bool isLoading = true;
  String? errorMessage;
  int selectedIndex = 0;

  final filters = const [
    'Semua',
    'Glukosa',
    'Fisiologis',
    'Aktivitas',
    'Makan',
    'Obat',
  ];

  List<Map<String, dynamic>> histories = [];

  @override
  void initState() {
    super.initState();

    selectedIndex = filters.indexOf(widget.initialCategory);
    if (selectedIndex < 0) selectedIndex = 0;

    _loadData();
  }



  String _mealSummary(Map<String, dynamic> item) {
    final parts = <String>[];

    final carbohydrate = item['carbohydrate_estimate'];
    if (carbohydrate != null && carbohydrate.toString().trim().isNotEmpty) {
      parts.add('Karbohidrat $carbohydrate gram');
    }

    final calories = item['calories'];
    if (calories != null && calories.toString().trim().isNotEmpty) {
      parts.add('Kalori $calories kkal');
    }

    return parts.join(' • ');
  }

  String _medicationDescription(Map<String, dynamic> item) {
    final parts = <String>[];

    final session = item['session']?.toString() ??
        item['session_name']?.toString() ??
        '';
    if (session.trim().isNotEmpty && session.trim() != '-') {
      parts.add('Sesi $session');
    }

    final dose = item['dose_per_session']?.toString() ??
        item['dosage']?.toString() ??
        '';
    if (dose.trim().isNotEmpty && dose.trim() != '-') {
      parts.add(dose);
    }

    final doctor = item['doctor_name']?.toString() ?? '';
    if (doctor.trim().isNotEmpty && doctor.trim() != '-') {
      parts.add('Resep dari $doctor');
    }

    return parts.join(' • ');
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final results = await Future.wait([
        ApiService.getPatientGlucoseRecords(widget.patientId),
        ApiService.getPatientPhysiologicalRecords(widget.patientId),
        ApiService.getPatientBehavioralRecords(widget.patientId),
        ApiService.getPatientMedicationRecords(widget.patientId),
      ]);

      final glucose = List<Map<String, dynamic>>.from(results[0] as List);
      final physiological = List<Map<String, dynamic>>.from(results[1] as List);
      final behavioral = Map<String, dynamic>.from(results[2] as Map);
      final medication = List<Map<String, dynamic>>.from(results[3] as List);

      final mapped = <Map<String, dynamic>>[
        ..._mapGlucose(glucose),
        ..._mapPhysiological(physiological),
        ..._mapActivity(
          List<Map<String, dynamic>>.from(behavioral['activities'] ?? []),
        ),
        ..._mapMeal(
          List<Map<String, dynamic>>.from(behavioral['meals'] ?? []),
        ),
        ..._mapMedication(medication),
      ];

      mapped.sort((a, b) {
        final dateA = DateTime.tryParse(a['date_raw']?.toString() ?? '') ??
            DateTime(2000);
        final dateB = DateTime.tryParse(b['date_raw']?.toString() ?? '') ??
            DateTime(2000);

        return dateB.compareTo(dateA);
      });

      if (!mounted) return;

      setState(() {
        histories = mapped;
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

  List<Map<String, dynamic>> _mapGlucose(List<Map<String, dynamic>> data) {
    return data.map((item) {
      return {
        'type': 'Glukosa',
        'title': 'Glukosa ${item['measurement_type'] ?? '-'}',
        'value': '${item['glucose_value'] ?? '-'}',
        'unit': 'mg/dL',
        'time': _formatDateTime(item['measured_at']),
        'date_raw': item['measured_at'],
        'badge': item['validation_status'] ?? 'Valid',
        'icon': Icons.opacity,
        'color': AppColors.red,
      };
    }).toList();
  }

  List<Map<String, dynamic>> _mapPhysiological(
    List<Map<String, dynamic>> data,
  ) {
    return data.map((item) {
      final systolic = item['systolic']?.toString() ?? '-';
      final diastolic = item['diastolic']?.toString() ?? '-';
      final weight = item['weight_kg']?.toString() ?? '-';
      final bmi = item['bmi']?.toString() ?? '-';

      return {
        'type': 'Fisiologis',
        'title': 'Data Fisiologis',
        'value': '$systolic/$diastolic',
        'unit': 'mmHg',
        'description': 'Berat $weight kg • BMI $bmi',
        'time': _formatDateTime(item['measured_at']),
        'date_raw': item['measured_at'],
        'badge': item['validation_status'] ?? 'Valid',
        'icon': Icons.monitor_heart_outlined,
        'color': Colors.orange,
      };
    }).toList();
  }

  List<Map<String, dynamic>> _mapActivity(List<Map<String, dynamic>> data) {
    return data.map((item) {
      return {
        'type': 'Aktivitas',
        'title': item['activity_name']?.toString() ?? 'Aktivitas',
        'value': '${item['duration_minutes'] ?? '-'}',
        'unit': 'menit',
        'description': item['intensity']?.toString() ?? '-',
        'time': _formatDateTime(item['activity_date']),
        'date_raw': item['activity_date'],
        'badge': item['validation_status'] ?? 'Valid',
        'icon': Icons.directions_run,
        'color': AppColors.primaryBlue,
      };
    }).toList();
  }

  List<Map<String, dynamic>> _mapMeal(List<Map<String, dynamic>> data) {
    return data.map((item) {
      return {
        'type': 'Makan',
        'title': item['meal_type_name']?.toString() ?? 'Pola Makan',
        'value': '',
        'unit': '',
        'description': _mealSummary(item),
        'time': _formatDateTime(item['meal_date']),
        'date_raw': item['meal_date'],
        'badge': item['validation_status'] ?? 'Valid',
        'icon': Icons.restaurant_outlined,
        'color': AppColors.primaryBlue,
      };
    }).toList();
  }

  List<Map<String, dynamic>> _mapMedication(List<Map<String, dynamic>> data) {
    return data.map((item) {
      final status = item['status']?.toString() ?? '-';

      return {
        'type': 'Obat',
        'title': item['medication_name']?.toString() ?? 'Obat',
        'value': '',
        'unit': '',
        'description': _medicationDescription(item),
        'time': _formatDateTime(item['log_date']),
        'date_raw': item['log_date'],
        'badge': status,
        'icon': Icons.medication_outlined,
        'color': status == 'Terlewat' ? AppColors.red : AppColors.primaryBlue,
      };
    }).toList();
  }

  List<Map<String, dynamic>> get filteredHistories {
    if (selectedIndex == 0) return histories;

    final selectedType = filters[selectedIndex];

    return histories.where((item) => item['type'] == selectedType).toList();
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
            _filterTabs(),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                      ? _errorState()
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: filteredHistories.isEmpty
                              ? _emptyState()
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    18,
                                    12,
                                    18,
                                    28,
                                  ),
                                  itemCount: filteredHistories.length,
                                  itemBuilder: (context, index) {
                                    return _historyCard(
                                      filteredHistories[index],
                                    );
                                  },
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
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12, topPad + 12, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              'Riwayat Data Kesehatan',
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
    );
  }

  Widget _filterTabs() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      color: AppColors.background,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(filters.length, (index) {
            final selected = selectedIndex == index;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => selectedIndex = index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.lightBlue : AppColors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: selected
                          ? AppColors.lightBlue
                          : AppColors.light1,
                    ),
                  ),
                  child: Text(
                    filters[index],
                    style: TextStyle(
                      color: selected
                          ? AppColors.primaryBlue
                          : AppColors.dark2,
                      fontSize: 13,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _historyCard(Map<String, dynamic> item) {
    final color = item['color'] as Color? ?? AppColors.primaryBlue;
    final description = item['description']?.toString() ?? '';
    final value = item['value']?.toString().trim() ?? '';
    final unit = item['unit']?.toString().trim() ?? '';
    final hasValue = value.isNotEmpty && value != '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.light1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item['icon'] as IconData? ?? Icons.history,
                color: color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title']?.toString() ?? 'Riwayat',
                  style: const TextStyle(
                    color: AppColors.dark1,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                if (hasValue) ...[
                  RichText(
                    text: TextSpan(
                      text: value,
                      style: TextStyle(
                        color: color,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      children: [
                        TextSpan(
                          text: unit.isEmpty ? '' : ' $unit',
                          style: const TextStyle(
                            color: AppColors.dark2,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (description.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.dark2,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 13,
                      color: AppColors.dark3,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item['time']?.toString() ?? '-',
                        style: const TextStyle(
                          color: AppColors.dark3,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _statusBadge(item['badge']?.toString() ?? '-'),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color bg;
    Color textColor;

    if (status == 'Valid' || status == 'Diminum') {
      bg = const Color(0xFFEAF7F1);
      textColor = const Color(0xFF10C878);
    } else if (status == 'Menunggu' || status == 'Terlewat') {
      bg = const Color(0xFFFFF3BA);
      textColor = Colors.orange;
    } else {
      bg = const Color(0xFFFFEAEA);
      textColor = AppColors.red;
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 86),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDateTime(dynamic value) {
    if (value == null) return '-';

    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();

    final local = date.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year} • '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  Widget _emptyState() {
    return ListView(
      children: const [
        SizedBox(height: 130),
        Icon(Icons.history, color: AppColors.primaryBlue, size: 50),
        SizedBox(height: 14),
        Center(
          child: Text(
            'Belum ada data pada kategori ini',
            style: TextStyle(
              color: AppColors.dark2,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          errorMessage ?? 'Gagal memuat data',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.dark2),
        ),
      ),
    );
  }
}
