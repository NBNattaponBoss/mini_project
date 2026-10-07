// ==============================================================================
// Home Screen (Dashboard): หน้าจอหลักแสดงภาพรวมทางการเงินของผู้ใช้
// ==============================================================================
// 1. โหลดข้อมูลภาพรวมจาก API `/dashboard` (ยอดคงเหลือ, ยอดฝากรวม, ยอดถอนรวม, 5 รายการล่าสุด)
// 2. แสดง Card ยอดเงินคงเหลือสุทธิ (Balance Hero Card)
// 3. แสดง Card สรุปยอดเงินฝากและเงินถอน
// 4. แสดง Donut Chart สัดส่วนเงินฝากเทียบกับเงินถอน (Financial Ratio)
// 5. แสดงรายการธุรกรรม 5 รายการล่าสุด พร้อมปุ่มกดดูรายการทั้งหมด

import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/login_screen.dart';
import 'package:my_app/models/dashboard_model.dart';
import 'package:my_app/models/transaction_model.dart';
import 'package:my_app/screens/transaction_form_screen.dart';
import 'package:my_app/screens/transaction_list_screen.dart';
import 'package:my_app/theme/app_colors.dart';
import 'package:my_app/utils/app_api.dart';
import 'package:my_app/utils/profile_image_service.dart';
import 'package:my_app/widgets/animated_header.dart';
import 'package:my_app/widgets/empty_state.dart';
import 'package:my_app/widgets/profile_avatar.dart';
import 'package:my_app/widgets/transaction_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onViewAllTransactions});

  final VoidCallback? onViewAllTransactions;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  String _username = '';
  Uint8List? _profileImage;
  DashboardModel? _dashboardData;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  /// ดึงข้อมูล Dashboard จาก API `/dashboard`:
  /// 1. อ่านข้อมูล username และรูปโปรไฟล์จาก SharedPreferences
  /// 2. ส่ง HTTP GET ไปยัง `/dashboard` โดยแนบ Bearer Token อัตโนมัติผ่าน AppAPI
  /// 3. แปลงผลลัพธ์ JSON เป็น DashboardModel และอัปเดต State ให้ UI แสดงผล
  Future<void> _fetchData() async {
    setState(() => _loading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      _username = prefs.getString('username') ?? 'User';
      final image = await ProfileImageService.getProfileImage(_username);

      final response = await AppAPI.get('/dashboard');
      final json = jsonDecode(response.body);
      final dashboardResponse = DashboardResponse.fromJson(json);

      if (!dashboardResponse.isError && dashboardResponse.data != null) {
        if (mounted) {
          setState(() {
            _profileImage = image;
            _dashboardData = dashboardResponse.data;
            _loading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _profileImage = image;
            _loading = false;
          });
          _showErrorDialog(dashboardResponse.errorMessage);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        _showErrorDialog('Unable to connect to the server.');
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

  /// ฟังก์ชันออกจากระบบจากปุ่มบน AppBar
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

  /// จัดรูปแบบตัวเลขจำนวนเงินให้แสดงสัญลักษณ์ ฿ และทศนิยม 2 ตำแหน่ง
  String _money(dynamic value) {
    return NumberFormat.currency(symbol: '฿', decimalDigits: 2)
        .format((value as num?)?.toDouble() ?? 0.0);
  }


  Widget _buildSummaryCard({
    required String label,
    required dynamic value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: AppColors.cardBorder,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _money(value),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<TransactionModel> recent =
        _dashboardData?.recentTransactions ?? [];

    final double totalDeposit = _dashboardData?.totalDeposit ?? 0.0;
    final double totalWithdraw = _dashboardData?.totalWithdraw ?? 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AnimatedTangKepHeader(
        title: 'ตังค์เก็บ (TangKep)',
        titleWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'ตังค์เก็บ (TangKep)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.white,
            ),
            tooltip: 'ออกจากระบบ',
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _fetchData,
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                    children: [
                      // User Greeting & Date
                      Row(
                        children: [
                          ProfileAvatar(
                            imageBytes: _profileImage,
                            radius: 21,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'ยินดีต้อนรับ,',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  _username.isNotEmpty ? _username : 'User',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.cardBorder,
                              ),
                            ),
                            child: Text(
                              DateFormat('d MMM yyyy').format(DateTime.now()),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Balance Hero Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFF59E0B),
                              Color(0xFFD97706),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.28),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'ยอดเงินคงเหลือ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white70,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${_dashboardData?.transactionCount ?? 0} รายการ',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _money(_dashboardData?.balance),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Deposit & Withdrawal Summary Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              label: 'เงินฝาก',
                              value: totalDeposit,
                              icon: Icons.south_west_rounded,
                              color: AppColors.deposit,
                              bgColor: AppColors.depositLight,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildSummaryCard(
                              label: 'เงินถอน',
                              value: totalWithdraw,
                              icon: Icons.north_east_rounded,
                              color: AppColors.withdrawal,
                              bgColor: AppColors.withdrawalLight,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Visual Summary: Financial Ratio Donut (Deposit vs Withdrawal)
                      _buildVisualSummary(totalDeposit, totalWithdraw),

                      const SizedBox(height: 20),

                      // Recent Transactions Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'รายการล่าสุด',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (recent.isNotEmpty)
                            TextButton(
                              onPressed: widget.onViewAllTransactions ??
                                  () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const TransactionListScreen(),
                                      ),
                                    );
                                    _fetchData();
                                  },
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('ดูทั้งหมด'),
                                  SizedBox(width: 2),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 11,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Recent Transactions List or Empty State
                      if (recent.isEmpty)
                        const Card(
                          elevation: 0,
                          child: EmptyState(
                            title: 'ยังไม่มีรายการธุรกรรม',
                            message:
                                'เริ่มต้นบันทึกการเงินของคุณโดยการเพิ่มรายการฝากหรือถอนเงิน',
                          ),
                        )
                      else
                        ...recent.map(
                          (item) => TransactionCard(
                            item: item,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TransactionFormScreen(
                                    transaction: item,
                                  ),
                                ),
                              );
                              _fetchData();
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  /// Circular visual comparing Deposit vs Withdrawal ratio from real DashboardModel data
  Widget _buildVisualSummary(double deposit, double withdraw) {
    final double total = deposit + withdraw;
    final double depositPercent = total > 0 ? (deposit / total) * 100 : 0.0;
    final double withdrawPercent = total > 0 ? (withdraw / total) * 100 : 0.0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: AppColors.cardBorder,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            // Donut Canvas
            SizedBox(
              width: 78,
              height: 78,
              child: CustomPaint(
                painter: _DonutChartPainter(
                  depositRatio: total > 0 ? deposit / total : 0.0,
                  withdrawRatio: total > 0 ? withdraw / total : 0.0,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.pie_chart_rounded,
                        size: 20,
                        color: AppColors.primaryDark,
                      ),
                      Text(
                        '${_dashboardData?.transactionCount ?? 0}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 18),

            // Legend & Breakdown
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'สัดส่วนการเงิน (ฝาก vs ถอน)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Deposit Row
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.deposit,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'เงินฝาก',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${depositPercent.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.deposit,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Withdrawal Row
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.withdrawal,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'เงินถอน',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${withdrawPercent.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.withdrawal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for Donut Chart (Deposit vs Withdrawal)
class _DonutChartPainter extends CustomPainter {
  final double depositRatio;
  final double withdrawRatio;

  const _DonutChartPainter({
    required this.depositRatio,
    required this.withdrawRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 5;
    const strokeWidth = 9.0;

    final basePaint = Paint()
      ..color = AppColors.cardBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Draw background ring
    canvas.drawCircle(center, radius, basePaint);

    if (depositRatio == 0 && withdrawRatio == 0) {
      return;
    }

    final depositPaint = Paint()
      ..color = AppColors.deposit
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final withdrawPaint = Paint()
      ..color = AppColors.withdrawal
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    const startAngle = -math.pi / 2;
    final depositSweep = depositRatio * 2 * math.pi;
    final withdrawSweep = withdrawRatio * 2 * math.pi;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Draw Deposit arc
    if (depositRatio > 0) {
      canvas.drawArc(rect, startAngle, depositSweep, false, depositPaint);
    }

    // Draw Withdrawal arc
    if (withdrawRatio > 0) {
      canvas.drawArc(rect, startAngle + depositSweep, withdrawSweep, false, withdrawPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.depositRatio != depositRatio ||
        oldDelegate.withdrawRatio != withdrawRatio;
  }
}