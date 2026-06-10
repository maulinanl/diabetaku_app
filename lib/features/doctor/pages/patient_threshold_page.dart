import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PatientThresholdPage extends StatefulWidget {
  const PatientThresholdPage({super.key});

  @override
  State<PatientThresholdPage> createState() => _PatientThresholdPageState();
}

class _PatientThresholdPageState extends State<PatientThresholdPage> {
  final List<_ThresholdItem> _items = [
    _ThresholdItem(
      title: 'Glukosa Puasa',
      lower: '70',
      upper: '130',
      unit: 'mg/dL',
      defaultLower: '70',
      defaultUpper: '130',
    ),
    _ThresholdItem(
      title: 'Glukosa Postprandial',
      lower: '70',
      upper: '180',
      unit: 'mg/dL',
      defaultLower: '70',
      defaultUpper: '180',
    ),
    _ThresholdItem(
      title: 'Tekanan Darah Sistolik',
      lower: '90',
      upper: '140',
      unit: 'mmHg',
      defaultLower: '90',
      defaultUpper: '140',
    ),
    _ThresholdItem(
      title: 'Tekanan Darah Diastolik',
      lower: '60',
      upper: '85',
      unit: 'mmHg',
      defaultLower: '60',
      defaultUpper: '85',
    ),
    _ThresholdItem(
      title: 'BMI',
      lower: '18.5',
      upper: '25.0',
      unit: '',
      defaultLower: '18.5',
      defaultUpper: '25.0',
    ),
  ];

  int? _editingIndex;
  final Map<int, TextEditingController> _lowerCtrls = {};
  final Map<int, TextEditingController> _upperCtrls = {};
  String? _errorText;

  @override
  void dispose() {
    for (final c in _lowerCtrls.values) {
      c.dispose();
    }
    for (final c in _upperCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _startEdit(int index) {
    _errorText = null;
    _lowerCtrls[index] = TextEditingController(text: _items[index].lower);
    _upperCtrls[index] = TextEditingController(text: _items[index].upper);
    setState(() => _editingIndex = index);
  }

  void _cancelEdit() {
    if (_editingIndex != null) {
      _lowerCtrls[_editingIndex!]?.dispose();
      _upperCtrls[_editingIndex!]?.dispose();
      _lowerCtrls.remove(_editingIndex!);
      _upperCtrls.remove(_editingIndex!);
    }
    setState(() {
      _editingIndex = null;
      _errorText = null;
    });
  }

  void _saveEdit(int index) {
    final low = _lowerCtrls[index]!.text.trim();
    final up = _upperCtrls[index]!.text.trim();
    final lowVal = double.tryParse(low.replaceAll(',', '.'));
    final upVal = double.tryParse(up.replaceAll(',', '.'));

    if (lowVal == null || upVal == null) {
      setState(() => _errorText = 'Masukkan angka yang valid');
      return;
    }
    if (upVal <= lowVal) {
      setState(
        () => _errorText = 'Batas atas harus lebih besar dari batas bawah',
      );
      return;
    }

    setState(() {
      _items[index].lower = low;
      _items[index].upper = up;
      _editingIndex = null;
      _errorText = null;
      _lowerCtrls[index]?.dispose();
      _upperCtrls[index]?.dispose();
      _lowerCtrls.remove(index);
      _upperCtrls.remove(index);
    });
  }

  void _resetToDefault(int index) {
    setState(() {
      _items[index].lower = _items[index].defaultLower;
      _items[index].upper = _items[index].defaultUpper;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: _items.length,
                itemBuilder: (context, i) {
                  final it = _items[i];
                  final editing = _editingIndex == i;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.light1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppColors.veryLightBlue,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.opacity,
                                      color: AppColors.primaryBlue,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    it.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              if (!editing)
                                OutlinedButton.icon(
                                  onPressed: () => _startEdit(i),
                                  icon: const Icon(Icons.edit, size: 16),
                                  label: const Text('Ubah'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    side: BorderSide(
                                      color: AppColors.primaryBlue,
                                    ),
                                    foregroundColor: AppColors.primaryBlue,
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                )
                              else
                                TextButton(
                                  onPressed: () => _resetToDefault(i),
                                  child: const Text(
                                    'Reset default',
                                    style: TextStyle(
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (!editing)
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Batas bawah',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.dark2,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${it.lower} ${it.unit}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.primaryBlue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Default: ${it.defaultLower}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.dark2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Batas atas',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.dark2,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${it.upper} ${it.unit}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.primaryBlue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Default: ${it.defaultUpper}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.dark2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _lowerCtrls[i],
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        decoration: InputDecoration(
                                          labelText: 'Batas bawah',
                                          suffixText: it.unit,
                                          filled: true,
                                          fillColor: Colors.white,
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            borderSide: BorderSide(
                                              color: AppColors.light1,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            borderSide: BorderSide(
                                              color: AppColors.primaryBlue,
                                              width: 1.6,
                                            ),
                                          ),
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 12,
                                              ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _upperCtrls[i],
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        decoration: InputDecoration(
                                          labelText: 'Batas atas',
                                          suffixText: it.unit,
                                          filled: true,
                                          fillColor: Colors.white,
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            borderSide: BorderSide(
                                              color: AppColors.light1,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            borderSide: BorderSide(
                                              color: AppColors.primaryBlue,
                                              width: 1.6,
                                            ),
                                          ),
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 12,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_errorText != null) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errorText!,
                                          style: const TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 40,
                                        child: OutlinedButton(
                                          onPressed: _cancelEdit,
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: AppColors.dark2,
                                            side: BorderSide(
                                              color: AppColors.light1,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                          ),
                                          child: const Text('Batal'),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: SizedBox(
                                        height: 40,
                                        child: ElevatedButton(
                                          onPressed: () => _saveEdit(i),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.primaryBlue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: const Text(
                                            'Simpan',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 210,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Batas Normal Pasien',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 90,
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
                        children: [
                          const Text(
                            'Angelica Sabi Gita',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '32 tahun • Perempuan',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.dark2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.veryLightBlue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'DM Tipe 2',
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThresholdItem {
  String title;
  String lower;
  String upper;
  final String unit;
  final String defaultLower;
  final String defaultUpper;

  _ThresholdItem({
    required this.title,
    required this.lower,
    required this.upper,
    required this.unit,
    required this.defaultLower,
    required this.defaultUpper,
  });
}
