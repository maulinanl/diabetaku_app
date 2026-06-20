import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';

class FamilyPhysiologicalFormPage extends StatefulWidget {
  final int patientId;
  final String patientInitial;
  final String patientName;
  final String patientInfo;

  const FamilyPhysiologicalFormPage({
    super.key,
    required this.patientId,
    required this.patientInitial,
    required this.patientName,
    required this.patientInfo,
  });

  @override
  State<FamilyPhysiologicalFormPage> createState() =>
      _FamilyPhysiologicalFormPageState();
}

class _FamilyPhysiologicalFormPageState
    extends State<FamilyPhysiologicalFormPage> {
  final systolicCtr = TextEditingController();
  final diastolicCtr = TextEditingController();
  final weightCtr = TextEditingController();
  final heightCtr = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  bool isSaving = false;
  bool isLoadingHeight = true;

  bool get isValid {
    return systolicCtr.text.trim().isNotEmpty ||
        diastolicCtr.text.trim().isNotEmpty ||
        weightCtr.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();

    for (final c in [systolicCtr, diastolicCtr, weightCtr]) {
      c.addListener(() => setState(() {}));
    }

    _loadPatientHeight();
  }

  Future<void> _loadPatientHeight() async {
    try {
      final data = await ApiService.getFamilyPatientDashboard(widget.patientId);
      final profile = data['profile'] ?? {};
      final height = profile['height_cm'];

      if (!mounted) return;

      setState(() {
        heightCtr.text = height == null ? '' : height.toString();
        isLoadingHeight = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoadingHeight = false);
    }
  }

  @override
  void dispose() {
    systolicCtr.dispose();
    diastolicCtr.dispose();
    weightCtr.dispose();
    heightCtr.dispose();
    super.dispose();
  }

  DateTime get measuredAt {
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
  }

  double? get bmi {
    final weight = double.tryParse(weightCtr.text.trim());
    final heightCm = double.tryParse(heightCtr.text.trim());

    if (weight == null || heightCm == null || heightCm <= 0) return null;

    final heightM = heightCm / 100;
    return double.parse((weight / (heightM * heightM)).toStringAsFixed(1));
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    setState(() => isSaving = true);

    try {
      await ApiService.storeFamilyPhysiological(
        patientId: widget.patientId,
        systolic: int.tryParse(systolicCtr.text.trim()),
        diastolic: int.tryParse(diastolicCtr.text.trim()),
        weightKg: double.tryParse(weightCtr.text.trim()),
        bmi: bmi,
        measuredAt: measuredAt,
      );

      if (!mounted) return;
      _showSuccessSheet();
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.dark1,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.dark1,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Tambah Data'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _patientCard(),
            const SizedBox(height: 18),
            _sectionTitle('Data Fisiologis'),
            const SizedBox(height: 14),

            _label('Tanggal dan waktu*'),
            Row(
              children: [
                Expanded(
                  child: _pickerBox(
                    text: _formatDate(selectedDate),
                    icon: Icons.calendar_month_rounded,
                    onTap: isSaving ? null : _pickDate,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _pickerBox(
                    text: _formatTime(selectedTime),
                    icon: Icons.access_time_rounded,
                    onTap: isSaving ? null : _pickTime,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            _label('Tekanan Darah'),
            Row(
              children: [
                Expanded(
                  child: _input(
                    controller: systolicCtr,
                    hint: 'Sistolik',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _input(
                    controller: diastolicCtr,
                    hint: 'Diastolik',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            _label('Berat Badan (kg)'),
            _input(
              controller: weightCtr,
              hint: 'Masukkan berat badan',
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 14),
            _label('Tinggi Badan (cm)'),
            _input(
              controller: heightCtr,
              hint: isLoadingHeight
                  ? 'Mengambil tinggi badan...'
                  : 'Tinggi badan pasien',
              keyboardType: TextInputType.number,
              readOnly: true,
            ),
            const SizedBox(height: 6),
            const Text(
              'Tinggi badan diambil dari profil pasien dan tidak dapat diubah oleh keluarga.',
              style: TextStyle(
                color: AppColors.dark2,
                fontSize: 11,
                height: 1.3,
              ),
            ),

            if (bmi != null) ...[
              const SizedBox(height: 10),
              Text(
                'BMI: $bmi',
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: isValid && !isSaving ? _save : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  disabledBackgroundColor: const Color(0xFFAFCBEA),
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Simpan'),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(context),
                child: const Text(
                  'Batal',
                  style: TextStyle(color: AppColors.primaryBlue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _patientCard() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.light1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.lightBlue,
            child: Text(
              widget.patientInitial,
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
                Text(
                  widget.patientName,
                  style: const TextStyle(
                    color: AppColors.dark1,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.patientInfo,
                  style: const TextStyle(color: AppColors.dark2, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.primaryBlue,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _pickerBox({
    required String text,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.light1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 17, color: AppColors.primaryBlue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: AppColors.dark1,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      enabled: !isSaving,
      readOnly: readOnly,
      keyboardType: keyboardType,
      inputFormatters: readOnly
          ? []
          : [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.dark3, fontSize: 12),
        filled: true,
        fillColor: readOnly ? AppColors.veryLightBlue : AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 13,
        ),
        suffixIcon: readOnly
            ? const Icon(
                Icons.lock_outline,
                size: 18,
                color: AppColors.dark2,
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.light1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.light1),
        ),
      ),
    );
  }

  void _showSuccessSheet() {
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
              const CircleAvatar(
                radius: 36,
                backgroundColor: Color(0xFFEAFBF3),
                child: Icon(Icons.check, color: Color(0xFF10C878), size: 36),
              ),
              const SizedBox(height: 18),
              const Text(
                'Data berhasil disimpan',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Data menunggu konfirmasi pasien sebelum masuk ke riwayat kesehatan.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.dark2, fontSize: 13),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text('Kembali'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Text(message),
      ),
    );
  }
}