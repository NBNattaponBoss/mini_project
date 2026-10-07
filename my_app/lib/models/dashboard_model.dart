// ==============================================================================
// Data Models: จัดการโครงสร้างข้อมูลสรุปหน้าภาพรวม (Dashboard Model)
// ==============================================================================

import 'package:my_app/models/transaction_model.dart';

/// Model แทนข้อมูลภาพรวมทางการเงินของหน้า Dashboard
class DashboardModel {
  double balance = 0.0;                       // ยอดเงินคงเหลือสุทธิ
  double totalDeposit = 0.0;                  // ยอดเงินฝากรวมทั้งหมด
  double totalWithdraw = 0.0;                 // ยอดเงินถอนรวมทั้งหมด
  int transactionCount = 0;                   // จำนวนรายการทั้งหมด
  List<TransactionModel> recentTransactions = []; // รายการธุรกรรม 5 รายการล่าสุด

  DashboardModel({
    required this.balance,
    required this.totalDeposit,
    required this.totalWithdraw,
    required this.transactionCount,
    required this.recentTransactions,
  });

  /// Factory Constructor แปลงข้อมูล JSON Map จาก API `/dashboard` เป็น DashboardModel
  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      totalDeposit: (json['totalDeposit'] as num?)?.toDouble() ?? 0.0,
      totalWithdraw: (json['totalWithdraw'] as num?)?.toDouble() ?? 0.0,
      transactionCount: (json['transactionCount'] as num?)?.toInt() ?? 0,
      recentTransactions: json['recentTransactions'] != null
          ? (json['recentTransactions'] as List)
              .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

/// Model ห่อหุ้ม Response จาก API `/dashboard`
class DashboardResponse {
  bool isError = false;
  DashboardModel? data;
  String errorMessage = '';

  DashboardResponse({
    required this.isError,
    this.data,
    required this.errorMessage,
  });

  /// Factory Constructor แปลง JSON Response จาก API พร้อมแยกสถานะ Error และ Data
  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    bool isError = json['isError'] ?? (json['success'] == false);
    String errorMessage = json['errorMessage'] ?? json['message'] ?? '';
    DashboardModel? data;

    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      data = DashboardModel.fromJson(json['data'] as Map<String, dynamic>);
    }

    return DashboardResponse(
      isError: isError,
      data: data,
      errorMessage: errorMessage,
    );
  }
}

