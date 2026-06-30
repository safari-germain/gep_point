class ConfigurationModel {
  final int id;
  final String key;
  final String value;
  final String type;
  final String? description;

  ConfigurationModel({
    required this.id,
    required this.key,
    required this.value,
    required this.type,
    this.description,
  });

  factory ConfigurationModel.fromJson(Map<String, dynamic> json) {
    return ConfigurationModel(
      id: json['id'],
      key: json['key'],
      value: json['value'].toString(),
      type: json['type'] ?? 'string',
      description: json['description'],
    );
  }

  bool get asBool => value.toLowerCase() == 'true' || value == '1';
  double get asDouble => double.tryParse(value) ?? 0.0;
  int get asInt => int.tryParse(value) ?? 0;
}
