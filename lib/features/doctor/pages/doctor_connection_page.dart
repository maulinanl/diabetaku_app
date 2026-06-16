import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';
import 'patient_detail_page.dart';

class DoctorConnectionPage extends StatefulWidget {
  const DoctorConnectionPage({super.key});

  @override
  State<DoctorConnectionPage> createState() => _DoctorConnectionPageState();
}

class _DoctorConnectionPageState extends State<DoctorConnectionPage> {
  int selectedTab = 0;
  final tabs = ['Menunggu', 'Diterima', 'Ditolak'];

  bool isLoading = true;
  String? errorMessage;
  int doctorId = 1;

  List<Map<String, dynamic>> pendingRequests = [];
  List<Map<String, dynamic>> acceptedRequests = [];
  List<Map<String, dynamic>> rejectedRequests = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || name.trim().isEmpty) return '-';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  int _calculateAge(String? birthDate) {
    if (birthDate == null) return 0;
    final date = DateTime.tryParse(birthDate);
    if (date == null) return 0;

    final now = DateTime.now();
    int age = now.year - date.year;

    if (now.month < date.month ||
        (now.month == date.month && now.day < date.day)) {
      age--;
    }

    return age;
  }

  String _formatDiabetesType(dynamic value) {
    final type = value?.toString() ?? '-';
    if (type.contains('1')) return 'Tipe 1';
    if (type.contains('2')) return 'Tipe 2';
    return type.replaceAll('_', ' ');
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      doctorId = prefs.getInt('doctor_id') ?? 1;

      final pending = await ApiService.getDoctorConnectionRequests(doctorId);
      final accepted = await ApiService.getDoctorPatients(doctorId);
      final rejected = await ApiService.getRejectedConnectionRequests(doctorId);

      setState(() {
        pendingRequests = pending;
        acceptedRequests = accepted;
        rejectedRequests = rejected;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  Future<void> _acceptRequest(int patientId) async {
    try {
      await ApiService.acceptConnectionRequest(
        doctorId: doctorId,
        patientId: patientId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permintaan berhasil diterima')),
      );

      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _rejectRequest(int patientId) async {
    try {
      await ApiService.rejectConnectionRequest(
        doctorId: doctorId,
        patientId: patientId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permintaan berhasil ditolak')),
      );

      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = selectedTab == 0
        ? pendingRequests
        : selectedTab == 1
        ? acceptedRequests
        : rejectedRequests;

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
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage != null
                    ? Center(child: Text(errorMessage!))
                    : Column(
                        children: [
                          _buildTabs(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                selectedTab == 0
                                    ? 'KONEKSI MENUNGGU - ${data.length}'
                                    : selectedTab == 1
                                    ? 'KONEKSI DITERIMA - ${data.length}'
                                    : 'KONEKSI DITOLAK - ${data.length}',
                                style: const TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: data.isEmpty
                                ? _emptyState()
                                : RefreshIndicator(
                                    onRefresh: _loadData,
                                    child: ListView.separated(
                                      padding: const EdgeInsets.fromLTRB(
                                        18,
                                        0,
                                        18,
                                        120,
                                      ),
                                      itemCount: data.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 14),
                                      itemBuilder: (context, index) {
                                        final item = data[index];

                                        final patientId = int.parse(
                                          item['patient_id'].toString(),
                                        );

                                        final name =
                                            item['full_name']?.toString() ??
                                            '-';
                                        final gender =
                                            item['gender']?.toString() ?? '-';
                                        final age = _calculateAge(
                                          item['date_of_birth']?.toString(),
                                        );
                                        final type = _formatDiabetesType(
                                          item['diabetes_type'],
                                        );

                                        final diagnosis = selectedTab == 0
                                            ? 'Menunggu persetujuan dokter'
                                            : selectedTab == 1
                                            ? 'Koneksi diterima'
                                            : 'Koneksi ditolak';

                                        return _RequestCard(
                                          initial: _getInitials(name),
                                          name: name,
                                          info:
                                              'DM $type • $age tahun • $gender',
                                          diagnosis: diagnosis,
                                          time: '',
                                          status: selectedTab,
                                          onDetail: () {
                                            if (selectedTab == 1) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      PatientDetailPage(
                                                        patientId: patientId,
                                                        isConnected: true,
                                                      ),
                                                ),
                                              );
                                            } else {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      RequestDetailPage(
                                                        patientId: patientId,
                                                        status: selectedTab,
                                                        name: name,
                                                        age: age,
                                                        gender: gender,
                                                        diabetesType:
                                                            'DM $type',
                                                        connectionStatus:
                                                            diagnosis,
                                                        onAccept:
                                                            selectedTab == 0
                                                            ? () =>
                                                                  _acceptRequest(
                                                                    patientId,
                                                                  )
                                                            : null,
                                                        onReject:
                                                            selectedTab == 0
                                                            ? () =>
                                                                  _rejectRequest(
                                                                    patientId,
                                                                  )
                                                            : null,
                                                      ),
                                                ),
                                              );
                                            }
                                          },
                                          onAccept: selectedTab == 0
                                              ? () => _acceptRequest(patientId)
                                              : null,
                                          onReject: selectedTab == 0
                                              ? () => _rejectRequest(patientId)
                                              : null,
                                        );
                                      },
                                    ),
                                  ),
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

  Widget _buildHeader(BuildContext context) {
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
      child: const Center(
        child: Text(
          'Permintaan Koneksi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final selected = selectedTab == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedTab = index),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primaryBlue : AppColors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: selected ? AppColors.primaryBlue : AppColors.light1,
                  ),
                ),
                child: Text(
                  tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 44),
        child: Text(
          'Tidak ada permintaan koneksi.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.primaryBlue, fontSize: 12),
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final String initial;
  final String name;
  final String info;
  final String diagnosis;
  final String time;
  final int status;
  final VoidCallback? onDetail;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const _RequestCard({
    required this.initial,
    required this.name,
    required this.info,
    required this.diagnosis,
    required this.time,
    required this.status,
    required this.onDetail,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = status == 0;
    final isAccepted = status == 1;
    final isRejected = status == 2;

    final statusColor = isRejected ? AppColors.red : AppColors.primaryBlue;
    final statusBg = isRejected ? AppColors.lightRed : AppColors.veryLightBlue;

    return InkWell(
      onTap: onDetail,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.light1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: isRejected
                      ? AppColors.lightRed
                      : AppColors.lightBlue,
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: isRejected ? AppColors.red : AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.dark1,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        info,
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onDetail != null)
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.dark3,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(
                    isAccepted
                        ? Icons.check_circle_outline
                        : isRejected
                        ? Icons.cancel_outlined
                        : Icons.hourglass_bottom_rounded,
                    size: 13,
                    color: statusColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    diagnosis,
                    style: TextStyle(color: statusColor, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (isPending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: onAccept,
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Terima'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: OutlinedButton.icon(
                        onPressed: onReject,
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Tolak'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.red,
                          side: const BorderSide(color: AppColors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class RequestDetailPage extends StatelessWidget {
  final int patientId;
  final int status;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  final String name;
  final int age;
  final String gender;
  final String diabetesType;
  final String connectionStatus;
  final String time;

  const RequestDetailPage({
    super.key,
    required this.patientId,
    required this.status,
    required this.name,
    required this.age,
    required this.gender,
    required this.diabetesType,
    required this.connectionStatus,
    this.onAccept,
    this.onReject,
    this.time = '08:15',
  });

  @override
  Widget build(BuildContext context) {
    final isPending = status == 0;
    final isAccepted = status == 1;
    final isRejected = status == 2;

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(context, isAccepted, isRejected),
            Expanded(
              child: Container(
                color: AppColors.background,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _dataPatientCard(),
                      if (isPending) ...[
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: onAccept,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Terima Permintaan'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: OutlinedButton(
                            onPressed: onReject,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.red,
                              side: const BorderSide(color: AppColors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Tolak Permintaan'),
                          ),
                        ),
                      ] else if (isAccepted) ...[
                        const SizedBox(height: 18),
                        _infoBox(
                          icon: Icons.check_circle_outline,
                          text:
                              'Permintaan koneksi ini telah diterima. Pasien sudah terhubung dengan dokter.',
                          color: AppColors.primaryBlue,
                          bg: AppColors.veryLightBlue,
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PatientDetailPage(
                                    patientId: patientId,
                                    isConnected: true,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Lihat Detail Pasien'),
                          ),
                        ),
                      ] else if (isRejected) ...[
                        const SizedBox(height: 18),
                        _infoBox(
                          icon: Icons.cancel_outlined,
                          text:
                              'Permintaan koneksi ini telah ditolak. Pasien tidak terhubung dengan dokter.',
                          color: AppColors.red,
                          bg: AppColors.lightRed,
                        ),
                      ],
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

  Widget _buildHeader(BuildContext context, bool isAccepted, bool isRejected) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 24),
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
              Expanded(
                child: Text(
                  isAccepted
                      ? 'Koneksi Aktif'
                      : isRejected
                      ? 'Koneksi Ditolak'
                      : 'Permintaan Koneksi',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: isRejected
                      ? AppColors.lightRed
                      : AppColors.lightBlue,
                  child: Icon(
                    isAccepted
                        ? Icons.check_circle_outline
                        : isRejected
                        ? Icons.cancel_outlined
                        : Icons.person_add_alt_1,
                    color: isRejected ? AppColors.red : AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isAccepted
                        ? 'Permintaan koneksi diterima\n$time'
                        : isRejected
                        ? 'Permintaan koneksi ditolak\n$time'
                        : 'Permintaan koneksi baru\n$time',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dataPatientCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.light1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Data Pasien',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 14),
          _DetailRow(label: 'Nama', value: name),
          _DetailRow(label: 'Usia', value: '$age tahun'),
          _DetailRow(label: 'Jenis Kelamin', value: gender),
          _DetailRow(label: 'Tipe Diabetes', value: diabetesType),
          _DetailRow(label: 'Status', value: connectionStatus),
        ],
      ),
    );
  }

  Widget _infoBox({
    required IconData icon,
    required String text,
    required Color color,
    required Color bg,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontSize: 12, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 12,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: AppColors.dark1, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
