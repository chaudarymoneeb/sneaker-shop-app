import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../theme/app_theme.dart';
import '../../controller/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/animated_primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _sent = false;

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.resetPassword(_emailController.text);
    if (!mounted) return;
    if (success) {
      setState(() => _sent = true);
    } else {
      Fluttertoast.showToast(msg: auth.errorMessage ?? 'Something went wrong.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reset Password',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                const SizedBox(height: 10),
                const Text(
                  "Enter the email associated with your account and we'll send a reset link.",
                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 36),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: _sent
                      ? Column(
                          key: const ValueKey('sent'),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.mark_email_read_outlined,
                              size: 60,
                              color: AppColors.black,
                            ).animate().scale(
                              curve: Curves.easeOutBack,
                              duration: 500.ms,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Check your inbox! A password reset link is on its way.',
                              style: TextStyle(fontSize: 15, height: 1.4),
                            ),
                          ],
                        )
                      : Column(
                          key: const ValueKey('form'),
                          children: [
                            CustomTextField(
                              controller: _emailController,
                              label: 'Email',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Enter your email';
                                }
                                if (!v.contains('@')) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 28),
                            AnimatedPrimaryButton(
                              label: 'Send Reset Link',
                              isLoading: auth.isLoading,
                              onPressed: _handleReset,
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
