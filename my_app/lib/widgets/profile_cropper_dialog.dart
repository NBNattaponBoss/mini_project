// ==============================================================================
// ProfileCropperDialog: Dialog ปรับแต่งและตัดรูปโปรไฟล์ให้เป็นสัดส่วน 1:1
// ==============================================================================
// ใช้ InteractiveViewer ในการเลื่อน ซูม หมุนภาพ และใช้ RenderRepaintBoundary ในการบันทึกภาพตัด

import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:my_app/theme/app_colors.dart';

/// Modal Dialog สำหรับครอบตัดภาพถ่ายโปรไฟล์ให้ได้สัดส่วน 1:1 พร้อมเส้นกรอบจัดองค์ประกอบ
class ProfileCropperDialog extends StatefulWidget {
  const ProfileCropperDialog({
    super.key,
    required this.imageBytes,
  });

  final Uint8List imageBytes;

  @override
  State<ProfileCropperDialog> createState() => _ProfileCropperDialogState();
}


class _ProfileCropperDialogState extends State<ProfileCropperDialog> {
  final GlobalKey _cropKey = GlobalKey();
  final TransformationController _transformationController =
      TransformationController();

  int _rotationQuarterTurns = 0;
  bool _isProcessing = false;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _rotateClockwise() {
    setState(() {
      _rotationQuarterTurns = (_rotationQuarterTurns + 1) % 4;
      _transformationController.value = Matrix4.identity();
    });
  }

  void _resetTransform() {
    setState(() {
      _rotationQuarterTurns = 0;
      _transformationController.value = Matrix4.identity();
    });
  }

  Future<void> _cropAndConfirm() async {
    setState(() => _isProcessing = true);

    try {
      final boundary =
          _cropKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        Navigator.pop(context);
        return;
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 2.5);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null && mounted) {
        final Uint8List croppedBytes = byteData.buffer.asUint8List();
        Navigator.pop(context, croppedBytes);
      } else {
        if (mounted) Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const double cropBoxSize = 280.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.crop_rounded,
                          color: AppColors.primaryDark,
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'ปรับแต่งรูปโปรไฟล์ (1:1)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      tooltip: 'ปิด',
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 1:1 Interactive Crop Box
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: cropBoxSize,
                    height: cropBoxSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // RepaintBoundary for high-res snapshot
                        RepaintBoundary(
                          key: _cropKey,
                          child: Container(
                            width: cropBoxSize,
                            height: cropBoxSize,
                            color: Colors.black,
                            child: InteractiveViewer(
                              transformationController:
                                  _transformationController,
                              minScale: 0.5,
                              maxScale: 4.0,
                              boundaryMargin: const EdgeInsets.all(
                                cropBoxSize,
                              ),
                              child: RotatedBox(
                                quarterTurns: _rotationQuarterTurns,
                                child: Image.memory(
                                  widget.imageBytes,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 1:1 Circular & Grid Mask Overlay
                        IgnorePointer(
                          child: CustomPaint(
                            size: const Size(cropBoxSize, cropBoxSize),
                            painter: _CropGridPainter(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Control Toolbar (Rotate & Reset)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: _rotateClockwise,
                      icon: const Icon(
                        Icons.rotate_right_rounded,
                        size: 18,
                      ),
                      label: const Text('หมุน 90°'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton.icon(
                      onPressed: _resetTransform,
                      icon: const Icon(
                        Icons.restart_alt_rounded,
                        size: 18,
                      ),
                      label: const Text('รีเซ็ต'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Action Buttons (Cancel & Save)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isProcessing
                            ? null
                            : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('ยกเลิก'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _isProcessing ? null : _cropAndConfirm,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'ใช้รูปนี้',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter rendering 1:1 circular guide overlay with rule-of-thirds grid
class _CropGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Outer subtle border
    final borderPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, borderPaint);

    // Rule-of-thirds guide lines inside circle
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final double step = size.width / 3;
    canvas.drawLine(
      Offset(step, 0),
      Offset(step, size.height),
      gridPaint,
    );
    canvas.drawLine(
      Offset(step * 2, 0),
      Offset(step * 2, size.height),
      gridPaint,
    );
    canvas.drawLine(
      Offset(0, step),
      Offset(size.width, step),
      gridPaint,
    );
    canvas.drawLine(
      Offset(0, step * 2),
      Offset(size.width, step * 2),
      gridPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}