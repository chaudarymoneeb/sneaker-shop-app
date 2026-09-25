import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../model/shoe_model.dart';
import '../../controller/wishlist_provider.dart';
import '../product/product_detail_screen.dart';

class ShoeCard extends StatefulWidget {
  final ShoeModel shoe;

  const ShoeCard({super.key, required this.shoe});

  @override
  State<ShoeCard> createState() => _ShoeCardState();
}

class _ShoeCardState extends State<ShoeCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final shoe = widget.shoe;
    final wishlist = context.watch<WishlistProvider>();
    final isWishlisted = wishlist.isWishlisted(shoe.id);
    final image = shoe.images.isNotEmpty ? shoe.images.first : '';
    final isAssetImage = image.startsWith('assets/');

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        setState(() => _isPressed = false);
        Navigator.of(context).push(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (_, animation, _) => FadeTransition(
              opacity: animation,
              child: ProductDetailScreen(shoe: shoe),
            ),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_isPressed ? 0.035 : 0)
          ..rotateY(_isPressed ? -0.035 : 0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Hero(
                    tag: 'shoe_${shoe.id}',
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      child: image.isNotEmpty
                          ? isAssetImage
                                ? Image.asset(image, fit: BoxFit.contain)
                                : CachedNetworkImage(
                                    imageUrl: image,
                                    fit: BoxFit.contain,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(
                                          Icons.image_not_supported_outlined,
                                        ),
                                  )
                          : const Icon(
                              Icons.image_not_supported_outlined,
                              size: 40,
                            ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => wishlist.toggle(shoe),
                      child: AnimatedScale(
                        scale: isWishlisted ? 1.15 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          color: isWishlisted
                              ? AppColors.accentRed
                              : AppColors.grey,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shoe.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    shoe.category,
                    style: const TextStyle(color: AppColors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${shoe.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
