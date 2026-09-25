import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 218,
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -40,
            child: Container(
              height: 210,
              width: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white12, width: 28),
              ),
            ),
          ),
          Positioned(
            right: 28,
            bottom: 30,
            child: Icon(icon, color: AppColors.accentRed, size: 78),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 30, 118, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  eyebrow,
                  style: const TextStyle(
                    color: AppColors.accentRed,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
