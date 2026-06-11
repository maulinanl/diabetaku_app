import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'clinical_note_detail_page.dart';

class DoctorHistoryPage extends StatefulWidget {
  const DoctorHistoryPage({super.key});

  @override
  State<DoctorHistoryPage> createState() => _DoctorHistoryPageState();
}

class _DoctorHistoryPageState extends State<DoctorHistoryPage> {
  int selectedFilter = 0;
  DateTimeRange? selectedRange;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  final filters = ['Semua', 'Catatan Klinis', '+ Rekomendasi'];

  final histories = [
    {
      'initial': 'SG',
      'name': 'Sona Gemilang',
      'age': '32 tahun • Laki-laki',
      'type': 'Rekomendasi',
      'status': 'Tidak Stabil',
      'description':
          'Glukosa postprandial 187 mg/dL, melebihi batas normal. Penyesuaian dosis Metformin diperlukan.',
      'followUp': 'Follow up: 7 Jul 2025',
    },
    {
      'initial': 'AB',
      'name': 'Ahmad Barik',
      'age': '27 tahun • Perempuan',
      'type': 'Catatan Klinis',
      'status': 'Stabil',
      'description':
          'Kondisi pasien stabil. Glukosa puasa dalam batas normal. Tekanan darah terkontrol baik.',
      'followUp': 'Tanpa rekomendasi',
    },
    {
      'initial': 'WH',
      'name': 'Wijaya',
      'age': '52 tahun • Laki-laki',
      'type': 'Rekomendasi',
      'status': 'Perlu perhatian',
      'description':
          'HbA1c turun ke 7.2% dan berat badan mulai terkontrol. Edukasi aktivitas fisik tetap dilanjutkan.',
      'followUp': 'Follow up: 10 Jul 2025',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = histories.where((item) {
      final name = item['name']!.toLowerCase();
      final matchesSearch = name.contains(searchQuery.toLowerCase());

      final matchesFilter = selectedFilter == 0
          ? true
          : selectedFilter == 1
          ? item['type'] == 'Catatan Klinis'
          : item['type'] == 'Rekomendasi';

      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: Container(
                color: AppColors.background,
                child: Column(
                  children: [
                    _buildFilters(),

                    Expanded(
                      child: filtered.isEmpty
                          ? _buildEmptyState()
                          : ListView(
                              padding: const EdgeInsets.fromLTRB(
                                18,
                                16,
                                18,
                                120,
                              ),
                              children: [
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        '7 Jun 2025 - Hari ini',
                                        style: TextStyle(
                                          color: AppColors.primaryBlue,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        final picked =
                                            await _showCompactDateRangePicker();

                                        if (picked != null) {
                                          setState(() {
                                            selectedRange = picked;
                                          });
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.calendar_month,
                                        size: 14,
                                      ),
                                      label: Text(
                                        selectedRange == null
                                            ? 'Rentang tanggal'
                                            : '${selectedRange!.start.day}/${selectedRange!.start.month} - ${selectedRange!.end.day}/${selectedRange!.end.month}',
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.primaryBlue,
                                        backgroundColor: AppColors.white,
                                        side: const BorderSide(
                                          color: AppColors.light1,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                ...filtered.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const ClinicalNoteDetailPage(),
                                          ),
                                        );
                                      },
                                      child: _HistoryCard(
                                        initial: item['initial']!,
                                        name: item['name']!,
                                        age: item['age']!,
                                        type: item['type']!,
                                        status: item['status']!,
                                        description: item['description']!,
                                        followUp: item['followUp']!,
                                      ),
                                    ),
                                  );
                                }),
                              ],
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

  Widget _buildHeader() {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(28, topPad + 28, 28, 28),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Riwayat',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 26),
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Cari nama pasien',
              hintStyle: const TextStyle(fontSize: 14, color: AppColors.dark3),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.primaryBlue,
                size: 22,
              ),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          searchQuery = '';
                        });
                      },
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.dark2,
                        size: 18,
                      ),
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(filters.length, (index) {
            final selected = selectedFilter == index;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedFilter = index;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primaryBlue : AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected ? AppColors.primaryBlue : AppColors.light1,
                  ),
                ),
                child: Text(
                  filters[index],
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.primaryBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Future<DateTimeRange?> _showCompactDateRangePicker() async {
    DateTime? startDate = selectedRange?.start;
    DateTime? endDate = selectedRange?.end;
    final now = DateTime.now();

    return showDialog<DateTimeRange>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 360,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Pilih Rentang Tanggal',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _rangeBox(
                            label: 'Mulai',
                            value: startDate == null
                                ? '-'
                                : '${startDate!.day}/${startDate!.month}/${startDate!.year}',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _rangeBox(
                            label: 'Selesai',
                            value: endDate == null
                                ? '-'
                                : '${endDate!.day}/${endDate!.month}/${endDate!.year}',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      height: 330,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppColors.primaryBlue,
                            onPrimary: Colors.white,
                            surface: Colors.white,
                            onSurface: AppColors.dark1,
                          ),
                        ),
                        child: CalendarDatePicker(
                          initialDate: startDate ?? now,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                          onDateChanged: (date) {
                            setDialogState(() {
                              if (startDate == null ||
                                  (startDate != null && endDate != null)) {
                                startDate = date;
                                endDate = null;
                              } else if (date.isBefore(startDate!)) {
                                endDate = startDate;
                                startDate = date;
                              } else {
                                endDate = date;
                              }
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.dark2,
                              side: const BorderSide(color: AppColors.light1),
                            ),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: startDate != null && endDate != null
                                ? () {
                                    Navigator.pop(
                                      dialogContext,
                                      DateTimeRange(
                                        start: startDate!,
                                        end: endDate!,
                                      ),
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                            ),
                            child: const Text('Terapkan'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _rangeBox({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.light1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.dark2, fontSize: 10),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final isSearching = searchQuery.trim().isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.veryLightBlue,
              child: Icon(
                isSearching ? Icons.search_off : Icons.history_toggle_off,
                color: AppColors.primaryBlue,
                size: 36,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isSearching ? 'Riwayat tidak ditemukan' : 'Belum ada riwayat',
              style: const TextStyle(
                color: AppColors.dark1,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Tidak ada riwayat untuk nama pasien yang kamu cari.'
                  : 'Catatan klinis dengan rekomendasi akan muncul di sini setelah kamu membuat catatan klinis untuk pasien.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String initial;
  final String name;
  final String age;
  final String type;
  final String status;
  final String description;
  final String followUp;

  const _HistoryCard({
    required this.initial,
    required this.name,
    required this.age,
    required this.type,
    required this.status,
    required this.description,
    required this.followUp,
  });

  @override
  Widget build(BuildContext context) {
    final isRecommendation = type == 'Rekomendasi';
    final statusColor = status == 'Stabil'
        ? const Color(0xFF10C878)
        : status == 'Tidak Stabil'
        ? Colors.orange
        : AppColors.primaryBlue;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.light1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.lightBlue,
                child: Text(
                  initial,
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
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.dark1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      age,
                      style: const TextStyle(
                        color: AppColors.dark2,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.veryLightBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isRecommendation ? '+ Rekomendasi' : 'Catatan Klinis',
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: status == 'Tidak Stabil'
                  ? const Color(0xFFFFF8E8)
                  : AppColors.veryLightBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  status == 'Stabil'
                      ? Icons.check_circle_outline
                      : Icons.warning_amber_rounded,
                  size: 16,
                  color: statusColor,
                ),
                const SizedBox(width: 6),
                Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.dark2,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  followUp,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 11,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.dark3),
            ],
          ),
        ],
      ),
    );
  }
}
