class TransactionModel {
  final int id;
  final String type; // transfer, conversion, distribution
  final String pointType; // marchand, notoriété, standard
  final double amount;
  final double fee;
  final String status; // pending, completed, failed
  final DateTime createdAt;
  final String? receiverName; // Nom du destinataire

  TransactionModel({
    required this.id,
    required this.type,
    required this.pointType,
    required this.amount,
    required this.fee,
    required this.status,
    required this.createdAt,
    this.receiverName,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['transaction_id'],
      type: json['type'],
      pointType: json['point_type'] ?? 'standard',
      amount: (json['amount'] is String)
          ? double.tryParse(json['amount']) ?? 0
          : (json['amount'] as num).toDouble(),
      fee: (json['fee'] is String)
          ? double.tryParse(json['fee']) ?? 0
          : (json['fee'] as num).toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      receiverName: json['to'] != null ? json['to']['name'] : null,
    );
  }
}