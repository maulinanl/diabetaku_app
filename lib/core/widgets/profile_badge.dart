import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

String formatDiabetesBadgeText(dynamic value) {
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

class ProfileBadge extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final bool dense;

  const ProfileBadge({
    super.key,
    required this.text,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    this.dense = false,
  });

  factory ProfileBadge.headerVerification(String value, {bool dense = false}) {
    final label = normalizeVerificationLabel(value);
    final status = label.toLowerCase();

    final isRejected = status == 'ditolak';
    final isPending = status == 'menunggu verifikasi' ||
        status == 'belum verifikasi' ||
        status.contains('menunggu') ||
        status.contains('belum');

    return ProfileBadge(
      text: label,
      icon: isRejected
          ? Icons.cancel_rounded
          : isPending
              ? Icons.pending_rounded
              : Icons.verified_rounded,
      backgroundColor: isRejected
          ? Colors.red.withValues(alpha: 0.18)
          : isPending
              ? Colors.orange.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.18),
      foregroundColor: Colors.white,
      borderColor: Colors.white.withValues(alpha: 0.35),
      dense: dense,
    );
  }

  factory ProfileBadge.emailVerification(String value, {bool dense = true}) {
    final label = normalizeVerificationLabel(value);
    final status = label.toLowerCase();
    final isVerified = status == 'terverifikasi';
    final isRejected = status == 'ditolak';

    return ProfileBadge(
      text: label,
      icon: isRejected
          ? Icons.cancel_rounded
          : isVerified
              ? Icons.verified_rounded
              : Icons.pending_rounded,
      backgroundColor: isRejected
          ? AppColors.lightRed
          : isVerified
              ? AppColors.veryLightBlue
              : const Color(0xFFFFF4E5),
      foregroundColor: isRejected
          ? AppColors.red
          : isVerified
              ? AppColors.primaryBlue
              : const Color(0xFFF59E0B),
      borderColor: isRejected
          ? AppColors.lightRed
          : isVerified
              ? AppColors.lightBlue
              : const Color(0xFFFFD89C),
      dense: dense,
    );
  }

  factory ProfileBadge.diabetesType(dynamic value, {bool dense = false}) {
    return ProfileBadge(
      text: formatDiabetesBadgeText(value),
      icon: Icons.opacity_rounded,
      backgroundColor: Colors.white.withValues(alpha: 0.18),
      foregroundColor: Colors.white,
      borderColor: Colors.white.withValues(alpha: 0.35),
      dense: dense,
    );
  }

  factory ProfileBadge.role(
    String value, {
    bool dense = false,
    IconData icon = Icons.volunteer_activism_outlined,
  }) {
    return ProfileBadge(
      text: value,
      icon: icon,
      backgroundColor: Colors.white.withValues(alpha: 0.18),
      foregroundColor: Colors.white,
      borderColor: Colors.white.withValues(alpha: 0.35),
      dense: dense,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 18,
        vertical: dense ? 4 : 7,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: dense ? 12 : 14, color: foregroundColor),
          SizedBox(width: dense ? 4 : 5),
          Text(
            text,
            style: TextStyle(
              color: foregroundColor,
              fontSize: dense ? 10 : 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

String normalizeVerificationLabel(String value) {
  final normalized = value.toLowerCase().trim();

  if (normalized == 'disetujui' ||
      normalized == 'verified' ||
      normalized == 'terverifikasi') {
    return 'Terverifikasi';
  }

  if (normalized == 'menunggu' ||
      normalized == 'pending' ||
      normalized.contains('menunggu')) {
    return 'Menunggu Verifikasi';
  }

  if (normalized == 'belum verifikasi' ||
      normalized == 'belum diverifikasi' ||
      normalized.contains('belum')) {
    return 'Belum Verifikasi';
  }

  if (normalized == 'ditolak' || normalized == 'rejected') {
    return 'Ditolak';
  }

  return value.trim().isEmpty ? 'Terverifikasi' : value.trim();
}
