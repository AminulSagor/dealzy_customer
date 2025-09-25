// lib/widgets/app_search_bar.dart
import 'package:flutter/material.dart';

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onTap,                     // 👈 NEW
    this.hintText = 'Search',
    this.horizontalPadding = 16.0,
    this.height = 50.0,
    this.backgroundColor = const Color(0xFFD7E1EB),
    this.leading,
    this.trailing,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;        // 👈 NEW

  final String hintText;
  final double horizontalPadding;
  final double height;
  final Color backgroundColor;

  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final radius = height / 2;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: SizedBox(
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Material( // ripple on tap
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,                  // 👈 handle whole-bar tap
              child: Stack(
                children: [
                  Container(color: backgroundColor),
                  Positioned.fill(
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        leading ?? const Icon(Icons.search, color: Colors.black87, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AbsorbPointer(
                            absorbing: onTap != null,   // 👈 prevent keyboard if it's a tappable bar
                            child: TextField(
                              controller: controller,
                              onChanged: onChanged,
                              onSubmitted: onSubmitted,
                              readOnly: onTap != null,  // 👈 avoid focus when navigation is desired
                              style: const TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                hintText: hintText,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ),
                        if (trailing != null) ...[
                          const SizedBox(width: 8),
                          trailing!,
                          const SizedBox(width: 12),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
