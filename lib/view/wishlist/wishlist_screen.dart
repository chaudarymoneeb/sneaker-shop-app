import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../theme/app_theme.dart';
import '../../controller/wishlist_provider.dart';
import '../../controller/shoe_provider.dart';
import '../widgets/shoe_card.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final shoeProvider = context.watch<ShoeProvider>();
    final wishlistedShoes = shoeProvider.allShoes
        .where((s) => wishlist.isWishlisted(s.id))
        .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Wishlist',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: wishlistedShoes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.favorite_border, size: 70, color: AppColors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Tap the heart on any shoe to save it here',
                    style: TextStyle(color: AppColors.grey),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.68,
              ),
              itemCount: wishlistedShoes.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 400),
                  columnCount: 2,
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: ShoeCard(shoe: wishlistedShoes[index]),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
