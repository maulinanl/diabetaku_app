import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';
import 'package:diabetaku_app/core/theme/app_button_styles.dart';

class PatientDoctorDetailPage extends StatefulWidget {
  final int doctorId;
  final String initial;
  final String name;
  final String info;
  final String status;
  final String date;

  const PatientDoctorDetailPage({
    super.key,
    required this.doctorId,
    required this.initial,
    required this.name,
    required this.info,
    required this.status,
    required this.date,
  });

  @override
  State<PatientDoctorDetailPage> createState() =>
      _PatientDoctorDetailPageState();
}

class _PatientDoctorDetailPageState extends State<PatientDoctorDetailPage> {
  late String currentStatus;
  late String currentDate;
  bool isProcessing = false;
  bool isRefreshingStatus = true;
  bool hasChanged = false;

  bool get isConnected => currentStatus == 'Terhubung';

  bool get isWaiting => currentStatus == 'Menunggu';

  @override
  void initState() {
    super.initState();
    currentStatus = _normalizeConnectionStatus(widget.status);
    currentDate = widget.date;
    _syncLatestConnectionStatus();
  }

  String _normalizeConnectionStatus(dynamic value) {
    final normalized = value?.toString().toLowerCase().trim() ?? '';

    if (normalized == 'diterima' || normalized == 'terhubung') {
      return 'Terhubung';
    }

    if (normalized == 'menunggu' ||
        normalized == 'menunggu persetujuan' ||
        normalized == 'menunggu persetujuan dokter') {
      return 'Menunggu';
    }

    return 'Belum Terhubung';
  }

  String _formatDate(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) return '-';

    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();

    return '${date.day}/${date.month}/${date.year}';
  }

  Map<String, dynamic>? _findDoctorById(List<Map<String, dynamic>> doctors) {
    for (final doctor in doctors) {
      final id = int.tryParse(doctor['doctor_id']?.toString() ?? '');
      if (id == widget.doctorId) return doctor;
    }

    return null;
  }

  Future<void> _syncLatestConnectionStatus() async {
    try {
      final patientId = await _getPatientId();
      final keyword = widget.name.trim().isEmpty ? '' : widget.name.trim();

      var doctors = await ApiService.searchDoctors(
        patientId: patientId,
        keyword: keyword,
      );

      var doctor = _findDoctorById(doctors);

      if (doctor == null && keyword.isNotEmpty) {
        doctors = await ApiService.searchDoctors(
          patientId: patientId,
          keyword: '',
        );
        doctor = _findDoctorById(doctors);
      }

      if (doctor == null || !mounted) {
        setState(() => isRefreshingStatus = false);
        return;
      }

      final latestStatus = _normalizeConnectionStatus(
        doctor['connection_status'] ?? doctor['status'],
      );

      setState(() {
        currentStatus = latestStatus;
        currentDate = _formatDate(
          doctor?['connected_since'] ?? doctor?['connected_at'] ?? widget.date,
        );
        isRefreshingStatus = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isRefreshingStatus = false);
    }
  }

  Future<int> _getPatientId() async {
    final prefs = await SharedPreferences.getInstance();
    final patientId = prefs.getInt('patient_id');

    if (patientId == null) {
      throw Exception('Patient ID tidak ditemukan');
    }

    return patientId;
  }

  Future<void> _requestConnection() async {
    setState(() => isProcessing = true);

    try {
      final patientId = await _getPatientId();

      await ApiService.requestDoctorConnection(
        patientId: patientId,
        doctorId: widget.doctorId,
      );

      if (!mounted) return;

      setState(() {
        currentStatus = 'Menunggu';
        isProcessing = false;
        hasChanged = true;
      });

      _showSuccessSheet(
        title: 'Permintaan Terkirim',
        message:
            'Permintaan koneksi dokter berhasil diajukan. Silakan menunggu persetujuan dokter.',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => isProcessing = false);
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _disconnectDoctor() async {
    setState(() => isProcessing = true);

    try {
      final patientId = await _getPatientId();

      await ApiService.disconnectDoctorConnection(
        patientId: patientId,
        doctorId: widget.doctorId,
      );

      if (!mounted) return;

      setState(() {
        currentStatus = 'Belum Terhubung';
        currentDate = '';
        isProcessing = false;
        hasChanged = true;
      });

      _showSuccessSheet(
        title: 'Relasi Terputus',
        message:
            'Relasi dengan dokter berhasil diputus. Kamu dapat mengajukan permintaan koneksi lagi jika diperlukan.',
      );
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (!isProcessing) {
          Navigator.pop(context, hasChanged);
        }
      },
      child: Scaffold(
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
                onPressed: () {
                  if (!isProcessing) {
                    Navigator.pop(context, hasChanged);
                  }
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Expanded(
                child: Text(
                  'Detail Dokter',
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
            widget.info,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _HeaderBadge(text: 'Terverifikasi'),
              const SizedBox(width: 8),
              _HeaderBadge(text: currentStatus),
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
            value: isConnected ? (currentDate.isEmpty ? '-' : currentDate) : currentStatus,
          ),
        ],
      ),
    );
  }

  String _getSpecialist() {
    if (!widget.info.contains('•')) return widget.info;

    return widget.info.split('•').first.trim();
  }

  String _getHospital() {
    if (!widget.info.contains('•')) return '-';

    return widget.info.split('•').last.trim();
  }

  Widget _actionButton(BuildContext context) {

    if (isConnected) {
      return _redButton(
        text: isProcessing ? 'Memproses...' : 'Putus Relasi',
        onPressed: isProcessing ? null : () => _showDisconnectSheet(context),
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
          style: AppButtonStyles.soft,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton.icon(
        onPressed: isProcessing ? null : () => _showRequestSheet(context),
        icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
        label: Text(
          isProcessing ? 'Memproses...' : 'Ajukan Permintaan Koneksi',
        ),
        style: AppButtonStyles.primary,
      ),
    );
  }

  Widget _redButton({required String text, required VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        onPressed: onPressed,
        style: AppButtonStyles.danger,
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
            _requestConnection();
          },
        );
      },
    );
  }

  void _showSuccessSheet({required String title, required String message}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _BottomSheetContent(
          icon: Icons.check_circle,
          iconBg: const Color(0xFFEAFBF3),
          iconColor: const Color(0xFF10C878),
          title: title,
          message: message,
          primaryText: 'OK',
          primaryColor: AppColors.primaryBlue,
          onPrimaryTap: () {
            Navigator.pop(sheetContext);
          },
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
          onPrimaryTap: () {
            Navigator.pop(sheetContext);
            _disconnectDoctor();
          },
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
              style: AppButtonStyles.primary,
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
