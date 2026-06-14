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

  final List<Map<String, String>> addedRecommendations = [];

  void _addRecommendation() {
    final text = recommendationController.text.trim();

    if (text.isEmpty) return;

    setState(() {
      addedRecommendations.add({'category': selectedCategory, 'text': text});

      recommendationController.clear();
      selectedCategory = 'Obat';
    });
  }

  void _removeRecommendation(int index) {
    setState(() {
      addedRecommendations.removeAt(index);
    });
  }

  final TextEditingController recommendationController = TextEditingController(
    text:
        'Tingkatkan dosis Metformin dari 500mg menjadi 850mg, dikonsumsi 2x sehari setelah makan. Monitor gula darah harian.',
  );

  @override
  void dispose() {
    recommendationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isValid = addedRecommendations.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Container(
                color: AppColors.background,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        onPressed: isValid
                            ? () => _showSuccessDialog(context)
                            : null,
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Batal',
                            style: TextStyle(color: AppColors.primaryBlue),
                          ),
                        ),
                      ),
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

  Widget _buildHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPad + 14, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 12),
          _buildPatientCard(),
        ],
      ),
    );
  }

  Widget _buildPatientCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.lightBlue,
            child: Text(
              'AS',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Angelica Sabi Gita',
                  style: TextStyle(
                    color: AppColors.dark1,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '32 tahun • Perempuan',
                  style: TextStyle(color: AppColors.dark2, fontSize: 13),
                ),
                SizedBox(height: 4),
                Text(
                  'DM Tipe 2',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
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
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: categories.map((category) {
            final selected = selectedCategory == category;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: category == categories.last ? 0 : 8,
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primaryBlue : AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.light1),
                    ),
                    child: Text(
                      category,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selected ? Colors.white : AppColors.dark2,
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
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
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: recommendationController,
          maxLines: 5,
          maxLength: 500,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Tulis rekomendasi untuk pasien...',
            hintStyle: const TextStyle(color: AppColors.dark3, fontSize: 12),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.all(14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.light1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaryBlue),
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
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton.icon(
            onPressed: _addRecommendation,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Tambahkan Rekomendasi'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              side: const BorderSide(color: AppColors.primaryBlue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        if (addedRecommendations.isNotEmpty) ...[
          const SizedBox(height: 14),
          const Text(
            'Rekomendasi yang ditambahkan',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),

          ...List.generate(addedRecommendations.length, (index) {
            final item = addedRecommendations[index];

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.veryLightBlue,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.lightBlue),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item['category']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item['text']!,
                          style: const TextStyle(
                            color: AppColors.dark2,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeRecommendation(index),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.dark3,
                      size: 18,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
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
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    selectedFamily1 = true;
                    selectedFamily2 = true;
                  });
                },
                child: const Text('Pilih Semua'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _recipientTile(
            initials: 'YS',
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primaryBlue : AppColors.light1,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: selected
                  ? AppColors.primaryBlue
                  : AppColors.veryLightBlue,
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
                  Text(
                    name,
                    style: const TextStyle(
                      color: AppColors.dark1,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                  child: Icon(Icons.check, color: Colors.green, size: 36),
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
        style: const TextStyle(color: AppColors.primaryBlue, fontSize: 12),
      ),
    );
  }
}
