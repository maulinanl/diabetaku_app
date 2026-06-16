import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'recommendation_form_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/services/api_service.dart';

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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
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
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
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
      padding: const EdgeInsets.all(12),
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
                style: TextStyle(fontWeight: FontWeight.w600),
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
          color: selected ? AppColors.lightBlue : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.lightBlue : AppColors.light1,
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
      padding: const EdgeInsets.all(12),
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
                style: const TextStyle(fontWeight: FontWeight.w600),
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
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(color: AppColors.light1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(color: AppColors.light1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(
                      color: AppColors.primaryBlue,
                      width: 1.6,
                    ),
                  ),
                  isDense: true,
                  counterText: '', // custom counter shown below
                  contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 36),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.light1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jadwal Kontrol',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: _pickFollowUpDate,
            icon: const Icon(Icons.calendar_month, size: 18),
            label: Text(
              _followUpDate == null
                  ? 'Pilih Tanggal Kontrol'
                  : _formatDate(_followUpDate!),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              alignment: Alignment.centerLeft,
              foregroundColor: AppColors.primaryBlue,
              backgroundColor: Colors.white,
              side: const BorderSide(color: AppColors.light1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final name = widget.patientProfile['full_name']?.toString() ?? '-';
    final gender = widget.patientProfile['gender']?.toString() ?? '-';

    String diabetesType =
        widget.patientProfile['diabetes_type']?.toString() ?? '-';
    diabetesType = diabetesType.replaceAll('_', ' ').toUpperCase();

    final age = _calculateAge(
      widget.patientProfile['date_of_birth']?.toString(),
    );
    final initials = _getInitials(name);
    return Container(
      constraints: const BoxConstraints(minHeight: 210),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
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
                child: Center(
                  child: Text(
                    'Buat Catatan Klinis',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
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
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.veryLightBlue,
                          width: 4,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
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
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.veryLightBlue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              diabetesType,
                              style: const TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
