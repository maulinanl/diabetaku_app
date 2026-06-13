import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DoctorPrescriptionPage extends StatefulWidget {
  const DoctorPrescriptionPage({super.key});

  @override
  State<DoctorPrescriptionPage> createState() => _DoctorPrescriptionPageState();
}

class _DoctorPrescriptionPageState extends State<DoctorPrescriptionPage> {
  int selectedSubTab = 0;

  final activePrescriptions = [
    {
      'medicine': 'Metformin',
      'dose': '850 mg',
      'form': 'Tablet',
      'schedule': 'Pagi 1 tablet • Malam 1 tablet',
      'rule': 'Sesudah makan',
      'note': 'Minum teratur dan jangan lewatkan dosis malam.',
      'doctor': 'dr. Agus Setiawan, Sp.PD',
      'date': '7 Jun 2025',
      'isMine': true,
    },
    {
      'medicine': 'Amlodipine',
      'dose': '5 mg',
      'form': 'Tablet',
      'schedule': 'Pagi 1 tablet',
      'rule': 'Sesudah sarapan',
      'note': 'Pantau tekanan darah secara rutin.',
      'doctor': 'dr. Rina Wulandari, Sp.PD',
      'date': '2 Jun 2025',
      'isMine': false,
    },
  ];

  final historyPrescriptions = [
    {
      'medicine': 'Metformin',
      'dose': '500 mg',
      'form': 'Tablet',
      'schedule': 'Pagi 1 tablet • Malam 1 tablet',
      'rule': 'Sesudah makan',
      'doctor': 'dr. Agus Setiawan, Sp.PD',
      'startDate': '1 Jan 2025',
      'endDate': '7 Jun 2025',
      'reason': 'Dosis diperbarui menjadi 850 mg',
    },
    {
      'medicine': 'Glimepiride',
      'dose': '2 mg',
      'form': 'Tablet',
      'schedule': 'Pagi 1 tablet',
      'rule': 'Sebelum makan',
      'doctor': 'dr. Agus Setiawan, Sp.PD',
      'startDate': '10 Feb 2025',
      'endDate': '15 Mei 2025',
      'reason': 'Obat dihentikan',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _subTabs(),
        const SizedBox(height: 14),
        if (selectedSubTab == 0) _activeContent() else _historyContent(),
      ],
    );
  }

  Widget _subTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.light1),
      ),
      child: Row(
        children: [_subTabItem('Aktif', 0), _subTabItem('Riwayat', 1)],
      ),
    );
  }

  Widget _subTabItem(String title, int index) {
    final selected = selectedSubTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedSubTab = index),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.lightBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
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

  Widget _activeContent() {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'RESEP AKTIF PASIEN',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showPrescriptionForm(context),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Tambah Obat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                textStyle: const TextStyle(fontSize: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...activePrescriptions.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _PrescriptionCard(
              medicine: item['medicine'] as String,
              dose: item['dose'] as String,
              form: item['form'] as String,
              schedule: item['schedule'] as String,
              rule: item['rule'] as String,
              note: item['note'] as String,
              doctor: item['doctor'] as String,
              date: item['date'] as String,
              isMine: item['isMine'] as bool,
              onEdit: () => _showPrescriptionForm(context, editMode: true),
              onStop: () => _showStopConfirmation(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _historyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RIWAYAT RESEP',
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        ...historyPrescriptions.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _PrescriptionHistoryCard(
              medicine: item['medicine'] as String,
              dose: item['dose'] as String,
              form: item['form'] as String,
              schedule: item['schedule'] as String,
              rule: item['rule'] as String,
              doctor: item['doctor'] as String,
              startDate: item['startDate'] as String,
              endDate: item['endDate'] as String,
              reason: item['reason'] as String,
            ),
          ),
        ),
      ],
    );
  }

  void _showPrescriptionForm(BuildContext context, {bool editMode = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.light1,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    editMode ? 'Ubah Obat' : 'Tambah Obat',
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _label('Nama Obat*'),
                  _input('Contoh: Metformin'),
                  const SizedBox(height: 12),
                  _label('Dosis*'),
                  _input('Contoh: 850 mg'),
                  const SizedBox(height: 12),
                  _label('Bentuk Sediaan*'),
                  _input('Contoh: Tablet'),
                  const SizedBox(height: 12),
                  _label('Indikasi'),
                  _input('Contoh: Mengontrol kadar glukosa darah'),
                  const SizedBox(height: 12),
                  _label('Jadwal Minum*'),
                  Row(
                    children: [
                      Expanded(child: _scheduleBox('Pagi')),
                      const SizedBox(width: 8),
                      Expanded(child: _scheduleBox('Siang')),
                      const SizedBox(width: 8),
                      Expanded(child: _scheduleBox('Malam')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _label('Aturan Minum'),
                  _input('Contoh: Sesudah makan'),
                  const SizedBox(height: 12),
                  _label('Catatan untuk pasien'),
                  _input('Contoh: Minum rutin sesuai jadwal', maxLines: 3),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _showSuccessSheet(
                          context,
                          editMode
                              ? 'Obat berhasil diperbarui'
                              : 'Obat berhasil ditambahkan ke resep',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: Text(
                        editMode ? 'Simpan Perubahan' : 'Simpan ke Resep',
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

  Widget _input(String hint, {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.dark3, fontSize: 12),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 13,
        ),
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

  Widget _scheduleBox(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.lightBlue),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showStopConfirmation(BuildContext context) {
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
                backgroundColor: AppColors.lightRed,
                child: Icon(Icons.block, color: AppColors.red, size: 36),
              ),
              const SizedBox(height: 18),
              const Text(
                'Hentikan obat ini?',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Obat tidak dihapus, tetapi statusnya menjadi tidak berlaku dan tersimpan sebagai riwayat.',
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
                    _showSuccessSheet(context, 'Obat berhasil dihentikan');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text('Ya, Hentikan'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(sheetContext),
                child: const Text(
                  'Batal',
                  style: TextStyle(color: AppColors.primaryBlue),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessSheet(BuildContext context, String message) {
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
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pasien dan keluarga akan menerima notifikasi pembaruan resep.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.dark2, fontSize: 13),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text('Selesai'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PrescriptionCard extends StatelessWidget {
  final String medicine;
  final String dose;
  final String form;
  final String schedule;
  final String rule;
  final String note;
  final String doctor;
  final String date;
  final bool isMine;
  final VoidCallback onEdit;
  final VoidCallback onStop;

  const _PrescriptionCard({
    required this.medicine,
    required this.dose,
    required this.form,
    required this.schedule,
    required this.rule,
    required this.note,
    required this.doctor,
    required this.date,
    required this.isMine,
    required this.onEdit,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.veryLightBlue,
                child: Icon(
                  Icons.medication_outlined,
                  color: AppColors.primaryBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  medicine,
                  style: const TextStyle(
                    color: AppColors.dark1,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _badge(isMine ? 'Resep Saya' : 'Dokter Lain'),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow('Dosis', '$dose • $form'),
          _infoRow('Jadwal', schedule),
          _infoRow('Aturan', rule),
          _infoRow('Catatan', note),
          const Divider(height: 24),
          Text(
            '$doctor • $date',
            style: const TextStyle(color: AppColors.dark2, fontSize: 11),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Ubah'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.block, size: 16),
                    label: const Text('Hentikan'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.red,
                      side: const BorderSide(color: AppColors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 62,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.dark1, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Resep Dokter Lain',
        style: TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 10,
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
}

class _PrescriptionHistoryCard extends StatelessWidget {
  final String medicine;
  final String dose;
  final String form;
  final String schedule;
  final String rule;
  final String doctor;
  final String startDate;
  final String endDate;
  final String reason;

  const _PrescriptionHistoryCard({
    required this.medicine,
    required this.dose,
    required this.form,
    required this.schedule,
    required this.rule,
    required this.doctor,
    required this.startDate,
    required this.endDate,
    required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.lightRed,
                child: Icon(
                  Icons.history_rounded,
                  color: AppColors.red,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  medicine,
                  style: const TextStyle(
                    color: AppColors.dark1,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _inactiveBadge(),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow('Dosis', '$dose • $form'),
          _infoRow('Jadwal', schedule),
          _infoRow('Aturan', rule),
          _infoRow('Berlaku', '$startDate - $endDate'),
          _infoRow('Alasan', reason),
          const Divider(height: 24),
          Text(
            doctor,
            style: const TextStyle(color: AppColors.dark2, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 62,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.dark1, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inactiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.lightRed,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.25)),
      ),
      child: const Text(
        'Tidak Berlaku',
        style: TextStyle(
          color: AppColors.red,
          fontSize: 9,
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
}
