import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';
import 'patient_glucose_form_page.dart';
import 'patient_physiology_form_page.dart';
import 'patient_meal_form_page.dart';
import 'patient_activity_form_page.dart';
import 'patient_medication_form_page.dart';

class PatientAddDataPage extends StatefulWidget {
  const PatientAddDataPage({super.key});

  @override
  State<PatientAddDataPage> createState() => _PatientAddDataPageState();
}

class _PatientAddDataPageState extends State<PatientAddDataPage> {
  bool isLoading = true;
  String? errorMessage;

  Map<String, String> todayStatus = {
    'glucose': 'Belum Ada Data',
    'physiological': 'Belum Ada Data',
    'activity': 'Belum Ada Data',
    'meal': 'Belum Ada Data',
    'medication': 'Belum Ada Data',
  };

  final List<Map<String, dynamic>> items = [
    {
      'title': 'Glukosa Darah',
      'subtitle': 'Catat kadar gula darah',
      'key': 'glucose',
      'icon': Icons.opacity_outlined,
      'page': const PatientGlucoseFormPage(),
    },
    {
      'title': 'Data Fisiologis',
      'subtitle': 'Tekanan darah dan BMI',
      'key': 'physiological',
      'icon': Icons.bar_chart_rounded,
      'page': const PatientPhysiologyFormPage(),
    },
    {
      'title': 'Aktivitas Fisik',
      'subtitle': 'Catat olahraga harian',
      'key': 'activity',
      'icon': Icons.directions_run_rounded,
      'page': const PatientActivityFormPage(),
    },
    {
      'title': 'Pola Makan',
      'subtitle': 'Catat makanan harian',
      'key': 'meal',
      'icon': Icons.restaurant_outlined,
      'page': const PatientMealFormPage(),
    },
    {
      'title': 'Kepatuhan Obat',
      'subtitle': 'Catat konsumsi obat',
      'key': 'medication',
      'icon': Icons.medication_outlined,
      'page': const PatientMedicationFormPage(),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadTodayStatus();
  }

  Future<void> _loadTodayStatus() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final patientId = prefs.getInt('patient_id');

      if (patientId == null) {
        throw Exception('Patient ID tidak ditemukan. Coba login ulang.');
      }

      final histories = await ApiService.getPatientHealthHistory(patientId);

      if (!mounted) return;

      setState(() {
        todayStatus = {
          'glucose': _getTodayStatus(histories['glucose']),
          'physiological': _getTodayStatus(histories['physiological']),
          'activity': _getTodayStatus(histories['activity']),
          'meal': _getTodayStatus(histories['meal']),
          'medication': _getTodayStatus(histories['medication']),
        };
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

  String _getTodayStatus(dynamic records) {
    if (records == null || records is! List || records.isEmpty) {
      return 'Belum Ada Data';
    }

    final todayRecords = records.where((item) {
      if (item is! Map) return false;

      final dateValue =
          item['measured_at'] ??
          item['activity_date'] ??
          item['meal_date'] ??
          item['log_date'];

      return _isToday(dateValue);
    }).toList();

    if (todayRecords.isEmpty) {
      return 'Belum Ada Data';
    }

    final hasWaiting = todayRecords.any((item) {
      if (item is! Map) return false;

      final status = item['validation_status']?.toString() ?? '';
      return status == 'Menunggu';
    });

    if (hasWaiting) {
      return 'Menunggu Validasi';
    }

    final hasValid = todayRecords.any((item) {
      if (item is! Map) return false;

      final status = item['validation_status']?.toString() ?? '';
      return status == 'Valid';
    });

    if (hasValid) {
      return 'Valid';
    }

    return 'Belum Ada Data';
  }

  bool _isToday(dynamic value) {
    if (value == null) return false;

    final date = DateTime.tryParse(value.toString());
    if (date == null) return false;

    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Color _statusBgColor(String status) {
    if (status == 'Valid') return const Color(0xFFEAFBF3);
    if (status == 'Menunggu Validasi') return const Color(0xFFFFF4C7);
    return AppColors.veryLightBlue;
  }

  Color _statusTextColor(String status) {
    if (status == 'Valid') return const Color(0xFF10C878);
    if (status == 'Menunggu Validasi') return Colors.orange;
    return AppColors.primaryBlue;
  }

  Future<void> _openForm(Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );

    if (mounted) {
      await _loadTodayStatus();
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
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return _errorState();
    }

    return RefreshIndicator(
      onRefresh: _loadTodayStatus,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.18,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          final key = item['key'].toString();
          final status = todayStatus[key] ?? 'Belum Ada Data';

          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _openForm(item['page'] as Widget),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.veryLightBlue,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item['title'].toString(),
                    style: const TextStyle(
                      color: AppColors.dark1,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item['subtitle'].toString(),
                    style: const TextStyle(
                      color: AppColors.dark2,
                      fontSize: 10,
                      height: 1.3,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _statusBgColor(status),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _statusTextColor(status)
                                  .withValues(alpha: 0.18),
                            ),
                          ),
                          child: Text(
                            status,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _statusTextColor(status),
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.dark3,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.red, size: 44),
            const SizedBox(height: 12),
            Text(
              errorMessage ?? 'Gagal memuat status data',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.dark2, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTodayStatus,
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
      padding: EdgeInsets.fromLTRB(20, topPad + 18, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: const Center(
        child: Text(
          'Tambah Data',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
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
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}