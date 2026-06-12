import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FamilyMedicationFormPage extends StatefulWidget {
  final String patientInitial;
  final String patientName;
  final String patientInfo;

  const FamilyMedicationFormPage({
    super.key,
    required this.patientInitial,
    required this.patientName,
    required this.patientInfo,
  });

  @override
  State<FamilyMedicationFormPage> createState() =>
      _FamilyMedicationFormPageState();
}

class _FamilyMedicationFormPageState extends State<FamilyMedicationFormPage> {
  int selectedStatus = 0;

  final statuses = ['Diminum', 'Tidak Diminum', 'Terlambat'];

  final medicineController = TextEditingController();
  final doseController = TextEditingController();
  final actualTimeController = TextEditingController();
  final noteController = TextEditingController();

  @override
  void dispose() {
    medicineController.dispose();
    doseController.dispose();
    actualTimeController.dispose();
    noteController.dispose();
    super.dispose();
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
            const Text(
              'Kepatuhan Obat',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            _label('Tanggal dan waktu*'),
            Row(
              children: [
                Expanded(child: _input(hint: '07/06/2025')),
                const SizedBox(width: 10),
                Expanded(child: _input(hint: '08:00')),
              ],
            ),
            const SizedBox(height: 14),
            _label('Nama obat*'),
            _input(
              hint: 'Contoh: Metformin',
              controller: medicineController,
            ),
            const SizedBox(height: 14),
            _label('Dosis*'),
            _input(
              hint: 'Contoh: 500 mg',
              controller: doseController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),
            _label('Status konsumsi*'),
            _choiceWrap(
              data: statuses,
              selectedIndex: selectedStatus,
              onTap: (index) => setState(() => selectedStatus = index),
            ),
            const SizedBox(height: 14),
            _label('Waktu aktual minum'),
            _input(
              hint: 'Contoh: 08:05',
              controller: actualTimeController,
            ),
            const SizedBox(height: 14),
            _label('Catatan opsional'),
            _input(
              hint: 'Tambahkan catatan',
              controller: noteController,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            _saveButton(context),
            const SizedBox(height: 12),
            _cancelButton(context),
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

  Widget _choiceWrap({
    required List<String> data,
    required int selectedIndex,
    required ValueChanged<int> onTap,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(data.length, (index) {
        final selected = selectedIndex == index;

        return GestureDetector(
          onTap: () => onTap(index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: selected ? AppColors.primaryBlue : AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? AppColors.primaryBlue : AppColors.light1,
              ),
            ),
            child: Text(
              data[index],
              style: TextStyle(
                color: selected ? Colors.white : AppColors.primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }),
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

  Widget _input({
    required String hint,
    TextEditingController? controller,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.dark3, fontSize: 12),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.light1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
      ),
    );
  }

  Widget _saveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        onPressed: () => _showSuccessSheet(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        child: const Text('Simpan'),
      ),
    );
  }

  Widget _cancelButton(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text(
          'Batal',
          style: TextStyle(color: AppColors.primaryBlue),
        ),
      ),
    );
  }

  void _showSuccessSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _successSheet(sheetContext, context),
    );
  }

  Widget _successSheet(BuildContext sheetContext, BuildContext pageContext) {
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
                Navigator.pop(pageContext);
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
  }
}