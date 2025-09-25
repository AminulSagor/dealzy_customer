import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_setting_controller.dart';

/// Lightweight design system for consistent color, spacing, and type.
class DS {
  // Colors
  static const Color primary = Color(0xFF2563EB); // Blue 600
  static const Color onPrimary = Colors.white;
  static const Color surface = Colors.white;
  static const Color surfaceAlt = Color(0xFFF7F9FC);
  static const Color textPrimary = Color(0xFF111827); // Gray 900
  static const Color textSecondary = Color(0xFF6B7280); // Gray 500
  static const Color divider = Color(0xFFE5E7EB); // Gray 200
  static const Color danger = Color(0xFFDC2626); // Red 600
  static const Color dangerSoft = Color(0xFFFEE2E2); // Red 100
  static const Color infoSoft = Color(0xFFE0ECFF); // Blue soft background
  static const Color skeleton = Color(0xFFEAEFF4);

  // Spacing (8pt grid)
  static EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h);
  static SizedBox gap4 = SizedBox(height: 4.h);
  static SizedBox gap8 = SizedBox(height: 8.h);
  static SizedBox gap12 = SizedBox(height: 12.h);
  static SizedBox gap16 = SizedBox(height: 16.h);
  static SizedBox gap24 = SizedBox(height: 24.h);

  // Type
  static TextStyle h6 = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: 0.15,
    height: 1.2,
  );

  static TextStyle label = const TextStyle(
    color: textSecondary,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static TextStyle value = const TextStyle(
    color: textPrimary,
    fontWeight: FontWeight.w600,
  );

  static BorderRadius br8 = BorderRadius.circular(8);
  static BorderRadius br12 = BorderRadius.circular(12);

  static BoxDecoration card = BoxDecoration(
    color: surface,
    borderRadius: DS.br12,
    border: Border.all(color: divider),
  );

  static ButtonStyle primaryTextButton = TextButton.styleFrom(
    foregroundColor: primary,
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
  );
}

class AppSettingView extends GetView<AppSettingController> {
  const AppSettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: DS.surfaceAlt,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: DS.surface,
        elevation: 0.5,
        surfaceTintColor: Colors.transparent,
        foregroundColor: DS.textPrimary,
        leading: const BackButton(color: Colors.black),
        title: Text(
          'Settings',
          style: TextStyle(color: DS.textPrimary, fontWeight: FontWeight.w700, fontSize: 18.sp),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          final loading = controller.isLoadingProfile.value;
          final err = controller.profileError.value;

          return ListView(
            padding: DS.pagePadding,
            children: [
              // Profile
              Text('Profile', style: DS.h6),
              DS.gap8,
              Container(
                decoration: DS.card,
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (loading) ...[
                      Row(
                        children: [
                          const _AvatarSkeleton(),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                _ShimmerLine(),
                                SizedBox(height: 8),
                                _ShimmerLine(width: 160),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ] else if (err != null) ...[
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: DS.dangerSoft,
                          borderRadius: DS.br8,
                          border: Border.all(color: DS.danger.withOpacity(.25)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: DS.danger),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                err,
                                style: const TextStyle(color: DS.danger, fontWeight: FontWeight.w600),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: controller.reloadProfile,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                              style: DS.primaryTextButton,
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _Avatar(
                            initials: _initials(controller.profileName.value),
                            imageUrl: controller.profileImageUrl.value,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Name', style: DS.label),
                                DS.gap4,
                                Text(
                                  controller.profileName.value.isEmpty ? '—' : controller.profileName.value,
                                  style: DS.value,
                                ),
                                DS.gap12,
                                Text('Phone', style: DS.label),
                                DS.gap4,
                                Text(
                                  controller.profilePhone.value.isEmpty ? '—' : controller.profilePhone.value,
                                  style: DS.value,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              DS.gap24,
              Divider(color: DS.divider, height: 1),

              // Danger Zone
              DS.gap24,
              Text('Danger Zone', style: DS.h6),
              DS.gap8,
              Container(
                decoration: DS.card,
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DestructiveActionTile(
                      icon: Icons.delete_forever,
                      title: 'Delete Profile',
                      description: 'Permanently remove your profile data. This action cannot be undone.',
                      onPressed: () async {
                        final expectedName = controller.profileName.value.trim();
                        final ok = await Get.dialog<bool>(
                          ConfirmDeleteDialog(expectedName: expectedName),
                          barrierDismissible: false,
                        );
                        if (ok == true) {
                          await controller.deleteProfileConfirmed(context);
                        }

                      },
                    ),
                    const Divider(height: 24),
                    _NeutralActionTile(
                      icon: Icons.logout_rounded,
                      title: 'Log Out',
                      description: 'End your session on this device.',
                      onPressed: () async {
                        final ok = await Get.dialog<bool>(
                          AlertDialog(
                            title: const Text('Log Out'),
                            content: const Text('Are you sure you want to log out?'),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(result: false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Get.back(result: true),
                                child: const Text('Log Out'),
                              ),
                            ],
                          ),
                          barrierDismissible: false,
                        );
                        if (ok == true) {
                          await controller.performLogout();
                        }
                      },
                    ),
                  ],
                ),
              ),

              DS.gap24,
            ],
          );
        }),
      ),
    );
  }

  static String _initials(String name) {
    if (name.trim().isEmpty) return 'U';
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
  }
}

/// ----- UI widgets -----

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.initials,
    this.imageUrl,
    this.size,
    this.radius,
  });

  final String initials;
  final String? imageUrl;
  final double? size;    // default 48.w
  final double? radius;  // default 12.r

  bool get _hasImage => (imageUrl != null) && imageUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final double s = size ?? 48.w;
    final double r = radius ?? 12.r;

    Widget fallback() => Container(
      width: s,
      height: s,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: DS.primary,
        borderRadius: BorderRadius.circular(r),
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: DS.onPrimary,
          fontWeight: FontWeight.w800,
          fontSize: (s * 0.33).clamp(12, 18),
          letterSpacing: 0.5,
        ),
      ),
    );

    if (!_hasImage) return fallback();

    return ClipRRect(
      borderRadius: BorderRadius.circular(r),
      child: SizedBox(
        width: s,
        height: s,
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
          errorBuilder: (_, __, ___) => fallback(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: DS.skeleton,
              alignment: Alignment.center,
              child: Text(
                initials,
                style: TextStyle(
                  color: DS.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: (s * 0.28).clamp(10, 16),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ShimmerLine extends StatelessWidget {
  const _ShimmerLine({this.width});
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: 14.h,
      decoration: BoxDecoration(
        color: DS.skeleton,
        borderRadius: DS.br8,
      ),
    );
  }
}

class _AvatarSkeleton extends StatelessWidget {
  const _AvatarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: DS.skeleton,
        borderRadius: BorderRadius.circular(12.r),
      ),
    );
  }
}

class _DestructiveActionTile extends StatelessWidget {
  const _DestructiveActionTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: DS.dangerSoft,
            borderRadius: DS.br8,
            border: Border.all(color: DS.danger.withOpacity(.15)),
          ),
          child: Icon(icon, color: DS.danger),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: DS.danger,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                ),
              ),
              DS.gap4,
              Text(description, style: const TextStyle(color: DS.textSecondary)),
              DS.gap12,
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: onPressed,
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DS.danger,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                    shape: RoundedRectangleBorder(borderRadius: DS.br8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NeutralActionTile extends StatelessWidget {
  const _NeutralActionTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: DS.infoSoft,
            borderRadius: DS.br8,
            border: Border.all(color: DS.primary.withOpacity(.15)),
          ),
          child: Icon(icon, color: DS.primary),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: DS.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                ),
              ),
              DS.gap4,
              Text(description, style: const TextStyle(color: DS.textSecondary)),
              DS.gap12,
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: onPressed,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Log Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DS.textPrimary,
                    side: const BorderSide(color: DS.divider),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                    shape: RoundedRectangleBorder(borderRadius: DS.br8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class ConfirmDeleteDialog extends StatefulWidget {
  const ConfirmDeleteDialog({required this.expectedName, super.key});
  final String expectedName;

  @override
  State<ConfirmDeleteDialog> createState() => _ConfirmDeleteDialogState();
}

class _ConfirmDeleteDialogState extends State<ConfirmDeleteDialog> {
  late final TextEditingController _ctrl;
  bool _canDelete = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController()
      ..addListener(() {
        final want = widget.expectedName.trim().toLowerCase();
        final got = _ctrl.text.trim().toLowerCase();
        final ok = got.isNotEmpty && got == want;
        if (ok != _canDelete) setState(() => _canDelete = ok);
      });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expected = widget.expectedName;
    final kb = MediaQuery.of(context).viewInsets.bottom;

    return MediaQuery.removeViewInsets(
      removeBottom: true,
      context: context,
      child: AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
        contentPadding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
        actionsPadding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 10.w),
            const Expanded(
              child: Text(
                'Delete Account',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: kb > 0 ? 12 : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This action is permanent and cannot be undone. '
                    'To confirm, type your full name exactly as it appears.',
                style: TextStyle(color: Color(0xFF4B5563), height: 1.35),
              ),
              SizedBox(height: 14.h),

              // Subtle info card
              _InfoCard(
                icon: Icons.info_outline_rounded,
                title: 'Data Deletion Timeline',
                body:
                'Your data will be scheduled for deletion within 14 days. '
                    'Access to your account will be revoked immediately.',
              ),
              SizedBox(height: 14.h),

              TextField(
                controller: _ctrl,
                autofocus: true,
                textInputAction: TextInputAction.done,
                scrollPadding: EdgeInsets.only(bottom: kb + 80),
                decoration: InputDecoration(
                  labelText: 'Enter your name to confirm',
                  hintText: expected.isEmpty ? null : expected,
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  prefixIcon: const Icon(Icons.edit, size: 18),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF2563EB)),
                  ),
                  errorText:
                  _ctrl.text.isEmpty || _canDelete ? null : 'Name does not match',
                ),
                onSubmitted: (_) => _tryDelete(),
              ),
              SizedBox(height: 6.h),

              // Tiny reassurance / policy note
              const Text(
                'Note: If this was a mistake, contact support promptly; recovery may be possible before deletion is processed.',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280), height: 1.35),
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF111827),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: _canDelete ? _tryDelete : null,
            icon: const Icon(Icons.delete_forever),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              disabledBackgroundColor: const Color(0xFFF3F4F6),
              disabledForegroundColor: const Color(0xFF9CA3AF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
          ),
        ],
      ),
    );
  }

  void _tryDelete() {
    if (!_canDelete) return;
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(true);
  }
}

/// --- Small info card used in the dialog ---
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0ECFF)),
      ),
      padding: EdgeInsets.all(12.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2563EB)),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    )),
                SizedBox(height: 4.h),
                Text(
                  body,
                  style: const TextStyle(color: Color(0xFF374151), height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

