import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
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
  final List<Map<String, dynamic>> items = [
    {
      'title': 'Glukosa Darah',
      'subtitle': 'Catat kadar gula darah',
      'status': 'Isi data',
      'icon': Icons.opacity_outlined,
      'page': const PatientGlucoseFormPage(),
    },
    {
      'title': 'Data Fisiologis',
      'subtitle': 'Tekanan darah dan BMI',
      'status': 'Isi data',
      'icon': Icons.bar_chart_rounded,
      'page': const PatientPhysiologyFormPage(),
    },
    {
      'title': 'Aktivitas Fisik',
      'subtitle': 'Catat olahraga harian',
      'status': 'Isi data',
      'icon': Icons.directions_run_rounded,
      'page': const PatientActivityFormPage(),
    },
    {
      'title': 'Pola Makan',
      'subtitle': 'Catat makanan harian',
      'status': 'Isi data',
      'icon': Icons.restaurant_outlined,
      'page': const PatientMealFormPage(),
    },
    {
      'title': 'Kepatuhan Obat',
      'subtitle': 'Catat konsumsi obat',
      'status': 'Isi data',
      'icon': Icons.medication_outlined,
      'page': const PatientMedicationFormPage(),
    },
  ];

  Future<void> _openForm(Widget page) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );

    if (result == true && mounted) {
      setState(() {});
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
            Expanded(
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
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.veryLightBlue,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.lightBlue,
                                  ),
                                ),
                                child: Text(
                                  item['status'].toString(),
                                  style: const TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
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