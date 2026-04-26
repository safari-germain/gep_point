class PointSaleModel {
  final int id;
  final int organisationId;
  final int? marketerUserId;
  final String pointType;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? organisation;
  final Map<String, dynamic>? marketer;

  PointSaleModel({
    required this.id,
    required this.organisationId,
    this.marketerUserId,
    required this.pointType,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.organisation,
    this.marketer,
  });

  factory PointSaleModel.fromJson(Map<String, dynamic> json) {
    return PointSaleModel(
      id: json['id'],
      organisationId: json['organisation_id'],
      marketerUserId: json['marketer_user_id'] != null ? json['marketer_user_id'] : null,
      pointType: json['point_type'],
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unit_price'] is String)
          ? double.parse(json['unit_price'])
          : (json['unit_price'] as num).toDouble(),
      totalPrice: (json['total_price'] is String)
          ? double.parse(json['total_price'])
          : (json['total_price'] as num).toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      organisation: json['organisation'],
      marketer: json['marketer'],
    );
  }
}