import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

typedef AppOptionLabelBuilder<T> = String Function(T item);
typedef AppOptionSelectedBuilder<T> = bool Function(T item);
typedef AppOptionTap<T> = void Function(T item);

class AppOptionBottomSheet<T> extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<T> items;
  final AppOptionLabelBuilder<T> labelBuilder;
  final AppOptionSelectedBuilder<T> isSelected;
  final AppOptionTap<T> onSelected;
  final double? maxHeightFactor;

  const AppOptionBottomSheet({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
    required this.labelBuilder,
    required this.isSelected,
    required this.onSelected,
    this.maxHeightFactor,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height *
        (maxHeightFactor ?? 0.58);

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
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
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 2),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final selected = isSelected(item);

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    title: Text(
                      labelBuilder(item),
                      style: TextStyle(
                        color: selected ? AppColors.primaryBlue : AppColors.dark1,
                        fontSize: 14,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    trailing: selected
                        ? const Icon(
                            Icons.check,
                            color: AppColors.primaryBlue,
                            size: 22,
                          )
                        : null,
                    onTap: () => onSelected(item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
