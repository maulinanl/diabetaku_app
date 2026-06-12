import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PatientRecommendationDetailPage extends StatelessWidget {
  const PatientRecommendationDetailPage({super.key});

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
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
                child: Column(
                  children: [
                    _conditionCard(),
                    const SizedBox(height: 14),
                    _textCard(
                      icon: Icons.description_outlined,
                      title: 'Catatan Dokter',
                      text:
                          'Pasien datang dengan keluhan glukosa postprandial tinggi mencapai 187 mg/dL. BMI 27.4 menunjukkan overweight. Kepatuhan obat 82% dalam 7 hari terakhir, perlu ditingkatkan. Tekanan darah masih terkontrol di 128/82 mmHg.',
                    ),
                    const SizedBox(height: 14),
                    _textCard(
                      icon: Icons.notes_rounded,
                      title: 'Rencana Penanganan',
                      text:
                          'Meningkatkan dosis Metformin 500mg ke 850mg. Konsultasi gizi untuk pola makan rendah karbohidrat. Olahraga aerobik minimal 30 menit, 3x seminggu.',
                    ),
                    const SizedBox(height: 14),
                    _recommendationCard(),
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
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.lightBlue,
                  child: Text(
                    'AS',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'dr. Agus Setiawan, Sp.PD',
                        style: TextStyle(
                          color: AppColors.dark1,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '7 Jun 2025 • 09:41',
                        style: TextStyle(
                          color: AppColors.dark2,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 7),
                      _smallBadge(
                        text: 'Rekomendasi',
                        bg: AppColors.veryLightBlue,
                        color: AppColors.primaryBlue,
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

  Widget _conditionCard() {
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
                Icons.assignment_outlined,
                color: AppColors.primaryBlue,
                size: 17,
              ),
              SizedBox(width: 8),
              Text(
                'Kondisi Pasien',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _smallBadge(
            text: 'Abnormal',
            bg: AppColors.lightRed,
            color: AppColors.red,
            icon: Icons.circle,
          ),
        ],
      ),
    );
  }

  Widget _textCard({
    required IconData icon,
    required String title,
    required String text,
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
              Icon(icon, color: AppColors.primaryBlue, size: 17),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
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
                'Rekomendasi',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _recommendationItem(
            icon: Icons.medication_outlined,
            label: 'Obat',
            text:
                'Tingkatkan dosis Metformin dari 500mg menjadi 850mg, dikonsumsi 2× sehari setelah makan. Monitor efek samping GI selama 2 minggu pertama.',
          ),
          const SizedBox(height: 12),
          _recommendationItem(
            icon: Icons.restaurant_outlined,
            label: 'Pola Makan',
            text:
                'Kurangi asupan karbohidrat sederhana. Pilih karbohidrat kompleks seperti nasi merah, oatmeal. Batasi porsi nasi putih maksimal ½ centong per makan.',
          ),
          const SizedBox(height: 12),
          _recommendationItem(
            icon: Icons.directions_run,
            label: 'Gaya Hidup',
            text:
                'Lakukan olahraga aerobik ringan-sedang minimal 30 menit, 3× seminggu. Contoh: jalan cepat, bersepeda, atau berenang.',
          ),
        ],
      ),
    );
  }

  Widget _recommendationItem({
    required IconData icon,
    required String label,
    required String text,
  }) {
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
            text: label,
            bg: AppColors.lightBlue,
            color: AppColors.primaryBlue,
            icon: icon,
          ),
          const SizedBox(height: 10),
          Text(
            text,
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