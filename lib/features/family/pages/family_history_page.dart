import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';
import 'family_history_detail_page.dart';
import 'family_recommendation_detail_page.dart';
import 'family_connection_page.dart';

class FamilyHistoryPage extends StatefulWidget {
  const FamilyHistoryPage({super.key});

  @override
  State<FamilyHistoryPage> createState() => _FamilyHistoryPageState();
}

class _FamilyHistoryPageState extends State<FamilyHistoryPage> {
  int mainTab = 0;
  int selectedPatientIndex = 0;
  int selectedFilter = 0;

  bool isLoading = true;
  String? errorMessage;

  List<Map<String, dynamic>> patients = [];
  List<Map<String, dynamic>> histories = [];
  List<Map<String, dynamic>> recommendations = [];

  final filters = const [
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
    _loadHistoryData();
  }

  Future<void> _loadHistoryData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final familyId = prefs.getInt('family_id');

      if (familyId == null) {
        throw Exception('Family ID tidak ditemukan. Coba login ulang.');
      }

      final familyPatients = await ApiService.getFamilyPatients(familyId);

      if (familyPatients.isEmpty) {
        if (!mounted) return;
        setState(() {
          patients = [];
          histories = [];
          recommendations = [];
          isLoading = false;
        });
        return;
      }

      final patientId = int.parse(
        familyPatients.first['patient_id'].toString(),
      );

      final results = await Future.wait([
        ApiService.getFamilyPatientHistories(patientId),
        ApiService.getFamilyPatientRecommendations(patientId),
      ]);

      final loadedHistories = _mapHealthHistories(
        results[0] as Map<String, dynamic>,
      );

      final loadedRecommendations = List<Map<String, dynamic>>.from(
        results[1] as List,
      );

      if (!mounted) return;

      setState(() {
        patients = familyPatients;
        histories = loadedHistories;
        recommendations = loadedRecommendations;
        selectedPatientIndex = 0;
        selectedFilter = 0;
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

  Future<void> _changePatient(int index) async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final patientId = int.parse(patients[index]['patient_id'].toString());

      final results = await Future.wait([
        ApiService.getFamilyPatientHistories(patientId),
        ApiService.getFamilyPatientRecommendations(patientId),
      ]);

      final loadedHistories = _mapHealthHistories(
        results[0] as Map<String, dynamic>,
      );

      final loadedRecommendations = List<Map<String, dynamic>>.from(
        results[1] as List,
      );

      if (!mounted) return;

      setState(() {
        selectedPatientIndex = index;
        selectedFilter = 0;
        histories = loadedHistories;
        recommendations = loadedRecommendations;
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
        'badge': item['validation_status']?.toString() ?? 'Valid',
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
        'badge': item['validation_status']?.toString() ?? 'Valid',
        'icon': Icons.bar_chart_rounded,
        'color': Colors.orange,
        'input_by_role': item['input_by_role']?.toString() ?? 'Pasien',
        'input_by_name': item['input_by_name']?.toString() ?? '-',
        'raw': item,
      });
    }

    for (final item in List<Map<String, dynamic>>.from(
      data['activity'] ?? [],
    )) {
      result.add({
        'type': 'Aktivitas',
        'title': item['activity_name']?.toString() ?? 'Aktivitas Fisik',
        'time': _formatDateTime(item['activity_date']),
        'date_raw': item['activity_date'],
        'value': '${item['duration_minutes'] ?? '-'}',
        'unit': 'menit',
        'badge': item['validation_status']?.toString() ?? 'Valid',
        'icon': Icons.directions_run,
        'color': AppColors.primaryBlue,
        'input_by_role': item['input_by_role']?.toString() ?? 'Pasien',
        'input_by_name': item['input_by_name']?.toString() ?? '-',
        'raw': item,
      });
    }

    for (final item in List<Map<String, dynamic>>.from(data['meal'] ?? [])) {
      final hasCarb = item['carbohydrate_estimate'] != null;

      result.add({
        'type': 'Makan',
        'title': item['meal_type_name']?.toString() ?? 'Pola Makan',
        'time': _formatDateTime(item['meal_date']),
        'date_raw': item['meal_date'],
        'value': '${item['carbohydrate_estimate'] ?? item['calories'] ?? '-'}',
        'unit': hasCarb ? 'gram' : 'kkal',
        'badge': item['validation_status']?.toString() ?? 'Valid',
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
      final consumptionStatus = item['status']?.toString() ?? '-';
      final validationStatus = item['validation_status']?.toString() ?? 'Valid';

      result.add({
        'type': 'Obat',
        'title': item['medication_name']?.toString() ?? 'Obat',
        'time': _formatDateTime(item['log_date']),
        'date_raw': item['log_date'],
        'value': consumptionStatus,
        'unit': '',
        'badge': validationStatus,

        'doctor': item['doctor_name']?.toString() ?? '-',
        'prescriptionStatus': 'Resep aktif',
        'icon': Icons.medication_outlined,
        'color':
            consumptionStatus == 'Terlewat' ||
                consumptionStatus == 'Tidak Diminum'
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

  String _formatDateTime(dynamic value) {
    if (value == null) return '-';

    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();

    return '${date.day}/${date.month}/${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
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

  String _patientInfo(Map<String, dynamic> patient) {
    final relation =
        patient['relation_name']?.toString() ??
        patient['relation']?.toString() ??
        '-';

    final dm = patient['diabetes_type']?.toString() ?? '-';

    return '$relation • $dm';
  }

  Color _badgeColor(String badge) {
    if (badge == 'Ditolak' || badge == 'Terlewat' || badge == 'Tidak Diminum') {
      return AppColors.red;
    }

    if (badge == 'Menunggu' || badge == 'Terlambat') {
      return Colors.orange;
    }

    return const Color(0xFF10C878);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return _errorState();
    }

    if (patients.isEmpty) {
      return _emptyHistoryState();
    }

    final selectedPatient = patients[selectedPatientIndex];

    final healthData = histories.where((item) {
      final type = item['type']?.toString() ?? '';

      if (!filters.contains(type)) return false;
      if (selectedFilter == 0) return true;

      return type == filters[selectedFilter];
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
                child: RefreshIndicator(
                  onRefresh: _loadHistoryData,
                  child: Column(
                    children: [
                      _patientCard(selectedPatient),
                      Expanded(
                        child: mainTab == 0
                            ? _healthContent(healthData)
                            : _recommendationContent(recommendations),
                      ),
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

  Widget _emptyHistoryState() {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 120),
                child: Column(
                  children: [
                    Container(
                      width: 118,
                      height: 118,
                      decoration: const BoxDecoration(
                        color: AppColors.veryLightBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.history_rounded,
                        size: 54,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 26),
                    const Text(
                      'Belum Ada Riwayat Pasien',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Riwayat data kesehatan dan rekomendasi dokter akan muncul setelah akun keluarga terhubung dengan pasien.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.dark2,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FamilyConnectionPage(),
                            ),
                          );
                        },
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
              errorMessage ?? 'Gagal memuat riwayat keluarga',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.dark2, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadHistoryData,
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

  Widget _patientCard(Map<String, dynamic> patient) {
    final name = _patientName(patient);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.light1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.lightBlue,
            child: Text(
              _initial(name),
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.dark1,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _patientInfo(patient),
                  style: const TextStyle(color: AppColors.dark2, fontSize: 11),
                ),
              ],
            ),
          ),
          if (patients.length > 1)
            OutlinedButton.icon(
              onPressed: _showPatientSelector,
              icon: const Icon(Icons.swap_horiz, size: 15),
              label: const Text('Ganti'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                side: const BorderSide(color: AppColors.light1),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
        ],
      ),
    );
  }

  Widget _healthContent(List<Map<String, dynamic>> data) {
    return Column(
      children: [
        _filterChips(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            children: [
              const Text(
                'DATA KESEHATAN',
                style: TextStyle(
                  color: AppColors.dark2,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              if (data.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(
                    child: Text(
                      'Belum ada riwayat untuk pasien ini',
                      style: TextStyle(color: AppColors.dark2),
                    ),
                  ),
                )
              else
                ...data.map((item) {
                  final badge = item['badge']?.toString() ?? '-';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _HistoryCard(
                      type: item['type']?.toString() ?? '-',
                      title: item['title']?.toString() ?? '-',
                      time: item['time']?.toString() ?? '-',
                      value: item['value']?.toString() ?? '',
                      unit: item['unit']?.toString() ?? '',
                      badge: badge,
                      doctor: item['doctor']?.toString(),
                      prescriptionStatus: item['prescriptionStatus']
                          ?.toString(),
                      icon: item['icon'] is IconData
                          ? item['icon'] as IconData
                          : Icons.description_outlined,
                      color: item['color'] is Color
                          ? item['color'] as Color
                          : _badgeColor(badge),
                      inputByRole:
                          item['input_by_role']?.toString() ?? 'Pasien',
                      inputByName: item['input_by_name']?.toString() ?? '-',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                FamilyHistoryDetailPage(history: item),
                          ),
                        );
                      },
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _recommendationContent(List<Map<String, dynamic>> data) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
      children: [
        const Text(
          'REKOMENDASI DOKTER',
          style: TextStyle(
            color: AppColors.dark2,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        if (data.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 80),
            child: Center(
              child: Text(
                'Belum ada rekomendasi untuk pasien ini',
                style: TextStyle(color: AppColors.dark2),
              ),
            ),
          )
        else
          ...data.map((item) {
            final doctor =
                item['doctor_name']?.toString() ??
                item['doctor']?.toString() ??
                'Dokter';

            final description =
                item['recommendation_text']?.toString() ??
                item['description']?.toString() ??
                '-';

            final status =
                item['category']?.toString() ??
                item['status']?.toString() ??
                'Rekomendasi';

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          FamilyRecommendationDetailPage(item: item),
                    ),
                  );
                },
                child: _RecommendationHistoryCard(
                  initial: _initial(doctor),
                  doctor: doctor,
                  date:
                      item['created_at']?.toString() ??
                      item['date']?.toString() ??
                      '-',
                  status: status,
                  description: description,
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _filterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Row(
        children: List.generate(filters.length, (index) {
          final selected = selectedFilter == index;

          return GestureDetector(
            onTap: () => setState(() => selectedFilter = index),
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
                subtitle: Text(_patientInfo(patient)),
                trailing: Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: AppColors.primaryBlue,
                ),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _changePatient(index);
                },
              );
            }),
          ),
        );
      },
    );
  }
}

class _HistoryCard extends StatelessWidget {
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
  final String inputByRole;
  final String inputByName;
  final VoidCallback onTap;

  const _HistoryCard({
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
    required this.inputByRole,
    required this.inputByName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value.isNotEmpty;
    final isMedication = type == 'Obat';
    final hasDoctor = doctor != null && doctor != '-';
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.dark1,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    time,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.dark2,
                      fontSize: 12,
                    ),
                  ),
                  if (isMedication && hasDoctor) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Resep dari $doctor',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (isMedication &&
                      prescriptionStatus != null &&
                      prescriptionStatus!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      prescriptionStatus!,
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
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _statusBadge(badge),
                      _inputBadge(inputByRole, inputByName),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (hasValue)
              SizedBox(
                width: isMedication ? 92 : 72,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (isMedication)
                      _medicationStatusBadge(value)
                    else ...[
                      Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: color,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        unit,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: AppColors.dark2,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String text) {
    Color bg;
    Color textColor;

    if (text == 'Disetujui' || text == 'Valid' || text == 'Diminum') {
      bg = const Color(0xFFEAFBF3);
      textColor = const Color(0xFF10C878);
    } else if (text == 'Ditolak' ||
        text == 'Terlewat' ||
        text == 'Tidak Diminum') {
      bg = AppColors.lightRed;
      textColor = AppColors.red;
    } else {
      bg = const Color(0xFFFFF4C7);
      textColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.18)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _inputBadge(String role, String name) {
    final isFamily = role == 'Keluarga';
    final text = isFamily && name != '-' ? '$role • $name' : role;

    return Container(
      constraints: const BoxConstraints(maxWidth: 170),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: isFamily ? const Color(0xFFFFF4DA) : AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFamily
              ? Colors.orange.withValues(alpha: 0.18)
              : AppColors.primaryBlue.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFamily ? Icons.family_restroom_rounded : Icons.person_rounded,
            size: 11,
            color: isFamily ? Colors.orange : AppColors.primaryBlue,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isFamily ? Colors.orange : AppColors.primaryBlue,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _medicationStatusBadge(String text) {
    final isBad = text == 'Terlewat' || text == 'Tidak Diminum';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isBad ? AppColors.lightRed : AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isBad
              ? AppColors.red.withValues(alpha: 0.18)
              : AppColors.primaryBlue.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isBad ? AppColors.red : AppColors.primaryBlue,
          fontSize: 11,
          fontWeight: FontWeight.w600,
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
            bg: const Color(0xFFFFF4DA),
            color: Colors.orange,
            icon: Icons.info_outline,
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
                  'Rekomendasi diterima keluarga',
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
