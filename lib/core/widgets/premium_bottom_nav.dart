import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class PremiumBottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const PremiumBottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class PremiumBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<PremiumBottomNavItem> items;
  final Function(int) onTap;

  const PremiumBottomNav({
    Key? key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      height: 85, // Increased height slightly to account for safe area / no margin
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isSelected = currentIndex == index;
          final color = isSelected ? AppColors.primaryColor : AppColors.textColorSecondary.withValues(alpha: 0.5);

          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (!isSelected) {
                  HapticFeedback.lightImpact();
                  onTap(index);
                }
              },
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min, // Use min to prevent vertical stretching
                children: [
                  Icon(
                    isSelected ? items[index].activeIcon : items[index].icon,
                    color: color,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    items[index].label,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      letterSpacing: 0.1,
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
