import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../patient/widgets/patient_health_form_widgets.dart';

class CaregiverPatientFormCard extends StatelessWidget {
  final String initial;
  final String name;
  final String info;

  const CaregiverPatientFormCard({
    super.key,
    required this.initial,
    required this.name,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.light1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.lightBlue,
            child: Text(
              initial,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w700,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.dark1,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  info,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.dark2,
                    fontSize: 11,
                    height: 1.3,
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

void showCaregiverHealthSuccessSheet({
  required BuildContext context,
  String title = 'Data berhasil disimpan',
  String message =
      'Data menunggu validasi pasien sebelum masuk ke riwayat kesehatan.',
  String buttonText = 'Selesai',
}) {
  showPatientHealthSuccessSheet(
    context: context,
    title: title,
    message: message,
    buttonText: buttonText,
  );
}

void showCaregiverFormSnackBar({
  required BuildContext context,
  required String message,
}) {
  showPatientFormSnackBar(context: context, message: message);
}
