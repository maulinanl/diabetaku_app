import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/diabetes_type_badge.dart';
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

      if (!mounted) return;

      setState(() {
        _items.clear();

        for (final item in data) {
          final lower = _parseDouble(
            item['custom_min'] ?? item['default_min'],
          )?.toStringAsFixed(2) ??
              '';

          final upper = _parseDouble(
            item['custom_max'] ?? item['default_max'],
          )?.toStringAsFixed(2) ??
              '';

          _items.add(
            _ThresholdItem(
              parameterId: int.tryParse(item['parameter_id'].toString()) ?? 0,
              title: item['parameter_name']?.toString() ?? '-',
              lower: lower,
              upper: upper,
              unit: item['unit']?.toString() ?? '',
              defaultLower: _parseDouble(item['default_min'])
                      ?.toStringAsFixed(2) ??
                  '',
              defaultUpper: _parseDouble(item['default_max'])
                      ?.toStringAsFixed(2) ??
                  '',
              validMin: _parseDouble(item['valid_min']),
              validMax: _parseDouble(item['valid_max']),
            ),
          );
        }

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

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
    final item = _items[index];
    final low = _lowerCtrls[index]!.text.trim();
    final up = _upperCtrls[index]!.text.trim();

    final lowVal = double.tryParse(low.replaceAll(',', '.'));
    final upVal = double.tryParse(up.replaceAll(',', '.'));

    if (lowVal == null || upVal == null) {
      setState(() => _errorText = 'Masukkan angka yang valid');
      return;
    }

    if (upVal <= lowVal) {
      setState(() {
        _errorText = 'Batas atas harus lebih besar dari batas bawah';
      });
      return;
    }

    if (item.validMin != null && lowVal < item.validMin!) {
      setState(() {
        _errorText =
            'Batas bawah ${item.title} tidak boleh kurang dari ${_formatLimit(item.validMin!)} ${item.unit}';
      });
      return;
    }

    if (item.validMax != null && upVal > item.validMax!) {
      setState(() {
        _errorText =
            'Batas atas ${item.title} tidak boleh lebih dari ${_formatLimit(item.validMax!)} ${item.unit}';
      });
      return;
    }

    try {
      await ApiService.updatePatientThreshold(
        patientId: widget.patientId,
        parameterId: item.parameterId,
        minValue: lowVal,
        maxValue: upVal,
      );

      await _fetchThresholds();

      if (widget.onThresholdChanged != null) {
        await widget.onThresholdChanged!();
      }

      if (!mounted) return;

      setState(() {
        item.lower = lowVal.toStringAsFixed(2);
        item.upper = upVal.toStringAsFixed(2);
        _hasChanges = true;
        _editingIndex = null;
        _errorText = null;
      });

      _disposeControllers(index);
      _showSuccessBottomSheet();
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void _disposeControllers(int index) {
    _lowerCtrls[index]?.dispose();
    _upperCtrls[index]?.dispose();
    _lowerCtrls.remove(index);
    _upperCtrls.remove(index);
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

      _disposeControllers(index);
      _showSuccessBottomSheet();
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(
        e.toString().replaceFirst('Exception: ', ''),
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
                  final item = _items[i];
                  final editing = _editingIndex == i;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.light1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _thresholdHeader(item: item, index: i, editing: editing),
                        const SizedBox(height: 12),
                        if (!editing)
                          _thresholdReadContent(item)
                        else
                          _thresholdEditContent(item, i),
                      ],
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

  Widget _thresholdHeader({
    required _ThresholdItem item,
    required int index,
    required bool editing,
  }) {
    return Row(
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
        Expanded(
          child: Text(
            item.title,
            style: const TextStyle(
              color: AppColors.dark1,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (!editing)
          OutlinedButton.icon(
            onPressed: () => _startEdit(index),
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Ubah'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              side: const BorderSide(color: AppColors.primaryBlue),
              foregroundColor: AppColors.primaryBlue,
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          )
        else
          TextButton(
            onPressed: () => _resetToDefault(index),
            child: const Text(
              'Reset default',
              style: TextStyle(color: AppColors.primaryBlue),
            ),
          ),
      ],
    );
  }

  Widget _thresholdReadContent(_ThresholdItem item) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _valueColumn(
                label: 'Batas bawah',
                value: '${item.lower} ${item.unit}',
                helper: 'Default: ${item.defaultLower} ${item.unit}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _valueColumn(
                label: 'Batas atas',
                value: '${item.upper} ${item.unit}',
                helper: 'Default: ${item.defaultUpper} ${item.unit}',
              ),
            ),
          ],
        ),
        _validRangeBox(item),
      ],
    );
  }

  Widget _thresholdEditContent(_ThresholdItem item, int index) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _numberField(
                controller: _lowerCtrls[index],
                label: 'Batas bawah',
                unit: item.unit,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _numberField(
                controller: _upperCtrls[index],
                label: 'Batas atas',
                unit: item.unit,
              ),
            ),
          ],
        ),
        _validRangeBox(item),
        if (_errorText != null) _errorBox(_errorText!),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 42,
                child: OutlinedButton(
                  onPressed: _cancelEdit,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.dark2,
                    side: const BorderSide(color: AppColors.light1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Batal'),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 42,
                child: ElevatedButton(
                  onPressed: () => _saveEdit(index),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Simpan'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _valueColumn({
    required String label,
    required String value,
    required String helper,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.dark2),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          helper,
          style: const TextStyle(fontSize: 11, color: AppColors.dark2),
        ),
      ],
    );
  }

  Widget _numberField({
    required TextEditingController? controller,
    required String label,
    required String unit,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        suffixText: unit,
        filled: true,
        fillColor: AppColors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.light1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.6),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _validRangeBox(_ThresholdItem item) {
    if (item.validMin == null || item.validMax == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.lightBlue),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.primaryBlue,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Rentang input valid: ${_formatLimit(item.validMin!)} - ${_formatLimit(item.validMax!)} ${item.unit}',
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorBox(String message) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.lightRed,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.red, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.red,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
        ],
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
    final topPad = MediaQuery.of(context).padding.top;
    final name = widget.patientProfile['full_name']?.toString() ?? '-';
    final gender = widget.patientProfile['gender']?.toString() ?? '-';
    final diabetesType = widget.patientProfile['diabetes_type']?.toString() ?? '-';
    final age = _calculateAge(widget.patientProfile['date_of_birth']?.toString());
    final initials = _getInitials(name);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
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
                child: Text(
                  'Batas Normal Pasien',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
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
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.lightBlue,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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
                          color: AppColors.dark1,
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
                      DiabetesTypeBadge(value: diabetesType),
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

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString().replaceAll(',', '.'));
  }

  String _formatLimit(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: isError ? AppColors.red : AppColors.primaryBlue,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
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
  final double? validMin;
  final double? validMax;

  _ThresholdItem({
    required this.parameterId,
    required this.title,
    required this.lower,
    required this.upper,
    required this.unit,
    required this.defaultLower,
    required this.defaultUpper,
    this.validMin,
    this.validMax,
  });
}
