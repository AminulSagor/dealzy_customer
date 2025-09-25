import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // for Clipboard
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DealzyloopUserAgreementPage extends StatelessWidget {
  const DealzyloopUserAgreementPage({super.key});

  static const String _email = 'support@dealzyloop.com';
  static const String _title = 'Dealzyloop Customer User Agreement';
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
        title: const Text('User Agreement & Privacy Policy'),
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

                        _sectionTitle(context, '1. Eligibility'),
                        _para(context,
                            'You must be at least 16 years old to use Dealzyloop. By registering, you confirm that the information you provide is accurate and complete.'),

                        _sectionTitle(context, '2. Service Description'),
                        _para(context,
                            'Dealzyloop is a platform that connects you with nearby shops to discover local deals, clearance items, and surplus stock. We do not handle delivery or payments—purchases are collected and completed directly at participating shops.'),

                        _sectionTitle(context, '3. Personal Data & Privacy'),
                        _para(context,
                            'We process your personal data (such as account information, location data for nearby deals, and app usage) in compliance with GDPR. You have the right to access, correct, delete, and restrict processing of your data at any time. Please see our Privacy Policy for full details.'),

                        _sectionTitle(context, '4. Data Sharing'),
                        _para(context,
                            'Your data will only be shared with participating shops to facilitate discovery of deals, and with trusted service providers who support the platform. We do not sell your personal data to third parties.'),

                        _sectionTitle(context, '5. Consent & Control'),
                        _para(context,
                            'You may manage your communication preferences (e.g., deal alerts, notifications) within the app. You can withdraw consent for marketing at any time without affecting your use of the platform.'),

                        _sectionTitle(context, '6. Responsible Use'),
                        _para(context,
                            'You agree not to misuse the platform, including posting offensive content, attempting to hack or disrupt services, or misrepresenting yourself. Breach of these rules may result in suspension or termination of your account.'),

                        _sectionTitle(context, '7. Liability'),
                        _para(context,
                            'Dealzyloop provides the platform “as is” and does not guarantee the availability, pricing accuracy, or quality of products listed by shops. Your transactions are directly with the shops, and Dealzyloop is not liable for disputes or losses arising from those purchases.'),

                        _sectionTitle(context, '8. Changes to Agreement'),
                        _para(context,
                            'We may update this User Agreement from time to time. You will be notified of significant changes via the app or email. Continued use of the platform after updates means you accept the revised terms.'),

                        _sectionTitle(context, '9. Contact'),
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
                        Text(
                          '🔒 Dealzyloop Privacy Policy',
                          style: text.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 16.h),

                        _para(context,
                            'This Privacy Policy explains how Dealzyloop collects, uses, and protects your personal data in compliance with the UK GDPR and EU GDPR where applicable.'),

                        _sectionTitle(context, '1. Data We Collect'),
                        _para(context,
                            'We collect account details (name, email, login), location data (to show nearby deals), and app usage data (bookmarks, searches).'),

                        _sectionTitle(context, '2. How We Use Data'),
                        _para(context,
                            'We use your data to deliver services (showing deals, sending notifications), improve our platform, and ensure security.'),

                        _sectionTitle(context, '3. Legal Basis'),
                        _para(context,
                            'We rely on your consent, contractual necessity, and legitimate interests as our lawful bases for processing under GDPR.'),

                        _sectionTitle(context, '4. Data Sharing'),
                        _para(context,
                            'We share data only with participating shops (for deal visibility) and trusted service providers. We never sell personal data to third parties.'),

                        _sectionTitle(context, '5. Data Retention'),
                        _para(context,
                            'We retain your personal data only as long as necessary for the purposes outlined. You may request deletion at any time.'),

                        _sectionTitle(context, '6. Your Rights'),
                        _para(context,
                            'You have the right to access, correct, delete, restrict, or port your data. You may also object to certain processing activities.'),

                        _sectionTitle(context, '7. Security'),
                        _para(context,
                            'We implement appropriate technical and organizational measures to protect your data from unauthorized access, loss, or misuse.'),

                        _sectionTitle(context, '8. International Transfers'),
                        _para(context,
                            'If data is transferred outside the UK/EU, we ensure appropriate safeguards such as Standard Contractual Clauses (SCCs).'),

                        _sectionTitle(context, '9. Updates to Policy'),
                        _para(context,
                            'We may update this Privacy Policy periodically. Users will be notified of significant changes.'),

                        _sectionTitle(context, '10. Contact'),
                        _para(context,
                            'For privacy inquiries or to exercise your GDPR rights, contact us at:'),
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
