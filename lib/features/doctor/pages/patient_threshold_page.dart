import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';

class PatientThresholdPage extends StatefulWidget {
  final int patientId;
  final Map<String, dynamic> patientProfile;
  final Future<void> Function()? onThresholdChanged;

  const PatientThresholdPage({
    super.key,
    required this.patientId,
    required this.patientProfile,
    this.onThresholdChanged,
  });

  @override
  State<PatientThresholdPage> createState() => _PatientThresholdPageState();
}

class _PatientThresholdPageState extends State<PatientThresholdPage> {
  bool isLoading = true;
  bool _hasChanges = false;
  String? errorMessage;
  final List<_ThresholdItem> _items = [];

  int? _editingIndex;
  final Map<int, TextEditingController> _lowerCtrls = {};
  final Map<int, TextEditingController> _upperCtrls = {};
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _fetchThresholds();
  }

  Future<void> _fetchThresholds() async {
    try {
      final data = await ApiService.getPatientThresholds(widget.patientId);

      setState(() {
        _items.clear();

        for (final item in data) {
          final lower =
              double.tryParse(
                (item['custom_min'] ?? item['default_min'] ?? '').toString(),
              )?.toStringAsFixed(2) ??
              '';

          final upper =
              double.tryParse(
                (item['custom_max'] ?? item['default_max'] ?? '').toString(),
              )?.toStringAsFixed(2) ??
              '';

          _items.add(
            _ThresholdItem(
              parameterId: item['parameter_id'],
              title: item['parameter_name']?.toString() ?? '-',
              lower: lower,
              upper: upper,
              unit: item['unit']?.toString() ?? '',
              defaultLower:
                  double.tryParse(
                    (item['default_min'] ?? '').toString(),
                  )?.toStringAsFixed(2) ??
                  '',
              defaultUpper:
                  double.tryParse(
                    (item['default_max'] ?? '').toString(),
                  )?.toStringAsFixed(2) ??
                  '',
            ),
          );
        }

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

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

  Future<void> _saveEdit(int index) async {
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

    try {
      await ApiService.updatePatientThreshold(
        patientId: widget.patientId,
        parameterId: _items[index].parameterId,
        minValue: lowVal,
        maxValue: upVal,
      );

      await _fetchThresholds();

      if (widget.onThresholdChanged != null) {
        await widget.onThresholdChanged!();
      }

      setState(() {
        _items[index].lower = lowVal.toStringAsFixed(2);
        _items[index].upper = upVal.toStringAsFixed(2);
        _hasChanges = true;

        _editingIndex = null;
        _errorText = null;

        _lowerCtrls[index]?.dispose();
        _upperCtrls[index]?.dispose();
        _lowerCtrls.remove(index);
        _upperCtrls.remove(index);
      });

      if (mounted) {
        _showSuccessBottomSheet();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  void _showSuccessBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 22),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      color: AppColors.veryLightBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.primaryBlue,
                      size: 56,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Batas Normal Berhasil Disimpan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Perubahan batas normal pasien sudah tersimpan dan akan digunakan pada proses monitoring berikutnya.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: AppColors.dark2,
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('OK'),
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

  Future<void> _resetToDefault(int index) async {
    try {
      await ApiService.resetPatientThreshold(
        patientId: widget.patientId,
        parameterId: _items[index].parameterId,
      );

      _lowerCtrls[index]?.text = _items[index].defaultLower;
      _upperCtrls[index]?.text = _items[index].defaultUpper;

      await _fetchThresholds();

      if (widget.onThresholdChanged != null) {
        await widget.onThresholdChanged!();
      }

      if (!mounted) return;

      setState(() {
        _hasChanges = true;
        _editingIndex = null;
        _errorText = null;
      });

      _showSuccessBottomSheet();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text(errorMessage!)),
      );
    }
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

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || name.trim().isEmpty) return '-';

    if (parts.length == 1) return parts.first[0].toUpperCase();

    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  int _calculateAge(String? birthDate) {
    if (birthDate == null) return 0;

    final date = DateTime.tryParse(birthDate);
    if (date == null) return 0;

    final now = DateTime.now();
    int age = now.year - date.year;

    if (now.month < date.month ||
        (now.month == date.month && now.day < date.day)) {
      age--;
    }

    return age;
  }

  Widget _buildHeader() {
    final name = widget.patientProfile['full_name']?.toString() ?? '-';
    final gender = widget.patientProfile['gender']?.toString() ?? '-';
    final diabetesType =
        widget.patientProfile['diabetes_type']?.toString() ?? '-';
    final age = _calculateAge(
      widget.patientProfile['date_of_birth']?.toString(),
    );
    final initials = _getInitials(name);

    return Container(
      height: 210,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
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
                onPressed: () => Navigator.pop(context, _hasChanges),
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
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
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
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$age tahun • $gender',
                        style: const TextStyle(
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
                        child: Text(
                          diabetesType,
                          style: const TextStyle(
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
          ),
        ],
      ),
    );
  }
}

class _ThresholdItem {
  final int parameterId;
  String title;
  String lower;
  String upper;
  final String unit;
  final String defaultLower;
  final String defaultUpper;

  _ThresholdItem({
    required this.parameterId,
    required this.title,
    required this.lower,
    required this.upper,
    required this.unit,
    required this.defaultLower,
    required this.defaultUpper,
  });
}
