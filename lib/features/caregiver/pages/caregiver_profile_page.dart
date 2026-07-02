import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/profile_badge.dart';
import '../../../data/services/api_service.dart';
import '../../auth/pages/change_password_page.dart';
import '../../auth/pages/login_page.dart';
import 'caregiver_edit_profile_page.dart';
import 'package:diabetaku_app/core/theme/app_button_styles.dart';

class CaregiverProfilePage extends StatefulWidget {
  const CaregiverProfilePage({super.key});

  @override
  State<CaregiverProfilePage> createState() => _CaregiverProfilePageState();
}

class _CaregiverProfilePageState extends State<CaregiverProfilePage> {
  bool isLoading = true;
  String? errorMessage;

  Map<String, dynamic>? profile;
  int totalPatients = 0;
  int totalMedicationSchedulesToday = 0;

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
      final caregiverId = prefs.getInt('caregiver_id');

      if (caregiverId == null) {
        throw Exception('Caregiver ID tidak ditemukan. Coba login ulang.');
      }

      final data = await ApiService.getCaregiverProfile(caregiverId);

      if (!mounted) return;

      setState(() {
        profile = data;
        totalPatients =
            int.tryParse(data['total_patients']?.toString() ?? '0') ?? 0;
        totalMedicationSchedulesToday =
            int.tryParse(
              data['total_medication_schedules_today']?.toString() ??
                  data['total_medication_checklists']?.toString() ??
                  '0',
            ) ??
            0;
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

  String get fullName => profile?['full_name']?.toString() ?? '-';
  String get email => profile?['email']?.toString() ?? '-';
  String get phone => profile?['phone_number']?.toString() ?? '-';
  String get gender => profile?['gender']?.toString() ?? '-';

  String get emailBadge {
    final verified = profile?['email_verified_at'];
    return verified == null ? 'Belum Verifikasi' : 'Terverifikasi';
  }

  String _initial(String name) {
    final parts = name.trim().split(' ').where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '-';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return _errorState();
    }

    return Container(
      color: AppColors.background,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: Container(
                color: AppColors.background,
                child: RefreshIndicator(
                  onRefresh: _loadProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 120),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _statCard(
                                totalPatients.toString(),
                                'Pasien Didampingi',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _statCard(
                                totalMedicationSchedulesToday.toString(),
                                'Jadwal Obat Hari Ini',
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

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.red, size: 42),
            const SizedBox(height: 12),
            Text(
              errorMessage ?? 'Gagal memuat profil pendamping',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.dark2, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProfile,
              style: AppButtonStyles.primary,
              child: const Text('Coba lagi'),
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
              _initial(fullName),
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            gender,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              ProfileBadge.role('Pendamping'),
              ProfileBadge.headerVerification(emailBadge),
            ],
          ),
        ],
      ),
    );
  }



  Widget _statCard(String value, String label, {String? suffix}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      decoration: _cardDecoration(),
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
          if (suffix != null) ...[
            const SizedBox(height: 2),
            Text(
              suffix,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.primaryBlue, fontSize: 10),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
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
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CaregiverEditProfilePage(),
                    ),
                  );
                  _loadProfile();
                },
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Ubah'),
                style: AppButtonStyles.outlined,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _profileItem(Icons.person_outline, 'Nama Lengkap', fullName),
          _profileItem(Icons.email_outlined, 'Email', email, badge: emailBadge),
          _profileItem(Icons.phone_outlined, 'Nomor Telepon', phone),
          _profileItem(Icons.wc_outlined, 'Jenis Kelamin', gender),
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

  Widget _statusBadge(String text) {
    final isVerified = text.toLowerCase() == 'terverifikasi';
    final bg = isVerified ? AppColors.veryLightBlue : Colors.orange.shade50;
    final color = isVerified ? AppColors.primaryBlue : Colors.orange.shade700;

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
            isVerified ? Icons.verified : Icons.pending,
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
      title: Text(
        title,
        style: const TextStyle(color: AppColors.dark1, fontSize: 13),
      ),
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

  void _showLogoutSheet(BuildContext context) {
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
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sesi login Anda akan dihapus dari perangkat ini.',
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

                  if (!context.mounted) return;

                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
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
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}
