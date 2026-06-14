import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PatientMedicationFormPage extends StatefulWidget {
  const PatientMedicationFormPage({super.key});

  @override
  State<PatientMedicationFormPage> createState() =>
      _PatientMedicationFormPageState();
}

class _PatientMedicationFormPageState extends State<PatientMedicationFormPage> {
  final noteCtr = TextEditingController();

  String selectedSchedule = 'Pagi';

  final schedules = ['Pagi', 'Siang', 'Malam'];

  final prescriptions = [
    {
      'medicine': 'Metformin',
      'dosage': '500 mg',
      'instruction': '1 tablet setelah makan',
      'schedule': 'Pagi',
      'doctor': 'dr. Agus Setiawan, Sp.PD',
      'checked': false,
    },
    {
      'medicine': 'Glimepiride',
      'dosage': '2 mg',
      'instruction': '1 tablet sebelum makan',
      'schedule': 'Pagi',
      'doctor': 'dr. Agus Setiawan, Sp.PD',
      'checked': false,
    },
    {
      'medicine': 'Metformin',
      'dosage': '500 mg',
      'instruction': '1 tablet setelah makan',
      'schedule': 'Malam',
      'doctor': 'dr. Agus Setiawan, Sp.PD',
      'checked': false,
    },
  ];

  bool get hasCheckedMedicine {
    return prescriptions.any(
      (item) => item['schedule'] == selectedSchedule && item['checked'] == true,
    );
  }

  @override
  void dispose() {
    noteCtr.dispose();
    super.dispose();
  }

  void _toggleMedicine(int index, bool? value) {
    setState(() {
      prescriptions[index]['checked'] = value ?? false;
    });
  }

  void _save() {
    final now = DateTime.now();

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
                'Kepatuhan obat tersimpan',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Obat yang diminum pada jadwal $selectedSchedule berhasil dicatat otomatis pada ${_formatTimestamp(now)}.',
                textAlign: TextAlign.center,
                style: const TextStyle(
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

  String _formatTimestamp(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final filteredPrescriptions = prescriptions
        .asMap()
        .entries
        .where((entry) => entry.value['schedule'] == selectedSchedule)
        .toList();

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
                    const SizedBox(height: 6),
                    const Text(
                      'Checklist obat sesuai resep aktif dari dokter. Waktu minum akan dicatat otomatis saat kamu menyimpan data.',
                      style: TextStyle(
                        color: AppColors.dark2,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),

                    _label('Waktu minum*'),
                    Row(
                      children: schedules.map((item) {
                        final selected = selectedSchedule == item;

                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => selectedSchedule = item);
                            },
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

                    _label('Daftar obat dari resep dokter*'),

                    if (filteredPrescriptions.isEmpty)
                      _emptyPrescription()
                    else
                      Column(
                        children: filteredPrescriptions.map((entry) {
                          final index = entry.key;
                          final item = entry.value;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _medicineCard(
                              index: index,
                              medicine: item['medicine'] as String,
                              dosage: item['dosage'] as String,
                              instruction: item['instruction'] as String,
                              doctor: item['doctor'] as String,
                              checked: item['checked'] as bool,
                            ),
                          );
                        }).toList(),
                      ),

                    _label('Catatan (opsional)'),
                    _input(
                      controller: noteCtr,
                      hint: 'Contoh: obat diminum setelah makan',
                    ),

                    const SizedBox(height: 26),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: hasCheckedMedicine ? _save : null,
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
                          'Simpan Checklist',
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

  Widget _medicineCard({
    required int index,
    required String medicine,
    required String dosage,
    required String instruction,
    required String doctor,
    required bool checked,
  }) {
    return InkWell(
      onTap: () => _toggleMedicine(index, !checked),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: checked ? AppColors.primaryBlue : AppColors.light1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Checkbox(
              value: checked,
              activeColor: AppColors.primaryBlue,
              onChanged: (value) => _toggleMedicine(index, value),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine,
                    style: const TextStyle(
                      color: AppColors.dark1,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$dosage • $instruction',
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Resep dari $doctor',
                    style: const TextStyle(
                      color: AppColors.dark2,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyPrescription() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.light1),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.medication_outlined,
            color: AppColors.primaryBlue,
            size: 34,
          ),
          SizedBox(height: 10),
          Text(
            'Tidak ada obat pada jadwal ini',
            style: TextStyle(
              color: AppColors.dark1,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Obat akan muncul sesuai resep aktif dari dokter.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.dark2, fontSize: 12, height: 1.4),
          ),
        ],
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

  Widget _input({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
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
