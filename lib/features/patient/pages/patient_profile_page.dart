import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/pages/login_page.dart';
import 'patient_edit_profile_page.dart';

class PatientProfilePage extends StatelessWidget {
  const PatientProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryBlue,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: Container(
                color: AppColors.background,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 120),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _statCard('47', 'Data Input')),
                          const SizedBox(width: 12),
                          Expanded(child: _statCard('2', 'Dokter Aktif')),
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
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPad + 22, 20, 26),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.lightBlue,
            child: Text(
              'AS',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Angelica Sabi Gita',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '32 Tahun • Perempuan',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 12),
          _dmBadge('DM Tipe 2'),
        ],
      ),
    );
  }

  Widget _dmBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
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

  Widget _statCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PatientEditProfilePage(),
                    ),
                  );
                },
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Ubah'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: const BorderSide(color: AppColors.primaryBlue),
                  foregroundColor: AppColors.primaryBlue,
                  backgroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _profileItem(
            Icons.person_outline,
            'Nama Lengkap',
            'Angelica Sabi Gita',
          ),
          _profileItem(
            Icons.email_outlined,
            'Email',
            'angelicaSabiGit@gmail.com',
            badge: 'Terverifikasi',
          ),
          _profileItem(Icons.phone_outlined, 'Nomor Telepon', '081234567890'),
          _profileItem(
            Icons.calendar_today_outlined,
            'Tanggal Lahir',
            '12 Mei 1994',
          ),
          _profileItem(
            Icons.location_on_outlined,
            'Alamat',
            'Jl. Kertanegara No. 12 Majapahit',
          ),

          const Divider(height: 30),

          const Row(
            children: [
              Icon(
                Icons.person_outline,
                color: AppColors.primaryBlue,
                size: 16,
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Data Medis',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _profileItem(Icons.opacity, 'Tipe DM', 'DM Tipe 2'),
          _profileItem(
            Icons.calendar_today_outlined,
            'Tanggal Diagnosis',
            '15 Maret 2018',
            badge: 'Valid',
          ),
          _profileItem(Icons.open_in_full, 'Tinggi Badan', '168 cm'),
          _profileItem(Icons.person_outline, 'Jenis Kelamin', 'Laki - Laki'),
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
                      _miniBadge(badge),
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

  Widget _miniBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFEAFBF3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF10C878),
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
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
          ),
          _menuTile(
            Icons.notifications_none,
            'Notifikasi',
            'Atur preferensi notifikasi',
          ),
          _menuTile(Icons.info_outline, 'Tentang aplikasi', 'Versi 1.0.0'),
        ],
      ),
    );
  }

  Widget _menuTile(IconData icon, String title, String subtitle) {
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
      onTap: () {},
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(sheetContext);
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
