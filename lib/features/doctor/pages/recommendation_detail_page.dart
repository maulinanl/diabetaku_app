import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class RecommendationDetailPage extends StatelessWidget {
  final String patientName;
  final String patientInfo;
  final String diabetesType;
  final List<Map<String, String>> recommendations;
  final List<Map<String, String>> recipients;
  final String time;

  const RecommendationDetailPage({
    super.key,
    required this.patientName,
    required this.patientInfo,
    required this.diabetesType,
    required this.recommendations,
    required this.recipients,
    required this.time,
  });

  factory RecommendationDetailPage.fromApi({
    required Map<String, dynamic> patient,
    required List<Map<String, dynamic>> recommendationsData,
    required List<Map<String, dynamic>> recipientsData,
    required String time,
  }) {
    final name = patient['full_name']?.toString() ?? '-';
    final gender = patient['gender']?.toString() ?? '-';
    final age = _calculateAgeStatic(patient['date_of_birth']?.toString());
    final diabetes = _formatDiabetesType(patient['diabetes_type']);

    return RecommendationDetailPage(
      patientName: name,
      patientInfo: '$age tahun • $gender',
      diabetesType: diabetes,
      time: time,
      recommendations: recommendationsData.map((item) {
        return {
          'category': item['category']?.toString() ?? '-',
          'text': item['recommendation_text']?.toString() ?? '-',
        };
      }).toList(),
      recipients: recipientsData.map((item) {
        return {
          'name': item['full_name']?.toString() ?? '-',
          'role': item['role']?.toString() ?? 'Penerima',
        };
      }).toList(),
    );
  }

  static int _calculateAgeStatic(String? birthDate) {
    if (birthDate == null) return 0;

    final date = DateTime.tryParse(birthDate);
    if (date == null) return 0;

    final now = DateTime.now();
    int age = now.year - date.year;

    if (now.month < date.month ||
        (now.month == date.month && now.day < date.day)) {
      age--;
    }

    return age;
  }

  static String _formatDiabetesType(dynamic value) {
    final type = value?.toString() ?? '-';

    if (type.contains('1')) return 'DM Tipe 1';
    if (type.contains('2')) return 'DM Tipe 2';

    return type.replaceAll('_', ' ');
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (name.trim().isEmpty) return '-';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              constraints: const BoxConstraints(minHeight: 210),
              padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 24),
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
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
                        child: Center(
                          child: Text(
                            'Detail Rekomendasi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _patientHeaderCard(),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                child: Column(
                  children: [
                    _sectionCard(
                      title: 'Rekomendasi Dokter',
                      icon: Icons.medical_information_outlined,
                      children: recommendations.isEmpty
                          ? [
                              const Text(
                                'Belum ada detail rekomendasi.',
                                style: TextStyle(
                                  color: AppColors.dark2,
                                  fontSize: 12,
                                ),
                              ),
                            ]
                          : recommendations.map((item) {
                              return _recommendationCard(
                                category: item['category'] ?? '-',
                                text: item['text'] ?? '-',
                              );
                            }).toList(),
                    ),
                    const SizedBox(height: 12),
                    _sectionCard(
                      title: 'Rekomendasi Dikirim Kepada',
                      icon: Icons.groups_rounded,
                      children: recipients.isEmpty
                          ? [
                              const Text(
                                'Belum ada data penerima.',
                                style: TextStyle(
                                  color: AppColors.dark2,
                                  fontSize: 12,
                                ),
                              ),
                            ]
                          : recipients.map((item) {
                              return _recipientCard(
                                name: item['name'] ?? '-',
                                role: item['role'] ?? '-',
                              );
                            }).toList(),
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

  Widget _patientHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.veryLightBlue, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _initials(patientName),
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientName,
                  style: const TextStyle(
                    color: AppColors.dark1,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  patientInfo,
                  style: const TextStyle(
                    color: AppColors.dark2,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _smallBadge(diabetesType),
                    _smallBadge(time),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.light1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _smallBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _recommendationCard({
    required String category,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              category,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.dark2,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _recipientCard({
    required String name,
    required String role,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBlue),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryBlue,
            child: Text(
              _initials(name),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: AppColors.dark1,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              role,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}