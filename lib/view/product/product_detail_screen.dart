import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../theme/app_theme.dart';
import '../../model/shoe_model.dart';
import '../../controller/cart_provider.dart';
import '../../controller/wishlist_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final ShoeModel shoe;
  const ProductDetailScreen({super.key, required this.shoe});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  int _imageIndex = 0;
  String? _selectedColor;
  String? _selectedSize;
  bool _descExpanded = false;
  late AnimationController _addToCartController;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.shoe.colorImageMap.keys.isNotEmpty
        ? widget.shoe.colorImageMap.keys.first
        : null;
    _addToCartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _addToCartController.dispose();
    super.dispose();
  }

  Future<void> _handleAddToCart() async {
    if (_selectedSize == null) {
      Fluttertoast.showToast(msg: 'Please select a size');
      return;
    }
    await _addToCartController.forward(from: 0);
    final cart = context.read<CartProvider>();
    await cart.addToCart(widget.shoe, _selectedSize!, _selectedColor ?? '');
    if (!mounted) return;
    Fluttertoast.showToast(msg: 'Added to cart 🛒');
  }

  @override
  Widget build(BuildContext context) {
    final shoe = widget.shoe;
    final wishlist = context.watch<WishlistProvider>();
    final isWishlisted = wishlist.isWishlisted(shoe.id);
    final displayImage =
        _selectedColor != null && shoe.colorImageMap.containsKey(_selectedColor)
        ? shoe.colorImageMap[_selectedColor]!
        : (shoe.images.isNotEmpty ? shoe.images[_imageIndex] : '');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _circleIconButton(
                    Icons.arrow_back,
                    () => Navigator.of(context).pop(),
                  ),
                  GestureDetector(
                    onTap: () => wishlist.toggle(shoe),
                    child: _circleIconButton(
                      isWishlisted ? Icons.favorite : Icons.favorite_border,
                      () => wishlist.toggle(shoe),
                      color: isWishlisted ? AppColors.accentRed : null,
                    ),
                  ),
                ],
              ),
            ),

            // Hero image with swipeable angles
            Expanded(
              flex: 4,
              child: Hero(
                tag: 'shoe_${shoe.id}',
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, anim) => ScaleTransition(
                    scale: anim,
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: displayImage.isNotEmpty
                      ? displayImage.startsWith('assets/')
                            ? Image.asset(
                                displayImage,
                                key: ValueKey(displayImage),
                                fit: BoxFit.contain,
                              )
                            : CachedNetworkImage(
                                key: ValueKey(displayImage),
                                imageUrl: displayImage,
                                fit: BoxFit.contain,
                              )
                      : const Icon(
                          Icons.image_not_supported_outlined,
                          size: 80,
                          key: ValueKey('placeholder'),
                        ),
                ),
              ),
            ),

            // Alternate angle thumbnails
            if (shoe.images.length > 1)
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: shoe.images.length,
                  itemBuilder: (context, index) {
                    final selected = index == _imageIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _imageIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 10),
                        width: 54,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selected
                                ? AppColors.black
                                : AppColors.lightGrey,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: shoe.images[index].startsWith('assets/')
                              ? Image.asset(
                                  shoe.images[index],
                                  fit: BoxFit.contain,
                                )
                              : CachedNetworkImage(
                                  imageUrl: shoe.images[index],
                                  fit: BoxFit.contain,
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Bottom details panel
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  shoe.brand.toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.accentRed,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  shoe.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${shoe.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (shoe.rating > 0)
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              shoe.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'customer rating',
                              style: TextStyle(
                                color: AppColors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        )
                      else
                        const Text(
                          'No customer reviews yet',
                          style: TextStyle(color: AppColors.grey, fontSize: 13),
                        ),
                      const SizedBox(height: 20),

                      if (shoe.colorImageMap.isNotEmpty) ...[
                        const Text(
                          'Color',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: shoe.colorImageMap.keys.map((color) {
                            final isSelected = _selectedColor == color;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedColor = color),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(right: 12),
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _colorFromName(color),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.black
                                        : Colors.transparent,
                                    width: 2.5,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                      ],

                      const Text(
                        'Size',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      if (shoe.sizes.isEmpty)
                        const Text(
                          'Sizes will be available soon.',
                          style: TextStyle(color: AppColors.grey),
                        )
                      else
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: shoe.sizes.map((size) {
                            final isSelected = _selectedSize == size;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedSize = size),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateX(isSelected ? 0.04 : 0)
                                  ..rotateY(isSelected ? -0.04 : 0),
                                transformAlignment: Alignment.center,
                                width: 48,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.black
                                      : AppColors.lightGrey,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    size,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 20),

                      const Text(
                        'Description',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        crossFadeState: _descExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: Text(
                          shoe.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.grey,
                            height: 1.5,
                          ),
                        ),
                        secondChild: Text(
                          shoe.description,
                          style: const TextStyle(
                            color: AppColors.grey,
                            height: 1.5,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _descExpanded = !_descExpanded),
                        child: Text(
                          _descExpanded ? 'Show less' : 'Read more',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed: _handleAddToCart,
                                icon: AnimatedBuilder(
                                  animation: _addToCartController,
                                  builder: (context, child) => Transform.scale(
                                    scale:
                                        1 + (_addToCartController.value * 0.4),
                                    child: const Icon(
                                      Icons.shopping_bag_outlined,
                                    ),
                                  ),
                                ),
                                label: const Text('Add to Cart'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleIconButton(IconData icon, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color ?? AppColors.black, size: 20),
      ),
    );
  }

  Color _colorFromName(String name) {
    switch (name.toLowerCase()) {
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'grey':
      case 'gray':
        return Colors.grey;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'pink':
        return Colors.pink;
      case 'yellow':
        return Colors.yellow;
      default:
        return AppColors.grey;
    }
  }
}
