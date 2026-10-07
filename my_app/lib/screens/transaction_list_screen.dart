// ==============================================================================
// TransactionListScreen: หน้าจอแสดงรายการธุรกรรมฝาก/ถอนทั้งหมดของผู้ใช้
// ==============================================================================
// รองรับ:
// 1. ดึงรายการธุรกรรมจาก API `/transactions` พร้อมตัวกรอง (ประเภท, เดือน, ปี)
// 2. ตัวกรองข้อมูล (Filter Toolbar)
// 3. การนำทางไปยังฟอร์มเพิ่มรายการใหม่ (Create) หรือแก้ไขรายการเดิม (Edit)
// 4. การลบรายการธุรกรรม (Delete) พร้อม Dialog ยืนยันความปลอดภัย

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_app/models/transaction_model.dart';
import 'package:my_app/screens/transaction_form_screen.dart';
import 'package:my_app/theme/app_colors.dart';
import 'package:my_app/utils/app_api.dart';
import 'package:my_app/widgets/animated_header.dart';
import 'package:my_app/widgets/empty_state.dart';
import 'package:my_app/widgets/transaction_card.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  bool _loading = true;
  List<TransactionModel> _items = [];
  String? _type;    // ตัวกรองประเภท: 'deposit', 'withdraw' หรือ null (ทั้งหมด)
  int? _month;      // ตัวกรองเดือน: 1 - 12 หรือ null (ทุกเดือน)
  int? _year;       // ตัวกรองปี ค.ศ. หรือ null (ทุกปี)

  final List<String> _thaiMonths = const [
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
    _fetchData();
  }

  /// ดึงข้อมูลรายการธุรกรรมจาก API `/transactions`
  /// นำเงื่อนไขตัวกรอง (type, month, year) มาประกอบเป็น Query Parameters
  Future<void> _fetchData() async {
    setState(() => _loading = true);

    try {
      final query = <String, String>{};

      if (_type != null) {
        query['type'] = _type!;
      }

      if (_month != null) {
        query['month'] = '$_month';
      }

      if (_year != null) {
        query['year'] = '$_year';
      }

      final response = await AppAPI.get(
        '/transactions',
        query: query.isNotEmpty ? query : null,
      );

      final json = jsonDecode(response.body);
      final transactionResponse = TransactionResponse.fromJson(json);

      if (!transactionResponse.isError) {
        if (mounted) {
          setState(() {
            _items = transactionResponse.data;
            _loading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _loading = false);
          _showErrorDialog(transactionResponse.errorMessage);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        _showErrorDialog('Unable to connect to the server.');
      }
    }
  }

  /// เปิดหน้าจอ TransactionFormScreen:
  /// - หากไม่ส่ง item -> โหมด "เพิ่มรายการใหม่" (Create Mode)
  /// - หากส่ง item -> โหมด "แก้ไขรายการ" (Edit Mode)
  /// เมื่อบันทึกเสร็จและปิดฟอร์มกลับมา จะสั่ง `_fetchData()` เพื่ออัปเดตรายการล่าสุด
  Future<void> _openForm([TransactionModel? item]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionFormScreen(
          transaction: item,
        ),
      ),
    );

    _fetchData();
  }


  /// แสดง Dialog ยืนยันก่อนดำเนินการลบรายการธุรกรรม
  Future<void> showConfirmDialog(
    BuildContext context,
    VoidCallback onConfirm,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                color: AppColors.withdrawal,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'ยืนยันการลบรายการ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: const Text(
            'คุณต้องการลบรายการนี้ใช่หรือไม่? การกระทำนี้ไม่สามารถย้อนกลับได้',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.withdrawal,
              ),
              child: const Text('ลบรายการ'),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  /// ลบรายการธุรกรรม:
  /// เรียก API DELETE `/transactions/:id` และทำการโหลดข้อมูลใหม่หลังลบสำเร็จ
  Future<void> _delete(TransactionModel item) async {
    await showConfirmDialog(context, () async {
      try {
        final response = await AppAPI.delete('/transactions/${item.id}');
        final json = jsonDecode(response.body);
        final isError = json['isError'] ?? (json['success'] == false);
        final errorMessage = json['errorMessage'] ?? json['message'] ?? '';

        if (!isError) {
          _fetchData();
        } else {
          _showErrorDialog(
            errorMessage.isNotEmpty
                ? errorMessage
                : 'Unable to delete transaction.',
          );
        }
      } catch (e) {
        _showErrorDialog('Unable to connect to the server.');
      }
    });
  }


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
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AnimatedTangKepHeader(
        title: 'รายการฝากถอน',
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              // Top Action & Filters Section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  children: [
                    // Primary Action: Add Transaction Button
                    FilledButton.icon(
                      onPressed: () => _openForm(),
                      icon: const Icon(
                        Icons.add_circle_outline_rounded,
                        size: 20,
                      ),
                      label: const Text('เพิ่มรายการ'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Filter Card
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(
                          color: AppColors.cardBorder,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            // Type filter
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _type,
                                hint: const Text(
                                  'ทุกประเภท',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'deposit',
                                    child: Text('เงินฝาก'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'withdraw',
                                    child: Text('เงินถอน'),
                                  ),
                                ],
                                onChanged: (v) {
                                  setState(() => _type = v);
                                  _fetchData();
                                },
                              ),
                            ),

                            // Month filter
                            DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _month,
                                hint: const Text(
                                  'ทุกเดือน',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                                items: List.generate(
                                  12,
                                  (i) => DropdownMenuItem(
                                    value: i + 1,
                                    child: Text(_thaiMonths[i]),
                                  ),
                                ),
                                onChanged: (v) {
                                  setState(() => _month = v);
                                  _fetchData();
                                },
                              ),
                            ),

                            // Year filter
                            DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _year,
                                hint: const Text(
                                  'ทุกปี',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                                items: List.generate(
                                  6,
                                  (i) => DropdownMenuItem(
                                    value: now.year - i,
                                    child: Text('${now.year - i}'),
                                  ),
                                ),
                                onChanged: (v) {
                                  setState(() => _year = v);
                                  _fetchData();
                                },
                              ),
                            ),

                            // Clear filters
                            if (_type != null ||
                                _month != null ||
                                _year != null)
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _type = null;
                                    _month = null;
                                    _year = null;
                                  });
                                  _fetchData();
                                },
                                icon: const Icon(
                                  Icons.clear_rounded,
                                  size: 16,
                                ),
                                label: const Text('ล้างตัวกรอง'),
                                style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  foregroundColor: AppColors.withdrawal,
                                  textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Transaction List Content
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _fetchData,
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : _items.isEmpty
                          ? ListView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 24,
                              ),
                              children: [
                                Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: const BorderSide(
                                      color: AppColors.cardBorder,
                                      width: 1,
                                    ),
                                  ),
                                  child: EmptyState(
                                    title: 'ยังไม่มีรายการฝากถอน',
                                    message: (_type != null ||
                                            _month != null ||
                                            _year != null)
                                        ? 'ไม่พบรายการที่ตรงกับตัวกรอง ลองเปลี่ยนตัวกรองหรือล้างตัวกรอง'
                                        : 'เริ่มต้นด้วยการเพิ่มรายการเงินฝากหรือถอนเงิน',
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                4,
                                16,
                                96,
                              ),
                              itemCount: _items.length,
                              itemBuilder: (_, index) {
                                return TransactionCard(
                                  item: _items[index],
                                  onTap: () => _openForm(_items[index]),
                                  onDelete: () => _delete(_items[index]),
                                );
                              },
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