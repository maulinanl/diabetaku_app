import 'package:flutter/material.dart';

import '../../../core/theme/app_button_styles.dart';
import '../../../core/theme/app_colors.dart';

class PatientFormHeader extends StatelessWidget {
  final String title;
  final bool disabled;
  final VoidCallback? onBack;

  const PatientFormHeader({
    super.key,
    required this.title,
    this.disabled = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12, topPad + 12, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: disabled ? null : (onBack ?? () => Navigator.pop(context)),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class PatientFormSectionTitle extends StatelessWidget {
  final String text;

  const PatientFormSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class PatientFormLabel extends StatelessWidget {
  final String text;

  const PatientFormLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
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
}

class PatientDateTimeBox extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final bool disabled;

  const PatientDateTimeBox({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(6),
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
}

InputDecoration patientFormInputDecoration({
  String? hint,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.dark4, fontSize: 13),
    filled: true,
    fillColor: AppColors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: AppColors.light1),
    ),
    disabledBorder: OutlineInputBorder(
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
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: AppColors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: AppColors.red, width: 1.4),
    ),
  );
}

class PatientChoiceChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;
  final double? width;

  const PatientChoiceChip({
    super.key,
    required this.text,
    required this.selected,
    this.onTap,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: selected ? Colors.white : AppColors.primaryBlue,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.15,
      ),
    );

    final Widget content;

    if (icon == null) {
      content = label;
    } else {
      content = Row(
        mainAxisSize: width == null ? MainAxisSize.min : MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: selected ? Colors.white : AppColors.primaryBlue,
            size: 16,
          ),
          const SizedBox(width: 6),
          width == null ? label : Flexible(child: label),
        ],
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: width,
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlue : AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primaryBlue : AppColors.light1,
          ),
        ),
        child: content,
      ),
    );
  }
}

class PatientMealTypeCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  const PatientMealTypeCard({
    super.key,
    required this.text,
    required this.icon,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlue : AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primaryBlue : AppColors.light1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : AppColors.primaryBlue,
              size: 19,
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.primaryBlue,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PatientFormSelectField extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final List<String> items;
  final bool disabled;
  final ValueChanged<String> onSelected;

  const PatientFormSelectField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onSelected,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PatientFormLabel(label),
        InkWell(
          onTap: disabled
              ? null
              : () => showPatientOptionSheet(
                    context: context,
                    title: label,
                    items: items,
                    selectedValue: value,
                    onSelected: onSelected,
                  ),
          borderRadius: BorderRadius.circular(6),
          child: InputDecorator(
            decoration: patientFormInputDecoration(),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? hint,
                    style: TextStyle(
                      color: value == null ? AppColors.dark4 : AppColors.dark1,
                      fontSize: 13,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.dark3,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PatientFormSubmitButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool isSaving;
  final VoidCallback onPressed;

  const PatientFormSubmitButton({
    super.key,
    required this.label,
    required this.enabled,
    required this.isSaving,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: enabled && !isSaving ? onPressed : null,
        style: AppButtonStyles.primary,
        child: isSaving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}

class PatientFormCancelButton extends StatelessWidget {
  final bool disabled;

  const PatientFormCancelButton({
    super.key,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: disabled ? null : () => Navigator.pop(context),
      child: const Center(
        child: Text(
          'Batal',
          style: TextStyle(color: AppColors.primaryBlue),
        ),
      ),
    );
  }
}

void showPatientHealthSuccessSheet({
  required BuildContext context,
  required String title,
  required String message,
  String buttonText = 'Selesai',
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 26),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.light1,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 24),
              const CircleAvatar(
                radius: 36,
                backgroundColor: Color(0xFFEAFBF3),
                child: Icon(
                  Icons.check_rounded,
                  color: Color(0xFF10C878),
                  size: 36,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.dark2,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.pop(context, true);
                  },
                  style: AppButtonStyles.primary,
                  child: Text(buttonText),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showPatientFormSnackBar({
  required BuildContext context,
  required String message,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: AppColors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      content: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );
}

void showPatientOptionSheet({
  required BuildContext context,
  required String title,
  required List<String> items,
  required String? selectedValue,
  required ValueChanged<String> onSelected,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.65,
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.light1,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final selected = item == selectedValue;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        item,
                        style: TextStyle(
                          color: selected
                              ? AppColors.primaryBlue
                              : AppColors.dark1,
                          fontSize: 13,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      trailing: selected
                          ? const Icon(
                              Icons.check,
                              color: AppColors.primaryBlue,
                            )
                          : null,
                      onTap: () {
                        onSelected(item);
                        Navigator.pop(sheetContext);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
