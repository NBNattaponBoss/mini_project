// ==============================================================================
// Login Screen: หน้าจอเข้าสู่ระบบสำหรับตรวจสอบสิทธิ์และรับ JWT Token
// ==============================================================================

import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:my_app/screens/main_shell.dart';
import 'package:my_app/screens/register_screen.dart';
import 'package:my_app/theme/app_colors.dart';
import 'package:my_app/utils/app_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;

  late AnimationController _particleController;

  // รายการอนุภาคพื้นหลังเคลื่อนไหวแบบคงที่ (Deterministic floating particles)
  static const List<_LoginParticle> _particles = [
    _LoginParticle(x: 0.10, y: 0.20, radius: 4.2, speed: 0.6, phase: 0.2, opacity: 0.24, isLight: true),
    _LoginParticle(x: 0.25, y: 0.12, radius: 5.6, speed: 0.5, phase: 1.4, opacity: 0.18, isLight: false),
    _LoginParticle(x: 0.40, y: 0.28, radius: 3.6, speed: 0.7, phase: 2.8, opacity: 0.25, isLight: true),
    _LoginParticle(x: 0.70, y: 0.15, radius: 5.8, speed: 0.55, phase: 0.9, opacity: 0.17, isLight: false),
    _LoginParticle(x: 0.85, y: 0.25, radius: 4.5, speed: 0.65, phase: 3.2, opacity: 0.22, isLight: true),
    _LoginParticle(x: 0.08, y: 0.52, radius: 5.0, speed: 0.5, phase: 1.7, opacity: 0.20, isLight: false),
    _LoginParticle(x: 0.90, y: 0.48, radius: 3.8, speed: 0.7, phase: 1.1, opacity: 0.24, isLight: true),
    _LoginParticle(x: 0.18, y: 0.75, radius: 6.0, speed: 0.45, phase: 2.5, opacity: 0.16, isLight: false),
    _LoginParticle(x: 0.32, y: 0.88, radius: 3.8, speed: 0.65, phase: 0.6, opacity: 0.22, isLight: true),
    _LoginParticle(x: 0.60, y: 0.80, radius: 4.8, speed: 0.55, phase: 2.2, opacity: 0.19, isLight: false),
    _LoginParticle(x: 0.78, y: 0.92, radius: 4.0, speed: 0.7, phase: 1.5, opacity: 0.25, isLight: true),
    _LoginParticle(x: 0.88, y: 0.72, radius: 5.4, speed: 0.5, phase: 3.5, opacity: 0.18, isLight: false),
    _LoginParticle(x: 0.05, y: 0.90, radius: 3.5, speed: 0.6, phase: 0.4, opacity: 0.23, isLight: true),
    _LoginParticle(x: 0.52, y: 0.95, radius: 5.2, speed: 0.5, phase: 1.0, opacity: 0.17, isLight: false),
  ];

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _particleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// ฟังก์ชันส่งคำขอเข้าสู่ระบบ (Login Flow):
  /// 1. ตรวจสอบความถูกต้องของแบบฟอร์ม (Form Validation)
  /// 2. เรียก API POST `/auth/login` พร้อมส่ง username และ password (auth: false เนื่องจากยังไม่มี Token)
  /// 3. อ่าน Response: หากสำเร็จจะได้รับ JWT Token และข้อมูล User
  /// 4. บันทึก `access_token` และ `username` ลงใน SharedPreferences บนเครื่อง
  /// 5. นำทางไปยัง MainShell (หน้าหลัก) และลบหน้าจอก่อนหน้าทั้งหมดออกจาก Navigation Stack
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      // 2. เรียก API เข้าสู่ระบบ
      final response = await AppAPI.post(
        '/auth/login',
        {
          'username': _usernameController.text.trim(),
          'password': _passwordController.text,
        },
        auth: false,
      );

      final json = jsonDecode(response.body);
      final isError = json['isError'] ?? (json['success'] == false);
      final errorMessage = json['errorMessage'] ?? json['message'] ?? '';

      // 3. ตรวจสอบผลการเข้าสู่ระบบ
      if (!isError && json['data'] != null) {
        final data = json['data'] as Map<String, dynamic>;
        final token = data['token'] as String;
        final user = data['user'] as Map<String, dynamic>;
        final username = user['username'] as String;

        // 4. บันทึก Token และ Username ลง SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);
        await prefs.setString('username', username);

        if (!mounted) return;

        // 5. นำทางไปยังหน้าหลัก MainShell
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const MainShell(),
          ),
          (route) => false,
        );
      } else {
        if (!mounted) return;
        _showErrorDialog(
          errorMessage.isNotEmpty
              ? errorMessage
              : 'Invalid username or password.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Unable to connect to the server.');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  /// แสดง Dialog แจ้งเตือนข้อผิดพลาด
  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColors.withdrawal,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'แจ้งเตือน',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Layer 1A: Full-Screen TangKep Orange/Gold Brand Background Gradient
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

          // Layer 1B: Subtle Animated Floating Particles (behind the card)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _LoginParticlePainter(
                    progress: _particleController.value,
                    particles: _particles,
                  ),
                );
              },
            ),
          ),

          // Layer 2 & 3: White Foreground Login Card & Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 420,
                  ),
                  child: Card(
                    elevation: 0,
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(
                        color: AppColors.cardBorder,
                        width: 1,
                      ),
                    ),
                    shadowColor: Colors.black.withValues(alpha: 0.15),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.14),
                            blurRadius: 28,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(28),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // App Branding / Logo
                            Center(
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: AppColors.cardBorder,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.16),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: Image.asset(
                                      'assets/logo.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Title: TangKep (ตังค์เก็บ)
                            const Text(
                              'ตังค์เก็บ (TangKep)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.3,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Subtitle
                            const Text(
                              'Sign in to manage your deposits and withdrawals.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Username field
                            TextFormField(
                              controller: _usernameController,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                hintText: 'Enter your username',
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                ),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty) {
                                  return 'Username is required.';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 18),

                            // Password field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) {
                                if (!_loading) {
                                  _login();
                                }
                              },
                              decoration: InputDecoration(
                                labelText: 'Password',
                                hintText: 'Enter your password',
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword =
                                          !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty) {
                                  return 'Password is required.';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 28),

                            // Sign in button
                            FilledButton(
                              onPressed: _loading ? null : _login,
                              child: _loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Sign in',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),

                            const SizedBox(height: 16),

                            // Register navigation
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account?",
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                                TextButton(
                                  onPressed: _loading
                                      ? null
                                      : () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const RegisterScreen(),
                                            ),
                                          );
                                        },
                                  child: const Text('Create an account'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
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

/// Lightweight deterministic particle for Login Screen ambient background
class _LoginParticle {
  final double x;
  final double y;
  final double radius;
  final double speed;
  final double phase;
  final double opacity;
  final bool isLight;

  const _LoginParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.phase,
    required this.opacity,
    required this.isLight,
  });
}

/// CustomPainter rendering smooth subtle background floating particles for Login
class _LoginParticlePainter extends CustomPainter {
  final double progress;
  final List<_LoginParticle> particles;

  _LoginParticlePainter({
    required this.progress,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      // Gentle slow upward drift
      final double dy = (p.y - (progress * p.speed * 0.3)) % 1.0;
      final double adjustedY = (dy < 0 ? dy + 1.0 : dy) * size.height;

      // Subtle horizontal sine wave
      final double wave = math.sin((progress * 2 * math.pi) + p.phase) * 10.0;
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
  bool shouldRepaint(covariant _LoginParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}