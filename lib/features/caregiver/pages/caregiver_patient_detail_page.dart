import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';
import 'package:diabetaku_app/core/theme/app_button_styles.dart';

class CaregiverPatientDetailPage extends StatefulWidget {
  final int patientId;
  final String initial;
  final String name;
  final String relation;
  final String date;

  const CaregiverPatientDetailPage({
    super.key,
    required this.patientId,
    required this.initial,
    required this.name,
    required this.relation,
    required this.date,
  });

  @override
  State<CaregiverPatientDetailPage> createState() =>
      _CaregiverPatientDetailPageState();
}

class _CaregiverPatientDetailPageState extends State<CaregiverPatientDetailPage> {
  bool isLoading = true;
  bool isProcessing = false;
  String? errorMessage;

  Map<String, dynamic>? patient;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final data = await ApiService.getCaregiverPatientDetail(widget.patientId);

      if (!mounted) return;

      setState(() {
        patient = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  Future<void> _disconnectPatient() async {
    setState(() => isProcessing = true);

    try {
      await ApiService.disconnectCaregiverPatient(patientId: widget.patientId);

      if (!mounted) return;

      setState(() => isProcessing = false);
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() => isProcessing = false);
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  String get name {
    return patient?['full_name']?.toString() ??
        patient?['name']?.toString() ??
        widget.name;
  }

  String get gender {
    return patient?['gender']?.toString() ?? '-';
  }

  String get diabetesType {
    return patient?['diabetes_type']?.toString() ?? '-';
  }

  String get height {
    final value = patient?['height_cm'];
    if (value == null || value.toString() == 'null') return '-';
    return '$value cm';
  }

  String get bloodType {
    final blood = patient?['blood_type']?.toString();
    final rhesus = patient?['rhesus_type']?.toString();

    if ((blood == null || blood == 'null') &&
        (rhesus == null || rhesus == 'null')) {
      return '-';
    }

    return '${blood ?? ''}${rhesus ?? ''}';
  }

  String get diagnosisDate {
    final value = patient?['diagnosis_date']?.toString();
    return _formatDate(value);
  }

  String get birthDate {
    final value = patient?['date_of_birth']?.toString();
    return _formatDate(value);
  }

  String get age {
    final value = patient?['date_of_birth']?.toString();
    final date = DateTime.tryParse(value ?? '');

    if (date == null) return '-';

    final now = DateTime.now();
    int age = now.year - date.year;

    if (now.month < date.month ||
        (now.month == date.month && now.day < date.day)) {
      age--;
    }

    return '$age tahun';
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty || value == 'null') return '-';

    final date = DateTime.tryParse(value);
    if (date == null) return value;

    return '${date.day}/${date.month}/${date.year}';
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
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                  ? _errorState()
                  : RefreshIndicator(
                      onRefresh: _loadDetail,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                        child: Column(
                          children: [
                            _infoCard(),
                            const SizedBox(height: 14),
                            _accessCard(),
                            const SizedBox(height: 22),
                            _disconnectButton(context),
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
                  'Detail Pasien',
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
            '$age • $diabetesType',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _HeaderBadge(text: 'Pasien'),
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
            label: 'Nama Pasien',
            value: name,
          ),
          _InfoRow(
            icon: Icons.monitor_heart_outlined,
            label: 'Tipe Diabetes',
            value: diabetesType,
          ),
          _InfoRow(
            icon: Icons.wc_outlined,
            label: 'Jenis Kelamin',
            value: gender,
          ),
          _InfoRow(
            icon: Icons.cake_outlined,
            label: 'Tanggal Lahir',
            value: birthDate,
          ),
          _InfoRow(
            icon: Icons.health_and_safety_outlined,
            label: 'Tanggal Diagnosis',
            value: diagnosisDate,
          ),
          _InfoRow(
            icon: Icons.height_outlined,
            label: 'Tinggi Badan',
            value: height,
          ),
          _InfoRow(
            icon: Icons.bloodtype_outlined,
            label: 'Golongan Darah',
            value: bloodType,
          ),
          _InfoRow(
            icon: Icons.people_alt_outlined,
            label: 'Hubungan',
            value: widget.relation,
          ),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Terhubung Sejak',
            value: widget.date,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _accessCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.light1),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.primaryBlue, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Sebagai pendamping pendamping, kamu dapat membantu menginput data kesehatan pasien, melihat riwayat tertentu, dan menerima notifikasi penting terkait kondisi pasien.',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 12,
                height: 1.4,
              ),
            ),
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
        style: AppButtonStyles.danger,
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
                'Putus relasi pasien?',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Setelah relasi diputus, pendamping tidak lagi dapat membantu input data, melihat riwayat pasien, atau menerima notifikasi penting.',
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
                    _disconnectPatient();
                  },
                  style: AppButtonStyles.danger,
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

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.red, size: 44),
            const SizedBox(height: 12),
            Text(
              errorMessage ?? 'Gagal memuat detail pasien',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.dark2, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDetail,
              style: AppButtonStyles.primary,
              child: const Text('Coba Lagi'),
            ),
          ],
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
