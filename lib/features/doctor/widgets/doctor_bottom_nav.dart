import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DoctorBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<_NavItem> items;

  const DoctorBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.items = const [
      _NavItem(icon: Icons.home_rounded, label: 'Beranda'),
      _NavItem(icon: Icons.person_add_alt_1_rounded, label: 'Permintaan'),
      _NavItem(icon: Icons.description_rounded, label: 'Riwayat'),
      _NavItem(icon: Icons.person_rounded, label: 'Profil'),
    ],
  }) : super(key: key);

  @override
Widget build(BuildContext context) {
  final bottomInset = MediaQuery.of(context).padding.bottom;
  const baseHeight = 88.0;

  return Container(
    height: baseHeight + bottomInset,
    padding: EdgeInsets.only(
      left: 12,
      right: 12,
      top: 8,
      bottom: bottomInset + 6,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(28),
        topRight: Radius.circular(28),
      ),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 12,
          offset: Offset(0, -6),
        ),
      ],
    ),
    child: Row(
      children: List.generate(items.length, (i) {
        final selected = i == currentIndex;
        final item = items[i];

        return Expanded(
          child: InkWell(
            onTap: () => onTap(i),
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.veryLightBlue
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.icon,
                    size: 22,
                    color: selected
                        ? AppColors.primaryBlue
                        : AppColors.dark2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.1,
                    color: selected
                        ? AppColors.primaryBlue
                        : AppColors.dark2,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    ),
  );
}

}
 
class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
