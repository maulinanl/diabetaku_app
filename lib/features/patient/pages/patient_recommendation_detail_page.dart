import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PatientRecommendationDetailPage extends StatelessWidget {
  final Map<String, dynamic> item;

  const PatientRecommendationDetailPage({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final doctor = _text(
      item['doctor'] ?? item['doctor_name'] ?? item['sender_name'],
      fallback: 'Dokter',
    );
    final date = _text(
      item['date'] ?? item['created_at'] ?? item['time'],
      fallback: '-',
      formatDate: true,
    );
    final recommendations = _recommendations();
    final category = recommendations.length == 1
        ? _text(recommendations.first['category'], fallback: 'Rekomendasi')
        : _text(item['category'] ?? item['status'], fallback: 'Rekomendasi');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _header(context, doctor, date, category),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                child: Column(
                  children: [
                    _infoCard(doctor, date, category),
                    const SizedBox(height: 14),
                    _recommendationSection(recommendations),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _text(
    dynamic value, {
    String fallback = '-',
    bool formatDate = false,
  }) {
    if (value == null || value.toString().trim().isEmpty) return fallback;

    if (!formatDate) return value.toString();

    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();

    return '${date.day}/${date.month}/${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  List<Map<String, dynamic>> _recommendations() {
    final raw = item['recommendations'];

    if (raw is List && raw.isNotEmpty) {
      return raw
          .whereType<Map>()
          .map((entry) => Map<String, dynamic>.from(entry))
          .toList();
    }

    return [
      {
        'category': item['category'] ?? item['status'] ?? 'Rekomendasi',
        'recommendation_text': item['recommendation_text'] ??
            item['description'] ??
            item['content'] ??
            item['message'] ??
            '-',
      },
    ];
  }

  Widget _header(
    BuildContext context,
    String doctor,
    String date,
    String category,
  ) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
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
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
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
                        doctor,
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

  Widget _infoCard(String doctor, String date, String category) {
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
          _infoRow('Dokter', doctor),
          _infoRow('Tanggal', date),
          _infoRow('Kategori', category),
        ],
      ),
    );
  }

  Widget _recommendationSection(List<Map<String, dynamic>> recommendations) {
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
                'Rekomendasi untuk Pasien',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recommendations.asMap().entries.map((entry) {
            final recommendation = entry.value;
            final category = _text(
              recommendation['category'],
              fallback: 'Rekomendasi',
            );
            final description = _text(
              recommendation['recommendation_text'] ??
                  recommendation['description'] ??
                  recommendation['content'],
            );

            return Padding(
              padding: EdgeInsets.only(
                bottom: entry.key == recommendations.length - 1 ? 0 : 10,
              ),
              child: _recommendationItem(category, description),
            );
          }),
        ],
      ),
    );
  }

  Widget _recommendationItem(String category, String description) {
    return Container(
      width: double.infinity,
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
            text: category,
            bg: AppColors.lightBlue,
            color: AppColors.primaryBlue,
            icon: _categoryIcon(category),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.dark1,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    final normalized = category.toLowerCase().replaceAll('_', ' ').trim();

    if (normalized.contains('obat')) return Icons.medication_outlined;
    if (normalized.contains('makan')) return Icons.restaurant_outlined;
    if (normalized.contains('aktivitas') ||
        normalized.contains('gaya hidup') ||
        normalized.contains('olahraga')) {
      return Icons.directions_run;
    }

    return Icons.assignment_outlined;
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
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.light1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}
