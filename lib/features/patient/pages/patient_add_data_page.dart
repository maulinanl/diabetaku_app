import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'patient_glucose_form_page.dart';
import 'patient_physiology_form_page.dart';
import 'patient_meal_form_page.dart';
import 'patient_activity_form_page.dart';
import 'patient_medication_form_page.dart';

class PatientAddDataPage extends StatelessWidget {
  const PatientAddDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'title': 'Glukosa Darah',
        'subtitle': 'Terakhir: 07.41',
        'status': 'Sudah diisi',
        'icon': Icons.opacity_outlined,
      },
      {
        'title': 'Data Fisiologis',
        'subtitle': 'Terakhir: kemarin',
        'status': 'Belum diisi',
        'icon': Icons.bar_chart_rounded,
      },
      {
        'title': 'Aktivitas Fisik',
        'subtitle': 'Belum ada hari ini',
        'status': 'Belum diisi',
        'icon': Icons.directions_run_rounded,
      },
      {
        'title': 'Pola Makan',
        'subtitle': 'Belum ada hari ini',
        'status': 'Belum diisi',
        'icon': Icons.restaurant_outlined,
      },
      {
        'title': 'Kepatuhan Obat',
        'subtitle': 'Terakhir: 17.30',
        'status': 'Sudah diisi',
        'icon': Icons.medication_outlined,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.25,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final done = item['status'] == 'Sudah diisi';

                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      if (index == 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PatientGlucoseFormPage(),
                          ),
                        );
                      } else if (index == 1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PatientPhysiologyFormPage(),
                          ),
                        );
                      } else if (index == 3) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PatientMealFormPage(),
                          ),
                        );
                      } else if (index == 2) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PatientActivityFormPage(),
                          ),
                        );
                      } else if (index == 4) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PatientMedicationFormPage(),
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
                              color: done
                                  ? const Color(0xFFEAFBF3)
                                  : AppColors.veryLightBlue,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item['status'] as String,
                              style: TextStyle(
                                color: done
                                    ? const Color(0xFF10C878)
                                    : AppColors.primaryBlue,
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
      padding: EdgeInsets.fromLTRB(20, topPad + 14, 20, 18),
      color: AppColors.primaryBlue,
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
}
