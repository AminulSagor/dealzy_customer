import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../routes/app_pages.dart';
import '../routes/app_routes.dart';
import '../storage/token_storage.dart';
import '../widgets/login_required_dialog.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
    this.barColor = const Color(0xFF124A89),
    this.activeColor = Colors.white,
    this.inactiveColor = const Color(0xCCFFFFFF),
  });

  final int currentIndex;
  final ValueChanged<int>? onTap;
  final Color barColor;
  final Color activeColor;
  final Color inactiveColor;

  static final Map<int, String> _routeByIndex = {
    0: AppRoutes.home,
    1: AppRoutes.storeSearch,
    2: AppRoutes.notification,
    3: AppRoutes.cart,
    4: AppRoutes.userProfile,
  };

  void _onTap(int i) {
    _handleTap(i);
  }

  Future<void> _handleTap(int i) async {
    if (i == currentIndex) return;

    if (i == 1 || i == 3) {
      final token = await TokenStorage.getToken();
      if (token == null || token.isEmpty) {
        Get.dialog(const LoginRequiredDialog(), barrierDismissible: false);
        return;
      }
    }

    final route = _routeByIndex[i];
    if (route != null) Get.offAllNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    // initialize ScreenUtil context if not already
    ScreenUtil.init(context);

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
        label: 'Cart',
        selectedIcon: 'assets/svg/cart_selected.svg',
        unselectedIcon: 'assets/svg/cart.svg',
      ),
      _NavItem(
        index: 4,
        label: 'User',
        selectedIcon: 'assets/svg/user.svg',
        unselectedIcon: 'assets/svg/user_not_selected.svg',
      ),
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: 64.h,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        color: barColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.map((it) {
            final isActive = currentIndex == it.index;
            return _buildItem(
              item: it,
              isActive: isActive,
              onPressed: onTap ?? _onTap,
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
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: () => onPressed(item.index),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
        child: isActive
            ? Container(
          padding: EdgeInsets.all(8.w),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: _svg(
            item.selectedIcon,
            color: barColor,
            size: 22.sp,
          ),
        )
            : ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 80.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _svg(item.unselectedIcon,
                  color: inactiveColor, size: 20.sp),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  item.label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: inactiveColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _svg(String path, {Color? color, double size = 22}) {
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
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
