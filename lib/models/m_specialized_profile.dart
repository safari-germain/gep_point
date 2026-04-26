class CompetenceModel {
  final int id;
  final String name;
  final String slug;

  CompetenceModel({required this.id, required this.name, required this.slug});

  factory CompetenceModel.fromJson(Map<String, dynamic> json) {
    return CompetenceModel(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
  };
}

class ExperienceModel {
  final int? id;
  final String companyName;
  final String jobTitle;
  final String? description;
  final DateTime startDate;
  final DateTime? endDate;

  ExperienceModel({
    this.id,
    required this.companyName,
    required this.jobTitle,
    this.description,
    required this.startDate,
    this.endDate,
  });

  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      id: json['id'],
      companyName: json['company_name'],
      jobTitle: json['job_title'],
      description: json['description'],
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'company_name': companyName,
    'job_title': jobTitle,
    'description': description,
    'start_date': startDate.toIso8601String(),
    'end_date': endDate?.toIso8601String(),
  };
}

class ConfigurationModel {
  final int id;
  final String key;
  final String value;
  final String type;

  ConfigurationModel({
    required this.id,
    required this.key,
    required this.value,
    required this.type,
  });

  factory ConfigurationModel.fromJson(Map<String, dynamic> json) {
    return ConfigurationModel(
      id: json['id'],
      key: json['key'],
      value: json['value'].toString(),
      type: json['type'] ?? 'string',
    );
  }
}
