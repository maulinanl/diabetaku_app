import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';
import 'family_activity_form_page.dart';
import 'family_glucose_form_page.dart';
import 'family_meal_form_page.dart';
import 'family_physiological_form_page.dart';
import 'family_medication_form_page.dart';

class FamilyAddDataPage extends StatefulWidget {
  final bool showBackButton;
  final VoidCallback? onGoConnection;

  const FamilyAddDataPage({
    super.key,
    this.showBackButton = true,
    this.onGoConnection,
  });

  @override
  State<FamilyAddDataPage> createState() => _FamilyAddDataPageState();
}

class _FamilyAddDataPageState extends State<FamilyAddDataPage> {
  int selectedPatientIndex = 0;

  bool isLoading = true;
  String? errorMessage;

  List<Map<String, dynamic>> patients = [];

  final items = const [
    {
      'title': 'Glukosa Darah',
      'subtitle': 'Input data untuk pasien',
      'icon': Icons.opacity_outlined,
    },
    {
      'title': 'Data Fisiologis',
      'subtitle': 'Tekanan darah & berat badan',
      'icon': Icons.bar_chart_rounded,
    },
    {
      'title': 'Aktivitas Fisik',
      'subtitle': 'Aktivitas harian pasien',
      'icon': Icons.directions_run_rounded,
    },
    {
      'title': 'Pola Makan',
      'subtitle': 'Catatan makanan pasien',
      'icon': Icons.restaurant_outlined,
    },
    {
      'title': 'Kepatuhan Obat',
      'subtitle': 'Checklist obat pasien',
      'icon': Icons.medication_outlined,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
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

      final data = await ApiService.getFamilyPatients(familyId);

      final acceptedPatients = data.where((item) {
        final status = item['status']?.toString();
        return status == 'Diterima' || status == 'Terhubung';
      }).toList();

      if (!mounted) return;

      setState(() {
        patients = acceptedPatients;
        selectedPatientIndex = 0;
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

  String _patientRelation(Map<String, dynamic> patient) {
    return patient['relation_name']?.toString() ??
        patient['relation']?.toString() ??
        '-';
  }

  String _patientDm(Map<String, dynamic> patient) {
    return patient['diabetes_type']?.toString() ?? '-';
  }

  String _patientInfo(Map<String, dynamic> patient) {
    return '${_patientRelation(patient)} • ${_patientDm(patient)}';
  }

  int _patientId(Map<String, dynamic> patient) {
    return int.parse(patient['patient_id'].toString());
  }

  void _openForm(int index) {
    final patient = patients[selectedPatientIndex];
    final patientId = _patientId(patient);
    final patientName = _patientName(patient);
    final patientInitial = _initial(patientName);
    final patientInfo = _patientInfo(patient);

    late Widget page;

    if (index == 0) {
      page = FamilyGlucoseFormPage(
        patientId: patientId,
        patientInitial: patientInitial,
        patientName: patientName,
        patientInfo: patientInfo,
      );
    } else if (index == 1) {
      page = FamilyPhysiologicalFormPage(
        patientId: patientId,
        patientInitial: patientInitial,
        patientName: patientName,
        patientInfo: patientInfo,
      );
    } else if (index == 2) {
      page = FamilyActivityFormPage(
        patientId: patientId,
        patientInitial: patientInitial,
        patientName: patientName,
        patientInfo: patientInfo,
      );
    } else if (index == 3) {
      page = FamilyMealFormPage(
        patientId: patientId,
        patientInitial: patientInitial,
        patientName: patientName,
        patientInfo: patientInfo,
      );
    } else {
      page = FamilyMedicationFormPage(
        patientId: patientId,
        patientInitial: patientInitial,
        patientName: patientName,
        patientInfo: patientInfo,
      );
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
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
    if (isLoading) return const Center(child: CircularProgressIndicator());

    if (errorMessage != null) return _errorState();

    if (patients.isEmpty) return _emptyState();

    final patient = patients[selectedPatientIndex];

    return Column(
      children: [
        _patientInfoCard(patient),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.22,
            ),
            itemBuilder: (context, index) {
              final item = items[index];

              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _openForm(index),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: _cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.veryLightBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: AppColors.primaryBlue,
                          size: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item['title'] as String,
                        style: const TextStyle(
                          color: AppColors.dark1,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['subtitle'] as String,
                        style: const TextStyle(
                          color: AppColors.dark2,
                          fontSize: 10,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.veryLightBlue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Menunggu validasi',
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _header(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, topPad + 14, 16, 18),
      color: AppColors.primaryBlue,
      child: Row(
        children: [
          widget.showBackButton
              ? IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                )
              : const SizedBox(width: 48),
          const Expanded(
            child: Text(
              'Tambah Data',
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
    );
  }

  Widget _patientInfoCard(Map<String, dynamic> patient) {
    final name = _patientName(patient);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBlue),
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
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _patientInfo(patient),
                  style: const TextStyle(color: Colors.white, fontSize: 11),
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
                foregroundColor: AppColors.dark1,
                backgroundColor: AppColors.lightBlue,
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.light1,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Pilih pasien untuk input data',
                style: TextStyle(
                  color: AppColors.dark1,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(patients.length, (index) {
                final patient = patients[index];
                final name = _patientName(patient);
                final selected = selectedPatientIndex == index;

                return InkWell(
                  onTap: () {
                    setState(() => selectedPatientIndex = index);
                    Navigator.pop(sheetContext);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: selected
                              ? AppColors.primaryBlue
                              : AppColors.lightBlue,
                          child: Text(
                            _initial(name),
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : AppColors.primaryBlue,
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
                                _patientInfo(patient),
                                style: const TextStyle(
                                  color: AppColors.dark2,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: AppColors.primaryBlue,
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.veryLightBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Data yang disimpan akan masuk sebagai data pasien terpilih dan menunggu validasi pasien.',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 42,
              backgroundColor: AppColors.lightBlue,
              child: Icon(
                Icons.person_add_alt_1,
                color: AppColors.primaryBlue,
                size: 42,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Belum Ada Pasien Terhubung',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hubungkan akun keluarga dengan pasien terlebih dahulu sebelum menambahkan data.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.dark2,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: widget.onGoConnection ?? () => Navigator.pop(context),
                icon: const Icon(Icons.people_alt_outlined, size: 18),
                label: const Text('Ke Menu Koneksi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
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
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.red, size: 44),
            const SizedBox(height: 12),
            Text(
              errorMessage ?? 'Gagal memuat data pasien',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.dark2, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPatients,
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