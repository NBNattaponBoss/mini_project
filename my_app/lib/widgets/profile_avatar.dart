// ==============================================================================
// ProfileAvatar Widget: แสดงรูปภาพโปรไฟล์ผู้ใช้ และเปิดตัวเลือกเปลี่ยนรูปภาพ
// ==============================================================================

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/theme/app_colors.dart';
import 'package:my_app/widgets/profile_cropper_dialog.dart';

/// Widget แสดงรูปโปรไฟล์วงกลม รองรับโหมดแก้ไข (isEditable)
/// เมื่อแตะที่รูปจะเปิด Bottom Sheet ให้เลือกถ่ายรูปหรือเลือกจากคลังภาพ แล้วตัดภาพเป็นสัดส่วน 1:1
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.imageBytes,
    this.radius = 28,
    this.isEditable = false,
    this.onImageChanged,
  });

  final Uint8List? imageBytes;
  final double radius;
  final bool isEditable;
  final ValueChanged<Uint8List?>? onImageChanged;


  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    Navigator.pop(context); // Close bottom sheet

    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 90,
      );

      if (file == null) return;

      final Uint8List rawBytes = await file.readAsBytes();

      if (!context.mounted) return;

      // Open 1:1 Crop Dialog
      final Uint8List? croppedBytes = await showDialog<Uint8List>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => ProfileCropperDialog(
          imageBytes: rawBytes,
        ),
      );

      if (croppedBytes != null && onImageChanged != null) {
        onImageChanged!(croppedBytes);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ไม่สามารถเลือกรูปภาพได้'),
            backgroundColor: AppColors.withdrawal,
          ),
        );
      }
    }
  }

  void _showImageSourcePicker(BuildContext context) {
    if (!isEditable) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'เปลี่ยนรูปโปรไฟล์',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.primaryDark,
                  ),
                ),
                title: const Text(
                  'ถ่ายภาพ',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('ใช้กล้องถ่ายรูปใหม่'),
                onTap: () => _pickImage(context, ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: AppColors.primaryDark,
                  ),
                ),
                title: const Text(
                  'เลือกจากคลังภาพ',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('เลือกภาพที่มีอยู่จากอุปกรณ์'),
                onTap: () => _pickImage(context, ImageSource.gallery),
              ),
              if (imageBytes != null) ...[
                const Divider(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.withdrawalLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.withdrawal,
                    ),
                  ),
                  title: const Text(
                    'ลบรูปโปรไฟล์',
                    style: TextStyle(
                      color: AppColors.withdrawal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    if (onImageChanged != null) {
                      onImageChanged!(null);
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double diameter = radius * 2;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main Avatar Circle
        InkWell(
          onTap: isEditable ? () => _showImageSourcePicker(context) : null,
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryLight,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: imageBytes != null
                  ? Image.memory(
                      imageBytes!,
                      width: diameter,
                      height: diameter,
                      fit: BoxFit.cover,
                    )
                  : Icon(
                      Icons.person_rounded,
                      color: AppColors.primaryDark,
                      size: radius * 1.1,
                    ),
            ),
          ),
        ),

        // Camera Badge Icon if Editable
        if (isEditable)
          Positioned(
            right: -2,
            bottom: -2,
            child: GestureDetector(
              onTap: () => _showImageSourcePicker(context),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }
}