class QrPayloadModel {
  final String type;
  final int id;

  QrPayloadModel({
    required this.type,
    required this.id,
  });

  factory QrPayloadModel.fromJson(Map<String, dynamic> json) {
    return QrPayloadModel(
      type: json['type'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
    };
  }
}
