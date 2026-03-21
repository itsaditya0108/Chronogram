import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:chronogram/screens/login/login_helper/aseet_helper.dart';
import 'package:chronogram/screens/sign_up/sign_up_screen/sign_up_screen.dart';
import 'package:chronogram/screens/home_screen/home_screen.dart';
import 'package:chronogram/app_helper/token_saver_helper/token_saver_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _dotsController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _ringAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.6, curve: Curves.easeInOutCubic)),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic)),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.1, 0.7, curve: Curves.easeInOutCubic)),
    );
    _ringAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.4, 1.0, curve: Curves.easeInOutCubic)),
    );

    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);

    _dotsController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat();

    _mainController.forward();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 3800));
    String? token = await TokenHelper.getToken();
    if (!mounted) return;
    Widget next = (token != null && token.isNotEmpty) ? const HomeScreen() : const SignUpScreen();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => next,
        settings: next is HomeScreen ? const RouteSettings(name: "HomeScreen") : null,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Glow: top-right ──
          Positioned(
            top: -100, right: -60,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) => Container(
                width: 300, height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.08 + 0.05 * _pulseController.value),
                      blurRadius: 140, spreadRadius: 50,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ── Glow: bottom-left ──
          Positioned(
            bottom: -60, left: -40,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) => Container(
                width: 200, height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepOrange.withOpacity(0.05 + 0.03 * _pulseController.value),
                      blurRadius: 110, spreadRadius: 30,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ── Main content ──
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ── Logo with Sweeping Ring ──
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _ringAnimation,
                            builder: (context, child) => CustomPaint(
                              painter: _RingPainter(_ringAnimation.value),
                              size: const Size(140, 140),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.15),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Image.asset(ScreenImage.allLogoBr, height: 100),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      // ── App name ──
                      const Text(
                        "CHRONOGRAM",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 6.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "PRESERVING MOMENTS FOREVER",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 3.0,
                        ),
                      ),
                      const SizedBox(height: 60),
                      // ── Custom Dots loader ──
                      AnimatedBuilder(
                        animation: _dotsController,
                        builder: (context, child) => _DotsLoader(
                          progress: _dotsController.value,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),


          // ── Version ──
          Positioned(
            bottom: 36, left: 0, right: 0,
            child: Center(
              child: Text(
                "v1.0.0",
                style: TextStyle(color: Colors.white.withOpacity(0.14), fontSize: 10, letterSpacing: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Sweeping orange arc during logo reveal
class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = SweepGradient(
        colors: [Colors.orange.withOpacity(0.0), Colors.orange.withOpacity(0.55 * progress)],
        stops: const [0.0, 1.0],
        transform: GradientRotation(-math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// 3 dots that bounce in sequence
class _DotsLoader extends StatelessWidget {
  final double progress;
  const _DotsLoader({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final offset = (progress - i * 0.18).clamp(0.0, 1.0);
        final bounce = math.sin(offset * math.pi);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 6, height: 6,
          transform: Matrix4.translationValues(0, -9 * bounce, 0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.orange.withOpacity(0.25 + 0.75 * bounce),
          ),
        );
      }),
    );
  }
}
