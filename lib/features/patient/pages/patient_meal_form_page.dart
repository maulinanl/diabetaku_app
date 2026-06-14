import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PatientMealFormPage extends StatefulWidget {
  const PatientMealFormPage({super.key});

  @override
  State<PatientMealFormPage> createState() => _PatientMealFormPageState();
}

class _PatientMealFormPageState extends State<PatientMealFormPage> {
  final carbCtr = TextEditingController();
  final calorieCtr = TextEditingController();
  final descriptionCtr = TextEditingController();

  DateTime selectedDate = DateTime(2025, 6, 7);
  TimeOfDay selectedTime = const TimeOfDay(hour: 7, minute: 26);

  String selectedMealType = 'Sarapan';

  final mealTypes = [
    ['Sarapan', Icons.wb_sunny_outlined],
    ['Makan siang', Icons.restaurant_outlined],
    ['Makan malam', Icons.dinner_dining_outlined],
    ['Snack', Icons.cookie_outlined],
  ];

  bool get isValid => true;

  @override
  void initState() {
    super.initState();
    carbCtr.addListener(() => setState(() {}));
    calorieCtr.addListener(() => setState(() {}));
    descriptionCtr.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    carbCtr.dispose();
    calorieCtr.dispose();
    descriptionCtr.dispose();
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
                'Data pola makan berhasil tersimpan.',
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
                    _sectionTitle('Pola Makan'),

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

                    _label('Tipe makan*'),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: mealTypes.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 0.95,
                          ),
                      itemBuilder: (context, index) {
                        final item = mealTypes[index];
                        final title = item[0] as String;
                        final icon = item[1] as IconData;
                        final selected = selectedMealType == title;

                        return GestureDetector(
                          onTap: () {
                            setState(() => selectedMealType = title);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.veryLightBlue
                                  : AppColors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primaryBlue
                                    : AppColors.light1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  icon,
                                  color: AppColors.primaryBlue,
                                  size: 19,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    _label('Estimasi karbohidrat (gram)'),
                    _input(
                      controller: carbCtr,
                      hint: 'Masukkan estimasi karbohidrat',
                      keyboardType: TextInputType.number,
                    ),

                    _label('Estimasi kalori (kkal)'),
                    _input(
                      controller: calorieCtr,
                      hint: 'Masukkan estimasi kalori',
                      keyboardType: TextInputType.number,
                    ),

                    _label('Deskripsi makanan'),
                    _input(
                      controller: descriptionCtr,
                      hint: 'Tulis makanan yang dikonsumsi',
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
