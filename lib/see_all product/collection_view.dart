import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import 'collection_controller.dart';

class CollectionView extends GetView<CollectionController> {
  const CollectionView({super.key});

  static const _blue = Color(0xFF124A89);
  static const _radius = 14.0;

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leadingWidth: 95,
        leading: TextButton.icon(
          onPressed: c.back,
          style: TextButton.styleFrom(foregroundColor: Colors.black87),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          label: const Text('Back',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: c.openMenu,
            tooltip: 'More',
          ),
        ],
        centerTitle: false,
      ),
      body: Obx(() => GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: c.items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,        // two cards per row
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.87,   // tweak to match screenshot
        ),
        itemBuilder: (_, i) => _ProductCard(
          data: c.items[i],
          onOpen: c.openItem,
          onAdd: c.addToCollection,
        ),
      )),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.data,
    required this.onOpen,
    required this.onAdd,
  });

  final CollectionItem data;
  final void Function(CollectionItem) onOpen;
  final void Function(CollectionItem) onAdd;

  static const _blue = Color(0xFF124A89);
  static const _radius = 14.0;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(_radius),
      onTap: () => onOpen(data),
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
              // product image
              Positioned.fill(
                child: data.image.startsWith('http')
                    ? Image.network(data.image, fit: BoxFit.cover)
                    : Image.asset(data.image, fit: BoxFit.cover),
              ),

              // gradient -> solid blue band at the bottom
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _blue.withOpacity(0.0),
                        _blue.withOpacity(0.75),
                        _blue.withOpacity(0.92),
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
                  child: Row(
                    children: [
                      // title + price
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '\$${data.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                      // plus button
                      Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => onAdd(data),
                          child: const SizedBox(
                            width: 34,
                            height: 34,
                            child: Icon(Icons.add, size: 20, color: _blue),
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
