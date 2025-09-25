import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/app_bottom_nav.dart';
import 'notification_controller.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  static const _triggerPadding = 120.0; // start loading more 120px before end

  @override
  Widget build(BuildContext context) {
    final bgPeach = const Color(0xFFF6EDE8);
    final titleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w800,
      color: const Color(0xFF1C1C1C),
    );
    final bodyStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: const Color(0xFF333333),
      height: 1.35,
    );
    final timeStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: const Color(0xFF5A5A5A),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 16.w,
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Obx(() {
        // Error state
        if (controller.error.value != null &&
            controller.error.value!.isNotEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.redAccent, size: 28),
                  SizedBox(height: 8.h),
                  Text(
                    controller.error.value!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black87),
                  ),
                  SizedBox(height: 12.h),
                  ElevatedButton(
                    onPressed: () => controller.retry(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Initial loading state
        if (controller.isLoading.value && controller.items.isEmpty) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        // Empty state
        if (controller.items.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => controller.fetchFirstPage(limit: 10),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: 120.h),
                const Icon(Icons.notifications_none_rounded,
                    size: 42, color: Colors.black38),
                SizedBox(height: 12.h),
                const Center(
                  child: Text(
                    'No notifications yet',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            ),
          );
        }

        // List with pull-to-refresh + infinite scroll
        return RefreshIndicator(
          onRefresh: () => controller.fetchFirstPage(limit: 10),
          // Detect when near the bottom to call loadMore()
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n is ScrollUpdateNotification) {
                final metrics = n.metrics;
                final nearEnd =
                    metrics.pixels >= metrics.maxScrollExtent - _triggerPadding;
                if (nearEnd && !controller.isLoadingMore.value) {
                  controller.loadMore();
                }
              }
              return false;
            },
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
              itemCount: controller.items.length + 1, // +1 for footer
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (_, i) {
                // Footer loader
                if (i == controller.items.length) {
                  return Obx(() => controller.isLoadingMore.value
                      ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                      : const SizedBox.shrink());
                }

                final n = controller.items[i];
                return Container(
                  decoration: BoxDecoration(
                    color: bgPeach,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x11000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  padding: EdgeInsets.all(12.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/png/fire_icon.png', // ensure in pubspec.yaml
                        width: 28.w,
                        height: 28.w,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n.title, style: titleStyle),
                            SizedBox(height: 4.h),
                            _ExpandableText(
                              text: n.body,
                              style: bodyStyle,
                              trimLines: 3,
                              linkColor: const Color(0xFF124A89),
                            ),
                            SizedBox(height: 6.h),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(n.time, style: timeStyle),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}

/// Lightweight, dependency-free expandable text.
/// Shows "See more" only when the text actually overflows.
class _ExpandableText extends StatefulWidget {
  const _ExpandableText({
    required this.text,
    this.style,
    this.trimLines = 3,
    this.linkColor = const Color(0xFF124A89),
  });

  final String text;
  final TextStyle? style;
  final int trimLines;
  final Color linkColor;

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText>
    with TickerProviderStateMixin {
  bool _expanded = false;
  bool _overflow = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate if it will overflow when collapsed.
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: widget.style),
          textDirection: TextDirection.ltr,
          maxLines: widget.trimLines,
          ellipsis: '…',
        )..layout(maxWidth: constraints.maxWidth);

        _overflow = painter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              child: Text(
                widget.text,
                style: widget.style,
                maxLines: _expanded ? null : widget.trimLines,
                overflow:
                _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
            ),
            if (_overflow) ...[
              const SizedBox(height: 4),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _expanded = !_expanded),
                child: Text(
                  _expanded ? 'See less' : 'See more',
                  style: TextStyle(
                    color: widget.linkColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
