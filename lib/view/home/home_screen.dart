import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/app_theme.dart';
import '../../controller/shoe_provider.dart';
import '../../controller/auth_provider.dart';
import '../widgets/shoe_card.dart';
import '../cart/cart_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  final List<Widget> _pages = const [
    _HomeTab(),
    WishlistScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _navIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'Cart',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final shoeProvider = context.watch<ShoeProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome back,',
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            authProvider.user?.name.split(' ').first ??
                                'Sneakerhead',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.lightGrey,
                        child: authProvider.user?.photoUrl != null
                            ? ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: authProvider.user!.photoUrl!,
                                ),
                              )
                            : const Icon(Icons.person, color: AppColors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              // Animated search bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: shoeProvider.setSearchQuery,
                      decoration: const InputDecoration(
                        hintText: 'Search for shoes...',
                        prefixIcon: Icon(Icons.search, color: AppColors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
              ),

              // Featured banner carousel
              if (shoeProvider.featuredShoes.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: SizedBox(
                      height: 210,
                      child: PageView.builder(
                        controller: PageController(viewportFraction: 0.88),
                        itemCount: shoeProvider.featuredShoes.length,
                        itemBuilder: (context, index) {
                          final shoe = shoeProvider.featuredShoes[index];
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              color: AppColors.black,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: SizedBox(
                                    height: 160,
                                    width: 180,
                                    child: shoe.images.isNotEmpty
                                        ? shoe.images.first.startsWith(
                                                'assets/',
                                              )
                                              ? Image.asset(
                                                  shoe.images.first,
                                                  fit: BoxFit.contain,
                                                  alignment:
                                                      Alignment.bottomRight,
                                                )
                                              : CachedNetworkImage(
                                                  imageUrl: shoe.images.first,
                                                  fit: BoxFit.contain,
                                                  alignment:
                                                      Alignment.bottomRight,
                                                )
                                        : null,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'FEATURED',
                                        style: TextStyle(
                                          color: AppColors.accentRed,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.2,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        shoe.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '\$${shoe.price.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

              // Category tabs
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    itemCount: shoeProvider.categories.length,
                    itemBuilder: (context, index) {
                      final cat = shoeProvider.categories[index];
                      final isSelected = shoeProvider.selectedCategory == cat;
                      return GestureDetector(
                        onTap: () => shoeProvider.setCategory(cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.black
                                : AppColors.lightGrey,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Text(
                              cat,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Shoe grid with staggered entrance animation
              if (shoeProvider.isLoading)
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.68,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Shimmer.fromColors(
                        baseColor: AppColors.lightGrey,
                        highlightColor: Colors.white,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      childCount: 6,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.68,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final shoe = shoeProvider.filteredShoes[index];
                      return AnimationConfiguration.staggeredGrid(
                        position: index,
                        duration: const Duration(milliseconds: 500),
                        columnCount: 2,
                        child: ScaleAnimation(
                          child: FadeInAnimation(child: ShoeCard(shoe: shoe)),
                        ),
                      );
                    }, childCount: shoeProvider.filteredShoes.length),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }
}
