import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'patient_detail_page.dart';
import '../widgets/doctor_bottom_nav.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({Key? key}) : super(key: key);

  @override
  _DoctorHomePageState createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final patients = [
      [
        'AS',
        'Angelica Sabi Gita',
        '32 tahun • Perempuan',
        'DM Tipe 2',
        '187',
        false,
      ],
      [
        'RY',
        'Restu Yuda Eka',
        '55 tahun • Laki - Laki',
        'DM Tipe 1',
        '185',
        false,
      ],
      [
        'DH',
        'Dayat Heru S.',
        '45 tahun • Laki - Laki',
        'DM Tipe 1',
        '112',
        true,
      ],
      [
        'SP',
        'Suryo Prasta',
        '40 tahun • Laki - Laki',
        'DM Tipe 2',
        '118',
        true,
      ],
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Builder(
              builder: (context) {
                final topPad = MediaQuery.of(context).padding.top;
                return Container(
                  padding: EdgeInsets.fromLTRB(24, topPad + 28, 24, 32),
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
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Selamat Pagi, semangat hari ini!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'dr. Agus Setiawan, S.PD',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.notifications_none_rounded,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari nama pasien',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.primaryBlue,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: patients.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final p = patients[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PatientDetailPage(),
                        ),
                      );
                    },
                    child: _PatientCard(
                      initials: p[0] as String,
                      name: p[1] as String,
                      info: p[2] as String,
                      type: p[3] as String,
                      glucose: p[4] as String,
                      isNormal: p[5] as bool,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: DoctorBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final String initials;
  final String name;
  final String info;
  final String type;
  final String glucose;
  final bool isNormal;

  const _PatientCard({
    required this.initials,
    required this.name,
    required this.info,
    required this.type,
    required this.glucose,
    required this.isNormal,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isNormal
        ? const Color(0xFF10C878)
        : const Color(0xFFFF3B3B);
    final statusBg = isNormal
        ? const Color(0xFFEAFBF3)
        : const Color(0xFFFFEEEE);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.lightBlue,
            child: Text(
              initials,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  info,
                  style: const TextStyle(color: AppColors.dark2, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.veryLightBlue,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.lightBlue),
                  ),
                  child: Text(
                    type,
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RichText(
                text: TextSpan(
                  text: glucose,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  children: const [
                    TextSpan(
                      text: ' mg/dL',
                      style: TextStyle(
                        color: AppColors.dark3,
                        fontSize: 11,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 12, color: statusColor),
                    const SizedBox(width: 5),
                    Text(
                      isNormal ? 'Normal' : 'Abnormal',
                      style: TextStyle(color: statusColor, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
