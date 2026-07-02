import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/pages/change_password_page.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/profile_badge.dart';
import '../../../data/services/api_service.dart';
import 'edit_doctor_profile_page.dart';
import '../../auth/pages/login_page.dart';
import 'package:diabetaku_app/core/theme/app_button_styles.dart';

class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({super.key});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  late String initialFullName;
  late String initialPhone;
  late String initialGender;
  late int initialSpecializationId;
  late String initialInstitution;
  Map<String, dynamic>? profile;
  bool isLoading = true;
  String? errorMessage;
  int activePatientCount = 0;
  int abnormalPatientCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final doctorId = prefs.getInt('doctor_id');

      if (doctorId == null) {
        throw Exception(
          'Doctor ID tidak ditemukan. Coba logout lalu login ulang.',
        );
      }

      final data = await ApiService.getDoctorProfile(doctorId);
      final patients = await ApiService.getDoctorPatients(doctorId);

      final activePatients = patients.where((patient) {
        final status =
            patient['relation_status']?.toString().toLowerCase() ?? 'diterima';

        return status == 'diterima';
      }).toList();

      final abnormalPatients = activePatients.where((patient) {
        final abnormal = patient['is_abnormal'];
        final status = patient['status']?.toString().toLowerCase();

        return abnormal == true ||
            abnormal == 1 ||
            abnormal?.toString() == '1' ||
            status == 'abnormal';
      }).length;

      if (!mounted) return;

      setState(() {
        profile = data;
        activePatientCount = activePatients.length;
        abnormalPatientCount = abnormalPatients;
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

  String _getInitials(String name) {
    final ignoredTitles = ['dr.', 'dr', 'prof.', 'prof', 'sp.', 'sp'];

    final words = name
        .trim()
        .split(' ')
        .where((e) => e.isNotEmpty)
        .where((e) => !ignoredTitles.contains(e.toLowerCase()))
        .toList();

    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }

    if (words.length == 1) {
      return words.first[0].toUpperCase();
    }

    return '-';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              )
            : errorMessage != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.dark1),
                  ),
                ),
              )
            : Column(
                children: [
                  _headerCard(context),
                  Expanded(
                    child: Container(
                      color: AppColors.background,
                      child: RefreshIndicator(
                        onRefresh: _loadProfile,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 22, 20, 170),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _statCard(
                                      activePatientCount.toString(),
                                      'Pasien Aktif',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _statCard(
                                      abnormalPatientCount.toString(),
                                      'Pasien Abnormal',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              _dataSection(context),
                              const SizedBox(height: 18),
                              _menuSection(),
                              const SizedBox(height: 18),
                              _logoutTile(context),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _headerCard(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    final name = profile?['full_name']?.toString() ?? '-';
    final specialization = profile?['specialization_name']?.toString() ?? '-';
    final institution = profile?['institution']?.toString() ?? '-';
    final verification = _verificationText(
      profile?['verification_status']?.toString() ?? 'Terverifikasi',
    );
    final initials = _getInitials(name);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPad + 24, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.lightBlue,
            child: Text(
              initials,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '$specialization • $institution',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              ProfileBadge.role(
                'Dokter',
                icon: Icons.medical_services_outlined,
              ),
              ProfileBadge.headerVerification(verification),
            ],
          ),
        ],
      ),
    );
  }

  String _verificationText(String value) {
    final status = value.toLowerCase();

    if (status == 'disetujui' || status == 'terverifikasi') {
      return 'Terverifikasi';
    }

    if (status == 'menunggu') return 'Menunggu Verifikasi';
    if (status == 'ditolak') return 'Ditolak';

    return 'Terverifikasi';
  }

  String _emailVerificationText(Map<String, dynamic>? data) {
    if (data == null) return 'Terverifikasi';
    if (!data.containsKey('email_verified_at')) return 'Terverifikasi';

    final verifiedAt = data['email_verified_at'];
    return verifiedAt == null ? 'Belum Verifikasi' : 'Terverifikasi';
  }

  Widget _statusBadge(String text) {
    final isVerified = text.toLowerCase() == 'terverifikasi' ||
        text.toLowerCase() == 'valid';
    final isRejected = text.toLowerCase() == 'ditolak';

    final bg = isRejected
        ? AppColors.lightRed
        : isVerified
            ? AppColors.veryLightBlue
            : Colors.orange.shade50;
    final color = isRejected
        ? AppColors.red
        : isVerified
            ? AppColors.primaryBlue
            : Colors.orange.shade700;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isRejected
                ? Icons.cancel_rounded
                : isVerified
                    ? Icons.verified
                    : Icons.pending,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 3),
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

  Widget _statCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.light1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppColors.dark2, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _dataSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                color: AppColors.primaryBlue,
                size: 16,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Data Diri',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  if (profile == null) return;

                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditDoctorProfilePage(profile: profile!),
                    ),
                  );

                  if (updated == true) {
                    _loadProfile();
                  }
                },
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Ubah'),
                style: AppButtonStyles.outlined,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _profileItem(
            Icons.person_outline,
            'Nama Lengkap',
            profile?['full_name']?.toString() ?? '-',
          ),
          _profileItem(
            Icons.email_outlined,
            'Email',
            profile?['email']?.toString() ?? '-',
            badge: _emailVerificationText(profile),
          ),
          _profileItem(
            Icons.phone_outlined,
            'Nomor Telepon',
            profile?['phone_number']?.toString() ?? '-',
          ),
          _profileItem(
            Icons.wc,
            'Jenis Kelamin',
            profile?['gender']?.toString() ?? '-',
          ),
          const Divider(height: 26),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Data Profesional',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _profileItem(
            Icons.medical_services_outlined,
            'Spesialisasi',
            profile?['specialization_name']?.toString() ?? '-',
          ),
          _profileItem(
            Icons.badge_outlined,
            'Nomor STR',
            profile?['str_number']?.toString() ?? '-',
            badge: 'Valid',
          ),
          _profileItem(
            Icons.local_hospital_outlined,
            'Institusi',
            profile?['institution']?.toString() ?? '-',
          ),
        ],
      ),
    );
  }

  Widget _profileItem(
    IconData icon,
    String label,
    String value, {
    String? badge,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
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
          const SizedBox(width: 10),
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
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: AppColors.dark1,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 6),
                      _statusBadge(badge),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuSection() {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _menuTile(
            Icons.lock_outline,
            'Ubah kata sandi',
            'Perbarui keamanan akun',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
              );
            },
          ),
          _menuTile(
            Icons.info_outline,
            'Tentang aplikasi',
            'Versi 1.0.0',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _menuTile(
    IconData icon,
    String title,
    String subtitle, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.veryLightBlue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primaryBlue, size: 18),
      ),
      title: Text(title, style: const TextStyle(fontSize: 13)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.dark3, fontSize: 11),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.dark3),
      onTap: onTap,
    );
  }

  Widget _logoutTile(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.lightRed,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.logout, color: AppColors.red, size: 18),
        ),
        title: const Text(
          'Keluar',
          style: TextStyle(color: AppColors.red, fontSize: 13),
        ),
        subtitle: const Text(
          'Akhiri sesi login',
          style: TextStyle(color: AppColors.dark3, fontSize: 11),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.dark3),
        onTap: () => _showLogoutSheet(context),
      ),
    );
  }

  void _showLogoutSheet(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
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
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.light1,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 24),
              const CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.lightRed,
                child: Icon(Icons.logout, color: AppColors.red, size: 36),
              ),
              const SizedBox(height: 18),
              const Text(
                'Yakin ingin keluar?',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sesi login Anda akan dihapus dari perangkat ini. Anda perlu masuk kembali untuk mengakses diabetAku.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.dark2, fontSize: 13),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  style: AppButtonStyles.danger,
                  child: const Text('Batal'),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(sheetContext);

                  await ApiService.logout();

                  if (!parentContext.mounted) return;

                  Navigator.of(parentContext).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Ya, Keluar',
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
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
