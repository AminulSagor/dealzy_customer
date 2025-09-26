import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // for Clipboard
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DealzyloopUserAgreementPage extends StatelessWidget {
  const DealzyloopUserAgreementPage({super.key});

  static const String _email = 'support@dealzyloop.com';
  static const String _title = 'Dealzyloop Customer App - End User License Agreement (EULA) & Terms of Service';
  static const String _lastUpdated = 'Last updated: September 24, 2025';
  static const String _version = 'v1.0';

  Future<void> _copyEmail(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: _email));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email address copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxW =
            constraints.maxWidth > 720 ? 720.0 : constraints.maxWidth;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ---------------- User Agreement ----------------
                        Text(
                          _title,
                          style: text.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Text(
                              _lastUpdated,
                              style: text.bodySmall
                                  ?.copyWith(color: theme.hintColor),
                            ),
                            Text('  •  ',
                                style: text.bodySmall
                                    ?.copyWith(color: theme.hintColor)),
                            Text(_version,
                                style: text.bodySmall
                                    ?.copyWith(color: theme.hintColor)),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Divider(height: 1, thickness: 1),

                        SizedBox(height: 16.h),
                        _para(
                          context,
                          'Welcome to Dealzyloop. By creating an account or using our services, you agree to the terms outlined below. This agreement is designed to ensure transparency, protect your rights, and comply with applicable laws including the UK GDPR and EU GDPR where applicable.',
                        ),

                        _sectionTitle(context, '1. No Tolerance for Objectionable Content or Abusive Conduct'),
                        _para(context,
                            'Dealzyloop has zero tolerance for objectionable content, '
                                'abusive behavior, harassment, or illegal activity. Examples include '
                                '- Offensive, hateful, or discriminatory language or images -'
                                ' Fraudulent, misleading, or false reports '
                                '- Spam or repeated posting of irrelevant content'
                                ' - Harassing, threatening, or abusive interactions'),

                        _sectionTitle(context, '2. Content Moderation'),
                        _para(context,
                            '- Users must only post lawful, respectful, and accurate feedback or reports. '
                                '- Dealzyloop reserves the right to remove any content that violates these terms without notice. '
                                '- Users who repeatedly violate these rules may have their accounts suspended or permanently banned.'),

                        _sectionTitle(context, '3. Reporting & Blocking'),
                        _para(context,
                            '- Users can report objectionable content directly in the app. '
                                '- Users may block or mute other users or shops they find abusive. '
                                '- Reports are reviewed within 24 hours. Content violating these Terms will be removed, and offending users may be banned.'
                                ''),

                        _sectionTitle(context, '4. Your Responsibilities'),
                        _para(context,
                            '- Customers must use the app responsibly and not misuse reporting features.'),

                        _sectionTitle(context, '5. Limitation of Liability'),
                        _para(context,
                            'Dealzyloop provides the platform “as is” and is not liable for user-generated content.'),

                        _sectionTitle(context, '6. Changes to Terms'),
                        _para(context,
                            'We may update these Terms from time to time. Continued use of the app means you accept the updated Terms.'),

                        _sectionTitle(context, '7. Contact'),
                        _para(context,
                            'For questions, requests, or GDPR-related inquiries (such as exercising your data rights), contact us at:'),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            SelectableText(
                              _email,
                              style: text.bodyMedium?.copyWith(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            FilledButton.icon(
                              onPressed: () => _copyEmail(context),
                              icon: const Icon(Icons.copy),
                              label: const Text('Copy Email'),
                            ),
                          ],
                        ),

                        SizedBox(height: 24.h),
                        Divider(height: 2, thickness: 2),
                        SizedBox(height: 24.h),

                        // ---------------- Privacy Policy ----------------
                        // Text(
                        //   '🔒 Dealzyloop Privacy Policy',
                        //   style: text.headlineSmall
                        //       ?.copyWith(fontWeight: FontWeight.w700),
                        // ),
                        // SizedBox(height: 16.h),
                        //
                        // _para(context,
                        //     'This Privacy Policy explains how Dealzyloop collects, uses, and protects your personal data in compliance with the UK GDPR and EU GDPR where applicable.'),
                        //
                        // _sectionTitle(context, '1. Data We Collect'),
                        // _para(context,
                        //     'We collect account details (name, email, login), location data (to show nearby deals), and app usage data (bookmarks, searches).'),
                        //
                        // _sectionTitle(context, '2. How We Use Data'),
                        // _para(context,
                        //     'We use your data to deliver services (showing deals, sending notifications), improve our platform, and ensure security.'),
                        //
                        // _sectionTitle(context, '3. Legal Basis'),
                        // _para(context,
                        //     'We rely on your consent, contractual necessity, and legitimate interests as our lawful bases for processing under GDPR.'),
                        //
                        // _sectionTitle(context, '4. Data Sharing'),
                        // _para(context,
                        //     'We share data only with participating shops (for deal visibility) and trusted service providers. We never sell personal data to third parties.'),
                        //
                        // _sectionTitle(context, '5. Data Retention'),
                        // _para(context,
                        //     'We retain your personal data only as long as necessary for the purposes outlined. You may request deletion at any time.'),
                        //
                        // _sectionTitle(context, '6. Your Rights'),
                        // _para(context,
                        //     'You have the right to access, correct, delete, restrict, or port your data. You may also object to certain processing activities.'),
                        //
                        // _sectionTitle(context, '7. Security'),
                        // _para(context,
                        //     'We implement appropriate technical and organizational measures to protect your data from unauthorized access, loss, or misuse.'),
                        //
                        // _sectionTitle(context, '8. International Transfers'),
                        // _para(context,
                        //     'If data is transferred outside the UK/EU, we ensure appropriate safeguards such as Standard Contractual Clauses (SCCs).'),
                        //
                        // _sectionTitle(context, '9. Updates to Policy'),
                        // _para(context,
                        //     'We may update this Privacy Policy periodically. Users will be notified of significant changes.'),
                        //
                        // _sectionTitle(context, '10. Contact'),
                        // _para(context,
                        //     'For privacy inquiries or to exercise your GDPR rights, contact us at:'),
                        // Wrap(
                        //   crossAxisAlignment: WrapCrossAlignment.center,
                        //   children: [
                        //     SelectableText(
                        //       _email,
                        //       style: text.bodyMedium?.copyWith(
                        //         decoration: TextDecoration.underline,
                        //         fontWeight: FontWeight.w600,
                        //       ),
                        //     ),
                        //     SizedBox(width: 12.w),
                        //     FilledButton.icon(
                        //       onPressed: () => _copyEmail(context),
                        //       icon: const Icon(Icons.copy),
                        //       label: const Text('Copy Email'),
                        //     ),
                        //   ],
                        // ),




                        SizedBox(height: 24.h),
                        Divider(height: 1, thickness: 1),
                        SizedBox(height: 12.h),
                        Center(
                          child: _tiny(
                              context, 'Dealzyloop Ltd. • All rights reserved.'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h, bottom: 6.h),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _para(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style:
        Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
      ),
    );
  }

  Widget _tiny(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(color: Theme.of(context).hintColor),
    );
  }
}
