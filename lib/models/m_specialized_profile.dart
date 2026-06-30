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
    'start_date': startDate.toIso8601String().split('T')[0],
    'end_date': endDate?.toIso8601String().split('T')[0],
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

class PortfolioModel {
  final int id;
  final int userId;
  final String title;
  final String? description;
  final String? imagePath;
  final String? imageUrl;
  final List<String> images;
  final List<String> imageUrls;
  final String? url;
  final DateTime? createdAt;

  PortfolioModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.imagePath,
    this.imageUrl,
    this.images = const [],
    this.imageUrls = const [],
    this.url,
    this.createdAt,
  });

  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    return PortfolioModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'] ?? '',
      description: json['description'],
      imagePath: json['image_path'],
      imageUrl: json['image_url'],
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      imageUrls: json['image_urls'] != null ? List<String>.from(json['image_urls']) : [],
      url: json['url'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'description': description,
    'image_path': imagePath,
    'image_url': imageUrl,
    'images': images,
    'image_urls': imageUrls,
    'url': url,
  };
}

class CertificationModel {
  final int id;
  final int userId;
  final String title;
  final String institution;
  final String? description;
  final String? imagePath;
  final String? imageUrl;
  final DateTime? grantedAt;

  CertificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.institution,
    this.description,
    this.imagePath,
    this.imageUrl,
    this.grantedAt,
  });

  factory CertificationModel.fromJson(Map<String, dynamic> json) {
    return CertificationModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'] ?? '',
      institution: json['institution'] ?? '',
      description: json['description'],
      imagePath: json['image_path'],
      imageUrl: json['image_url'],
      grantedAt: json['granted_at'] != null ? DateTime.tryParse(json['granted_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'institution': institution,
    'description': description,
    'image_path': imagePath,
    'image_url': imageUrl,
    'granted_at': grantedAt?.toIso8601String(),
  };
}
