// ==============================================================================
// Splash Screen: หน้าจอเปิดแอปพลิเคชันและตรวจสอบสถานะการเข้าสู่ระบบ (Session Checking)
// ==============================================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:my_app/login_screen.dart';
import 'package:my_app/screens/main_shell.dart';
import 'package:my_app/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // กำหนดตำแหน่งและคุณสมบัติของอนุภาคพื้นหลังเคลื่อนไหว (Background Particles)
  static const List<_Particle> _particles = [
    _Particle(x: 0.12, y: 0.18, radius: 4.8, speed: 0.8, phase: 0.0, opacity: 0.28, isLight: true),
    _Particle(x: 0.28, y: 0.32, radius: 6.2, speed: 0.6, phase: 1.2, opacity: 0.22, isLight: false),
    _Particle(x: 0.45, y: 0.12, radius: 4.2, speed: 1.0, phase: 2.4, opacity: 0.30, isLight: true),
    _Particle(x: 0.72, y: 0.22, radius: 6.8, speed: 0.7, phase: 0.8, opacity: 0.20, isLight: false),
    _Particle(x: 0.88, y: 0.15, radius: 5.2, speed: 0.9, phase: 3.1, opacity: 0.26, isLight: true),
    _Particle(x: 0.08, y: 0.48, radius: 5.8, speed: 0.75, phase: 1.8, opacity: 0.24, isLight: false),
    _Particle(x: 0.22, y: 0.62, radius: 4.4, speed: 1.1, phase: 0.5, opacity: 0.32, isLight: true),
    _Particle(x: 0.82, y: 0.55, radius: 6.5, speed: 0.65, phase: 2.9, opacity: 0.22, isLight: false),
    _Particle(x: 0.92, y: 0.42, radius: 4.0, speed: 0.95, phase: 1.4, opacity: 0.28, isLight: true),
    _Particle(x: 0.15, y: 0.78, radius: 7.0, speed: 0.55, phase: 3.7, opacity: 0.20, isLight: false),
    _Particle(x: 0.35, y: 0.85, radius: 4.6, speed: 0.85, phase: 0.9, opacity: 0.26, isLight: true),
    _Particle(x: 0.58, y: 0.72, radius: 5.5, speed: 0.7, phase: 2.1, opacity: 0.24, isLight: false),
    _Particle(x: 0.76, y: 0.88, radius: 5.0, speed: 1.05, phase: 1.6, opacity: 0.30, isLight: true),
    _Particle(x: 0.89, y: 0.75, radius: 6.0, speed: 0.6, phase: 3.3, opacity: 0.22, isLight: false),
    _Particle(x: 0.05, y: 0.92, radius: 4.2, speed: 0.9, phase: 0.3, opacity: 0.28, isLight: true),
    _Particle(x: 0.65, y: 0.38, radius: 5.2, speed: 0.8, phase: 2.7, opacity: 0.25, isLight: true),
    _Particle(x: 0.50, y: 0.95, radius: 6.4, speed: 0.65, phase: 1.1, opacity: 0.21, isLight: false),
    _Particle(x: 0.38, y: 0.45, radius: 4.5, speed: 1.0, phase: 3.0, opacity: 0.27, isLight: true),
  ];

  @override
  void initState() {
    super.initState();

    // Controller สำหรับ Animation การเปิดตัวของโลโก้ (Fade & Scale In)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Controller สำหรับ Animation ของอนุภาคพื้นหลังเคลื่อนไหวแบบวนลูป
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutCubic,
      ),
    );

    _entranceController.forward();
    // เริ่มต้นตรวจสอบ Session การเข้าสู่ระบบ
    _checkSession();
  }

  /// ตรวจสอบว่าผู้ใช้มี Access Token ที่เคยบันทึกไว้ใน SharedPreferences หรือไม่:
  /// - หากมี Token -> นำทางไปยังหน้าหลัก MainShell ทันที (Auto Login)
  /// - หากไม่มี Token -> นำทางไปยังหน้าเข้าสู่ระบบ LoginScreen
  Future<void> _checkSession() async {
    // หน่วงเวลา 1.4 วินาที เพื่อให้แสดงผล Animation และแบรนด์ TangKep ได้อย่างสวยงาม
    await Future.delayed(const Duration(milliseconds: 1400));

    final prefs = await SharedPreferences.getInstance();
    final hasToken = prefs.getString('access_token')?.isNotEmpty == true;

    if (!mounted) return;

    // เปลี่ยนหน้าโดยไม่ให้ผู้ใช้กดย้อนกลับมาที่ SplashScreen ได้อีก (pushReplacement)
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            hasToken ? const MainShell() : const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _particleController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. TangKep Orange/Gold Brand Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFBBF24), // Warm gold highlight
                    AppColors.primary,  // 0xFFF59E0B TangKep primary gold/amber
                    AppColors.primaryDark, // 0xFFD97706
                    Color(0xFFB45309), // Rich deep gold/amber base
                  ],
                  stops: [0.0, 0.35, 0.75, 1.0],
                ),
              ),
            ),
          ),

          // 2. Subtle Animated Floating Particles (Positioned behind the logo)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ParticlePainter(
                    progress: _particleController.value,
                    particles: _particles,
                  ),
                );
              },
            ),
          ),

          // 3. Main Centered Logo & Branding Content
          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Large Application Logo in Elevated White Card
                      Container(
                        width: 148,
                        height: 148,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(36),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 30,
                              offset: const Offset(0, 14),
                            ),
                            BoxShadow(
                              color: AppColors.primaryDark.withValues(alpha: 0.30),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Image.asset(
                              'assets/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Thai App Name: ตังค์เก็บ
                      const Text(
                        'ตังค์เก็บ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          shadows: [
                            Shadow(
                              color: Color(0x33000000),
                              offset: Offset(0, 2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 4),

                      // English App Name: TangKep
                      Text(
                        'TangKep',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          shadows: const [
                            Shadow(
                              color: Color(0x29000000),
                              offset: Offset(0, 1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Animated Loading Indicator (Three Pulsing Dots)
                      const _ThreeDotsLoading(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Particle model for deterministic floating ambient background
class _Particle {
  final double x;
  final double y;
  final double radius;
  final double speed;
  final double phase;
  final double opacity;
  final bool isLight;

  const _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.phase,
    required this.opacity,
    required this.isLight,
  });
}

/// CustomPainter rendering smooth floating particles
class _ParticlePainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;

  _ParticlePainter({
    required this.progress,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      // Upward floating movement with smooth cyclic wrap
      final double dy = (p.y - (progress * p.speed * 0.4)) % 1.0;
      final double adjustedY = (dy < 0 ? dy + 1.0 : dy) * size.height;

      // Gentle horizontal oscillation
      final double wave = math.sin((progress * 2 * math.pi) + p.phase) * 12.0;
      final double adjustedX = (p.x * size.width) + wave;

      final paint = Paint()
        ..color = p.isLight
            ? Colors.white.withValues(alpha: p.opacity)
            : AppColors.primaryLight.withValues(alpha: p.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(adjustedX, adjustedY),
        p.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Lightweight continuous 3-dot pulsing loading indicator harmonized with the gold background
class _ThreeDotsLoading extends StatefulWidget {
  const _ThreeDotsLoading();

  @override
  State<_ThreeDotsLoading> createState() => _ThreeDotsLoadingState();
}

class _ThreeDotsLoadingState extends State<_ThreeDotsLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _dotsController;

  @override
  void initState() {
    super.initState();
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dotsController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final double phase = (_dotsController.value * 2 * math.pi) - (index * 0.8);
            final double wave = (math.sin(phase) + 1.0) / 2.0;

            final double scale = 0.85 + (wave * 0.50);
            final double opacity = 0.40 + (wave * 0.60);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: opacity),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}