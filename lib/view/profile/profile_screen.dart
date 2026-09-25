import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../controller/auth_provider.dart';
import '../../controller/theme_provider.dart';
import '../../model/services/supabase_service.dart';
import '../splash/splash_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log out?'),
        content: const Text(
          'You\'ll need to sign in again to access your account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Log Out',
              style: TextStyle(color: AppColors.accentRed),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (_, animation, _) =>
                FadeTransition(opacity: animation, child: const SplashScreen()),
          ),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: AppColors.lightGrey,
                child: Text(
                  (user?.name.isNotEmpty ?? false)
                      ? user!.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(color: AppColors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          _SectionTitle('Preferences'),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: SwitchListTile(
              title: const Text(
                'Dark Mode',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              secondary: const Icon(Icons.dark_mode_outlined),
              value: themeProvider.isDarkMode,
              onChanged: (_) => themeProvider.toggleTheme(),
              activeThumbColor: AppColors.black,
            ),
          ),
          const SizedBox(height: 24),

          _SectionTitle('Order History'),
          if (user != null) _OrderHistoryList(uid: user.uid),
          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _confirmLogout(context),
              icon: const Icon(Icons.logout, color: AppColors.accentRed),
              label: const Text(
                'Log Out',
                style: TextStyle(
                  color: AppColors.accentRed,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.accentRed),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
      ),
    );
  }
}

class _OrderHistoryList extends StatelessWidget {
  final String uid;
  const _OrderHistoryList({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: SupabaseService().streamOrders(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final orders = snapshot.data!;
        if (orders.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Text(
                'No orders yet',
                style: TextStyle(color: AppColors.grey),
              ),
            ),
          );
        }
        return Column(
          children: orders.map((order) {
            final items = List<Map<String, dynamic>>.from(order['items'] ?? []);
            final createdAt = order['createdAt'];
            String dateStr = '';
            if (createdAt != null &&
                createdAt.runtimeType.toString().contains('Timestamp')) {
              dateStr = DateFormat.yMMMd().format(createdAt.toDate());
            }
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(
                  'Order #${(order['orderId'] ?? '').toString().substring(0, 8).toUpperCase()}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '$dateStr · ${order['status'] ?? 'Processing'}',
                  style: const TextStyle(color: AppColors.grey, fontSize: 12),
                ),
                trailing: Text(
                  '\$${(order['total'] ?? 0).toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                children: items
                    .map(
                      (item) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          item['name'] ?? '',
                          style: const TextStyle(fontSize: 14),
                        ),
                        subtitle: Text(
                          'Size ${item['selectedSize']} · ${item['selectedColor']} · Qty ${item['quantity']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
