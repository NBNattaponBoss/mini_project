// ==============================================================================
// AnimatedTangKepHeader: ส่วนหัว AppBar แบบเคลื่อนไหวสไตล์แบรนด์ตังค์เก็บ
// ==============================================================================
// มีพื้นหลัง Gradient สีทอง-ส้ม พร้อมฟองอากาศเคลื่อนไหว (Custom Painter) แบบ Loop

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom AppBar ที่แสดง Title, Back Button, Action Buttons พร้อมพื้นหลังเคลื่อนไหว
class AnimatedTangKepHeader extends StatefulWidget
    implements PreferredSizeWidget {
  const AnimatedTangKepHeader({
    super.key,
    required this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.height = kToolbarHeight,
  });

  final String title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  State<AnimatedTangKepHeader> createState() => _AnimatedTangKepHeaderState();
}


class _AnimatedTangKepHeaderState extends State<AnimatedTangKepHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool canPop = parentRoute?.canPop ?? false;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF59E0B),
            Color(0xFFD97706),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x33D97706),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Animated Decorative Circles (Background Layer)
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _HeaderBubblesPainter(_controller.value),
                  size: Size.infinite,
                );
              },
            ),
          ),

          // 2. Foreground Header Content (SafeArea)
          SafeArea(
            bottom: false,
            child: NavigationToolbar(
              leading: widget.leading ??
                  (canPop
                      ? IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () => Navigator.maybePop(context),
                          tooltip: 'ย้อนกลับ',
                        )
                      : null),
              middle: widget.titleWidget ??
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                  ),
              trailing: widget.actions != null
                  ? IconTheme(
                      data: const IconThemeData(
                        color: Colors.white,
                        size: 24,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: widget.actions!,
                      ),
                    )
                  : null,
              centerMiddle: widget.centerTitle,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for subtle animated decorative bubbles & circles
class _HeaderBubblesPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0

  _HeaderBubblesPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Clip to canvas area so circles never bleed or overflow horizontally
    canvas.clipRect(Offset.zero & size);

    // 1. Large Top-Right Floating Circle (White)
    final Offset center1 = Offset(
      size.width * 0.88 + math.sin(progress * math.pi) * 8,
      size.height * 0.22 + math.cos(progress * math.pi) * 6,
    );
    final double radius1 = 44 + math.sin(progress * math.pi) * 4;
    final paint1 = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center1, radius1, paint1);

    // 2. Top-Left Floating Circle (Light Yellow)
    final Offset center2 = Offset(
      size.width * 0.10 + math.cos(progress * math.pi) * 6,
      size.height * 0.32 + math.sin(progress * math.pi) * 7,
    );
    final double radius2 = 28 + math.cos(progress * math.pi) * 3;
    final paint2 = Paint()
      ..color = const Color(0xFFFEF3C7).withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center2, radius2, paint2);

    // 3. Center-Right Pulsing Dot (White)
    final Offset center3 = Offset(
      size.width * 0.68 + math.sin(progress * math.pi * 1.4) * 6,
      size.height * 0.68 + math.cos(progress * math.pi * 1.4) * 5,
    );
    final double radius3 = 13 + math.sin(progress * math.pi) * 3;
    final paint3 = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center3, radius3, paint3);

    // 4. Center-Left Horizontal Drifting Dot (Light Yellow)
    final Offset center4 = Offset(
      size.width * 0.26 + math.sin(progress * math.pi) * 7,
      size.height * 0.76 + math.cos(progress * math.pi) * 4,
    );
    final double radius4 = 10 + math.cos(progress * math.pi) * 2;
    final paint4 = Paint()
      ..color = const Color(0xFFFEF3C7).withValues(alpha: 0.20)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center4, radius4, paint4);

    // 5. Far-Right Bottom Subtle Circle (White)
    final Offset center5 = Offset(
      size.width * 0.96 + math.cos(progress * math.pi) * 5,
      size.height * 0.82 + math.sin(progress * math.pi) * 5,
    );
    final double radius5 = 22 + math.sin(progress * math.pi) * 3;
    final paint5 = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center5, radius5, paint5);

    // 6. Top-Center Soft Pulsing Dot (White)
    final Offset center6 = Offset(
      size.width * 0.44 + math.cos(progress * math.pi) * 5,
      size.height * 0.18 + math.sin(progress * math.pi) * 4,
    );
    final double radius6 = 7 + math.sin(progress * math.pi) * 2;
    final double opacity6 = 0.16 + (math.sin(progress * math.pi) * 0.08);
    final paint6 = Paint()
      ..color = Colors.white.withValues(alpha: opacity6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center6, radius6, paint6);
  }

  @override
  bool shouldRepaint(covariant _HeaderBubblesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}