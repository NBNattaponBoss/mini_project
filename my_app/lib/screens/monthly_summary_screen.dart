// ==============================================================================
// MonthlySummaryScreen: หน้าจอรายงานสรุปรายรับ-รายจ่ายประจำเดือน (Monthly Summary)
// ==============================================================================
// 1. ผู้ใช้สามารถเลือกเดือนและปีที่ต้องการดูสรุปผ่าน Modal Date Picker
// 2. เรียก API GET `/summary/monthly?month=X&year=Y`
// 3. แสดงยอดเงินคงเหลือสุทธิ (Balance) ของเดือนนั้น
// 4. แสดงผล Donut Chart แสดงสัดส่วนเงินฝากเทียบกับเงินถอน
// 5. แสดงรายละเอียดแจกแจงเงินฝากและเงินถอน

import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/models/monthly_summary_model.dart';
import 'package:my_app/theme/app_colors.dart';
import 'package:my_app/utils/app_api.dart';
import 'package:my_app/widgets/animated_header.dart';
import 'package:my_app/widgets/empty_state.dart';

class MonthlySummaryScreen extends StatefulWidget {
  const MonthlySummaryScreen({super.key});

  @override
  State<MonthlySummaryScreen> createState() => _MonthlySummaryScreenState();
}

class _MonthlySummaryScreenState extends State<MonthlySummaryScreen> {
  late int _month;
  late int _year;

  bool _loading = true;
  MonthlySummaryModel? _summaryData;

  static const List<String> _thaiMonths = [
    'มกราคม',
    'กุมภาพันธ์',
    'มีนาคม',
    'เมษายน',
    'พฤษภาคม',
    'มิถุนายน',
    'กรกฎาคม',
    'สิงหาคม',
    'กันยายน',
    'ตุลาคม',
    'พฤศจิกายน',
    'ธันวาคม',
  ];

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _month = now.month;
    _year = now.year;

    _fetchData();
  }

  /// ดึงข้อมูลสรุปรายเดือนจาก API `/summary/monthly` ตามเดือนและปีที่เลือก
  Future<void> _fetchData() async {
    setState(() => _loading = true);

    try {
      final response = await AppAPI.get(
        '/summary/monthly',
        query: {
          'month': '$_month',
          'year': '$_year',
        },
      );

      final json = jsonDecode(response.body);
      final summaryResponse = MonthlySummaryResponse.fromJson(json);

      if (!summaryResponse.isError && summaryResponse.data != null) {
        if (mounted) {
          setState(() {
            _summaryData = summaryResponse.data;
            _loading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _loading = false);
          _showErrorDialog(summaryResponse.errorMessage);
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

  /// จัดรูปแบบตัวเลขให้เป็นสกุลเงินบาท (฿)
  String _money(dynamic value) {
    return NumberFormat.currency(
      symbol: '฿',
      decimalDigits: 2,
    ).format((value as num?)?.toDouble() ?? 0.0);
  }

  /// เปิด Custom Dialog สำหรับเลือกเดือนและปี พ.ศ.
  Future<void> _openMonthYearPicker() async {
    final result = await showDialog<Map<String, int>>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return _MonthYearPickerDialog(
          selectedMonth: _month,
          selectedYear: _year,
          thaiMonths: _thaiMonths,
        );
      },
    );

    if (result != null && mounted) {
      final newMonth = result['month'] ?? _month;
      final newYear = result['year'] ?? _year;

      if (newMonth != _month || newYear != _year) {
        setState(() {
          _month = newMonth;
          _year = newYear;
        });
        _fetchData();
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final double totalDeposit = _summaryData?.totalDeposit ?? 0.0;
    final double totalWithdraw = _summaryData?.totalWithdraw ?? 0.0;
    final double balance = _summaryData?.balance ?? 0.0;
    final bool hasData = totalDeposit > 0 || totalWithdraw > 0;
    final int thaiYear = _year + 543;
    final String currentMonthText = '${_thaiMonths[_month - 1]} $thaiYear';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AnimatedTangKepHeader(
        title: 'สรุป',
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _fetchData,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                // 1. Mobile Finance App Header Bar (Title & Month/Year Selector Trigger)
                _buildHeaderSelector(currentMonthText),

                const SizedBox(height: 16),

                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(64),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else ...[
                  // 2. Large Balance Hero Card (Balance + Deposit & Withdrawal breakdown)
                  _buildBalanceHeroCard(
                    balance: balance,
                    totalDeposit: totalDeposit,
                    totalWithdraw: totalWithdraw,
                    periodText: currentMonthText,
                  ),

                  const SizedBox(height: 16),

                  // 3. Financial Ratio Donut Chart (เงินฝาก vs เงินถอน)
                  _buildVisualRatioCard(
                    deposit: totalDeposit,
                    withdraw: totalWithdraw,
                  ),

                  const SizedBox(height: 16),

                  // 4. Monthly Detail Card (รายละเอียดเดือน)
                  _buildMonthlyDetailCard(
                    deposit: totalDeposit,
                    withdraw: totalWithdraw,
                    balance: balance,
                  ),

                  if (!hasData) ...[
                    const SizedBox(height: 16),
                    const Card(
                      elevation: 0,
                      child: EmptyState(
                        title: 'ยังไม่มีรายการในเดือนนี้',
                        message:
                            'ลองเพิ่มรายการฝากหรือถอนเพื่อดูสรุปของเดือนนี้',
                        icon: Icons.calendar_today_outlined,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Top Month/Year selector trigger bar
  Widget _buildHeaderSelector(String currentMonthText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cardBorder,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                color: AppColors.primaryDark,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'รอบเดือนที่เลือก',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: _openMonthYearPicker,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryLight,
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentMonthText,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_drop_down_rounded,
                    color: AppColors.primaryDark,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Large Balance Hero Card with prominent balance and embedded Deposit/Withdrawal metrics
  Widget _buildBalanceHeroCard({
    required double balance,
    required double totalDeposit,
    required double totalWithdraw,
    required String periodText,
  }) {
    return Container(
      width: double.infinity,
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'คงเหลือ',
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
                  periodText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _money(balance),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Deposit summary
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.deposit.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.south_west_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'เงินฝาก',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              '+${_money(totalDeposit)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                const SizedBox(width: 12),
                // Withdrawal summary
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.withdrawal.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.north_east_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'เงินถอน',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              '-${_money(totalWithdraw)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Visual ratio card using Donut Chart (เงินฝาก vs เงินถอน)
  Widget _buildVisualRatioCard({
    required double deposit,
    required double withdraw,
  }) {
    final double total = deposit + withdraw;
    final bool hasData = total > 0;
    final double depositRatio = hasData ? (deposit / total) : 0.0;
    final double withdrawRatio = hasData ? (withdraw / total) : 0.0;
    final double depositPercent = hasData ? depositRatio * 100 : 0.0;
    final double withdrawPercent = hasData ? withdrawRatio * 100 : 0.0;

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
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.pie_chart_rounded,
                  color: AppColors.primaryDark,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'สัดส่วนฝาก / ถอน',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!hasData)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.cardBorder,
                            width: 6,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.pie_chart_outline_rounded,
                            color: AppColors.textMuted,
                            size: 26,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'ยังไม่มีข้อมูลของเดือนนี้',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Row(
                children: [
                  // Donut Canvas
                  SizedBox(
                    width: 84,
                    height: 84,
                    child: CustomPaint(
                      painter: _MonthlyDonutChartPainter(
                        depositRatio: depositRatio,
                        withdrawRatio: withdrawRatio,
                      ),
                      child: Center(
                        child: Text(
                          '${depositPercent.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.deposit,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Legend and Percentage Breakdown
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Deposit Legend
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.deposit,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'เงินฝาก',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${depositPercent.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.deposit,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Withdrawal Legend
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.withdrawal,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'เงินถอน',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${withdrawPercent.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
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
          ],
        ),
      ),
    );
  }

  /// Monthly Detail Card showing deposit, withdrawal, and balance
  Widget _buildMonthlyDetailCard({
    required double deposit,
    required double withdraw,
    required double balance,
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
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.primaryDark,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'รายละเอียดเดือน',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Deposit detail row
            _buildDetailRow(
              title: 'เงินฝาก',
              amount: deposit,
              amountPrefix: '+',
              amountColor: AppColors.deposit,
              icon: Icons.south_west_rounded,
              iconBgColor: AppColors.depositLight,
              iconColor: AppColors.deposit,
            ),
            const Divider(height: 20, color: AppColors.cardBorder),
            // Withdrawal detail row
            _buildDetailRow(
              title: 'เงินถอน',
              amount: withdraw,
              amountPrefix: '-',
              amountColor: AppColors.withdrawal,
              icon: Icons.north_east_rounded,
              iconBgColor: AppColors.withdrawalLight,
              iconColor: AppColors.withdrawal,
            ),
            const Divider(height: 20, color: AppColors.cardBorder),
            // Balance detail row
            _buildDetailRow(
              title: 'คงเหลือ',
              amount: balance,
              amountPrefix: '',
              amountColor: AppColors.textPrimary,
              icon: Icons.account_balance_wallet_rounded,
              iconBgColor: AppColors.primaryContainer,
              iconColor: AppColors.primaryDark,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String title,
    required double amount,
    required String amountPrefix,
    required Color amountColor,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    bool isBold = false,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          '$amountPrefix${_money(amount)}',
          style: TextStyle(
            color: amountColor,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

/// Custom painter for Donut Chart (Deposit vs Withdrawal) in Monthly Summary
class _MonthlyDonutChartPainter extends CustomPainter {
  final double depositRatio;
  final double withdrawRatio;

  const _MonthlyDonutChartPainter({
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
  bool shouldRepaint(covariant _MonthlyDonutChartPainter oldDelegate) {
    return oldDelegate.depositRatio != depositRatio ||
        oldDelegate.withdrawRatio != withdrawRatio;
  }
}

/// Dedicated TangKep Pop-up / Modal Month & Year Picker Dialog
class _MonthYearPickerDialog extends StatefulWidget {
  const _MonthYearPickerDialog({
    required this.selectedMonth,
    required this.selectedYear,
    required this.thaiMonths,
  });

  final int selectedMonth;
  final int selectedYear;
  final List<String> thaiMonths;

  @override
  State<_MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<_MonthYearPickerDialog> {
  late int _tempMonth;
  late int _tempYear;

  @override
  void initState() {
    super.initState();
    _tempMonth = widget.selectedMonth;
    _tempYear = widget.selectedYear;
  }

  void _previousYear() {
    setState(() {
      _tempYear -= 1;
    });
  }

  void _nextYear() {
    setState(() {
      _tempYear += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final int thaiYear = _tempYear + 543;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        color: AppColors.primaryDark,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'เลือกเดือน',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Year Selector Stepper (< 2569 >)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: _previousYear,
                        icon: const Icon(
                          Icons.chevron_left_rounded,
                          color: AppColors.textPrimary,
                        ),
                        tooltip: 'ปีก่อนหน้า',
                      ),
                      Text(
                        '$thaiYear',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: _nextYear,
                        icon: const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textPrimary,
                        ),
                        tooltip: 'ปีถัดไป',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 12 Months Grid (2 columns x 6 rows)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.7,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final int monthIndex = index + 1;
                    final String monthName = widget.thaiMonths[index];
                    final bool isSelected = _tempMonth == monthIndex;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _tempMonth = monthIndex;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryDark
                                : AppColors.cardBorder,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                monthName,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.check_rounded,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Action Buttons (Cancel & Confirm)
                Row(
                  children: [
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        textStyle: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      child: const Text('ยกเลิก'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(context, {
                          'month': _tempMonth,
                          'year': _tempYear,
                        });
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'ยืนยัน',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
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