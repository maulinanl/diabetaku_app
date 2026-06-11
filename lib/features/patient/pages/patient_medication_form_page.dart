import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PatientMedicationFormPage extends StatefulWidget {
  const PatientMedicationFormPage({super.key});

  @override
  State<PatientMedicationFormPage> createState() =>
      _PatientMedicationFormPageState();
}

class _PatientMedicationFormPageState extends State<PatientMedicationFormPage> {
  final medicineCtr = TextEditingController();
  final dosageCtr = TextEditingController();
  final noteCtr = TextEditingController();

  DateTime selectedDate = DateTime(2025, 6, 7);
  TimeOfDay selectedTime = const TimeOfDay(hour: 17, minute: 30);

  String selectedStatus = 'Diminum';

  final statuses = ['Diminum', 'Terlambat', 'Terlewat'];

  bool get isValid =>
      medicineCtr.text.trim().isNotEmpty &&
      dosageCtr.text.trim().isNotEmpty &&
      selectedStatus.isNotEmpty;

  @override
  void initState() {
    super.initState();
    medicineCtr.addListener(() => setState(() {}));
    dosageCtr.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    medicineCtr.dispose();
    dosageCtr.dispose();
    noteCtr.dispose();
    super.dispose();
  }

  String get dateText {
    return '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}';
  }

  String get timeText {
    return '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
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
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) setState(() => selectedDate = picked);
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
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) setState(() => selectedTime = picked);
  }

  void _save() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
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
                'Data kepatuhan obat berhasil tersimpan.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.dark2, fontSize: 13),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text('Tambah data lain'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Kembali ke beranda',
                  style: TextStyle(color: AppColors.primaryBlue),
                ),
              ),
            ],
          ),
        );
      },
    );
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Kepatuhan Obat'),

                    _label('Tanggal dan waktu*'),
                    Row(
                      children: [
                        Expanded(
                          child: _dateTimeBox(
                            text: dateText,
                            icon: Icons.calendar_today_outlined,
                            onTap: _pickDate,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _dateTimeBox(
                            text: timeText,
                            icon: Icons.access_time,
                            onTap: _pickTime,
                          ),
                        ),
                      ],
                    ),

                    _label('Nama obat*'),
                    _input(
                      controller: medicineCtr,
                      hint: 'Masukkan nama obat',
                    ),

                    _label('Dosis*'),
                    _input(
                      controller: dosageCtr,
                      hint: 'Contoh: 500 mg / 1 tablet',
                    ),

                    _label('Status konsumsi*'),
                    Row(
                      children: statuses.map((item) {
                        final selected = selectedStatus == item;

                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => selectedStatus = item),
                            child: Container(
                              height: 42,
                              margin: const EdgeInsets.only(right: 8),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primaryBlue
                                    : AppColors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.light1),
                              ),
                              child: Text(
                                item,
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : AppColors.primaryBlue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    _label('Catatan (opsional)'),
                    _input(
                      controller: noteCtr,
                      hint: 'Tambahkan catatan obat',
                    ),

                    const SizedBox(height: 26),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isValid ? _save : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          disabledBackgroundColor: const Color(0xFFAFCBEA),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          'Simpan',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Center(
                        child: Text(
                          'Batal',
                          style: TextStyle(color: AppColors.primaryBlue),
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

  Widget _header(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, topPad + 14, 16, 18),
      color: AppColors.primaryBlue,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              'Tambah Data',
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
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.primaryBlue,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _dateTimeBox({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.light1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: AppColors.dark1, fontSize: 13),
              ),
            ),
            Icon(icon, color: AppColors.primaryBlue, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.dark4, fontSize: 13),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
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
}