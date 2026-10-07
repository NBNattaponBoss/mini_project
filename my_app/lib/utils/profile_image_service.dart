// ==============================================================================
// ProfileImageService: บริการจัดการบันทึกและดึงรูปโปรไฟล์ผู้ใช้แบบ Local Storage
// ==============================================================================
// จัดเก็บรูปโปรไฟล์ใน SharedPreferences ในรูปแบบ Base64 String โดยแยกตาม username
// ทำให้แต่ละบัญชีผู้ใช้มีรูปโปรไฟล์เป็นของตนเองบนเครื่องอุปกรณ์

import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

/// Service สำหรับจัดการรูปภาพโปรไฟล์ผู้ใช้ใน Local Storage (SharedPreferences)
class ProfileImageService {
  /// สร้าง Key สำหรับจัดเก็บใน SharedPreferences โดยแยกตามชื่อผู้ใช้
  static String _key(String username) => 'profile_photo_${username.trim()}';

  /// ดึงข้อมูลรูปภาพโปรไฟล์ (Uint8List bytes) ของผู้ใช้ที่ระบุ
  /// คืนค่าเป็น null หากยังไม่มีการตั้งรูปโปรไฟล์หรือเกิดข้อผิดพลาด
  static Future<Uint8List?> getProfileImage(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final base64String = prefs.getString(_key(username));
      if (base64String != null && base64String.isNotEmpty) {
        // ถอดรหัสจาก Base64 String กลับมาเป็น Byte Array (Uint8List)
        return base64Decode(base64String);
      }
    } catch (_) {
      // กรณีเกิด Error ให้ fallback คืนค่า null เพื่อแสดงรูป Avatar พื้นฐาน
    }
    return null;
  }

  /// บันทึกข้อมูลรูปภาพโปรไฟล์ลงใน SharedPreferences โดยเข้ารหัสเป็น Base64 String
  static Future<bool> saveProfileImage(
    String username,
    Uint8List imageBytes,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final base64String = base64Encode(imageBytes);
      return await prefs.setString(_key(username), base64String);
    } catch (_) {
      return false;
    }
  }

  /// ลบรูปโปรไฟล์ของผู้ใช้ที่ระบุออกจาก SharedPreferences
  static Future<bool> deleteProfileImage(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_key(username));
    } catch (_) {
      return false;
    }
  }
}