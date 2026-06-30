class WithdrawalModel {
  final int id;
  final double amount;
  final double usdValue;
  final String status;
  final String? paymentMethod;
  final String? paymentDetails;
  final DateTime createdAt;

  WithdrawalModel({
    required this.id,
    required this.amount,
    required this.usdValue,
    required this.status,
    this.paymentMethod,
    this.paymentDetails,
    required this.createdAt,
  });

  factory WithdrawalModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalModel(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      usdValue: (json['usd_value'] as num).toDouble(),
      status: json['status'],
      paymentMethod: json['payment_method'],
      paymentDetails: json['payment_details'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
