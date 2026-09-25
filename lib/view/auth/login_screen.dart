import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../theme/app_theme.dart';
import '../../controller/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/animated_primary_button.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import '../home/home_screen.dart';
import 'auth_brand_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _shake = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      setState(() => _shake = true);
      Future.delayed(
        const Duration(milliseconds: 500),
        () => setState(() => _shake = false),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.signIn(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, animation, _) =>
              FadeTransition(opacity: animation, child: const HomeScreen()),
        ),
        (route) => false,
      );
    } else {
      setState(() => _shake = true);
      Future.delayed(
        const Duration(milliseconds: 500),
        () => setState(() => _shake = false),
      );
      Fluttertoast.showToast(
        msg: auth.errorMessage ?? 'Login failed. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const AuthBrandHeader(
                eyebrow: 'SNEAKER CLUB',
                title: 'Welcome back.',
                subtitle: 'Your next favorite pair is waiting.',
                icon: Icons.directions_run_rounded,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
                child: Form(
                  key: _formKey,
                  child: ShakeErrorWrapper(
                    triggerShake: _shake,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sign in',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ).animate().fadeIn().slideX(begin: -0.12, end: 0),
                        const SizedBox(height: 6),
                        const Text(
                          'Pick up where you left off.',
                          style: TextStyle(color: AppColors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 24),
                        CustomTextField(
                          controller: _emailController,
                          label: 'Email address',
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
                        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.12),
                        const SizedBox(height: 14),
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Enter your password';
                            }
                            if (v.length < 6) return 'At least 6 characters';
                            return null;
                          },
                        ).animate().fadeIn(delay: 160.ms).slideY(begin: 0.12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen(),
                              ),
                            ),
                            child: const Text('Forgot password?'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedPrimaryButton(
                          label: 'Log in',
                          isLoading: auth.isLoading,
                          onPressed: _handleLogin,
                        ).animate().fadeIn(delay: 240.ms).slideY(begin: 0.12),
                        const SizedBox(height: 26),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                'NEW HERE?',
                                style: TextStyle(
                                  color: AppColors.grey,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.4,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SignUpScreen(),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.black,
                              side: const BorderSide(color: AppColors.black),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Create an account',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ],
                    ),
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
