import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_theme.dart';
import '../../../controller/auth_provider.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _controller.forward();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    final auth = context.read<AuthProvider>();
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 1800)),
      auth.ready,
    ]);
    if (!mounted) return;

    Widget nextScreen = auth.isAuthenticated
        ? const HomeScreen()
        : const LoginScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, animation, _) =>
            FadeTransition(opacity: animation, child: nextScreen),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnim.value,
              child: Transform.scale(
                scale: _scaleAnim.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 90,
                      width: 140,
                      child: CustomPaint(painter: _SwooshPainter()),
                    ),
                    const SizedBox(height: 20),
                    SlideTransition(
                      position: _slideAnim,
                      child: const Text(
                        'NIKE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SwooshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.05, size.height * 0.75);
    path.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.95,
      size.width * 0.55,
      size.height * 0.55,
    );
    path.lineTo(size.width * 0.95, size.height * 0.05);
    path.quadraticBezierTo(
      size.width * 0.65,
      size.height * 0.35,
      size.width * 0.35,
      size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.55,
      size.width * 0.05,
      size.height * 0.75,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
