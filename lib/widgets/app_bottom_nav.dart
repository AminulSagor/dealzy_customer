import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../routes/app_pages.dart';
import '../routes/app_routes.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    this.onTap, // optional override if a page needs custom behavior
    this.barColor = const Color(0xFF124A89),
    this.activeColor = Colors.white,
    this.inactiveColor = const Color(0xCCFFFFFF),
  });

  final int currentIndex;
  final ValueChanged<int>? onTap;
  final Color barColor;
  final Color activeColor;
  final Color inactiveColor;

  // single source of truth for tab -> route mapping
  static final Map<int, String> _routeByIndex = {
    0: AppRoutes.home,
    1: AppRoutes.storeSearch,
    2: AppRoutes.notification,
    3: AppRoutes.userProfile,
  };

  void _defaultNavigate(int i) {
    if (i == currentIndex) return; // already on this tab
    final route = _routeByIndex[i];
    if (route != null) Get.offAllNamed(route); // swap root to the tab
  }

  @override
  Widget build(BuildContext context) {
    final items = <_NavItem>[
      _NavItem(
        index: 0,
        label: 'Home',
        selectedIcon: 'assets/svg/home.svg',
        unselectedIcon: 'assets/svg/home_not_selected.svg',
      ),
      _NavItem(
        index: 1,
        label: 'Filter',
        selectedIcon: 'assets/svg/filter.svg',
        unselectedIcon: 'assets/svg/filter_not_selected.svg',
      ),
      _NavItem(
        index: 2,
        label: 'Notify',
        selectedIcon: 'assets/svg/notification.svg',
        unselectedIcon: 'assets/svg/notification_not_selected.svg',
      ),
      _NavItem(
        index: 3,
        label: 'User',
        selectedIcon: 'assets/svg/user.svg',
        unselectedIcon: 'assets/svg/user_not_selected.svg',
      ),
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        color: barColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: items.map((it) {
            final isActive = currentIndex == it.index;
            return _buildItem(
              item: it,
              isActive: isActive,
              onPressed: (onTap ?? _defaultNavigate),
              activeColor: activeColor,
              inactiveColor: inactiveColor,
              barColor: barColor,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildItem({
    required _NavItem item,
    required bool isActive,
    required ValueChanged<int> onPressed,
    required Color activeColor,
    required Color inactiveColor,
    required Color barColor,
  }) {
    // Touch target
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onPressed(item.index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: isActive
        // SELECTED: show icon only, inside a white circle
            ? Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: _svg(
            item.selectedIcon,
            // tint to bar color for contrast inside white circle
            color: barColor,
            size: 22,
          ),
        )
        // UNSELECTED: show icon + text side-by-side
            : Row(
          children: [
            _svg(item.unselectedIcon,
                color: inactiveColor, size: 22),
            const SizedBox(width: 6),
            Text(
              item.label,
              style: TextStyle(
                color: inactiveColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _svg(String path, {Color? color, double size = 22}) {
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      // If your SVGs already have the desired colors, remove `colorFilter`.
      colorFilter:
      color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }
}

class _NavItem {
  final int index;
  final String label;
  final String selectedIcon;
  final String unselectedIcon;

  _NavItem({
    required this.index,
    required this.label,
    required this.selectedIcon,
    required this.unselectedIcon,
  });
}
