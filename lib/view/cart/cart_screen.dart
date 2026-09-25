import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: const Center(child: Text('Your cart is empty')),
    );
  }
}

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;
  const OrderSuccessScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                    height: 120,
                    width: 120,
                    decoration: const BoxDecoration(
                      color: AppColors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 60,
                    ),
                  )
                  .animate()
                  .scale(
                    begin: const Offset(0, 0),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  )
                  .then()
                  .shake(duration: 400.ms, hz: 2),
              const SizedBox(height: 30),
              const Text(
                'Order Confirmed!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),
              const SizedBox(height: 10),
              Text(
                'Order #${orderId.substring(0, 8).toUpperCase()}',
                style: const TextStyle(color: AppColors.grey),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 6),
              const Text(
                'Your kicks are on the way. Track your order\nanytime from your profile.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.grey, height: 1.5),
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).popUntil((route) => route.isFirst),
                    child: const Text('Continue Shopping'),
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}
