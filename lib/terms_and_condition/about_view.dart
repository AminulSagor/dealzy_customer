import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  static final Uri _privacyUri = Uri.parse(
    'https://dealzyloop.com/privacy-policy-customer.html',
  );

  Future<void> _openExternal(BuildContext context, Uri uri) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Couldn’t open link. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'DealzyLoop',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF124A89),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'DealzyLoop is your trusted multi-vendor e-commerce shopping app, designed to give customers a safe and seamless buying experience in the UK.',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
            const SizedBox(height: 20),

            const _FeatureItem(
              icon: Icons.shopping_cart_outlined,
              title: 'Shop Easily',
              description: 'Browse a wide variety of products listed by sellers.',
            ),
            const _FeatureItem(
              icon: Icons.verified_outlined,
              title: 'Buy With Confidence',
              description:
              'Every product is reviewed and approved by the admin before it’s available.',
            ),
            const _FeatureItem
              (
              icon: Icons.block_outlined,
              title: 'Stay Protected',
              description: 'Block or report any seller instantly if you face issues.',
            ),
            const _FeatureItem(
              icon: Icons.lock_outline,
              title: 'Secure Shopping',
              description: 'Enjoy a safe, user-friendly checkout process.',
            ),
            const _FeatureItem(
              icon: Icons.security_outlined,
              title: 'Data Privacy Guaranteed',
              description:
              'Your personal and payment information is encrypted and stored securely. We never share customer data with third parties.',
            ),

            const SizedBox(height: 20),
            Text(
              'At DealzyLoop, we focus on quality, trust, and data safety so you can shop with complete peace of mind.\n\nYour marketplace, your choice — welcome to DealzyLoop!',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
            const SizedBox(height: 30),

            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.privacy_tip_outlined),
                label: const Text('Privacy Policy'),
                onPressed: () => _openExternal(context, _privacyUri),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF124A89),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF124A89), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    )),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(color: Colors.black87, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
