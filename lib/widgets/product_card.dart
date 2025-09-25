import 'package:flutter/material.dart';

class ProductCard<T> extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.item,              // payload you get back in callbacks
    required this.title,
    required this.image,
    required this.price,
    this.offerPrice,
    this.expiryBadges = const [],
    required this.onOpen,
    required this.onAdd,
    this.expiringStyle = false,
    this.brandColor = const Color(0xFF124A89),
  });

  // Generic payload (your ProductItem, or anything else)
  final T item;

  // Display props (decouple UI from model)
  final String title;
  final String image;
  final double price;
  final double? offerPrice;
  final List<String> expiryBadges;

  // Callbacks (typed with T)
  final void Function(T) onOpen;
  final void Function(T) onAdd;

  final bool expiringStyle;
  final Color brandColor;

  static const _radius = 14.0;

  @override
  Widget build(BuildContext context) {
    final hasOffer = offerPrice != null;

    return InkWell(
      borderRadius: BorderRadius.circular(_radius),
      onTap: () => onOpen(item),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_radius),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_radius),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFECECEC),
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported_outlined),
                  ),
                ),
              ),

              if (expiringStyle && expiryBadges.isNotEmpty)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Row(
                    children: expiryBadges.map((t) {
                      return Container(
                        margin: const EdgeInsets.only(right: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.12),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          t,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

              // Bottom blue gradient overlay
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.0),
                        brandColor.withOpacity(0.75),
                        brandColor.withOpacity(0.92),
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(12, 18, 12, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  '\£${price.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: hasOffer ? Colors.white70 : Colors.white,
                                    decoration: hasOffer
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    fontSize: 12,
                                  ),
                                ),
                                if (hasOffer) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    '\£${offerPrice!.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => onAdd(item),
                          child: SizedBox(
                            width: 34,
                            height: 34,
                            child: Icon(Icons.add, size: 20, color: brandColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
