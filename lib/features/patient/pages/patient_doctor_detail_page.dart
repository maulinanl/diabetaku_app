import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PatientDoctorDetailPage extends StatelessWidget {
  final String initial;
  final String name;
  final String info;
  final String status;
  final String date;

  const PatientDoctorDetailPage({
    super.key,
    this.initial = 'AS',
    this.name = 'dr. Agus Setiawan, Sp.PD',
    this.info = 'Penyakit Dalam • RS Cipto Mangunkusumo',
    this.status = 'Terhubung',
    this.date = 'Sejak 1 Jan 2025',
  });

  bool get isConnected => status == 'Terhubung';
  bool get isWaiting => status == 'Menunggu';
  bool get isNotConnected => status == 'Belum Terhubung';

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
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                child: Column(
                  children: [
                    _infoCard(),
                    const SizedBox(height: 22),
                    _actionButton(context),
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
      padding: EdgeInsets.fromLTRB(16, topPad + 14, 16, 24),
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
                  'Detail Dokter',
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
          const SizedBox(height: 14),
          CircleAvatar(
            radius: 42,
            backgroundColor: AppColors.lightBlue,
            child: Text(
              initial,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            info,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _HeaderBadge(text: 'Terverifikasi'),
              const SizedBox(width: 8),
              _HeaderBadge(text: status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.medical_services_outlined,
            label: 'Spesialisasi',
            value: _getSpecialist(),
          ),
          _InfoRow(
            icon: Icons.local_hospital_outlined,
            label: 'Institusi',
            value: _getHospital(),
          ),
          const _InfoRow(
            icon: Icons.verified_outlined,
            label: 'Status Verifikasi',
            value: 'Terverifikasi oleh admin',
          ),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: isConnected ? 'Terhubung sejak' : 'Status koneksi',
            value: isConnected ? date : status,
          ),
        ],
      ),
    );
  }

  String _getSpecialist() {
    final parts = info.split('•');
    return parts.isNotEmpty ? parts[0].trim() : '-';
  }

  String _getHospital() {
    final parts = info.split('•');
    return parts.length > 1 ? parts[1].trim() : '-';
  }

  Widget _actionButton(BuildContext context) {
    if (isConnected) {
      return _redButton(
        text: 'Putus Relasi',
        onPressed: () => _showDisconnectSheet(context),
      );
    }

    if (isWaiting) {
      return SizedBox(
        width: double.infinity,
        height: 46,
        child: ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.access_time, size: 16),
          label: const Text('Menunggu Persetujuan'),
          style: ElevatedButton.styleFrom(
            disabledBackgroundColor: AppColors.veryLightBlue,
            disabledForegroundColor: AppColors.primaryBlue,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton.icon(
        onPressed: () => _showRequestSheet(context),
        icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
        label: const Text('Ajukan Permintaan Koneksi'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  Widget _redButton({required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.red,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _showRequestSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _BottomSheetContent(
          icon: Icons.person_add_alt_1_rounded,
          iconBg: AppColors.veryLightBlue,
          iconColor: AppColors.primaryBlue,
          title: 'Ajukan koneksi dokter?',
          message:
              'Permintaan koneksi akan dikirim ke dokter. Jika diterima, dokter dapat memantau data kesehatanmu.',
          primaryText: 'Ya, Ajukan',
          primaryColor: AppColors.primaryBlue,
          onPrimaryTap: () {
            Navigator.pop(sheetContext);
            _showSuccessSheet(context);
          },
        );
      },
    );
  }

  void _showSuccessSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _BottomSheetContent(
          icon: Icons.check_circle,
          iconBg: const Color(0xFFEAFBF3),
          iconColor: const Color(0xFF10C878),
          title: 'Permintaan Terkirim',
          message:
              'Permintaan koneksi dokter berhasil diajukan. Silakan menunggu persetujuan dokter.',
          primaryText: 'OK',
          primaryColor: AppColors.primaryBlue,
          onPrimaryTap: () => Navigator.pop(sheetContext),
          showCancel: false,
        );
      },
    );
  }

  void _showDisconnectSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _BottomSheetContent(
          icon: Icons.link_off_rounded,
          iconBg: AppColors.lightRed,
          iconColor: AppColors.red,
          title: 'Putus relasi dokter?',
          message:
              'Dokter tidak lagi dapat memantau data kesehatanmu setelah relasi diputus.',
          primaryText: 'Ya, Putus Relasi',
          primaryColor: AppColors.red,
          onPrimaryTap: () => Navigator.pop(sheetContext),
        );
      },
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
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

class _HeaderBadge extends StatelessWidget {
  final String text;

  const _HeaderBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.veryLightBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.dark1,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSheetContent extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String message;
  final String primaryText;
  final Color primaryColor;
  final VoidCallback onPrimaryTap;
  final bool showCancel;

  const _BottomSheetContent({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.primaryText,
    required this.primaryColor,
    required this.onPrimaryTap,
    this.showCancel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: iconBg,
            child: Icon(icon, color: iconColor, size: 34),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.dark2,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: onPrimaryTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(primaryText),
            ),
          ),
          if (showCancel)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Batal',
                style: TextStyle(color: AppColors.primaryBlue),
              ),
            ),
        ],
      ),
    );
  }
}
