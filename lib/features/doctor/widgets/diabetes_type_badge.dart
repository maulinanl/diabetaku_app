import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

String formatDiabetesType(dynamic value) {
  final raw = value?.toString().trim() ?? '';

  if (raw.isEmpty || raw == '-') return '-';

  final normalized = raw
      .toLowerCase()
      .replaceAll('_', ' ')
      .replaceAll('-', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  final hasTypeOne = normalized.contains('tipe 1') ||
      normalized.contains('type 1') ||
      RegExp(r'(^|[^0-9])1([^0-9]|$)').hasMatch(normalized);

  final hasTypeTwo = normalized.contains('tipe 2') ||
      normalized.contains('type 2') ||
      RegExp(r'(^|[^0-9])2([^0-9]|$)').hasMatch(normalized);

  if (hasTypeOne) return 'DM Tipe 1';
  if (hasTypeTwo) return 'DM Tipe 2';

  final cleaned = raw
      .replaceAll('_', ' ')
      .replaceAll('-', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  if (cleaned.toLowerCase().startsWith('dm ')) return cleaned;

  return cleaned;
}

class DiabetesTypeBadge extends StatelessWidget {
  final dynamic value;
  final bool dense;
  final bool inactive;

  const DiabetesTypeBadge({
    super.key,
    required this.value,
    this.dense = false,
    this.inactive = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = formatDiabetesType(value);

    final bg = inactive ? AppColors.light1 : AppColors.veryLightBlue;
    final color = inactive ? AppColors.dark3 : AppColors.primaryBlue;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.opacity,
            size: dense ? 10 : 11,
            color: color,
          ),
          SizedBox(width: dense ? 3 : 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: dense ? 10 : 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
