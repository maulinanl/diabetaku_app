import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/diabetes_type_badge.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../data/services/api_service.dart';

class RecommendationFormPage extends StatefulWidget {
  final int patientId;
  final Map<String, dynamic> patientProfile;
  final int clinicalNoteId;

  const RecommendationFormPage({
    super.key,
    required this.patientId,
    required this.patientProfile,
    required this.clinicalNoteId,
  });

  @override
  State<RecommendationFormPage> createState() => _RecommendationFormPageState();
}

class _RecommendationFormPageState extends State<RecommendationFormPage> {
  String selectedCategory = 'Obat';
  bool sendToCaregiver = true;
  bool _isSending = false;

  final List<Map<String, String>> addedRecommendations = [];

  List<Map<String, dynamic>> caregivers = [];
  final Set<int> selectedCaregiverUserIds = {};
  bool isLoadingCaregivers = true;

  String _getInitials(String name) {
    final parts = name.trim().split(' ');

    if (parts.isEmpty || name.trim().isEmpty) return '-';

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

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

  void _addRecommendation() {
    final text = recommendationController.text.trim();

    if (text.isEmpty) return;

    setState(() {
      addedRecommendations.add({'category': selectedCategory, 'text': text});

      recommendationController.clear();
      selectedCategory = 'Obat';
    });
  }

  void _removeRecommendation(int index) {
    setState(() {
      addedRecommendations.removeAt(index);
    });
  }

  final TextEditingController recommendationController =
      TextEditingController();

  @override
  void dispose() {
    recommendationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isValid = addedRecommendations.isNotEmpty;

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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategorySection(),
                      const SizedBox(height: 16),
                      _buildRecommendationInput(),
                      const SizedBox(height: 16),
                      _buildAddedRecommendation(),
                      const SizedBox(height: 16),
                      _buildCaregiverSwitch(),
                      const SizedBox(height: 16),
                      if (sendToCaregiver) _buildRecipientSection(),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: _isSending ? 'Mengirim...' : 'Kirim Rekomendasi',
                        onPressed: isValid && !_isSending
                            ? _sendRecommendations
                            : null,
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Batal',
                            style: TextStyle(color: AppColors.primaryBlue),
                          ),
                        ),
                      ),
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

  Widget _buildHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 24),
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
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Expanded(
                child: Text(
                  'Tambah Rekomendasi',
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
          const SizedBox(height: 12),
          _buildPatientCard(),
        ],
      ),
    );
  }

  Widget _buildPatientCard() {
    final name = widget.patientProfile['full_name']?.toString() ?? '-';

    final gender = widget.patientProfile['gender']?.toString() ?? '-';

    final diabetesType =
        widget.patientProfile['diabetes_type']?.toString() ?? '-';

    final age = _calculateAge(
      widget.patientProfile['date_of_birth']?.toString(),
    );

    final initials = _getInitials(name);

    return Container(
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
            radius: 28,
            backgroundColor: AppColors.lightBlue,
            child: Text(
              initials,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$age tahun • $gender',
                  style: const TextStyle(color: AppColors.dark2, fontSize: 13),
                ),
                const SizedBox(height: 4),
                DiabetesTypeBadge(value: diabetesType),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    final categories = ['Obat', 'Pola Makan', 'Gaya Hidup'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori rekomendasi *',
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: categories.map((category) {
            final selected = selectedCategory == category;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: category == categories.last ? 0 : 8,
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primaryBlue : AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.light1),
                    ),
                    child: Text(
                      category,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selected ? Colors.white : AppColors.dark2,
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecommendationInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Isi rekomendasi *',
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: recommendationController,
          maxLines: 5,
          maxLength: 500,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Tulis rekomendasi untuk pasien...',
            hintStyle: const TextStyle(color: AppColors.dark3, fontSize: 12),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.all(14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.light1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaryBlue),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecipientSection() {
    if (isLoadingCaregivers) {
      return const Center(child: CircularProgressIndicator());
    }

    if (caregivers.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.light1),
        ),
        child: const Text(
          'Belum ada pendamping yang terhubung dengan pasien.',
          style: TextStyle(color: AppColors.dark2, fontSize: 12),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.light1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Pilih penerima',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    selectedCaregiverUserIds
                      ..clear()
                      ..addAll(
                        caregivers.map((e) => int.parse(e['user_id'].toString())),
                      );
                  });
                },
                child: const Text('Pilih Semua'),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...caregivers.map((caregiver) {
            final userId = int.parse(caregiver['user_id'].toString());
            final name = caregiver['full_name']?.toString() ?? '-';
            final relation = caregiver['relation_name']?.toString() ?? 'Pendamping';
            final selected = selectedCaregiverUserIds.contains(userId);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _recipientTile(
                initials: _getInitials(name),
                name: name,
                relation: relation,
                selected: selected,
                onTap: () {
                  setState(() {
                    if (selected) {
                      selectedCaregiverUserIds.remove(userId);
                    } else {
                      selectedCaregiverUserIds.add(userId);
                    }
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAddedRecommendation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton.icon(
            onPressed: _addRecommendation,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Tambahkan Rekomendasi'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              side: const BorderSide(color: AppColors.primaryBlue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        if (addedRecommendations.isNotEmpty) ...[
          const SizedBox(height: 14),
          const Text(
            'Rekomendasi yang ditambahkan',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),

          ...List.generate(addedRecommendations.length, (index) {
            final item = addedRecommendations[index];

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.veryLightBlue,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.lightBlue),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item['category']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item['text']!,
                          style: const TextStyle(
                            color: AppColors.dark2,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeRecommendation(index),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.dark3,
                      size: 18,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildCaregiverSwitch() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.light1),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.veryLightBlue,
            child: Icon(Icons.groups, color: AppColors.primaryBlue),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Beritahu pendamping',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Teruskan ke pendamping pasien',
                  style: TextStyle(color: AppColors.dark3, fontSize: 11),
                ),
              ],
            ),
          ),
          Switch(
            value: sendToCaregiver,
            activeThumbColor: AppColors.primaryBlue,
            onChanged: (value) {
              setState(() {
                sendToCaregiver = value;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchCaregivers();
  }

  Future<void> _fetchCaregivers() async {
    try {
      final data = await ApiService.getPatientCaregivers(widget.patientId);

      setState(() {
        caregivers = data;
        selectedCaregiverUserIds.addAll(
          data.map((e) => int.parse(e['user_id'].toString())),
        );
        isLoadingCaregivers = false;
      });
    } catch (_) {
      setState(() => isLoadingCaregivers = false);
    }
  }

  Future<void> _sendRecommendations() async {
    if (addedRecommendations.isEmpty) return;

    final patientUserId = widget.patientProfile['user_id'];

    if (patientUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID pasien tidak ditemukan')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final recipientUserIds = <int>[int.parse(patientUserId.toString())];

      if (sendToCaregiver) {
        recipientUserIds.addAll(selectedCaregiverUserIds);
      }

      await ApiService.storeRecommendations(
        clinicalNoteId: widget.clinicalNoteId,
        recommendations: addedRecommendations,
        recipientUserIds: recipientUserIds,
      );

      setState(() => _isSending = false);

      if (mounted) {
        _showSuccessDialog(context);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSending = false);
      _showSuccessDialog(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Widget _recipientTile({
    required String initials,
    required String name,
    required String relation,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primaryBlue : AppColors.light1,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: selected
                  ? AppColors.primaryBlue
                  : AppColors.veryLightBlue,
              child: Text(
                initials,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.primaryBlue,
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
                      color: AppColors.dark1,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    relation,
                    style: const TextStyle(
                      color: AppColors.dark3,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? AppColors.primaryBlue : AppColors.light1,
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    final patientName =
        widget.patientProfile['full_name']?.toString() ?? 'Pasien';

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 28),

                  Container(
                    width: 110,
                    height: 110,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEAFBF3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFF10C878),
                      size: 62,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Rekomendasi Terkirim',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Rekomendasi berhasil dikirim dan terhubung dengan catatan klinis.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: AppColors.dark2,
                    ),
                  ),

                  const SizedBox(height: 22),

                  _successRecipient('$patientName (Pasien)', Icons.person),

                  if (sendToCaregiver)
                    ...caregivers
                        .where((caregiver) {
                          final userId = int.parse(
                            caregiver['user_id'].toString(),
                          );
                          return selectedCaregiverUserIds.contains(userId);
                        })
                        .map((caregiver) {
                          final name = caregiver['full_name']?.toString() ?? '-';
                          final relation =
                              caregiver['relation_name']?.toString() ?? 'Pendamping';

                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: _successRecipient(
                              '$name ($relation)',
                              Icons.groups,
                            ),
                          );
                        }),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        Navigator.pop(context, true);
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Selesai',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _successRecipient(String name, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightBlue),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryBlue),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              name,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
