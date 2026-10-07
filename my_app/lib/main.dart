// ==============================================================================
// จุดเริ่มต้นการทำงานของแอปพลิเคชัน Flutter (Application Entry Point)
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:my_app/screens/splash_screen.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/utils/app_api.dart';

/// ฟังก์ชันหลัก main() สำหรับเริ่มต้นการทำงานของแอปพลิเคชัน
void main() {
  runApp(
    const PersonalAccountApp(),
  );
}

/// Root Widget ของแอปพลิเคชัน กำหนด Theme, Navigation Key และหน้าเริ่มต้น (Splash Screen)
class PersonalAccountApp extends StatelessWidget {
  const PersonalAccountApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // กำหนด navigatorKey เพื่อให้ AppAPI สามารถสั่งเปลี่ยนหน้า (เช่น เตะกลับไปหน้า Login เมื่อ Token หมดอายุ / 401)
      // ได้จากทุกที่โดยตรง แม้จะอยู่นอก BuildContext ก็ตาม
      navigatorKey: AppAPI.navigatorKey,
      title: 'ตังค์เก็บ TangKep',
      debugShowCheckedModeBanner: false,
      // ธีมรวมของแอปพลิเคชัน (สีหลัก Warm Amber/Gold, Typography, Button Styling)
      theme: AppTheme.lightTheme,
      // หน้าจอเริ่มต้นคือ SplashScreen เพื่อตรวจสอบสถานะ Token/Session ของผู้ใช้
      home: const SplashScreen(),
    );
  }
}