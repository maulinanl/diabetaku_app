import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';
import 'caregiver_patient_detail_page.dart';

class CaregiverConnectionPage extends StatefulWidget {
  const CaregiverConnectionPage({super.key});

  @override
  State<CaregiverConnectionPage> createState() => _CaregiverConnectionPageState();
}

class _CaregiverConnectionPageState extends State<CaregiverConnectionPage> {
  int mainTab = 0;

  final searchCtr = TextEditingController();

  bool isLoading = true;
  bool isSearching = false;
  bool isSubmitting = false;
  bool hasSearched = false;
  String? errorMessage;

  int? caregiverId;

  List<Map<String, dynamic>> connectedPatients = [];
  List<Map<String, dynamic>> searchResults = [];
  List<Map<String, dynamic>> relationTypes = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();

    searchCtr.addListener(() {
      setState(() {
        hasSearched = false;
        searchResults = [];
      });
    });
  }

  @override
  void dispose() {
    searchCtr.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final storedCaregiverId = prefs.getInt('caregiver_id');

      if (storedCaregiverId == null) {
        throw Exception('Caregiver ID tidak ditemukan. Coba login ulang.');
      }

      final patients = await ApiService.getCaregiverPatients(storedCaregiverId);
      final relations = await ApiService.getRelationTypes();

      if (!mounted) return;

      setState(() {
        caregiverId = storedCaregiverId;
        connectedPatients = patients;
        relationTypes = relations;
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

  Future<void> _searchPatients() async {
    final email = searchCtr.text.trim();

    if (email.isEmpty) {
      setState(() {
        searchResults = [];
        hasSearched = false;
      });
      return;
    }

    if (!email.contains('@')) {
      setState(() {
        searchResults = [];
        hasSearched = false;
      });
      return;
    }

    try {
      FocusScope.of(context).unfocus();

      setState(() {
        isSearching = true;
        hasSearched = false;
        searchResults = [];
      });

      final result = await ApiService.findCaregiverPatient(email: email);

      if (!mounted) return;

      setState(() {
        searchResults = result;
        hasSearched = true;
        isSearching = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSearching = false;
        hasSearched = true;
      });

      _showSnackBar(message: e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _requestConnection({
    required int patientId,
    required Map<String, dynamic> relation,
  }) async {
    if (caregiverId == null) return;

    try {
      setState(() => isSubmitting = true);

      await ApiService.requestCaregiverConnection(
        caregiverId: caregiverId!,
        patientId: patientId,
        relationTypeId: int.parse(relation['relation_type_id'].toString()),
      );

      if (!mounted) return;

      _showSnackBar(
        message: 'Permintaan koneksi berhasil dikirim',
        isError: false,
      );

      await _loadInitialData();
      await _searchPatients();
    } catch (e) {
      if (!mounted) return;

      _showSnackBar(message: e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  String _connectionStatus(Map<String, dynamic> patient) {
    final status = patient['status']?.toString();

    if (status == 'Diterima') return 'Terhubung';
    if (status == 'Menunggu') return 'Menunggu';

    return 'Belum Terhubung';
  }

  String _initial(String name) {
    final parts = name.trim().split(' ').where((e) => e.isNotEmpty).toList();

    if (parts.isEmpty) return '-';
    if (parts.length == 1) return parts.first[0].toUpperCase();

    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String _patientName(Map<String, dynamic> patient) {
    return patient['full_name']?.toString() ??
        patient['name']?.toString() ??
        '-';
  }

  String _patientInfo(Map<String, dynamic> patient) {
    final dm = patient['diabetes_type']?.toString() ?? '-';
    final gender = patient['gender']?.toString();

    if (gender == null || gender == '-' || gender == 'null') return dm;

    return '$dm • $gender';
  }

  String _patientRelation(Map<String, dynamic> patient) {
    return patient['relation_name']?.toString() ??
        patient['relation']?.toString() ??
        '-';
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty || value == 'null') return '-';

    final date = DateTime.tryParse(value);
    if (date == null) return value;

    return '${date.day}/${date.month}/${date.year}';
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
            _tabs(),
            Expanded(child: _content()),
          ],
        ),
      ),
    );
  }

  Widget _content() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return _errorState();
    }

    if (mainTab == 0) return _connectedPatientContent();

    return _searchPatientContent();
  }

  Widget _header(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPad + 18, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: const Center(
        child: Text(
          'Koneksi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _tabs() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.light1),
      ),
      child: Row(
        children: [_mainTabItem('Pasien', 0), _mainTabItem('Cari Pasien', 1)],
      ),
    );
  }

  Widget _mainTabItem(String title, int index) {
    final selected = mainTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => mainTab = index),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.lightBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: selected ? AppColors.primaryBlue : AppColors.dark1,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _connectedPatientContent() {
    final acceptedPatients = connectedPatients.where((item) {
      final status = item['status']?.toString();
      return status == 'Diterima' || status == 'Terhubung';
    }).toList();

    if (acceptedPatients.isEmpty) return _emptyPatient();

    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
        children: [
          Text(
            'PASIEN SAYA - ${acceptedPatients.length} TERHUBUNG',
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...acceptedPatients.map((item) {
            final name = _patientName(item);

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _ConnectionCard(
                initial: _initial(name),
                name: name,
                info: '${_patientRelation(item)} • ${_patientInfo(item)}',
                status: 'Terhubung',
                date: _formatDate(
                  item['connected_at']?.toString() ??
                      item['connected_since']?.toString(),
                ),
                showVerified: false,
                onTap: () async {
                  final changed = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CaregiverPatientDetailPage(
                        patientId: int.parse(item['patient_id'].toString()),
                        initial: _initial(name),
                        name: name,
                        relation: _patientRelation(item),
                        date: _formatDate(
                          item['connected_at']?.toString() ??
                              item['connected_since']?.toString(),
                        ),
                      ),
                    ),
                  );

                  if (changed == true) {
                    await _loadInitialData();
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _searchPatientContent() {
    final keyword = searchCtr.text.trim();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
      children: [
        _searchBox(),
        const SizedBox(height: 24),
        if (keyword.isEmpty)
          _emptySearch()
        else if (isSearching)
          const Center(child: CircularProgressIndicator())
        else if (!keyword.contains('@') || !hasSearched)
          _typingEmailHint()
        else if (searchResults.isEmpty)
          _notFound()
        else ...[
          Text(
            'HASIL PENCARIAN - ${searchResults.length} PASIEN',
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...searchResults.map((item) {
            final name = _patientName(item);
            final status = _connectionStatus(item);
            final connected = status == 'Terhubung';
            final pending = status == 'Menunggu';

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _SearchPatientCard(
                initial: _initial(name),
                name: name,
                info: _patientInfo(item),
                status: status,
                onTap: () async {
                  final changed = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CaregiverPatientSearchDetailPage(
                        patient: item,
                        relationTypes: relationTypes,
                        isConnected: connected,
                        isPending: pending,
                        isSubmitting: isSubmitting,
                        onSubmit: (relation) async {
                          await _requestConnection(
                            patientId: int.parse(item['patient_id'].toString()),
                            relation: relation,
                          );
                        },
                      ),
                    ),
                  );

                  if (changed == true) {
                    await _loadInitialData();
                    await _searchPatients();
                  }
                },
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _searchBox() {
    final email = searchCtr.text.trim();

    return TextField(
      controller: searchCtr,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _searchPatients(),
      decoration: InputDecoration(
        hintText: 'Masukkan email pasien',
        hintStyle: const TextStyle(color: AppColors.dark3, fontSize: 12),
        prefixIcon: const Icon(
          Icons.email_outlined,
          color: AppColors.primaryBlue,
          size: 18,
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (email.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                color: AppColors.dark3,
                onPressed: () {
                  searchCtr.clear();
                  setState(() {
                    searchResults = [];
                    hasSearched = false;
                  });
                },
              ),
            IconButton(
              icon: isSearching
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search, size: 20),
              color: AppColors.primaryBlue,
              onPressed: isSearching ? null : _searchPatients,
            ),
          ],
        ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.light1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _emptyPatient() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 34),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 42,
              backgroundColor: AppColors.lightBlue,
              child: Icon(
                Icons.group_add_rounded,
                color: AppColors.primaryBlue,
                size: 42,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Belum ada pasien terhubung',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cari pasien menggunakan email untuk mengajukan koneksi sebagai pendamping pendamping.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.dark2,
                fontSize: 12,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () => setState(() => mainTab = 1),
                icon: const Icon(Icons.email_outlined, size: 18),
                label: const Text('Cari Pasien'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptySearch() {
    return const Column(
      children: [
        SizedBox(height: 70),
        Icon(Icons.email_outlined, size: 64, color: AppColors.dark3),
        SizedBox(height: 16),
        Text(
          'Cari Pasien',
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Masukkan email pasien yang ingin kamu dampingi.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.dark2, fontSize: 12),
        ),
      ],
    );
  }

  Widget _typingEmailHint() {
    return const Column(
      children: [
        SizedBox(height: 60),
        Icon(
          Icons.alternate_email_rounded,
          size: 64,
          color: AppColors.dark3,
        ),
        SizedBox(height: 14),
        Text(
          'Lengkapi email pasien',
          style: TextStyle(
            color: AppColors.dark1,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            'Ketik email lengkap pasien terlebih dahulu, lalu tekan ikon cari.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.dark2,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }

  Widget _notFound() {
    return const Column(
      children: [
        SizedBox(height: 60),
        Icon(Icons.person_search_outlined, size: 64, color: AppColors.dark3),
        SizedBox(height: 12),
        Text(
          'Pasien tidak ditemukan',
          style: TextStyle(
            color: AppColors.dark1,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          errorMessage ?? 'Gagal memuat koneksi pendamping',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.dark2, fontSize: 13),
        ),
      ),
    );
  }

  void _showSnackBar({required String message, bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? AppColors.red : AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  final String initial;
  final String name;
  final String info;
  final String status;
  final String date;
  final bool showVerified;
  final VoidCallback? onTap;

  const _ConnectionCard({
    required this.initial,
    required this.name,
    required this.info,
    required this.status,
    required this.date,
    required this.showVerified,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isConnected = status == 'Diterima' || status == 'Terhubung';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: _cardDecoration(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.lightBlue,
              child: Text(
                initial,
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: AppColors.dark1,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    info,
                    style: const TextStyle(
                      color: AppColors.dark2,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (showVerified)
                        _statusBadge(
                          text: 'Terverifikasi',
                          bg: AppColors.veryLightBlue,
                          textColor: AppColors.primaryBlue,
                          icon: Icons.verified,
                        ),
                      _statusBadge(
                        text: status,
                        bg: isConnected
                            ? const Color(0xFFEAFBF3)
                            : AppColors.veryLightBlue,
                        textColor: isConnected
                            ? const Color(0xFF10C878)
                            : AppColors.primaryBlue,
                        icon: isConnected
                            ? Icons.check_circle
                            : Icons.access_time,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _dateBox(date),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Padding(
              padding: EdgeInsets.only(top: 30),
              child: Icon(Icons.chevron_right, color: AppColors.dark3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateBox(String date) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            size: 12,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(width: 5),
          Text(
            date,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge({
    required String text,
    required Color bg,
    required Color textColor,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: textColor),
            const SizedBox(width: 3),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
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

class CaregiverPatientSearchDetailPage extends StatefulWidget {
  final Map<String, dynamic> patient;
  final List<Map<String, dynamic>> relationTypes;
  final bool isConnected;
  final bool isPending;
  final bool isSubmitting;
  final Future<void> Function(Map<String, dynamic> relation) onSubmit;

  const CaregiverPatientSearchDetailPage({
    super.key,
    required this.patient,
    required this.relationTypes,
    required this.isConnected,
    required this.isPending,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  State<CaregiverPatientSearchDetailPage> createState() =>
      _CaregiverPatientSearchDetailPageState();
}

class _CaregiverPatientSearchDetailPageState
    extends State<CaregiverPatientSearchDetailPage> {
  Map<String, dynamic>? selectedRelation;
  bool isSubmitting = false;

  String get name =>
      widget.patient['full_name']?.toString() ??
      widget.patient['name']?.toString() ??
      '-';

  String get email => widget.patient['email']?.toString() ?? '-';

  String get gender => widget.patient['gender']?.toString() ?? '-';

  String get dm => widget.patient['diabetes_type']?.toString() ?? '-';

  String get initial {
    final parts = name.trim().split(' ').where((e) => e.isNotEmpty).toList();

    if (parts.isEmpty) return '-';
    if (parts.length == 1) return parts.first[0].toUpperCase();

    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Future<void> _submit() async {
    if (selectedRelation == null) return;

    setState(() => isSubmitting = true);

    try {
      await widget.onSubmit(selectedRelation!);

      if (!mounted) return;

      Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.isConnected
        ? 'Terhubung'
        : widget.isPending
        ? 'Menunggu'
        : 'Belum Terhubung';

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
                    _infoCard(status),
                    const SizedBox(height: 18),
                    if (!widget.isConnected && !widget.isPending)
                      _relationCard(),
                    const SizedBox(height: 22),
                    _button(),
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
      color: AppColors.primaryBlue,
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Expanded(
                child: Text(
                  'Detail Pasien',
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
            '$dm • $gender',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String status) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _InfoRow(icon: Icons.person_outline, label: 'Nama', value: name),
          _InfoRow(icon: Icons.email_outlined, label: 'Email', value: email),
          _InfoRow(
            icon: Icons.monitor_heart_outlined,
            label: 'Tipe DM',
            value: dm,
          ),
          _InfoRow(
            icon: Icons.check_circle_outline,
            label: 'Status',
            value: status,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _relationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih Hubungan',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.relationTypes.map((item) {
            final relationName =
                item['relation_name']?.toString() ??
                item['name']?.toString() ??
                '-';

            final selected =
                selectedRelation?['relation_type_id']?.toString() ==
                item['relation_type_id']?.toString();

            return InkWell(
              onTap: () => setState(() => selectedRelation = item),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      relationName,
                      style: const TextStyle(
                        color: AppColors.dark1,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _button() {
    if (widget.isConnected) {
      return SizedBox(
        width: double.infinity,
        height: 46,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            disabledBackgroundColor: const Color(0xFFEAFBF3),
            disabledForegroundColor: const Color(0xFF10C878),
          ),
          child: const Text('Sudah Terhubung'),
        ),
      );
    }

    if (widget.isPending) {
      return SizedBox(
        width: double.infinity,
        height: 46,
        child: ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.access_time, size: 18),
          label: const Text('Menunggu Persetujuan'),
          style: ElevatedButton.styleFrom(
            disabledBackgroundColor: const Color(0xFFFFF4DA),
            disabledForegroundColor: Colors.orange,
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton.icon(
        onPressed: selectedRelation != null && !isSubmitting ? _submit : null,
        icon: isSubmitting
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.person_add_alt_1, size: 18),
        label: const Text('Ajukan Koneksi'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          disabledBackgroundColor: const Color(0xFFAFCBEA),
          foregroundColor: Colors.white,
          elevation: 0,
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

class _SearchPatientCard extends StatelessWidget {
  final String initial;
  final String name;
  final String info;
  final String status;
  final VoidCallback onTap;

  const _SearchPatientCard({
    required this.initial,
    required this.name,
    required this.info,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isConnected = status == 'Terhubung';
    final isPending = status == 'Menunggu';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.lightBlue,
              child: Text(
                initial,
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: AppColors.dark1,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    info,
                    style: const TextStyle(
                      color: AppColors.dark2,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _statusBadge(
                    text: status,
                    bg: isConnected
                        ? const Color(0xFFEAFBF3)
                        : isPending
                        ? const Color(0xFFFFF4DA)
                        : AppColors.veryLightBlue,
                    textColor: isConnected
                        ? const Color(0xFF10C878)
                        : isPending
                        ? Colors.orange
                        : AppColors.primaryBlue,
                    icon: isConnected
                        ? Icons.check_circle
                        : isPending
                        ? Icons.access_time
                        : Icons.person_add_alt_1,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.dark3),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge({
    required String text,
    required Color bg,
    required Color textColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: textColor),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}
