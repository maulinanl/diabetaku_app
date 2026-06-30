import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CaregiverRecommendationDetailPage extends StatelessWidget {
  final Map<String, dynamic> item;

  const CaregiverRecommendationDetailPage({
    super.key,
    required this.item,
  });

  String get doctorName =>
      item['doctor_name']?.toString() ??
      item['doctor']?.toString() ??
      'Dokter';

  String get date =>
      item['created_at']?.toString() ??
      item['date']?.toString() ??
      '-';

  String get category =>
      item['category']?.toString() ??
      item['status']?.toString() ??
      'Rekomendasi';

  String get recommendationText =>
      item['recommendation_text']?.toString() ??
      item['description']?.toString() ??
      '-';

  String get targetPatient =>
      item['patient_name']?.toString() ??
      item['full_name']?.toString() ??
      'Pasien';

  List<Map<String, dynamic>> get recommendationItems {
    final raw = item['items'];
    if (raw is List) {
      return List<Map<String, dynamic>>.from(raw);
    }
    return [item];
  }

  String get categorySummary =>
      item['category_summary']?.toString() ??
      recommendationItems
          .map((e) => e['category']?.toString() ?? 'Rekomendasi')
          .toSet()
          .join(', ');

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                child: Column(
                  children: [
                    _infoCard(),
                    const SizedBox(height: 14),
                    _recommendationCard(),
                    const SizedBox(height: 14),
                  ],
                ),
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
      padding: EdgeInsets.fromLTRB(16, topPad + 16, 16, 24),
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
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Expanded(
                child: Text(
                  'Detail Rekomendasi',
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
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.lightBlue,
                  child: Icon(
                    Icons.send_outlined,
                    color: AppColors.primaryBlue,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorName,
                        style: const TextStyle(
                          color: AppColors.dark1,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: const TextStyle(
                          color: AppColors.dark2,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 7),
                      _smallBadge(
                        text: category,
                        bg: AppColors.veryLightBlue,
                        color: AppColors.primaryBlue,
                        icon: _categoryIcon(category),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primaryBlue, size: 17),
              SizedBox(width: 8),
              Text(
                'Informasi Rekomendasi',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow('Dokter', doctorName),
          _infoRow('Tanggal', date),
          _infoRow('Kategori', categorySummary),
          _infoRow('Untuk Pasien', targetPatient),
        ],
      ),
    );
  }

  Widget _recommendationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.send_outlined, color: AppColors.primaryBlue, size: 17),
              SizedBox(width: 8),
              Text(
                'Rekomendasi untuk Pendamping',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recommendationItems.map((rec) {
            final recCategory = rec['category']?.toString() ?? 'Rekomendasi';
            final recText = rec['recommendation_text']?.toString() ??
                rec['description']?.toString() ??
                '-';

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.veryLightBlue.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.light1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _smallBadge(
                    text: recCategory,
                    bg: AppColors.lightBlue,
                    color: AppColors.primaryBlue,
                    icon: _categoryIcon(recCategory),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    recText,
                    style: const TextStyle(
                      color: AppColors.dark1,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Obat':
        return Icons.medication_outlined;
      case 'Pola Makan':
        return Icons.restaurant_outlined;
      case 'Aktivitas Fisik':
      case 'Gaya Hidup':
        return Icons.directions_run;
      default:
        return Icons.assignment_outlined;
    }
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.dark2, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallBadge({
    required String text,
    required Color bg,
    required Color color,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 12),
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
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.light1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}