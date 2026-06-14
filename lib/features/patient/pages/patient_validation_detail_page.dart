import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PatientValidationDetailPage extends StatelessWidget {
  final String name;
  final String relation;
  final String type;
  final String value;
  final String time;
  final String note;
  final IconData icon;

  const PatientValidationDetailPage({
    super.key,
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
                    _detailSection(),
                    const SizedBox(height: 14),
                    _noteSection(),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _showActionSheet(context, false);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.red,
                              side: const BorderSide(color: AppColors.red),
                              minimumSize: const Size.fromHeight(46),
                            ),
                            child: const Text('Tolak'),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _showActionSheet(context, true);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(46),
                              elevation: 0,
                            ),
                            child: const Text('Setujui'),
                          ),
                        ),
                      ],
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

  Widget _header(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 24),
      color: AppColors.primaryBlue,
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
                  'Validasi Data',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),

          const SizedBox(height: 12),

          Text(type, style: const TextStyle(color: Colors.white, fontSize: 14)),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(time, style: const TextStyle(color: Colors.white, fontSize: 11)),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4DA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Menunggu Validasi',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Data',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 14),

          _row('Jenis Data', type),
          _row('Nilai', value),
          _row('Diinput Oleh', name),
          _row('Hubungan', relation),
          _row('Waktu Input', time),
        ],
      ),
    );
  }

  Widget _noteSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Catatan Keluarga',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.veryLightBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(note, style: const TextStyle(color: AppColors.dark1)),
          ),
        ],
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
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

  void _showActionSheet(BuildContext context, bool approve) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                approve ? 'Data berhasil divalidasi' : 'Data ditolak',
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                approve
                    ? 'Data telah masuk ke riwayat kesehatan pasien.'
                    : 'Data tidak akan dimasukkan ke riwayat kesehatan pasien.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.dark2),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Selesai'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.light1),
    );
  }
}
