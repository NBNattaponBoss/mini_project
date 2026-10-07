// ==============================================================================
// Data Models: จัดการโครงสร้างข้อมูลสรุปยอดรายเดือน (Monthly Summary Model)
// ==============================================================================

/// Model แทนข้อมูลสรุปยอดการเงินประจำเดือน
class MonthlySummaryModel {
  double totalDeposit = 0.0;    // ยอดเงินฝากรวมประจำเดือน
  double totalWithdraw = 0.0;   // ยอดเงินถอนรวมประจำเดือน
  double balance = 0.0;         // ยอดคงเหลือสุทธิของเดือน (totalDeposit - totalWithdraw)

  MonthlySummaryModel({
    required this.totalDeposit,
    required this.totalWithdraw,
    required this.balance,
  });

  /// Factory Constructor แปลงข้อมูล JSON Map จาก API `/summary/monthly` เป็น MonthlySummaryModel
  factory MonthlySummaryModel.fromJson(Map<String, dynamic> json) {
    return MonthlySummaryModel(
      totalDeposit: (json['totalDeposit'] as num?)?.toDouble() ?? 0.0,
      totalWithdraw: (json['totalWithdraw'] as num?)?.toDouble() ?? 0.0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Model ห่อหุ้ม Response จาก API `/summary/monthly`
class MonthlySummaryResponse {
  bool isError = false;
  MonthlySummaryModel? data;
  String errorMessage = '';

  MonthlySummaryResponse({
    required this.isError,
    this.data,
    required this.errorMessage,
  });

  /// Factory Constructor แปลง JSON Response จาก Server
  factory MonthlySummaryResponse.fromJson(Map<String, dynamic> json) {
    bool isError = json['isError'] ?? (json['success'] == false);
    String errorMessage = json['errorMessage'] ?? json['message'] ?? '';
    MonthlySummaryModel? data;

    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      data = MonthlySummaryModel.fromJson(json['data'] as Map<String, dynamic>);
    }

    return MonthlySummaryResponse(
      isError: isError,
      data: data,
      errorMessage: errorMessage,
    );
  }
}

