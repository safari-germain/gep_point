class ConversionModel {
  final int id;
  final int userId;
  final double standardAmount;
  final double cashAmount;
  final double fee;
  final double rate;
  final DateTime createdAt;

  ConversionModel({
    required this.id,
    required this.userId,
    required this.standardAmount,
    required this.cashAmount,
    required this.fee,
    required this.rate,
    required this.createdAt,
  });

  factory ConversionModel.fromJson(Map<String, dynamic> json) {
    return ConversionModel(
      id: json['id'],
      userId: json['user_id'],
      standardAmount: (json['standard_amount'] as num).toDouble(),
      cashAmount: (json['cash_amount'] as num).toDouble(),
      fee: (json['fee'] as num).toDouble(),
      rate: (json['rate'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'standard_amount': standardAmount,
      'cash_amount': cashAmount,
      'fee': fee,
      'rate': rate,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
