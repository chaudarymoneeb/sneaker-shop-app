import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.label,
    this.controller,
    this.icon,
    this.keyboardType,
    this.validator,
    this.isPassword = false,
  });

  final String label;
  final TextEditingController? controller;
  final IconData? icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool isPassword;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.grey, fontSize: 14),
        prefixIcon: icon == null
            ? null
            : Icon(icon, color: AppColors.grey, size: 21),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE8E5E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.black, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accentRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accentRed, width: 1.4),
        ),
      ),
    );
  }
}
