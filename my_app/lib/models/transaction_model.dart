// ==============================================================================
// Data Models: จัดการโครงสร้างข้อมูลรายการธุรกรรม (Transaction Model)
// ==============================================================================

/// Model แทนข้อมูลรายการธุรกรรม 1 รายการ (เงินฝากหรือเงินถอน)
class TransactionModel {
  int id = 0;
  String type = 'deposit';              // 'deposit' (ฝาก) หรือ 'withdraw' (ถอน)
  double amount = 0.0;                  // จำนวนเงิน
  DateTime transactionDate = DateTime.now(); // วันที่ทำรายการ
  String description = '';             // รายละเอียด/บันทึกความจำ
  DateTime? createdAt;                 // วันที่บันทึกลงระบบ (Nullable)

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.transactionDate,
    required this.description,
    this.createdAt,
  });

  /// Factory Constructor แปลงข้อมูล JSON Map จาก API Server ให้เป็น TransactionModel Dart Object
  /// พร้อมทั้งทำ Safe Type Casting และกำหนดค่า Default เพื่อป้องกัน Null Pointer Exception
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: json['type'] as String? ?? 'deposit',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      transactionDate: json['transaction_date'] != null
          ? DateTime.parse(json['transaction_date'] as String)
          : DateTime.now(),
      description: json['description'] as String? ?? '',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'] as String),
    );
  }

  /// แปลง TransactionModel ให้เป็น Map สำหรับส่งไปเป็น JSON Body ใน API Request (Create / Update)
  /// โดยแปลงวันที่ให้อยู่ในฟอร์แมตมาตรฐานสากล ISO YYYY-MM-DD
  Map<String, dynamic> toPayload() {
    return {
      'type': type,
      'amount': amount,
      'transaction_date':
          '${transactionDate.year.toString().padLeft(4, '0')}-'
          '${transactionDate.month.toString().padLeft(2, '0')}-'
          '${transactionDate.day.toString().padLeft(2, '0')}',
      'description': description,
    };
  }
}

/// Model ห่อหุ้ม Response จาก API `/transactions` เพื่อตรวจจับข้อผิดพลาดและส่งต่อข้อมูลรายการ
class TransactionResponse {
  bool isError = false;
  List<TransactionModel> data = [];
  String errorMessage = '';

  TransactionResponse({
    required this.isError,
    required this.data,
    required this.errorMessage,
  });

  /// Factory Constructor แปลง JSON Response จาก Server
  /// รองรับทั้งกรณีที่ `data` ส่งมาเป็น List ของ Transaction หรือเป็น Object เดี่ยว
  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    bool isError = json['isError'] ?? (json['success'] == false);
    String errorMessage = json['errorMessage'] ?? json['message'] ?? '';
    List<TransactionModel> data = [];

    if (json['data'] != null) {
      if (json['data'] is List) {
        data = (json['data'] as List)
            .map((item) => TransactionModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (json['data'] is Map<String, dynamic>) {
        data = [TransactionModel.fromJson(json['data'] as Map<String, dynamic>)];
      }
    }

    return TransactionResponse(
      isError: isError,
      data: data,
      errorMessage: errorMessage,
    );
  }
}