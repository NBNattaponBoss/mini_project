// ==============================================================================
// AppColors: กำหนดชุดสีมาตรฐานของแอปพลิเคชัน (Design System Color Palette)
// ==============================================================================

import 'package:flutter/material.dart';

/// ชุดสีมาตรฐานสำหรับแอปพลิเคชันบัญชีการเงิน "ตังค์เก็บ (TangKep)"
class AppColors {
  // โทนสีหลักของแบรนด์: Warm Gold / Amber
  static const Color primary = Color(0xFFF59E0B);
  static const Color primaryDark = Color(0xFFD97706);
  static const Color primaryLight = Color(0xFFFEF3C7);
  static const Color primaryContainer = Color(0xFFFFFBEB);

  // สีพื้นหลังและพื้นผิว (Backgrounds & Surface)
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFE2E8F0);

  // สีของข้อความ (Typography Colors)
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // สีแสดงผลทางการเงิน (Financial Indicators)
  static const Color deposit = Color(0xFF10B981);       // เงินฝาก: สีเขียวมรกต (Emerald Green)
  static const Color depositLight = Color(0xFFD1FAE5);
  static const Color withdrawal = Color(0xFFEF4444);    // เงินถอน: สีแดง (Red)
  static const Color withdrawalLight = Color(0xFFFEE2E2);

  // สีของแบบฟอร์มและ Input Fields
  static const Color inputBorder = Color(0xFFCBD5E1);
  static const Color inputFocusedBorder = Color(0xFFF59E0B);
  static const Color inputFill = Colors.white;
}