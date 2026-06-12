import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'family_glucose_form_page.dart';
import 'family_physiological_form_page.dart';
import 'family_activity_form_page.dart';
import 'family_meal_form_page.dart';
import 'family_medication_form_page.dart';

class FamilyAddDataPage extends StatefulWidget {
  const FamilyAddDataPage({super.key});

  @override
  State<FamilyAddDataPage> createState() => _FamilyAddDataPageState();
}

class _FamilyAddDataPageState extends State<FamilyAddDataPage> {
  int selectedPatientIndex = 0;

  final patients = [
    {
      'initial': 'BS',
      'name': 'Budi Santoso',
      'relation': 'Ayah',
      'dm': 'DM Tipe 2',
      'age': '58 th',
    },
    {
      'initial': 'SR',
      'name': 'Sari Rahayu',
      'relation': 'Ibu',
      'dm': 'DM Tipe 2',
      'age': '55 th',
    },
  ];

  final items = [
    {
      'title': 'Glukosa Darah',
      'subtitle': 'Input data untuk pasien',
      'status': 'Menunggu validasi',
      'icon': Icons.opacity_outlined,
    },
    {
      'title': 'Data Fisiologis',
      'subtitle': 'Tekanan darah & berat badan',
      'status': 'Menunggu validasi',
      'icon': Icons.bar_chart_rounded,
    },
    {
      'title': 'Aktivitas Fisik',
      'subtitle': 'Aktivitas harian pasien',
      'status': 'Menunggu validasi',
      'icon': Icons.directions_run_rounded,
    },
    {
      'title': 'Pola Makan',
      'subtitle': 'Catatan makanan pasien',
      'status': 'Menunggu validasi',
      'icon': Icons.restaurant_outlined,
    },
    {
  'title': 'Kepatuhan Obat',
  'subtitle': 'Pencatatan konsumsi obat',
  'status': 'Menunggu validasi',
  'icon': Icons.medication_outlined,
},
  ];

  @override
  Widget build(BuildContext context) {
    final patient = patients[selectedPatientIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _header(context),
            _patientInfoCard(patient),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.22,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final patient = patients[selectedPatientIndex];

                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      final patient = patients[selectedPatientIndex];

                      if (index == 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FamilyGlucoseFormPage(
                              patientInitial: patient['initial']!,
                              patientName: patient['name']!,
                              patientInfo:
                                  '${patient['relation']} • ${patient['dm']} • ${patient['age']}',
                            ),
                          ),
                        );
                      } else if (index == 1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FamilyPhysiologicalFormPage(
                              patientInitial: patient['initial']!,
                              patientName: patient['name']!,
                              patientInfo:
                                  '${patient['relation']} • ${patient['dm']} • ${patient['age']}',
                            ),
                          ),
                        );
                      } else if (index == 2) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FamilyActivityFormPage(
                              patientInitial: patient['initial']!,
                              patientName: patient['name']!,
                              patientInfo:
                                  '${patient['relation']} • ${patient['dm']} • ${patient['age']}',
                            ),
                          ),
                        );
                      } else if (index == 3) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FamilyMealFormPage(
                              patientInitial: patient['initial']!,
                              patientName: patient['name']!,
                              patientInfo:
                                  '${patient['relation']} • ${patient['dm']} • ${patient['age']}',
                            ),
                          ),
                        );
                      } else if (index == 4) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => FamilyMedicationFormPage(
        patientInitial: patient['initial']!,
        patientName: patient['name']!,
        patientInfo:
            '${patient['relation']} • ${patient['dm']} • ${patient['age']}',
      ),
    ),
  );
}
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
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
                      ),
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
        ),
      ),
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
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
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

  Widget _patientInfoCard(Map<String, String> patient) {
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
              patient['initial']!,
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
                  patient['name']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${patient['relation']} • ${patient['dm']} • ${patient['age']}',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ],
            ),
          ),
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
                            patient['initial']!,
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
                                patient['name']!,
                                style: const TextStyle(
                                  color: AppColors.dark1,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${patient['relation']} • ${patient['dm']} • ${patient['age']}',
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
}
