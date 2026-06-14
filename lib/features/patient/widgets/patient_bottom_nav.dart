import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PatientBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final bool isAddSelected;
  final ValueChanged<int> onTap;
  final VoidCallback onAddTap;

  const PatientBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAddTap,
    this.isAddSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SizedBox(
      height: 98 + bottomInset,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 78 + bottomInset,
            padding: EdgeInsets.only(
              left: 8,
              right: 8,
              top: 10,
              bottom: bottomInset + 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(34),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                _navItem(index: 0, icon: Icons.home_rounded, label: 'Beranda'),
                _navItem(
                  index: 1,
                  icon: Icons.person_add_alt_1_rounded,
                  label: 'Koneksi',
                ),

                const SizedBox(width: 70),

                _navItem(
                  index: 3,
                  icon: Icons.description_rounded,
                  label: 'Riwayat',
                ),
                _navItem(index: 4, icon: Icons.person_rounded, label: 'Profil'),
              ],
            ),
          ),

          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: onAddTap,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: isAddSelected
                      ? AppColors.primaryBlue
                      : AppColors.lightBlue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.20),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(color: AppColors.background, width: 5),
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: isAddSelected ? Colors.white : AppColors.primaryBlue,
                  size: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final selected = !isAddSelected && currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: selected ? AppColors.primaryBlue : AppColors.dark3,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primaryBlue : AppColors.dark3,
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
