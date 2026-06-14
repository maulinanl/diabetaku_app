import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ClinicalNoteDetailPage extends StatelessWidget {
  final bool isConnected;

  const ClinicalNoteDetailPage({super.key, this.isConnected = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                child: Column(
                  children: [
                    if (!isConnected) ...[
                      _disconnectedInfo(),
                      const SizedBox(height: 12),
                    ],
                    _infoCard(
                      icon: Icons.description_outlined,
                      title: 'Referensi Data Klinis',
                      child: Column(
                        children: const [
                          _ReferenceRow(
                            label: 'Glukosa Postprandial',
                            value: '187 mg/dL',
                          ),
                          _ReferenceRow(
                            label: 'Tekanan Darah',
                            value: '128/82 mmHg',
                          ),
                          _ReferenceRow(label: 'BMI', value: '27.4'),
                          _ReferenceRow(label: 'Kepatuhan Obat', value: '82%'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _infoCard(
                      icon: Icons.favorite,
                      title: 'Kondisi Pasien',
                      child: _statusChip('Tidak Stabil'),
                    ),
                    const SizedBox(height: 12),
                    _infoCard(
                      icon: Icons.sticky_note_2,
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
                    const SizedBox(height: 12),
                    _infoCard(
                      icon: Icons.notes_outlined,
                      title: 'Rencana Penanganan',
                      child: const Text(
                        'Meningkatkan dosis Metformin 500 mg ke 850 mg. Konsultasi gizi untuk pola makan rendah karbohidrat. Olahraga aerobik minimal 30 menit, 3x seminggu.',
                        style: TextStyle(
                          color: AppColors.dark2,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _infoCard(
                      icon: Icons.calendar_today_outlined,
                      title: 'Jadwal Kontrol',
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '07/07/2025',
                            style: TextStyle(
                              color: AppColors.dark1,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '30 hari lagi',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _recommendationSection(),
                  ],
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
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 22),
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
                child: Text(
                  'Detail Catatan Klinis',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
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
                    color: isConnected ? AppColors.lightBlue : AppColors.light1,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.veryLightBlue,
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'AS',
                      style: TextStyle(
                        color: isConnected
                            ? AppColors.primaryBlue
                            : AppColors.dark4,
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
                      const Text(
                        'Angelica Sabi Gita',
                        style: TextStyle(
                          color: AppColors.dark1,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '32 tahun • Perempuan',
                        style: TextStyle(fontSize: 13, color: AppColors.dark2),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _smallBadge(
                            text: 'DM Tipe 2',
                            bg: AppColors.veryLightBlue,
                            color: AppColors.primaryBlue,
                          ),
                          if (!isConnected)
                            _smallBadge(
                              text: 'Tidak Terhubung',
                              bg: AppColors.light1,
                              color: AppColors.dark4,
                            ),
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

  Widget _recommendationSection() {
    final recommendations = [
      {
        'category': 'Obat',
        'content':
            'Tingkatkan dosis Metformin dari 500 mg menjadi 850 mg, dikonsumsi 2x sehari setelah makan.',
        'sentTo': 'Pasien dan keluarga',
      },
      {
        'category': 'Pola Makan',
        'content':
            'Kurangi konsumsi karbohidrat sederhana dan perbanyak sayur tinggi serat.',
        'sentTo': 'Pasien',
      },
    ];

    return Container(
      width: double.infinity,
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
          const Row(
            children: [
              Icon(Icons.send_outlined, size: 17, color: AppColors.primaryBlue),
              SizedBox(width: 8),
              Text(
                'Rekomendasi Terkait',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...recommendations.map((item) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item['category']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item['content']!,
                    style: const TextStyle(
                      color: AppColors.dark1,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.notifications_none_rounded,
                        size: 14,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Dikirim ke ${item['sentTo']}',
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
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
          Row(
            children: [
              Icon(icon, size: 17, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _statusChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightRed,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.18)),
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

  Widget _smallBadge({
    required String text,
    required Color bg,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _disconnectedInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.light1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.dark4.withValues(alpha: 0.18)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.dark4, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Pasien sudah tidak terhubung. Catatan klinis hanya dapat dilihat sebagai data lama.',
              style: TextStyle(
                color: AppColors.dark4,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferenceRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReferenceRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.dark2, fontSize: 12),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
