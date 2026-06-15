import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ClinicalNoteDetailPage extends StatelessWidget {
  final bool hasRecommendation;

  const ClinicalNoteDetailPage({super.key, this.hasRecommendation = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Container(
                color: AppColors.background,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _infoCard(
                        icon: Icons.favorite_border,
                        title: 'Kondisi Pasien',
                        child: _statusChip('Abnormal'),
                      ),
                      const SizedBox(height: 14),
                      _infoCard(
                        icon: Icons.description_outlined,
                        title: 'Catatan Dokter',
                        child: const Text(
                          'Pasien datang dengan keluhan glukosa postprandial tinggi mencapai 187 mg/dL. BMI 27.4 menunjukkan overweight. Kepatuhan obat 82% dalam 7 hari terakhir, perlu ditingkatkan. Tekanan darah masih terkontrol di 128/82 mmHg.',
                          style: TextStyle(
                            color: AppColors.dark2,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _infoCard(
                        icon: Icons.notes_outlined,
                        title: 'Rencana Penanganan',
                        child: const Text(
                          'Meningkatkan dosis Metformin 500mg ke 850mg. Konsultasi gizi untuk pola makan rendah karbohidrat. Olahraga aerobik minimal 30 menit, 3x seminggu.',
                          style: TextStyle(
                            color: AppColors.dark2,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _infoCard(
                        icon: Icons.calendar_today_outlined,
                        title: 'Follow Up',
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '7 Juli 2025',
                              style: TextStyle(
                                color: AppColors.dark1,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              '30 hari lagi',
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (hasRecommendation) ...[
                        const SizedBox(height: 18),
                        _recommendationSection(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recommendationSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.recommend_outlined,
                size: 16,
                color: AppColors.primaryBlue,
              ),
              SizedBox(width: 6),
              Text(
                'Rekomendasi Dokter',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _recommendationItem(
            category: 'Obat',
            description:
                'Tingkatkan dosis Metformin dari 500mg menjadi 850mg, dikonsumsi 2x sehari setelah makan. Monitor gula darah harian.',
          ),
          const SizedBox(height: 10),
          _recommendationItem(
            category: 'Pola Makan',
            description:
                'Kurangi konsumsi karbohidrat sederhana dan perbanyak sayur rendah indeks glikemik.',
          ),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 12),

          const Row(
            children: [
              Icon(
                Icons.groups_outlined,
                size: 16,
                color: AppColors.primaryBlue,
              ),
              SizedBox(width: 6),
              Text(
                'Rekomendasi Dikirim Kepada',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          _wrapRecipient(name: 'Angelica Sabi Gita', relation: 'Pasien'),

          const SizedBox(height: 8),

          _wrapRecipient(name: 'Yeni Dewi Sinta', relation: 'Istri'),

          const SizedBox(height: 8),

          _wrapRecipient(name: 'Agus Santoso', relation: 'Anak'),
        ],
      ),
    );
  }

  Widget _recommendationItem({
    required String category,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lightBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              category,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.dark2,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _wrapRecipient({required String name, required String relation}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lightBlue),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryBlue,
            child: Text(
              name.split(' ').take(2).map((e) => e[0]).join(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: AppColors.dark1,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              relation,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 22),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
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
                  'Detail Catatan Klinis',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.lightBlue,
                  child: Text(
                    'AS',
                    style: TextStyle(
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
                      const Text(
                        'Angelica Sabi Gita',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        '32 tahun • Perempuan',
                        style: TextStyle(color: AppColors.dark2, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _miniBadge('DM Tipe 2'),
                          if (hasRecommendation) ...[
                            const SizedBox(width: 6),
                            _miniBadge('+ Rekomendasi'),
                          ],
                        ],
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

  Widget _miniBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightBlue),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primaryBlue),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _statusChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.lightRed,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.red,
          fontSize: 12,
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
