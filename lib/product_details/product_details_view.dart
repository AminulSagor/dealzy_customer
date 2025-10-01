import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../storage/token_storage.dart';
import '../widgets/login_required_dialog.dart';
import 'product_details_controller.dart';

class ProductDetailsView extends GetView<ProductDetailsController> {
  const ProductDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Reactive body: loading → spinner, error → message, data → content
          Obx(() {
            if (c.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (c.error.value != null) {
              return _ErrorState(
                message: c.error.value!,
                onRetry: () => c.onInit(), // simple retry
              );
            }

            // Main scroll when data present
            return ListView(
              padding: EdgeInsets.only(
                bottom: 100 + MediaQuery.of(context).padding.bottom,
              ),
              children: [
                // 1) Full-bleed image (touches top/left/right)
                _HeroImage(controller: c),

                // 2) Curved white body that "carves" into the image
                Transform.translate(
                  offset: const Offset(0, -24),
                  child: _CurvedBody(controller: c),
                ),
              ],
            );
          }),

          // Floating back button over the image
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: Material(
              shape: const CircleBorder(),
              color: Colors.black.withOpacity(0.5),
              clipBehavior: Clip.antiAlias,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                onPressed: Get.back,
                tooltip: 'Back',
              ),
            ),
          ),

          // Floating Bookmark button
          Positioned(
            left: 0,
            right: 0,
            bottom: 14 + MediaQuery.of(context).padding.bottom,
            child: Center(
              child: // In ProductDetailsView, where the "Bookmark" button is:
              Obx(() {
                final busy = c.isBookmarking.value;
                return ElevatedButton(
                  onPressed: busy ? null : c.onBookmark, // disabled when busy
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF124A89),
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(.18),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                      side: const BorderSide(color: Colors.black12),
                    ),
                  ),
                  child: Text(
                    busy ? 'Saving...' : 'Bookmark',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-bleed hero image (handles empty/fallback safely)
class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.controller});
  final ProductDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final images = c.product.images;
    return AspectRatio(
      aspectRatio: 1,
      child: (images.isEmpty)
          ? Container(
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported_rounded, size: 48, color: Colors.grey),
      )
          : PageView.builder(
        controller: c.pageCtrl,
        itemCount: images.length,
        itemBuilder: (_, i) => Image.network(
          images[i],
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

/// White curved body that contains dots + all content
class _CurvedBody extends StatelessWidget {
  const _CurvedBody({required this.controller});
  final ProductDetailsController controller;

  static const double _pad = 16.0;

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(_pad, 12, _pad, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dots on white background (explicit Rx read)
            Center(
              child: Obx(() {
                final page = c.currentPage.value;          // <-- Rx read
                final total = c.product.images.length;     // non-Rx is fine
                if (total <= 1) return const SizedBox(height: 20);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    total,
                        (i) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (page == i)
                            ? const Color(0xFF124A89)
                            : Colors.blueGrey.withOpacity(.35),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 6),

            // Title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    c.product.title,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.5,
                      color: Colors.black87,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Price row — dynamic (shows strike-through only if discounted)
            _PriceRow(controller: c),

            const SizedBox(height: 12),

            // Specs
            _SpecRow(label: 'Brand', value: c.product.brand),
            _SpecRow(label: 'Model', value: c.product.model),
            _SpecRow(label: 'Color', value: c.product.color),
            _SpecRow(label: 'Size', value: c.product.sizeText),
            _SpecRow(label: 'Category', value: c.product.category),
            _SpecRow(label: 'Availability', value: c.product.availabilityText),
            const SizedBox(height: 10),

            // Description (explicit Rx read)
            Obx(() => _ExpandableText(
              text: c.product.description,
              expanded: c.descExpanded.value, // <-- Rx read
              onToggle: c.toggleDesc,
            )),

            // Shop Details
            const SizedBox(height: 8),

            Row(
              children: [
                const Text(
                  'Shop Details',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Obx(() {
                  final reporting = c.isReporting.value;
                  return TextButton(
                    onPressed: reporting
                        ? null
                        : () async {
                      // 🔹 Check login first
                      final token = await TokenStorage.getToken();
                      if (token == null || token.isEmpty) {
                        // Show your login dialog if not logged in
                        Get.dialog(const LoginRequiredDialog(), barrierDismissible: false);
                        return;
                      }

                      // 🔹 Only open report dialog if logged in
                      final payload = await showDialog<_ReportPayload>(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => _ReportInappropriateDialog(
                          productTitle: c.product.title,
                        ),
                      );

                      // If user submitted, compose message and send
                      if (payload != null) {
                        final msg = [
                          'Reason: ${payload.reason}',
                          if (payload.notes.trim().isNotEmpty)
                            'Notes: ${payload.notes.trim()}',
                        ].join('\n');
                        await c.reportProduct(msg);
                      }
                    },
                    child: Text(
                      reporting ? 'Reporting…' : 'Report Inappropriate',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        decoration: TextDecoration.underline, // looks like a link
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }),

              ],
            ),
            const SizedBox(height: 8),
            _ShopDetails(controller: c),
            const SizedBox(height: 18),
            // Inside Column of _CurvedBody after _ShopDetails(controller: c),





          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.controller});
  final ProductDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final p = controller.product;
    final hasDiscount = p.offerPrice < p.mrp;

    if (hasDiscount) {
      return Row(
        children: [
          Text(
            '\£${p.mrp.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.black45,
              decoration: TextDecoration.lineThrough,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '\£${p.offerPrice.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.red,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 6),
          const Text('(offer)', style: TextStyle(color: Colors.black54)),
        ],
      );
    }

    // No discount → single price, no strike-through
    return Text(
      '\$${p.mrp.toStringAsFixed(0)}',
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  const _SpecRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label : ',
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: const TextStyle(color: Colors.black87, height: 1.25),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandableText extends StatelessWidget {
  const _ExpandableText({
    required this.text,
    required this.expanded,
    required this.onToggle,
    this.trimLines = 3,
  });

  final String text;
  final bool expanded;
  final VoidCallback onToggle;
  final int trimLines;

  @override
  Widget build(BuildContext context) {
    final showToggle = text.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          textAlign: TextAlign.left,
          maxLines: expanded ? null : trimLines,
          overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.black87, height: 1.35),
        ),
        if (showToggle) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onToggle,
            child: Text(
              expanded ? 'see less' : 'see more',
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Colors.black54,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ShopDetails extends StatelessWidget {
  const _ShopDetails({required this.controller});
  final ProductDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: (c.store.photoUrl != null && c.store.photoUrl!.isNotEmpty)
                    ? NetworkImage(c.store.photoUrl!)
                    : null,
                child: (c.store.photoUrl == null || c.store.photoUrl!.isEmpty)
                    ? const Icon(Icons.store_rounded, color: Colors.black45)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // store name + category
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.store.name,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                c.store.category,
                                textAlign: TextAlign.left,
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        // view shop link
                        TextButton(
                          onPressed: c.goToStoreDetails,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'View Shop',
                            style: TextStyle(
                              color: Color(0xFF124A89),
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.storefront_rounded, size: 18, color: Colors.black87),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  c.store.address,
                  textAlign: TextAlign.left,
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.phone_rounded, size: 18, color: Colors.black87),
              const SizedBox(width: 6),
              Text(
                c.store.phone,
                textAlign: TextAlign.left,
                style: const TextStyle(color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 18, color: Colors.black87),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('${c.openLabel12h} ',
                        style: const TextStyle(color: Colors.black87)),
                    Text(
                      c.isOpenNow ? '(open) ' : '(close) ',
                      style: TextStyle(
                        color: c.isOpenNow ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text('to ', style: TextStyle(color: Colors.black87)),
                    Text(c.closeLabel12h,
                        style: const TextStyle(color: Colors.black87)),
                    const Text(
                      ' (close)',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}




class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 36, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportPayload {
  final String reason;
  final String notes;
  const _ReportPayload({required this.reason, required this.notes});
}

class _ReportInappropriateDialog extends StatefulWidget {
  const _ReportInappropriateDialog({required this.productTitle});

  final String productTitle;

  @override
  State<_ReportInappropriateDialog> createState() => _ReportInappropriateDialogState();
}

class _ReportInappropriateDialogState extends State<_ReportInappropriateDialog> {
  final _notesCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedReason;
  bool _ack = true; // pre-checked to reduce friction

  static const _reasons = <String>[
    'Spam or misleading',
    'Hate/harassment',
    'Nudity/sexual content',
    'Illegal or dangerous',
    'Violence or gore',
    'Other',
  ];

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
      contentPadding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      title: Row(
        children: const [
          CircleAvatar(
            radius: 16,
            backgroundColor: Color(0x14D32F2F),
            child: Icon(Icons.flag_outlined, color: Color(0xFFD32F2F)),
          ),
          SizedBox(width: 10),
          Text('Report Inappropriate'),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Policy / assurance text for App Review
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Is this post inappropriate?\n'
                        'We will review this report within 24 hours and, if deemed inappropriate, '
                        'the post will be removed within that timeframe. We will also take action '
                        'against its author. There is zero tolerance for objectionable content or abuse.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black87, height: 1.25),
                  ),
                ),
                const SizedBox(height: 12),

                // Product context (helps moderators)
                Text(
                  'Item: ${widget.productTitle}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: 8),

                // Reasons
                Text('Choose a reason', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 6),
                ..._reasons.map((r) => RadioListTile<String>(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(r),
                  value: r,
                  groupValue: _selectedReason,
                  onChanged: (v) => setState(() => _selectedReason = v),
                )),

                // Notes
                const SizedBox(height: 6),
                Text('Add details (optional)', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'Describe what’s wrong.',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _ack,
                  onChanged: (v) => setState(() => _ack = v ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text(
                    'I understand false reports may lead to restrictions.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: (_selectedReason != null && _ack)
              ? () {
            Navigator.pop(
              context,
              _ReportPayload(
                reason: _selectedReason!,
                notes: _notesCtrl.text,
              ),
            );
          }
              : null,
          child: const Text('Send Report'),
        ),
      ],
    );
  }
}

