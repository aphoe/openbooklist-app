import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';

/// Bottom navigation bar with Home, Saved, Grid, Settings tabs.
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key, required this.selectedIndex, this.onTap});

  final int selectedIndex;
  final ValueChanged<int>? onTap;

  static const _items = [
    _NavItem(
      label: 'Bookmarks',
      icon: Icons.bookmark_border,
      activeIcon: Icons.bookmark,
    ),
    _NavItem(
      label: 'Category',
      icon: Icons.folder_outlined,
      activeIcon: Icons.folder,
    ),
    _NavItem(label: 'Tags', icon: Icons.label_outline, activeIcon: Icons.label),
    _NavItem(
      label: 'Settings',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderGray)),
        boxShadow: [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _items.length,
              (i) => _NavButton(
                item: _items[i],
                isActive: i == selectedIndex,
                onTap: () => onTap?.call(i),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? item.activeIcon : item.icon,
              size: 24,
              color: isActive ? AppColors.primary : AppColors.gray300,
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: AppTextStyles.labelCaps.copyWith(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
