class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.transactionDate,
    required this.description,
    this.createdAt,
  });

  final int id;
  final String type;
  final double amount;
  final DateTime transactionDate;
  final String description;
  final DateTime? createdAt;

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      transactionDate: DateTime.parse(
        json['transaction_date'] as String,
      ),
      description: json['description'] as String? ?? '',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(
              json['created_at'] as String,
            ),
    );
  }

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