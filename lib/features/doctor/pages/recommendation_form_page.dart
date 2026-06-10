import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';

class RecommendationFormPage extends StatefulWidget {
  const RecommendationFormPage({super.key});

  @override
  State<RecommendationFormPage> createState() => _RecommendationFormPageState();
}

class _RecommendationFormPageState extends State<RecommendationFormPage> {
  String selectedCategory = 'Obat';
  bool sendToFamily = true;
  bool selectedFamily1 = true;
  bool selectedFamily2 = false;

  final TextEditingController recommendationController =
      TextEditingController(
    text:
        'Tingkatkan dosis Metformin dari 500mg menjadi 850mg, dikonsumsi 2x sehari setelah makan. Monitor gula darah harian.',
  );

  @override
  Widget build(BuildContext context) {
    final isValid = selectedCategory.isNotEmpty &&
        recommendationController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 18),
              _buildPatientCard(),
              const SizedBox(height: 18),
              _buildCategorySection(),
              const SizedBox(height: 16),
              _buildRecommendationInput(),
              const SizedBox(height: 16),
              _buildAddedRecommendation(),
              const SizedBox(height: 16),
              _buildFamilySwitch(),
              const SizedBox(height: 16),
              if (sendToFamily) _buildRecipientSection(),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Kirim Rekomendasi',
                onPressed: isValid ? () => _showSuccessDialog(context) : null,
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 22, 4, 24),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(18),
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 12),
          _buildPatientCard(inner: true),
        ],
      ),
    );
  }

  Widget _buildPatientCard({bool inner = false}) {
    return Container(
      margin: inner ? const EdgeInsets.symmetric(horizontal: 18) : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.lightBlue,
            child: Text(
              'AS',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Angelica Sabi Gita',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '32 tahun • Perempuan',
                  style: TextStyle(fontSize: 12, color: AppColors.dark2),
                ),
                Text(
                  'DM Tipe 2',
                  style: TextStyle(fontSize: 11, color: AppColors.primaryBlue),
                ),
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
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: categories.map((category) {
            final selected = selectedCategory == category;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color:
                          selected ? AppColors.primaryBlue : AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.light1),
                    ),
                    child: Text(
                      category,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selected ? Colors.white : AppColors.dark2,
                        fontSize: 12,
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
          style: TextStyle(color: AppColors.primaryBlue, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: recommendationController,
          maxLines: 5,
          maxLength: 500,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Tulis rekomendasi untuk pasien...',
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.light1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.light1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddedRecommendation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '+ Rekomendasi yang ditambahkan',
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.veryLightBlue,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.lightBlue),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        selectedCategory,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      recommendationController.text,
                      style: const TextStyle(
                        color: AppColors.dark2,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.light1,
              style: BorderStyle.solid,
            ),
          ),
          child: const Center(
            child: Text(
              '+ Tambah kategori lain',
              style: TextStyle(color: AppColors.dark2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFamilySwitch() {
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
                  'Beritahu keluarga',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Teruskan ke keluarga pasien',
                  style: TextStyle(color: AppColors.dark3, fontSize: 11),
                ),
              ],
            ),
          ),
          Switch(
            value: sendToFamily,
            activeColor: AppColors.primaryBlue,
            onChanged: (value) {
              setState(() {
                sendToFamily = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecipientSection() {
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
                  style: TextStyle(color: AppColors.primaryBlue),
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    selectedFamily1 = true;
                    selectedFamily2 = true;
                  });
                },
                child: const Text(
                  'Pilih Semua',
                  style: TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _recipientTile(
            initials: 'SD',
            name: 'Yeni Dewi Sinta',
            relation: 'Istri',
            selected: selectedFamily1,
            onTap: () {
              setState(() {
                selectedFamily1 = !selectedFamily1;
              });
            },
          ),
          const SizedBox(height: 8),
          _recipientTile(
            initials: 'AS',
            name: 'Agus Santoso',
            relation: 'Anak',
            selected: selectedFamily2,
            disabled: false,
            onTap: () {
              setState(() {
                selectedFamily2 = !selectedFamily2;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _recipientTile({
    required String initials,
    required String name,
    required String relation,
    required bool selected,
    bool disabled = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: disabled ? AppColors.light4 : AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primaryBlue : AppColors.light1,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  selected ? AppColors.primaryBlue : AppColors.veryLightBlue,
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
                  Text(name),
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
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 34,
                  backgroundColor: Color(0xFFE7F8EF),
                  child: Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Rekomendasi Terkirim',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Rekomendasi berhasil dikirim dan terhubung dengan catatan klinis.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.dark2, fontSize: 12),
                ),
                const SizedBox(height: 18),
                _successRecipient('Angelica Sabi Gita (Pasien)'),
                const SizedBox(height: 8),
                if (sendToFamily && selectedFamily1)
                  _successRecipient('Yeni Dewi Sinta (Istri)'),
                if (sendToFamily && selectedFamily2)
                  _successRecipient('Agus Santoso (Anak)'),
                const SizedBox(height: 18),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('Kembali ke Beranda'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _successRecipient(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        name,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 12,
        ),
      ),
    );
  }
}