import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/diabetes_type_badge.dart';
import '../../../data/services/api_service.dart';
import 'patient_detail_page.dart';
import 'package:diabetaku_app/core/theme/app_button_styles.dart';

class DoctorConnectionPage extends StatefulWidget {
  final int initialTab;
  final int? initialPatientId;
  final VoidCallback? onInitialPatientHandled;

  const DoctorConnectionPage({
    super.key,
    this.initialTab = 0,
    this.initialPatientId,
    this.onInitialPatientHandled,
  });

  @override
  State<DoctorConnectionPage> createState() => _DoctorConnectionPageState();
}

class _DoctorConnectionPageState extends State<DoctorConnectionPage> {
  int selectedTab = 0;
  bool hasOpenedInitialPatient = false;
  final tabs = ['Menunggu', 'Pasien', 'Ditolak'];

  bool isLoading = true;
  String? errorMessage;
  int doctorId = 1;

  List<Map<String, dynamic>> pendingRequests = [];
  List<Map<String, dynamic>> acceptedRequests = [];
  List<Map<String, dynamic>> rejectedRequests = [];

  @override
  void initState() {
    super.initState();
    selectedTab = widget.initialTab;
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
    return formatDiabetesType(value);
  }

  Future<void> _loadData() async {
    if (!mounted) return;

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

      if (!mounted) return;

      setState(() {
        pendingRequests = pending;
        acceptedRequests = accepted;
        rejectedRequests = rejected;
        isLoading = false;
      });

      _openInitialPatientIfNeeded();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  Future<void> _acceptRequest(int patientId) async {
    await ApiService.acceptConnectionRequest(
      doctorId: doctorId,
      patientId: patientId,
    );

    await _loadData();
  }

  Future<void> _rejectRequest(int patientId) async {
    await ApiService.rejectConnectionRequest(
      doctorId: doctorId,
      patientId: patientId,
    );

    await _loadData();
  }

  void _openInitialPatientIfNeeded() {
    final initialPatientId = widget.initialPatientId;

    if (initialPatientId == null || hasOpenedInitialPatient) return;

    hasOpenedInitialPatient = true;
    widget.onInitialPatientHandled?.call();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _openConnectionItemByPatientId(initialPatientId);
    });
  }

  Map<String, dynamic>? _findConnectionItem(
    int patientId,
    List<Map<String, dynamic>> source,
  ) {
    for (final item in source) {
      final itemPatientId = int.tryParse(item['patient_id'].toString());
      if (itemPatientId == patientId) return item;
    }
    return null;
  }

  Future<void> _openConnectionItemByPatientId(int patientId) async {
    final pendingItem = _findConnectionItem(patientId, pendingRequests);
    if (pendingItem != null) {
      setState(() => selectedTab = 0);
      await _openConnectionItemDetail(pendingItem, 0);
      return;
    }

    final acceptedItem = _findConnectionItem(patientId, acceptedRequests);
    if (acceptedItem != null) {
      setState(() => selectedTab = 1);
      await _openConnectionItemDetail(acceptedItem, 1);
      return;
    }

    final rejectedItem = _findConnectionItem(patientId, rejectedRequests);
    if (rejectedItem != null) {
      setState(() => selectedTab = 2);
      await _openConnectionItemDetail(rejectedItem, 2);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Permintaan koneksi tidak ditemukan')),
    );
  }

  Future<void> _openConnectionItemDetail(
    Map<String, dynamic> item,
    int tabStatus,
  ) async {
    final patientId = int.parse(item['patient_id'].toString());
    final name = item['full_name']?.toString() ?? '-';
    final gender = item['gender']?.toString() ?? '-';
    final age = _calculateAge(item['date_of_birth']?.toString());
    final type = _formatDiabetesType(item['diabetes_type']);

    final diagnosis = tabStatus == 0
        ? 'Menunggu persetujuan dokter'
        : tabStatus == 1
        ? 'Koneksi diterima'
        : tabStatus == 3
        ? 'Relasi diputus'
        : 'Koneksi ditolak';

    if (tabStatus == 1 || tabStatus == 3) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PatientDetailPage(
            patientId: patientId,
            isConnected: tabStatus == 1,
          ),
        ),
      );

      await _loadData();
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RequestDetailPage(
          patientId: patientId,
          status: tabStatus,
          name: name,
          age: age,
          gender: gender,
          diabetesType: type,
          connectionStatus: diagnosis,
          onAccept: tabStatus == 0 ? () => _acceptRequest(patientId) : null,
          onReject: tabStatus == 0 ? () => _rejectRequest(patientId) : null,
        ),
      ),
    );

    if (result == true) {
      await _loadData();
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
      backgroundColor: AppColors.background,
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
                                    ? 'PASIEN - ${data.length}'
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

                                        final relationStatus =
                                            item['relation_status']?.toString() ??
                                            (selectedTab == 1
                                                ? 'Diterima'
                                                : selectedTab == 0
                                                ? 'Menunggu'
                                                : 'Ditolak');

                                        final isDisconnected =
                                            relationStatus.toLowerCase().trim() ==
                                            'diputus';

                                        final statusCode = selectedTab == 1 &&
                                                isDisconnected
                                            ? 3
                                            : selectedTab;

                                        final diagnosis = selectedTab == 0
                                            ? 'Menunggu persetujuan dokter'
                                            : statusCode == 1
                                            ? 'Koneksi diterima'
                                            : statusCode == 3
                                            ? 'Relasi diputus'
                                            : 'Koneksi ditolak';

                                        return _RequestCard(
                                          initial: _getInitials(name),
                                          name: name,
                                          info: '$type • $age tahun • $gender',
                                          diagnosis: diagnosis,
                                          status: statusCode,
                                          onDetail: () =>
                                              _openConnectionItemDetail(
                                                item,
                                                statusCode,
                                              ),
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
      padding: EdgeInsets.fromLTRB(20, topPad + 24, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: const Text(
        'Koneksi Pasien',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final selected = selectedTab == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedTab = index),
              child: Container(
                height: 34,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primaryBlue : AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected ? AppColors.primaryBlue : AppColors.light1,
                  ),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.primaryBlue,
                    fontSize: 11,
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
  final int status;
  final VoidCallback onDetail;

  const _RequestCard({
    required this.initial,
    required this.name,
    required this.info,
    required this.diagnosis,
    required this.status,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    final isAccepted = status == 1;
    final isRejected = status == 2;
    final isDisconnected = status == 3;

    final statusColor = isRejected
        ? AppColors.red
        : isDisconnected
        ? AppColors.dark3
        : AppColors.primaryBlue;
    final statusBg = isRejected
        ? AppColors.lightRed
        : isDisconnected
        ? AppColors.light1
        : AppColors.veryLightBlue;

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
                      : isDisconnected
                      ? AppColors.light1
                      : AppColors.lightBlue,
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: isRejected
                          ? AppColors.red
                          : isDisconnected
                          ? AppColors.dark3
                          : AppColors.primaryBlue,
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
                        : isDisconnected
                        ? Icons.link_off_rounded
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
          ],
        ),
      ),
    );
  }
}

class RequestDetailPage extends StatefulWidget {
  final int patientId;
  final int status;
  final Future<void> Function()? onAccept;
  final Future<void> Function()? onReject;

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
  State<RequestDetailPage> createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> {
  bool isProcessing = false;
  late int currentStatus;
  late String currentStatusText;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.status;
    currentStatusText = widget.connectionStatus;
  }

  Future<void> _confirmAccept() async {
    await _showConfirmSheet(
      title: 'Terima permintaan koneksi?',
      message:
          'Pasien akan terhubung dengan dokter dan dapat dipantau melalui aplikasi.',
      icon: Icons.check_circle_outline,
      iconColor: AppColors.primaryBlue,
      buttonText: 'Terima Permintaan',
      buttonColor: AppColors.primaryBlue,
      onConfirm: _handleAccept,
    );
  }

  Future<void> _confirmReject() async {
    await _showConfirmSheet(
      title: 'Tolak permintaan koneksi?',
      message:
          'Permintaan koneksi akan ditolak dan pasien tidak akan terhubung dengan dokter.',
      icon: Icons.cancel_outlined,
      iconColor: AppColors.red,
      buttonText: 'Tolak Permintaan',
      buttonColor: AppColors.red,
      onConfirm: _handleReject,
    );
  }

  Future<void> _handleAccept() async {
    if (widget.onAccept == null || isProcessing) return;

    setState(() => isProcessing = true);

    try {
      await widget.onAccept!();

      if (!mounted) return;

      setState(() {
        currentStatus = 1;
        currentStatusText = 'Koneksi diterima';
        isProcessing = false;
      });

      await _showSuccessSheet(
        title: 'Koneksi Berhasil',
        message:
            'Pasien telah berhasil terhubung dengan dokter. Anda sekarang dapat memantau kondisi pasien.',
        icon: Icons.check_circle_outline,
        buttonText: 'Lihat Detail Pasien',
        onPrimaryTap: () {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PatientDetailPage(
                patientId: widget.patientId,
                isConnected: true,
              ),
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => isProcessing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _handleReject() async {
    if (widget.onReject == null || isProcessing) return;

    setState(() => isProcessing = true);

    try {
      await widget.onReject!();

      if (!mounted) return;

      setState(() {
        currentStatus = 2;
        currentStatusText = 'Koneksi ditolak';
        isProcessing = false;
      });

      await _showSuccessSheet(
        title: 'Permintaan Ditolak',
        message:
            'Permintaan koneksi pasien telah ditolak dan tidak akan ditampilkan sebagai koneksi aktif.',
        icon: Icons.cancel_outlined,
        buttonText: 'Kembali',
        isReject: true,
        onPrimaryTap: () {
          Navigator.pop(context);
          Navigator.pop(context, true);
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => isProcessing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _showConfirmSheet({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    required String buttonText,
    required Color buttonColor,
    required Future<void> Function() onConfirm,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.light1,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 24),
                CircleAvatar(
                  radius: 42,
                  backgroundColor: iconColor.withValues(alpha: 0.12),
                  child: Icon(icon, color: iconColor, size: 46),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.dark2,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      onConfirm();
                    },
                    style: AppButtonStyles.primary,
                    child: Text(buttonText),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showSuccessSheet({
    required String title,
    required String message,
    required IconData icon,
    required String buttonText,
    required VoidCallback onPrimaryTap,
    bool isReject = false,
  }) async {
    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.light1,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 24),
                CircleAvatar(
                  radius: 42,
                  backgroundColor: isReject
                      ? AppColors.lightRed
                      : AppColors.veryLightBlue,
                  child: Icon(
                    icon,
                    color: isReject ? AppColors.red : AppColors.primaryBlue,
                    size: 46,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.dark2,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: onPrimaryTap,
                    style: AppButtonStyles.danger,
                    child: Text(buttonText),
                  ),
                ),
                if (!isReject) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context, true);
                    },
                    child: const Text(
                      'Kembali',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPending = currentStatus == 0;
    final isAccepted = currentStatus == 1;
    final isRejected = currentStatus == 2;

    return Scaffold(
      backgroundColor: AppColors.background,
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
                        _primaryButton(),
                        const SizedBox(height: 12),
                        _outlineButton(),
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
                        _detailButton(),
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

  Widget _primaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton.icon(
        onPressed: isProcessing ? null : _confirmAccept,
        icon: const Icon(Icons.check, size: 16),
        label: const Text('Terima permintaan'),
        style: AppButtonStyles.primary,
      ),
    );
  }

  Widget _outlineButton() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton.icon(
        onPressed: isProcessing ? null : _confirmReject,
        icon: const Icon(Icons.close, size: 16),
        label: const Text('Tolak permintaan'),
        style: AppButtonStyles.outlinedDanger,
      ),
    );
  }

  Widget _detailButton() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PatientDetailPage(
                patientId: widget.patientId,
                isConnected: true,
              ),
            ),
          );
        },
        icon: const Icon(Icons.visibility_outlined, size: 16),
        label: const Text('Lihat Detail Pasien'),
        style: AppButtonStyles.primary,
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isAccepted, bool isRejected) {
    final topPad = MediaQuery.of(context).padding.top;

    final title = isAccepted
        ? 'Koneksi Aktif'
        : isRejected
            ? 'Koneksi Ditolak'
            : 'Permintaan Koneksi';

    final description = isAccepted
        ? 'Permintaan koneksi diterima'
        : isRejected
            ? 'Permintaan koneksi ditolak'
            : 'Permintaan koneksi baru';

    final icon = isAccepted
        ? Icons.check_circle_outline
        : isRejected
            ? Icons.cancel_outlined
            : Icons.person_add_alt_1;

    final iconColor = isRejected ? AppColors.red : AppColors.primaryBlue;
    final iconBg = isRejected ? AppColors.lightRed : AppColors.lightBlue;

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
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
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
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: iconBg,
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        description,
                        style: const TextStyle(
                          color: AppColors.dark1,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.time,
                        style: const TextStyle(
                          color: AppColors.dark2,
                          fontSize: 12,
                        ),
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
          _DetailRow(label: 'Nama', value: widget.name),
          _DetailRow(label: 'Usia', value: '${widget.age} tahun'),
          _DetailRow(label: 'Jenis Kelamin', value: widget.gender),
          _DetailRow(label: 'Tipe Diabetes', value: widget.diabetesType),
          _DetailRow(label: 'Status', value: currentStatusText),
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
