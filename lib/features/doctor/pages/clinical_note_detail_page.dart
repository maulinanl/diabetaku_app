import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';

class ClinicalNoteDetailPage extends StatefulWidget {
  final bool hasRecommendation;
  final Map<String, dynamic> historyData;

  const ClinicalNoteDetailPage({
    super.key,
    required this.hasRecommendation,
    required this.historyData,
  });

  @override
  State<ClinicalNoteDetailPage> createState() => _ClinicalNoteDetailPageState();
}

class _ClinicalNoteDetailPageState extends State<ClinicalNoteDetailPage> {
  Map<String, dynamic>? recommendationData;
  bool isLoadingRecommendation = false;
  String? recommendationError;

  @override
  void initState() {
    super.initState();

    if (widget.hasRecommendation) {
      _loadRecommendationDetail();
    }
  }

  Future<void> _loadRecommendationDetail() async {
    final clinicalNoteId = int.tryParse(
      widget.historyData['clinical_note_id']?.toString() ?? '',
    );

    if (clinicalNoteId == null) return;

    setState(() {
      isLoadingRecommendation = true;
      recommendationError = null;
    });

    try {
      final data = await ApiService.getRecommendationDetail(clinicalNoteId);

      if (!mounted) return;

      setState(() {
        recommendationData = data;
        isLoadingRecommendation = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        recommendationError = e.toString().replaceFirst('Exception: ', '');
        isLoadingRecommendation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.historyData['full_name']?.toString() ?? '-';
    final gender = widget.historyData['gender']?.toString() ?? '-';
    final birthDate = widget.historyData['date_of_birth']?.toString();
    final diabetesType = widget.historyData['diabetes_type']?.toString() ?? '-';

    final patientCondition =
        widget.historyData['patient_condition']?.toString() ?? '-';
    final doctorNote = widget.historyData['doctor_note']?.toString() ?? '-';
    final treatmentPlan =
        widget.historyData['treatment_plan']?.toString() ?? '-';
    final followUpDate = widget.historyData['follow_up_date']?.toString();

    final age = _calculateAge(birthDate);
    final initials = _getInitials(name);

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(
              context: context,
              name: name,
              initials: initials,
              age: age,
              gender: gender,
              diabetesType: diabetesType,
            ),
            Expanded(
              child: Container(
                color: AppColors.background,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _infoCard(
                        icon: Icons.favorite_border,
                        title: 'Kondisi Pasien',
                        child: _statusChip(patientCondition),
                      ),
                      const SizedBox(height: 14),
                      _infoCard(
                        icon: Icons.description_outlined,
                        title: 'Catatan Dokter',
                        child: _paragraphText(doctorNote),
                      ),
                      const SizedBox(height: 14),
                      _infoCard(
                        icon: Icons.notes_outlined,
                        title: 'Rencana Penanganan',
                        child: _paragraphText(treatmentPlan),
                      ),
                      const SizedBox(height: 14),
                      _infoCard(
                        icon: Icons.calendar_today_outlined,
                        title: 'Follow Up',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              followUpDate == null || followUpDate == 'null'
                                  ? 'Tanpa follow up'
                                  : _formatDate(followUpDate),
                              style: const TextStyle(
                                color: AppColors.dark1,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (followUpDate != null &&
                                followUpDate != 'null') ...[
                              const SizedBox(height: 6),
                              Text(
                                _getFollowUpDistance(followUpDate),
                                style: const TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (widget.hasRecommendation) ...[
                        const SizedBox(height: 18),
                        _recommendationSection(),
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

  Widget _buildHeader({
    required BuildContext context,
    required String name,
    required String initials,
    required int age,
    required String gender,
    required String diabetesType,
  }) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 22),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
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
                  'Detail Catatan Klinis',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.lightBlue,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                      Text(
                        '$age tahun • $gender',
                        style: const TextStyle(
                          color: AppColors.dark2,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _miniBadge(diabetesType),
                          if (widget.hasRecommendation)
                            _miniBadge('+ Rekomendasi'),
                        ],
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

  Widget _recommendationSection() {
    if (isLoadingRecommendation) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: _cardDecoration(),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (recommendationError != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(),
        child: Text(
          recommendationError!,
          style: const TextStyle(color: AppColors.red, fontSize: 12),
        ),
      );
    }

    if (recommendationData == null) {
      return const SizedBox();
    }

    final recommendations = List<Map<String, dynamic>>.from(
      recommendationData!['recommendations'] ?? [],
    );

    final recipients = List<Map<String, dynamic>>.from(
      recommendationData!['recipients'] ?? [],
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.recommend_outlined,
                  size: 16, color: AppColors.primaryBlue),
              SizedBox(width: 6),
              Text(
                'Rekomendasi Dokter',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (recommendations.isEmpty)
            const Text(
              'Belum ada detail rekomendasi.',
              style: TextStyle(color: AppColors.dark2, fontSize: 12),
            )
          else
            ...recommendations.map((item) {
              return _recommendationItem(
                category: item['category']?.toString() ?? '-',
                description: item['recommendation_text']?.toString() ?? '-',
              );
            }),
          const SizedBox(height: 14),
          const Divider(color: AppColors.light1),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.groups_outlined,
                  size: 16, color: AppColors.primaryBlue),
              SizedBox(width: 6),
              Text(
                'Rekomendasi Dikirim Kepada',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (recipients.isEmpty)
            const Text(
              'Belum ada data penerima.',
              style: TextStyle(color: AppColors.dark2, fontSize: 12),
            )
          else
            ...recipients.map((item) {
              return _recipientItem(
                name: item['full_name']?.toString() ?? '-',
                role: item['role']?.toString() ?? '-',
              );
            }),
        ],
      ),
    );
  }

  Widget _recommendationItem({
    required String category,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lightBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              category,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.dark2,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _recipientItem({
    required String name,
    required String role,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lightBlue),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryBlue,
            child: Text(
              _getInitials(name),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: AppColors.dark1,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _miniBadge(role),
        ],
      ),
    );
  }

  Widget _paragraphText(String text) {
    return Text(
      text,
      style: const TextStyle(color: AppColors.dark2, fontSize: 13, height: 1.5),
    );
  }

  Widget _miniBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightBlue),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primaryBlue),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _statusChip(String text) {
    final lower = text.toLowerCase();

    final isBad =
        lower.contains('tidak') ||
        lower.contains('memburuk') ||
        lower.contains('abnormal');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isBad ? AppColors.lightRed : AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isBad ? AppColors.red : AppColors.primaryBlue,
          fontSize: 12,
          fontWeight: FontWeight.w600,
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
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    final words = name.trim().split(' ').where((e) => e.isNotEmpty).toList();

    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }

    return words.isNotEmpty ? words.first[0].toUpperCase() : '-';
  }

  int _calculateAge(String? birthDate) {
    if (birthDate == null) return 0;

    final dob = DateTime.tryParse(birthDate);
    if (dob == null) return 0;

    final now = DateTime.now();
    int age = now.year - dob.year;

    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }

    return age;
  }

  String _formatDate(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return value;

    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getFollowUpDistance(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return '-';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final followUp = DateTime(date.year, date.month, date.day);

    final diff = followUp.difference(today).inDays;

    if (diff > 0) return '$diff hari lagi';
    if (diff == 0) return 'Hari ini';
    return 'Sudah lewat ${diff.abs()} hari';
  }
}