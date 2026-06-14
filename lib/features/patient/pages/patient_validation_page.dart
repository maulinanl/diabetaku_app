import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'patient_validation_detail_page.dart';

class PatientValidationPage extends StatelessWidget {
  const PatientValidationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [
      {
        'name': 'Kartika Putri Citra',
        'relation': 'Istri',
        'type': 'Glukosa Darah',
        'value': '182 mg/dL',
        'time': '7 Jun 2025 • 08:10',
        'note': 'Diinput setelah sarapan',
        'icon': Icons.opacity,
      },
      {
        'name': 'Aditya Yoga Saputra',
        'relation': 'Anak',
        'type': 'Berat Badan',
        'value': '78.5 kg',
        'time': '7 Jun 2025 • 07:30',
        'note': 'Diinput dari timbangan rumah',
        'icon': Icons.monitor_weight_outlined,
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
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final item = data[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _ValidationCard(
                      name: item['name'] as String,
                      relation: item['relation'] as String,
                      type: item['type'] as String,
                      value: item['value'] as String,
                      time: item['time'] as String,
                      note: item['note'] as String,
                      icon: item['icon'] as IconData,
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
              'Validasi Data',
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
}

class _ValidationCard extends StatelessWidget {
  final String name;
  final String relation;
  final String type;
  final String value;
  final String time;
  final String note;
  final IconData icon;

  const _ValidationCard({
    required this.name,
    required this.relation,
    required this.type,
    required this.value,
    required this.time,
    required this.note,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PatientValidationDetailPage(
              name: name,
              relation: relation,
              type: type,
              value: value,
              time: time,
              note: note,
              icon: icon,
            ),
          ),
        );
      },
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
                    name.substring(0, 2).toUpperCase(),
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
