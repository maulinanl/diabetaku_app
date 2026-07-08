import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/diabetes_type_badge.dart';
import 'recommendation_form_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/services/api_service.dart';
import 'package:diabetaku_app/core/theme/app_button_styles.dart';

class ClinicalNoteFormPage extends StatefulWidget {
  final int patientId;
  final Map<String, dynamic> patientProfile;

  const ClinicalNoteFormPage({
    super.key,
    required this.patientId,
    required this.patientProfile,
  });

  @override
  State<ClinicalNoteFormPage> createState() => _ClinicalNoteFormPageState();
}

class _ClinicalNoteFormPageState extends State<ClinicalNoteFormPage> {
  final _formKey = GlobalKey<FormState>();

  int _kondisi = 1;
  final TextEditingController _catatanCtr = TextEditingController();
  final TextEditingController _rencanaCtr = TextEditingController();
  DateTime? _followUpDate;
  

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

  @override
  void dispose() {
    _catatanCtr.dispose();
    _rencanaCtr.dispose();
    super.dispose();
  }

  Future<void> _pickFollowUpDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _followUpDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
              child: Material(color: Colors.transparent, child: child!),
            ),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _followUpDate = picked;
      });
    }
  }

  int? _clinicalNoteId;
  bool _isSaving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final doctorId = prefs.getInt('doctor_id') ?? 1;

      final clinicalNoteId = await ApiService.storeClinicalNote(
        patientId: widget.patientId,
        doctorId: doctorId,
        patientCondition: _getKondisiText(),
        doctorNote: _catatanCtr.text.trim(),
        treatmentPlan: _rencanaCtr.text.trim(),
        followUpDate: _followUpDate,
      );

      setState(() {
        _clinicalNoteId = clinicalNoteId;
        _isSaving = false;
      });

      _showSavedSheet();
    } catch (e) {
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  String _getKondisiText() {
    switch (_kondisi) {
      case 0:
        return 'Tidak Stabil';
      case 1:
        return 'Stabil';
      case 2:
        return 'Memburuk';
      case 3:
        return 'Membaik';
      default:
        return 'Stabil';
    }
  }

  void _showSavedSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
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
                backgroundColor: Color(0xFFEAFBF3),
                child: Icon(Icons.check, color: Color(0xFF10C878), size: 36),
              ),
              const SizedBox(height: 18),
              const Text(
                'Catatan Klinis Tersimpan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Catatan klinis berhasil disimpan. Referensi data klinis terkait telah dilampirkan.',
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecommendationFormPage(
                          patientId: widget.patientId,
                          patientProfile: widget.patientProfile,
                          clinicalNoteId: _clinicalNoteId!,
                        ),
                      ),
                    );
                  },
                  style: AppButtonStyles.primary,
                  child: const Text('Tambah Rekomendasi'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  Navigator.pop(context, true);
                },
                child: const Text(
                  'Selesai',
                  style: TextStyle(color: AppColors.primaryBlue),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildKondisiCard(),
                      const SizedBox(height: 12),
                      _buildTextAreaCard(
                        label: 'Catatan Dokter',
                        controller: _catatanCtr,
                        hint: 'Tulis keluhan, gejala, pemeriksaan singkat...',
                        maxLength: 300,
                      ),
                      const SizedBox(height: 12),
                      _buildTextAreaCard(
                        label: 'Rencana Penanganan',
                        controller: _rencanaCtr,
                        hint: 'Mis. rekomendasi obat, edukasi, rujukan...',
                        maxLength: 300,
                      ),
                      const SizedBox(height: 12),
                      _buildFollowUpCard(),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          style: AppButtonStyles.primary,
                          child: _isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Simpan Catatan',
                                  style: TextStyle(
                                    color: AppColors.background,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Batal',
                          style: TextStyle(color: AppColors.dark2),
                        ),
                      ),
                      const SizedBox(height: 8),
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

  Widget _buildKondisiCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.light1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.favorite, color: AppColors.primaryBlue, size: 18),
              SizedBox(width: 8),
              Text(
                'Kondisi Pasien *',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // grid-like chips (2 columns) for neat layout
          LayoutBuilder(
            builder: (context, constraints) {
              final chipWidth = (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _choiceChip(
                    label: 'Tidak Stabil',
                    value: 0,
                    icon: Icons.warning_amber_rounded,
                    width: chipWidth,
                  ),
                  _choiceChip(
                    label: 'Membaik',
                    value: 3,
                    icon: Icons.thumb_up,
                    width: chipWidth,
                  ),
                  _choiceChip(
                    label: 'Stabil',
                    value: 1,
                    icon: Icons.check_circle_outline,
                    width: chipWidth,
                  ),
                  _choiceChip(
                    label: 'Memburuk',
                    value: 2,
                    icon: Icons.trending_down,
                    width: chipWidth,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _choiceChip({
    required String label,
    required int value,
    IconData? icon,
    double? width,
  }) {
    final selected = _kondisi == value;
    return InkWell(
      onTap: () => setState(() => _kondisi = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.veryLightBlue : AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primaryBlue : AppColors.light1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            if (icon != null)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primaryBlue.withOpacity(0.12)
                      : AppColors.veryLightBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: selected
                      ? AppColors.primaryBlue
                      : AppColors.primaryBlue,
                ),
              ),
            if (icon != null) const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? AppColors.primaryBlue : AppColors.dark2,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextAreaCard({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLength = 300,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.light1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sticky_note_2, color: AppColors.primaryBlue, size: 18),
              const SizedBox(width: 8),
              Text(
                label + (label.endsWith('*') ? '' : ''),
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              TextFormField(
                controller: controller,
                maxLines: null,
                minLines: 4,
                maxLength: maxLength,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(
                    color: AppColors.dark4,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    borderSide: BorderSide(color: AppColors.light1),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    borderSide: BorderSide(color: AppColors.light1),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    borderSide: BorderSide(
                      color: AppColors.primaryBlue,
                      width: 1.4,
                    ),
                  ),
                  isDense: true,
                  counterText: '',
                  contentPadding: const EdgeInsets.fromLTRB(14, 14, 14, 36),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? '$label wajib diisi'
                    : null,
              ),
              Positioned(
                right: 8,
                bottom: 6,
                child: Builder(
                  builder: (context) {
                    final text = controller.text;
                    return Text(
                      '${text.length}/$maxLength',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.dark2,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.light1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_month, color: AppColors.primaryBlue, size: 18),
              SizedBox(width: 8),
              Text(
                'Jadwal Kontrol',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: _pickFollowUpDate,
              icon: const Icon(Icons.calendar_month, size: 18),
              label: Text(
                _followUpDate == null
                    ? 'Pilih Tanggal Kontrol'
                    : _formatDate(_followUpDate!),
              ),
              style: AppButtonStyles.outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final topPad = MediaQuery.of(context).padding.top;
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
      padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Expanded(
                child: Text(
                  'Buat Catatan Klinis',
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
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
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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
                      const SizedBox(height: 6),
                      Text(
                        '$age tahun • $gender',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.dark2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DiabetesTypeBadge(value: diabetesType),
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
}
