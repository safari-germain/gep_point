class WalletModel {
  final int id;
  final int userId;
  final double standardBalance;
  final double cashBalance;
  final double notorietyBalance;
  final DateTime updatedAt;

  WalletModel({
    required this.id,
    required this.userId,
    required this.standardBalance,
    required this.cashBalance,
    required this.notorietyBalance,
    required this.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'],
      userId: json['user_id'],
      standardBalance: (json['standard_balance'] as num).toDouble(),
      cashBalance: (json['cash_balance'] as num).toDouble(),
      notorietyBalance: (json['notoriety_balance'] as num).toDouble(),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'standard_balance': standardBalance,
      'cash_balance': cashBalance,
      'notoriety_balance': notorietyBalance,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
