import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ClinicalNoteDetailPage extends StatelessWidget {
  const ClinicalNoteDetailPage({super.key});

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
            child: const Row(
              children: [
                CircleAvatar(
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
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Angelica Sabi Gita',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        '32 tahun • Perempuan',
                        style: TextStyle(
                          color: AppColors.dark2,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'DM Tipe 2',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 11,
                        ),
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

  Widget _infoCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
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
      child: const Text(
        'Abnormal',
        style: TextStyle(
          color: AppColors.red,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
} 