import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';

class PatientCaregiverDetailPage extends StatefulWidget {
  final int caregiverId;
  final String initial;
  final String name;
  final String relation;
  final String date;

  const PatientCaregiverDetailPage({
    super.key,
    required this.caregiverId,
    required this.initial,
    required this.name,
    required this.relation,
    required this.date,
  });

  @override
  State<PatientCaregiverDetailPage> createState() =>
      _PatientCaregiverDetailPageState();
}

class _PatientCaregiverDetailPageState extends State<PatientCaregiverDetailPage> {
  bool isProcessing = false;

  Future<int> _getPatientId() async {
    final prefs = await SharedPreferences.getInstance();
    final patientId = prefs.getInt('patient_id');

    if (patientId == null) {
      throw Exception('Patient ID tidak ditemukan');
    }

    return patientId;
  }

  Future<void> _disconnectCaregiver() async {
    setState(() => isProcessing = true);

    try {
      final patientId = await _getPatientId();

      await ApiService.disconnectCaregiverConnection(
        patientId: patientId,
        caregiverId: widget.caregiverId,
      );

      if (!mounted) return;

      setState(() => isProcessing = false);

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() => isProcessing = false);
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

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
                    _disconnectButton(context),
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
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: isProcessing ? null : () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Expanded(
                child: Text(
                  'Detail Pendamping',
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
              widget.initial,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            widget.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.relation,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _HeaderBadge(text: 'Pendamping'),
              SizedBox(width: 8),
              _HeaderBadge(text: 'Terhubung'),
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
            icon: Icons.person_outline,
            label: 'Nama',
            value: widget.name,
          ),
          _InfoRow(
            icon: Icons.people_alt_outlined,
            label: 'Hubungan',
            value: widget.relation,
          ),
          const _InfoRow(
            icon: Icons.check_circle_outline,
            label: 'Status',
            value: 'Terhubung',
          ),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Terhubung sejak',
            value: widget.date,
          ),
          const _InfoRow(
            icon: Icons.health_and_safety_outlined,
            label: 'Akses Pendamping',
            value:
                'Dapat membantu input data, melihat riwayat tertentu, dan menerima notifikasi penting.',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _disconnectButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        onPressed: isProcessing ? null : () => _showDisconnectSheet(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.red,
          disabledBackgroundColor: AppColors.lightRed,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(
          isProcessing ? 'Memproses...' : 'Putus Relasi',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showDisconnectSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.lightRed,
                child: Icon(
                  Icons.link_off_rounded,
                  color: AppColors.red,
                  size: 34,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Putus relasi pendamping?',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pendamping tidak lagi dapat membantu menginput data, melihat riwayat tertentu, atau menerima notifikasi penting setelah relasi diputus.',
                textAlign: TextAlign.center,
                style: TextStyle(
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
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _disconnectCaregiver();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text('Ya, Putus Relasi'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(sheetContext),
                child: const Text(
                  'Batal',
                  style: TextStyle(color: AppColors.primaryBlue),
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
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
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
                    height: 1.35,
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