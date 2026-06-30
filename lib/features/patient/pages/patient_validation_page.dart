import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';
import 'patient_validation_detail_page.dart';

class PatientValidationPage extends StatefulWidget {
  const PatientValidationPage({super.key});

  @override
  State<PatientValidationPage> createState() => _PatientValidationPageState();
}

class _PatientValidationPageState extends State<PatientValidationPage> {
  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> data = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
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

      final result = await ApiService.getPatientPendingValidations(patientId);

      if (!mounted) return;

      setState(() {
        data = result;
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

  String _formatDate(dynamic value) {
    if (value == null) return '-';

    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();

    return '${date.day}/${date.month}/${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  IconData _iconByType(String type) {
    switch (type) {
      case 'glucose':
        return Icons.opacity;
      case 'physiological':
        return Icons.favorite_border;
      case 'activity':
        return Icons.directions_run;
      case 'meal':
        return Icons.restaurant_outlined;
      default:
        return Icons.assignment_outlined;
    }
  }

  String _valueWithUnit(Map<String, dynamic> item) {
    final value = item['value']?.toString() ?? '-';
    final unit = item['unit']?.toString() ?? '';

    return unit.isEmpty ? value : '$value $unit';
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.red, size: 42),
              const SizedBox(height: 12),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.dark2, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
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

    if (data.isEmpty) {
      return _emptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];

          final type = item['record_type']?.toString() ?? '';
          final name =
              item['input_by']?.toString() ??
              item['inputBy']?.toString() ??
              '-';

          final relation = item['relation']?.toString() ?? 'Keluarga';
          final title = item['title']?.toString() ?? '-';
          final time = _formatDate(item['date']);
          final value = _valueWithUnit(item);
          final note = item['note']?.toString() ?? 'Tidak ada catatan.';

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _ValidationCard(
              name: name,
              relation: relation,
              type: title,
              value: value,
              time: time,
              note: note,
              icon: _iconByType(type),
              onTap: () async {
                final changed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PatientValidationDetailPage(item: item),
                  ),
                );

                if (changed == true) {
                  _loadData();
                }
              },
            ),
          );
        },
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
              'Validasi Data',
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

  Widget _emptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 38),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 38,
              backgroundColor: AppColors.veryLightBlue,
              child: Icon(
                Icons.verified_outlined,
                color: AppColors.primaryBlue,
                size: 38,
              ),
            ),
            SizedBox(height: 18),
            Text(
              'Tidak ada data menunggu validasi',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.dark1,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Data dari keluarga yang perlu dikonfirmasi akan muncul di halaman ini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ValidationCard extends StatelessWidget {
  final String name;
  final String relation;
  final String type;
  final String value;
  final String time;
  final String note;
  final IconData icon;
  final VoidCallback onTap;

  const _ValidationCard({
    required this.name,
    required this.relation,
    required this.type,
    required this.value,
    required this.time,
    required this.note,
    required this.icon,
    required this.onTap,
  });

  String get initial {
    final cleanName = name.trim();

    if (cleanName.isEmpty || cleanName == '-') return 'K';

    final parts = cleanName.split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.lightBlue,
                  child: Text(
                    initial,
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
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        relation,
                        style: const TextStyle(
                          color: AppColors.dark2,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                _badge('Menunggu'),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.veryLightBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.primaryBlue, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type,
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          value,
                          style: const TextStyle(
                            color: AppColors.dark1,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          time,
                          style: const TextStyle(
                            color: AppColors.dark2,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              note,
              style: const TextStyle(
                color: AppColors.dark2,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const Divider(height: 24),
            const Row(
              children: [
                Icon(
                  Icons.visibility_outlined,
                  size: 16,
                  color: AppColors.primaryBlue,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Lihat detail dan validasi',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.dark3),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4DA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.orange,
          fontSize: 10,
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
