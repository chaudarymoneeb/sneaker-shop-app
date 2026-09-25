import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../theme/app_theme.dart';
import '../../controller/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/animated_primary_button.dart';
import 'login_screen.dart';
import 'auth_brand_header.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _shake = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      _triggerShake();
      return;
    }
    if (_passwordController.text != _confirmController.text) {
      Fluttertoast.showToast(msg: 'Passwords do not match');
      _triggerShake();
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.signUp(
      _emailController.text,
      _passwordController.text,
      _nameController.text,
    );

    if (!mounted) return;

    if (success) {
      await _showSignupSuccessCard();
    } else {
      _triggerShake();
      Fluttertoast.showToast(msg: auth.errorMessage ?? 'Sign up failed.');
    }
  }

  Future<void> _showSignupSuccessCard() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: const Icon(
          Icons.mark_email_read_rounded,
          color: AppColors.accentRed,
          size: 42,
        ),
        title: const Text(
          'Successfully signed up!',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Check your email and confirm your account. After confirmation, log in to start shopping.',
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go to login'),
            ),
          ),
        ],
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _triggerShake() {
    setState(() => _shake = true);
    Future.delayed(
      const Duration(milliseconds: 500),
      () => setState(() => _shake = false),
    );
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
                eyebrow: 'JOIN THE CLUB',
                title: 'Build your rotation.',
                subtitle: 'Save favorites, track orders, and move in style.',
                icon: Icons.auto_awesome_rounded,
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
                          'Create your account',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ).animate().fadeIn().slideX(begin: -0.12, end: 0),
                        const SizedBox(height: 6),
                        const Text(
                          'A few details and you are ready to shop.',
                          style: TextStyle(color: AppColors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 24),
                        CustomTextField(
                          controller: _nameController,
                          label: 'Full name',
                          icon: Icons.person_outline,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Enter your name'
                              : null,
                        ).animate().fadeIn(delay: 80.ms).slideY(begin: 0.12),
                        const SizedBox(height: 12),
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
                        ).animate().fadeIn(delay: 130.ms).slideY(begin: 0.12),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          validator: (v) => (v == null || v.length < 8)
                              ? 'At least 8 characters'
                              : null,
                        ).animate().fadeIn(delay: 180.ms).slideY(begin: 0.12),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _confirmController,
                          label: 'Confirm password',
                          icon: Icons.verified_user_outlined,
                          isPassword: true,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Confirm your password'
                              : null,
                        ).animate().fadeIn(delay: 230.ms).slideY(begin: 0.12),
                        const SizedBox(height: 24),
                        AnimatedPrimaryButton(
                          label: 'Create account',
                          isLoading: auth.isLoading,
                          onPressed: _handleSignUp,
                        ).animate().fadeIn(delay: 280.ms).slideY(begin: 0.12),
                        const SizedBox(height: 22),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(
                              'Already have an account?  Log in',
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
