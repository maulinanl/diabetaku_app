import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';
import 'patient_recommendation_detail_page.dart';

class PatientHistoryPage extends StatefulWidget {
  const PatientHistoryPage({super.key});

  @override
  State<PatientHistoryPage> createState() => _PatientHistoryPageState();
}

class _PatientHistoryPageState extends State<PatientHistoryPage> {
  int mainTab = 0;
  int healthFilter = 0;
  int? selectedDoctorId;

  DateTimeRange? selectedRange;

  bool isLoading = true;
  String? errorMessage;

  List<Map<String, dynamic>> healthHistories = [];
  List<Map<String, dynamic>> recommendationHistories = [];
  List<Map<String, dynamic>> connectedDoctors = [];

  final healthFilters = const [
    'Semua',
    'Glukosa',
    'Fisiologis',
    'Aktivitas',
    'Makan',
    'Obat',
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final patientId = prefs.getInt('patient_id');

      if (patientId == null) {
        throw Exception('Patient ID tidak ditemukan. Coba login ulang.');
      }

      final results = await Future.wait([
        ApiService.getPatientHealthHistory(patientId),
        ApiService.getPatientRecommendations(patientId),
        ApiService.getConnectedDoctors(patientId),
      ]);

      if (!mounted) return;

      setState(() {
        healthHistories = _mapHealthHistories(
          results[0] as Map<String, dynamic>,
        );
        recommendationHistories = _mapRecommendationHistories(
          results[1] as List<Map<String, dynamic>>,
        );
        connectedDoctors = results[2] as List<Map<String, dynamic>>;
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

  List<Map<String, dynamic>> _mapHealthHistories(Map<String, dynamic> data) {
    final List<Map<String, dynamic>> result = [];

    for (final item in List<Map<String, dynamic>>.from(data['glucose'] ?? [])) {
      result.add({
        'type': 'Glukosa',
        'title': 'Glukosa ${item['measurement_type'] ?? '-'}',
        'time': _formatDateTime(item['measured_at']),
        'date_raw': item['measured_at'],
        'value': '${item['glucose_value'] ?? '-'}',
        'unit': 'mg/dL',
        'badge': item['validation_status'] ?? 'Valid',
        'icon': Icons.opacity,
        'color': AppColors.red,
        'input_by_role': item['input_by_role']?.toString() ?? 'Pasien',
        'input_by_name': item['input_by_name']?.toString() ?? '-',
        'raw': item,
      });
    }

    for (final item in List<Map<String, dynamic>>.from(
      data['physiological'] ?? [],
    )) {
      result.add({
        'type': 'Fisiologis',
        'title': 'Data Fisiologis',
        'time': _formatDateTime(item['measured_at']),
        'date_raw': item['measured_at'],
        'value': '${item['systolic'] ?? '-'}/${item['diastolic'] ?? '-'}',
        'unit': 'mmHg',
        'badge': item['validation_status'] ?? 'Valid',
        'icon': Icons.bar_chart_rounded,
        'color': Colors.orange,
        'input_by_role': item['input_by_role']?.toString() ?? 'Pasien',
        'input_by_name': item['input_by_name']?.toString() ?? '-',
        'raw': item,
      });
    }

    for (final item in List<Map<String, dynamic>>.from(data['activity'] ?? [])) {
      result.add({
        'type': 'Aktivitas',
        'title': item['activity_name']?.toString() ?? 'Aktivitas Fisik',
        'time': _formatDateTime(item['activity_date']),
        'date_raw': item['activity_date'],
        'value': '${item['duration_minutes'] ?? '-'}',
        'unit': 'menit',
        'badge': item['validation_status'] ?? 'Valid',
        'icon': Icons.directions_run,
        'color': AppColors.primaryBlue,
        'input_by_role': item['input_by_role']?.toString() ?? 'Pasien',
        'input_by_name': item['input_by_name']?.toString() ?? '-',
        'raw': item,
      });
    }

    for (final item in List<Map<String, dynamic>>.from(data['meal'] ?? [])) {
      result.add({
        'type': 'Makan',
        'title': item['meal_type_name']?.toString() ?? 'Pola Makan',
        'time': _formatDateTime(item['meal_date']),
        'date_raw': item['meal_date'],
        'value': '${item['carbohydrate_estimate'] ?? '-'}',
        'unit': 'gram',
        'badge': item['validation_status'] ?? 'Valid',
        'icon': Icons.restaurant_outlined,
        'color': AppColors.primaryBlue,
        'input_by_role': item['input_by_role']?.toString() ?? 'Pasien',
        'input_by_name': item['input_by_name']?.toString() ?? '-',
        'raw': item,
      });
    }

    for (final item in List<Map<String, dynamic>>.from(
      data['medication'] ?? [],
    )) {
      result.add({
        'type': 'Obat',
        'title': item['medication_name']?.toString() ?? 'Obat',
        'time': _formatDateTime(item['log_date']),
        'date_raw': item['log_date'],
        'value': '',
        'unit': '',
        'badge': item['status']?.toString() ?? '-',
        'doctor': item['doctor_name']?.toString() ?? '-',
        'prescriptionStatus': 'Resep aktif',
        'icon': Icons.medication_outlined,
        'color': item['status'] == 'Terlewat'
            ? AppColors.red
            : AppColors.primaryBlue,
        'input_by_role': item['input_by_role']?.toString() ?? 'Pasien',
        'input_by_name': item['input_by_name']?.toString() ?? '-',
        'raw': item,
      });
    }

    result.sort((a, b) {
      final dateA = DateTime.tryParse(a['date_raw']?.toString() ?? '');
      final dateB = DateTime.tryParse(b['date_raw']?.toString() ?? '');

      if (dateA == null || dateB == null) return 0;
      return dateB.compareTo(dateA);
    });

    return result;
  }

  List<Map<String, dynamic>> _mapRecommendationHistories(
    List<Map<String, dynamic>> data,
  ) {
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final item in data) {
      final clinicalNoteKey = item['clinical_note_id']?.toString().trim();
      final key = clinicalNoteKey != null && clinicalNoteKey.isNotEmpty
          ? clinicalNoteKey
          : 'recommendation_${item['recommendation_id'] ?? grouped.length}';

      grouped.putIfAbsent(key, () => <Map<String, dynamic>>[]);
      grouped[key]!.add(item);
    }

    final result = grouped.entries.map((entry) {
      final items = entry.value;
      final first = items.first;
      final doctorName = first['doctor_name']?.toString() ?? 'Dokter';
      final initial = doctorName.isNotEmpty ? doctorName[0].toUpperCase() : 'D';
      final categories = items
          .map((item) => item['category']?.toString() ?? 'Rekomendasi')
          .where((category) => category.trim().isNotEmpty)
          .toSet()
          .toList();
      final description = items.length == 1
          ? items.first['recommendation_text']?.toString() ?? '-'
          : '${items.length} rekomendasi: ${categories.join(', ')}';

      return {
        'initial': initial,
        'doctor': doctorName,
        'doctor_name': doctorName,
        'doctor_id': first['doctor_id']?.toString() ?? '',
        'date': _formatDateTime(first['created_at']),
        'created_at': first['created_at']?.toString() ?? '',
        'status': items.length == 1
            ? (first['category']?.toString() ?? 'Rekomendasi')
            : '${items.length} Rekomendasi',
        'category': items.length == 1
            ? (first['category']?.toString() ?? 'Rekomendasi')
            : '${items.length} Rekomendasi',
        'description': description,
        'recommendation_text': first['recommendation_text']?.toString() ?? '-',
        'recommendation_id': first['recommendation_id']?.toString() ?? '',
        'clinical_note_id': first['clinical_note_id']?.toString() ?? entry.key,
        'recommendations': items,
      };
    }).toList();

    result.sort((a, b) {
      final aDate = DateTime.tryParse(a['created_at']?.toString() ?? '');
      final bDate = DateTime.tryParse(b['created_at']?.toString() ?? '');
      if (aDate == null || bDate == null) return 0;
      return bDate.compareTo(aDate);
    });

    return result;
  }

  String _formatDateTime(dynamic value) {
    if (value == null) return '-';

    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();

    return '${date.day}/${date.month}/${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  List<Map<String, dynamic>> get _filteredHealth {
    return healthHistories.where((item) {
      final matchType =
          healthFilter == 0 || item['type'] == healthFilters[healthFilter];

      final date = DateTime.tryParse(item['date_raw']?.toString() ?? '');

      final matchDate =
          selectedRange == null ||
          date == null ||
          (!date.isBefore(selectedRange!.start) &&
              date.isBefore(selectedRange!.end.add(const Duration(days: 1))));

      return matchType && matchDate;
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredRecommendations {
    if (selectedDoctorId == null) return recommendationHistories;

    return recommendationHistories.where((item) {
      return item['doctor_id'] == selectedDoctorId.toString();
    }).toList();
  }

  String _selectedDoctorName() {
    if (selectedDoctorId == null) return 'Semua Dokter';

    final doctor = connectedDoctors.firstWhere(
      (item) => item['doctor_id']?.toString() == selectedDoctorId.toString(),
      orElse: () => {},
    );

    return doctor['full_name']?.toString() ??
        doctor['doctor_name']?.toString() ??
        'Dokter';
  }

  @override
  Widget build(BuildContext context) {
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
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage != null
                    ? _errorState()
                    : mainTab == 0
                    ? _healthContent(_filteredHealth)
                    : _recommendationContent(_filteredRecommendations),
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
              errorMessage ?? 'Gagal memuat riwayat',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.dark2, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadHistory,
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

  Widget _header(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, topPad + 30, 24, 26),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
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

  Widget _healthContent(List<Map<String, dynamic>> data) {
    return Column(
      children: [
        _filterChips(
          filters: healthFilters,
          selectedIndex: healthFilter,
          onTap: (index) => setState(() => healthFilter = index),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selectedRange == null ? 'SEMUA RIWAYAT' : 'RIWAYAT TERPILIH',
                  style: const TextStyle(
                    color: AppColors.dark2,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _dateRangeButton(),
            ],
          ),
        ),
        Expanded(
          child: data.isEmpty
              ? _emptyState('Belum ada riwayat data kesehatan')
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final item = data[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _HealthHistoryCard(
                          type: item['type'] as String,
                          title: item['title'] as String,
                          time: item['time'] as String,
                          value: item['value'] as String,
                          unit: item['unit'] as String,
                          badge: item['badge'] as String,
                          doctor: item['doctor'] as String?,
                          prescriptionStatus:
                              item['prescriptionStatus'] as String?,
                          icon: item['icon'] as IconData,
                          color: item['color'] as Color,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PatientHealthDetailPage(
                                  type: item['type'] as String,
                                  item: Map<String, dynamic>.from(
                                    item['raw'] as Map,
                                  ),
                                ),
                              ),
                            );
                          },
                          inputByRole:
                              item['input_by_role']?.toString() ?? 'Pasien',
                          inputByName: item['input_by_name']?.toString() ?? '-',
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _recommendationContent(List<Map<String, dynamic>> data) {
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
                child: GestureDetector(
                  onTap: _showDoctorFilterSheet,
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.light1),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedDoctorName(),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.dark3,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.dark2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: data.isEmpty
              ? _emptyState('Belum ada riwayat rekomendasi')
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final item = data[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PatientRecommendationDetailPage(item: item),
                              ),
                            );
                          },
                          child: _RecommendationHistoryCard(
                            initial: item['initial'] ?? 'D',
                            doctor: item['doctor'] ?? 'Dokter',
                            date: item['date'] ?? '-',
                            status: item['status'] ?? 'Rekomendasi',
                            description: item['description'] ?? '-',
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  void _showDoctorFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.light1,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Pilih Dokter',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                _doctorOptionTile(
                  title: 'Semua Dokter',
                  selected: selectedDoctorId == null,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    setState(() => selectedDoctorId = null);
                  },
                ),
                if (connectedDoctors.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    child: Text(
                      'Belum ada dokter terhubung',
                      style: TextStyle(color: AppColors.dark2, fontSize: 13),
                    ),
                  )
                else
                  ...connectedDoctors.map((doctor) {
                    final doctorId = int.tryParse(
                      doctor['doctor_id']?.toString() ?? '',
                    );

                    final name = doctor['full_name']?.toString() ??
                        doctor['doctor_name']?.toString() ??
                        'Dokter';

                    return _doctorOptionTile(
                      title: name,
                      selected: selectedDoctorId == doctorId,
                      onTap: () {
                        Navigator.pop(sheetContext);
                        setState(() => selectedDoctorId = doctorId);
                      },
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _doctorOptionTile({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.veryLightBlue : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primaryBlue : AppColors.light1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: selected ? AppColors.primaryBlue : AppColors.dark1,
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? AppColors.primaryBlue : AppColors.dark4,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.dark2,
          fontSize: 13,
          fontWeight: FontWeight.w500,
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
      onLongPress: () {
        setState(() {
          selectedRange = null;
        });
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
          Text(label, style: const TextStyle(color: AppColors.dark2, fontSize: 10)),
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
  final String type;
  final String title;
  final String time;
  final String value;
  final String unit;
  final String badge;
  final String? doctor;
  final String? prescriptionStatus;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String inputByRole;
  final String inputByName;

  const _HealthHistoryCard({
    required this.type,
    required this.title,
    required this.time,
    required this.value,
    required this.unit,
    required this.badge,
    this.doctor,
    this.prescriptionStatus,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.inputByRole,
    required this.inputByName,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value.isNotEmpty;
    final isInactivePrescription = prescriptionStatus == 'Tidak berlaku';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 104),
        padding: const EdgeInsets.all(12),
        decoration: _cardDecoration(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                mainAxisAlignment: MainAxisAlignment.center,
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

                  if (type == 'Obat' && doctor != null && doctor != '-') ...[
                    const SizedBox(height: 4),
                    Text(
                      'Resep dari $doctor',
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      prescriptionStatus ?? '',
                      style: TextStyle(
                        color: isInactivePrescription
                            ? AppColors.red
                            : const Color(0xFF10C878),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],

                  const SizedBox(height: 7),
                  _inputBadge(inputByRole, inputByName),
                ],
              ),
            ),

            const SizedBox(width: 8),

            if (hasValue)
              SizedBox(
                width: 72,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: color,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      unit,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: AppColors.dark2,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              )
            else
              _smallBadge(badge),
          ],
        ),
      ),
    );
  }

  Widget _smallBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightBlue),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _inputBadge(String role, String name) {
    final isCaregiver = role == 'Pendamping';
    final text = isCaregiver ? '$role • $name' : role;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: isCaregiver ? const Color(0xFFFFF4DA) : AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCaregiver
              ? Colors.orange.withValues(alpha: 0.18)
              : AppColors.primaryBlue.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCaregiver ? Icons.family_restroom_rounded : Icons.person_rounded,
            size: 11,
            color: isCaregiver ? Colors.orange : AppColors.primaryBlue,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isCaregiver ? Colors.orange : AppColors.primaryBlue,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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

class _RecommendationHistoryCard extends StatelessWidget {
  final String initial;
  final String doctor;
  final String date;
  final String status;
  final String description;

  const _RecommendationHistoryCard({
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
                  'Lihat detail rekomendasi',
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
  final Map<String, dynamic> item;

  const PatientHealthDetailPage({
    super.key,
    required this.type,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final data = _getDetailData(type, item);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _header(context, data),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  children: [
                    _detailSection(data),
                    const SizedBox(height: 14),
                    _inputInfoSection(),
                    const SizedBox(height: 14),
                    _noteSection(data),
                    const SizedBox(height: 18),
                    _readonlyInfo(type),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  String _text(dynamic value, {String fallback = '-'}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    if (text.isEmpty || text == 'null') return fallback;
    return text;
  }

  String _bmiText(Map<String, dynamic> item) {
    final existing = item['bmi'];
    if (existing != null && existing.toString().trim().isNotEmpty) {
      return existing.toString();
    }

    final weight = double.tryParse(item['weight_kg']?.toString() ?? '');
    final heightCm = double.tryParse(
      item['height_cm']?.toString() ?? item['patient_height_cm']?.toString() ?? '',
    );

    if (weight == null || heightCm == null || heightCm <= 0) return '-';

    final heightM = heightCm / 100;
    final bmi = weight / (heightM * heightM);
    return bmi.toStringAsFixed(1);
  }

  Widget _inputInfoSection() {
    final inputByRole = _text(item['input_by_role'], fallback: 'Pasien');
    final inputByName = _text(item['input_by_name'], fallback: '-');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Input',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _inputInfoRow('Diinput oleh', inputByRole),
          _inputInfoRow('Nama Penginput', inputByName),
        ],
      ),
    );
  }

  Widget _inputInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.dark2, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getDetailData(String type, Map<String, dynamic> item) {
    if (type == 'Glukosa') {
      return {
        'icon': Icons.opacity,
        'value': '${item['glucose_value'] ?? '-'}',
        'unit': 'mg/dL',
        'date': _formatDetailDate(item['measured_at']),
        'status': item['validation_status'] ?? 'Valid',
        'sections': [
          ['Tipe pengukuran', '${item['measurement_type'] ?? '-'}'],
          ['Nilai', '${item['glucose_value'] ?? '-'} mg/dL'],
          ['Status', '${item['validation_status'] ?? 'Valid'}'],
        ],
        'note': item['note']?.toString() ?? '',
      };
    }

    if (type == 'Fisiologis') {
      return {
        'icon': Icons.bar_chart_rounded,
        'value': '${item['systolic'] ?? '-'}/${item['diastolic'] ?? '-'}',
        'unit': 'mmHg',
        'date': _formatDetailDate(item['measured_at']),
        'status': item['validation_status'] ?? 'Valid',
        'sections': [
          ['Sistolik', '${item['systolic'] ?? '-'} mmHg'],
          ['Diastolik', '${item['diastolic'] ?? '-'} mmHg'],
          ['Berat Badan', '${item['weight_kg'] ?? '-'} kg'],
          ['BMI', '${_bmiText(item)} kg/m²'],
          ['Status', '${item['validation_status'] ?? 'Valid'}'],
        ],
        'note': item['note']?.toString() ?? '',
      };
    }

    if (type == 'Aktivitas') {
      return {
        'icon': Icons.directions_run,
        'value': '${item['duration_minutes'] ?? '-'}',
        'unit': 'menit',
        'date': _formatDetailDate(item['activity_date']),
        'status': item['intensity'] ?? '-',
        'sections': [
          ['Durasi', '${item['duration_minutes'] ?? '-'} menit'],
          ['Intensitas', '${item['intensity'] ?? '-'}'],
          ['Status', '${item['validation_status'] ?? 'Valid'}'],
        ],
        'note': item['note']?.toString() ?? '',
      };
    }

    if (type == 'Makan') {
      return {
        'icon': Icons.restaurant_outlined,
        'value': '${item['carbohydrate_estimate'] ?? '-'}',
        'unit': 'gram',
        'date': _formatDetailDate(item['meal_date']),
        'status': item['validation_status'] ?? 'Valid',
        'sections': [
          [
            'Estimasi karbohidrat',
            '${item['carbohydrate_estimate'] ?? '-'} gram',
          ],
          ['Kalori', '${item['calories'] ?? '-'} kkal'],
          ['Status', '${item['validation_status'] ?? 'Valid'}'],
        ],
        'note': item['food_description']?.toString() ?? '',
      };
    }

    return {
      'icon': Icons.medication_outlined,
      'value': item['medication_name']?.toString() ?? 'Obat',
      'unit': item['session']?.toString() ?? '',
      'date': _formatDetailDate(item['log_date']),
      'status': item['status']?.toString() ?? '-',
      'sections': [
        ['Nama Obat', '${item['medication_name'] ?? '-'}'],
        ['Jadwal', '${item['session'] ?? '-'}'],
        ['Dosis', '${item['dose_per_session'] ?? '-'}'],
        ['Status Konsumsi', '${item['status'] ?? '-'}'],
        ['Waktu Checklist', _formatDetailDate(item['checked_at'])],
        ['Status Validasi', '${item['validation_status'] ?? 'Valid'}'],
      ],
      'note': item['note']?.toString() ?? '',
    };
  }

  String _formatDetailDate(dynamic value) {
    if (value == null) return '-';

    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();

    const months = [
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

    return '${date.day} ${months[date.month - 1]} ${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _header(BuildContext context, Map<String, dynamic> data) {
  final topPad = MediaQuery.of(context).padding.top;
  final isBad = data['status'] == 'Abnormal';

  return Container(
    width: double.infinity,
    padding: EdgeInsets.fromLTRB(16, topPad + 16, 16, 24),
    decoration: const BoxDecoration(
      color: AppColors.primaryBlue,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(22),
        bottomRight: Radius.circular(22),
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
                'Detail Riwayat',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 48),
          ],
        ),

        const SizedBox(height: 18),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.lightBlue,
                child: Icon(
                  data['icon'] as IconData,
                  color: AppColors.primaryBlue,
                  size: 26,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['value'].toString(),
                      style: const TextStyle(
                        color: AppColors.dark1,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${data['unit']} • ${data['date']}',
                      style: const TextStyle(
                        color: AppColors.dark2,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.veryLightBlue,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.primaryBlue.withValues(alpha: .15),
                        ),
                      ),
                      child: Text(
                        data['status'].toString(),
                        style: TextStyle(
                          color: isBad
                              ? AppColors.red
                              : AppColors.primaryBlue,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  Widget _detailSection(Map<String, dynamic> data) {
    final sections = data['sections'] as List<List<String>>;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Data',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ...sections.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      row[1],
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
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
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Catatan',
            style: TextStyle(
              color: AppColors.primaryBlue,
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
              style: const TextStyle(
                color: AppColors.dark1,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _readonlyInfo(String type) {
    final message = type == 'Obat'
        ? 'Data obat berasal dari checklist kepatuhan pasien. Riwayat ini hanya dapat dilihat dan tidak dapat diubah dari halaman ini.'
        : 'Riwayat ini hanya dapat dilihat dari halaman detail. Penghapusan data belum diaktifkan agar data backend tetap aman.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.primaryBlue,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
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
