// ==============================================================================
// MainShell: หน้าจอหลักและโครงสร้าง Navigation หลักของแอปพลิเคชัน
// ==============================================================================
// รวม Tab ต่างๆ เข้าด้วยกันผ่าน IndexedStack และ Bottom Navigation Bar:
// 1. Tab 0: HomeScreen (ภาพรวม / Dashboard)
// 2. Tab 1: TransactionListScreen (รายการธุรกรรมทั้งหมด)
// 3. Center FAB: ปุ่มลัดเพิ่มรายการธุรกรรม (TransactionFormScreen)
// 4. Tab 2: MonthlySummaryScreen (สรุปยอดรายเดือน)
// 5. Tab 3: _MoreScreen (เมนูเพิ่มเติมและออกจากระบบ)

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:my_app/login_screen.dart';
import 'package:my_app/screens/home_screen.dart';
import 'package:my_app/screens/monthly_summary_screen.dart';
import 'package:my_app/screens/transaction_form_screen.dart';
import 'package:my_app/screens/transaction_list_screen.dart';
import 'package:my_app/theme/app_colors.dart';
import 'package:my_app/utils/profile_image_service.dart';
import 'package:my_app/widgets/animated_header.dart';
import 'package:my_app/widgets/profile_avatar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;
  // _refreshKey ใช้สำหรับสั่ง Rebuild หน้าจอภายใน IndexedStack เมื่อมีการเพิ่ม/แก้ไข/ลบข้อมูลธุรกรรม
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  /// รีเฟรชข้อมูลทุกแท็บเมื่อกลับมาจากการเพิ่มหรือแก้ไขรายการ
  void _refreshAll() {
    setState(() {
      _refreshKey++;
    });
  }

  /// เปิดหน้าจอสำหรับเพิ่มรายการเงินฝาก/เงินถอนใหม่
  Future<void> _openAddTransaction() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TransactionFormScreen(),
      ),
    );
    _refreshAll();
  }

  @override
  Widget build(BuildContext context) {
    // รายการหน้าจอทั้งหมดที่จะแสดงผลภายใน IndexedStack
    final List<Widget> screens = [
      HomeScreen(
        key: ValueKey('home_$_refreshKey'),
        onViewAllTransactions: () => _onTabTapped(1),
      ),
      TransactionListScreen(
        key: ValueKey('tx_list_$_refreshKey'),
      ),
      MonthlySummaryScreen(
        key: ValueKey('summary_$_refreshKey'),
      ),
      _MoreScreen(
        key: ValueKey('more_$_refreshKey'),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      // การใช้ IndexedStack:
      // ช่วยให้สามารถสลับระหว่างแต่ละหน้าได้โดยยังคง State เดิมของแต่ละแท็บไว้
      // เช่น ตำแหน่งการ Scroll, ข้อมูลที่โหลดไว้ หรือตัวกรองที่เลือกไว้ ไม่ถูก Reset ใหม่
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      // ปุ่ม Floating Action Button (FAB) ตรงกลางสำหรับเปิดหน้าเพิ่มรายการธุรกรรมด่วน
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTransaction,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        tooltip: 'เพิ่มรายการ',
        child: const Icon(
          Icons.add_rounded,
          size: 32,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // แถบ Bottom Navigation Bar พร้อมรอยเว้าตรงกลาง (Notched Bar) สำหรับวาง FAB
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: AppColors.cardBorder,
              width: 1,
            ),
          ),
        ),
        child: BottomAppBar(
          elevation: 0,
          color: Colors.white,
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Tab 1: ภาพรวม
              _buildNavItem(
                index: 0,
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard_rounded,
                label: 'ภาพรวม',
              ),

              // Tab 2: รายการ
              _buildNavItem(
                index: 1,
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long_rounded,
                label: 'รายการ',
              ),

              // เว้นช่องว่างตรงกลางสำหรับปุ่ม FAB
              const SizedBox(width: 44),

              // Tab 3: สรุป
              _buildNavItem(
                index: 2,
                icon: Icons.pie_chart_outline_rounded,
                activeIcon: Icons.pie_chart_rounded,
                label: 'สรุป',
              ),

              // Tab 4: เพิ่มเติม
              _buildNavItem(
                index: 3,
                icon: Icons.more_horiz_rounded,
                activeIcon: Icons.more_horiz_rounded,
                label: 'เพิ่มเติม',
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final bool isSelected = _currentIndex == index;
    final Color color = isSelected ? AppColors.primaryDark : AppColors.textSecondary;

    return InkWell(
      onTap: () => _onTabTapped(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: color,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// หน้าจอแท็บ "เพิ่มเติม" (More Screen)
/// แสดงข้อมูลผู้ใช้งาน, รูปโปรไฟล์ 1:1, รายละเอียดแอปพลิเคชัน และปุ่มออกจากระบบ (Logout)
class _MoreScreen extends StatefulWidget {
  const _MoreScreen({super.key});

  @override
  State<_MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<_MoreScreen> {
  String _username = '';
  Uint8List? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  /// โหลดชื่อผู้ใช้และรูปโปรไฟล์ที่บันทึกไว้ใน Local Storage
  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString('username') ?? 'User';
    final image = await ProfileImageService.getProfileImage(user);
    if (mounted) {
      setState(() {
        _username = user;
        _profileImage = image;
      });
    }
  }

  /// จัดการเมื่อผู้ใช้อัปโหลดหรือลบรูปภาพโปรไฟล์ใหม่
  Future<void> _handleImageChanged(Uint8List? newBytes) async {
    if (newBytes != null) {
      await ProfileImageService.saveProfileImage(_username, newBytes);
    } else {
      await ProfileImageService.deleteProfileImage(_username);
    }
    if (mounted) {
      setState(() {
        _profileImage = newBytes;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newBytes != null
                ? 'อัปเดตรูปโปรไฟล์เรียบร้อยแล้ว'
                : 'ลบรูปโปรไฟล์เรียบร้อยแล้ว',
          ),
          backgroundColor: AppColors.primaryDark,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// ฟังก์ชันออกจากระบบ (Logout Flow):
  /// 1. แสดง Confirmation Dialog ยืนยันความตั้งใจของผู้ใช้
  /// 2. ลบ Access Token และ Username ออกจาก SharedPreferences บนเครื่อง
  ///    (เนื่องจากระบบใช้ Stateless JWT และไม่มี Server-side Token Revocation Table
  ///     การ Logout ฝั่ง Client ทำได้โดยการลบ Token ออกจาก Local Storage
  ///     เพื่อไม่ให้ Client ส่ง Token ดังกล่าวไปใน Authorization Header ได้อีก)
  /// 3. นำทางผู้ใช้กลับไปยัง LoginScreen และล้าง Navigation Stack ทั้งหมด
  Future<void> _logout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('ยืนยันออกจากระบบ'),
        content: const Text('คุณต้องการออกจากระบบหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.withdrawal,
            ),
            child: const Text('ออกจากระบบ'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // ลบ Token ออกจาก Local SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('username');

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AnimatedTangKepHeader(
        title: 'เพิ่มเติม',
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              // User Account Info Card with Editable 1:1 Profile Avatar
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(
                    color: AppColors.cardBorder,
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      ProfileAvatar(
                        imageBytes: _profileImage,
                        radius: 32,
                        isEditable: true,
                        onImageChanged: _handleImageChanged,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _username.isNotEmpty ? _username : 'User',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'แตะที่รูปเพื่อเปลี่ยนรูปโปรไฟล์ (1:1)',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Application Information Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(
                    color: AppColors.cardBorder,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.cardBorder,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      title: const Text(
                        'แอปพลิเคชัน',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        'ตังค์เก็บ (TangKep) v1.0',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(
                        Icons.shield_outlined,
                        color: AppColors.textSecondary,
                      ),
                      title: const Text(
                        'ระบบจัดการบัญชีเงินฝากส่วนตัว',
                        style: TextStyle(fontSize: 14),
                      ),
                      subtitle: const Text(
                        'Personal Deposit Account Management',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Logout Action Button
              OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.withdrawal,
                ),
                label: const Text(
                  'ออกจากระบบ',
                  style: TextStyle(
                    color: AppColors.withdrawal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(
                    color: AppColors.withdrawal,
                    width: 1.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}