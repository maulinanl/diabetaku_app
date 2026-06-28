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

  final categories = const [
    'Glukosa',
    'Fisiologis',
    'Aktivitas',
    'Makan',
    'Obat',
  ];

  List<Map<String, dynamic>> glucose = [];
  List<Map<String, dynamic>> physiological = [];
  List<Map<String, dynamic>> activity = [];
  List<Map<String, dynamic>> meal = [];
  List<Map<String, dynamic>> medication = [];

  @override
  void initState() {
    super.initState();
    selectedIndex = categories.indexOf(widget.initialCategory);
    if (selectedIndex < 0) selectedIndex = 0;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      glucose = await ApiService.getPatientGlucoseRecords(widget.patientId);
      physiological =
          await ApiService.getPatientPhysiologicalRecords(widget.patientId);

      final behavioral =
          await ApiService.getPatientBehavioralRecords(widget.patientId);

      activity = List<Map<String, dynamic>>.from(
        behavioral['activities'] ?? [],
      );

      meal = List<Map<String, dynamic>>.from(
        behavioral['meals'] ?? [],
      );

      medication = await ApiService.getPatientMedicationRecords(widget.patientId);

      _sortAllData();

      if (!mounted) return;
      setState(() => isLoading = false);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  void _sortAllData() {
    glucose.sort((a, b) => _compareDateDesc(a['measured_at'], b['measured_at']));
    physiological.sort(
      (a, b) => _compareDateDesc(a['measured_at'], b['measured_at']),
    );
    activity.sort(
      (a, b) => _compareDateDesc(a['activity_date'], b['activity_date']),
    );
    meal.sort((a, b) => _compareDateDesc(a['meal_date'], b['meal_date']));
    medication.sort((a, b) => _compareDateDesc(a['log_date'], b['log_date']));
  }

  int _compareDateDesc(dynamic a, dynamic b) {
    final dateA = DateTime.tryParse(a?.toString() ?? '') ?? DateTime(2000);
    final dateB = DateTime.tryParse(b?.toString() ?? '') ?? DateTime(2000);
    return dateB.compareTo(dateA);
  }

  List<Map<String, dynamic>> get currentData {
    switch (categories[selectedIndex]) {
      case 'Glukosa':
        return glucose;
      case 'Fisiologis':
        return physiological;
      case 'Aktivitas':
        return activity;
      case 'Makan':
        return meal;
      case 'Obat':
        return medication;
      default:
        return [];
    }
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
            _categoryTabs(),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                      ? _errorState()
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: currentData.isEmpty
                              ? _emptyState()
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    18,
                                    14,
                                    18,
                                    28,
                                  ),
                                  itemCount: currentData.length,
                                  itemBuilder: (context, index) {
                                    return _historyCard(currentData[index]);
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
              'Riwayat Data Pasien',
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

  Widget _categoryTabs() {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(categories.length, (index) {
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
                    categories[index],
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
    final type = categories[selectedIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
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
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconBox(type),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _titleByType(type, item),
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _valueByType(type, item),
                  style: const TextStyle(
                    color: AppColors.dark1,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
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
                        _dateByType(type, item),
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
          _statusBadge(item, type),
        ],
      ),
    );
  }

  Widget _iconBox(String type) {
    IconData icon;

    switch (type) {
      case 'Glukosa':
        icon = Icons.opacity;
        break;
      case 'Fisiologis':
        icon = Icons.monitor_heart_outlined;
        break;
      case 'Aktivitas':
        icon = Icons.directions_run;
        break;
      case 'Makan':
        icon = Icons.restaurant_outlined;
        break;
      case 'Obat':
        icon = Icons.medication_outlined;
        break;
      default:
        icon = Icons.history;
    }

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: AppColors.primaryBlue, size: 21),
    );
  }

  String _titleByType(String type, Map<String, dynamic> item) {
    if (type == 'Glukosa') {
      return item['measurement_type']?.toString() ?? 'Data Glukosa';
    }

    if (type == 'Fisiologis') {
      return 'Data Fisiologis';
    }

    if (type == 'Aktivitas') {
      return item['activity_name']?.toString() ?? 'Aktivitas';
    }

    if (type == 'Makan') {
      return item['meal_type_name']?.toString() ?? 'Pola Makan';
    }

    if (type == 'Obat') {
      return item['medication_name']?.toString() ?? 'Kepatuhan Obat';
    }

    return 'Riwayat';
  }

  String _valueByType(String type, Map<String, dynamic> item) {
    if (type == 'Glukosa') {
      return '${item['glucose_value'] ?? '-'} mg/dL';
    }

    if (type == 'Fisiologis') {
      final systolic = item['systolic']?.toString() ?? '-';
      final diastolic = item['diastolic']?.toString() ?? '-';
      final weight = item['weight_kg']?.toString() ?? '-';
      final bmi = item['bmi']?.toString() ?? '-';

      return 'Tekanan darah: $systolic/$diastolic mmHg\nBerat badan: $weight kg • BMI: $bmi';
    }

    if (type == 'Aktivitas') {
      return '${item['duration_minutes'] ?? '-'} menit • ${item['intensity'] ?? '-'}';
    }

    if (type == 'Makan') {
      final desc = item['food_description']?.toString() ?? '-';
      final carb = item['carbohydrate_estimate']?.toString() ?? '-';
      final calories = item['calories']?.toString() ?? '-';

      return '$desc\nKarbohidrat: $carb gram • Kalori: $calories kkal';
    }

    if (type == 'Obat') {
      final status = item['status']?.toString() ?? '-';
      final session = item['session']?.toString() ?? '-';
      final dose = item['dose_per_session']?.toString() ?? '-';
      final dosage = item['dosage']?.toString() ?? '';
      final form = item['form']?.toString() ?? '';
      final checkedAt = item['checked_at'];
      final note = item['note']?.toString();

      final doseText = dosage.isNotEmpty || form.isNotEmpty
          ? '$dosage $form'.trim()
          : 'Dosis: $dose';

      final checkedText = checkedAt == null
          ? 'Belum ada waktu checklist'
          : 'Dicatat: ${_formatDateTime(checkedAt)}';

      final noteText =
          note == null || note.trim().isEmpty ? '' : '\nCatatan: $note';

      return '$status\nSesi: $session • $doseText\n$checkedText$noteText';
    }

    return '-';
  }

  String _dateByType(String type, Map<String, dynamic> item) {
    dynamic raw;

    if (type == 'Glukosa') raw = item['measured_at'];
    if (type == 'Fisiologis') raw = item['measured_at'];
    if (type == 'Aktivitas') raw = item['activity_date'];
    if (type == 'Makan') raw = item['meal_date'];
    if (type == 'Obat') raw = item['log_date'];

    return _formatDate(raw);
  }

  String _formatDate(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');

    if (date == null) return value?.toString() ?? '-';

    final local = date.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }

  String _formatDateTime(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');

    if (date == null) return value?.toString() ?? '-';

    final local = date.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year} • '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  Widget _statusBadge(Map<String, dynamic> item, String type) {
    final status = type == 'Obat'
        ? item['status']?.toString() ?? '-'
        : item['validation_status']?.toString() ?? 'Valid';

    Color bg;
    Color textColor;

    if (status == 'Valid' || status == 'Diminum') {
      bg = const Color(0xFFEAF7F1);
      textColor = const Color(0xFF10C878);
    } else if (status == 'Menunggu' || status == 'Terlambat') {
      bg = const Color(0xFFFFF3BA);
      textColor = Colors.orange;
    } else {
      bg = const Color(0xFFFFEAEA);
      textColor = AppColors.red;
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 82),
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