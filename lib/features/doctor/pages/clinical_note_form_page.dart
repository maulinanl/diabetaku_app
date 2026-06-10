import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ClinicalNoteFormPage extends StatefulWidget {
  const ClinicalNoteFormPage({super.key});

  @override
  State<ClinicalNoteFormPage> createState() => _ClinicalNoteFormPageState();
}

class _ClinicalNoteFormPageState extends State<ClinicalNoteFormPage> {
  final _formKey = GlobalKey<FormState>();
  // kondisi pasien: 0 = tidak stabil, 1 = stabil, 2 = memburuk, 3 = membaik
  int _kondisi = 1;
  final TextEditingController _catatanCtr = TextEditingController();
  final TextEditingController _rencanaCtr = TextEditingController();
  DateTime? _followUpDate;

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
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        final mq = MediaQuery.of(context).size;
        final maxWidth = mq.width * 0.94;
        final constrainedWidth = maxWidth > 420 ? 420.0 : maxWidth;
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constrainedWidth),
            child: Material(color: Colors.transparent, child: child!),
          ),
        );
      },
    );

    if (picked != null) setState(() => _followUpDate = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'kondisi': _kondisi,
      'catatan': _catatanCtr.text.trim(),
      'rencana': _rencanaCtr.text.trim(),
      'followUp': _followUpDate?.toIso8601String(),
    };

    Navigator.of(context).pop(data);
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeaderAdd(topPad),
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
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.light1),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: AppColors.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _pickFollowUpDate,
              child: Container(
                height: 44,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.veryLightBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _followUpDate == null
                      ? 'Tanggal Follow Up'
                      : _formatDate(_followUpDate!),
                  style: TextStyle(
                    color: _followUpDate == null
                        ? AppColors.dark2
                        : AppColors.dark1,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => setState(() => _followUpDate = null),
            icon: const Icon(Icons.refresh, color: AppColors.primaryBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAdd(double topPad) {
    return Container(
      height: 204,
      padding: EdgeInsets.fromLTRB(18, topPad + 10, 18, 12),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Tambah Catatan Klinis',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            child: Row(
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
                  child: const Center(
                    child: Text(
                      'AS',
                      style: TextStyle(
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
                    children: const [
                      Text(
                        'Angelica Sabi Gita',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '32 tahun • Perempuan',
                        style: TextStyle(fontSize: 13, color: AppColors.dark2),
                      ),
                      SizedBox(height: 8),
                      SizedBox(
                        height: 28,
                        child: Chip(
                          label: Text('DM Tipe 2'),
                          backgroundColor: AppColors.veryLightBlue,
                        ),
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
}
