class OrganisationModel {
  final int id;
  final String name;
  final String? description;
  final String? image;
  final int? adminUserId;
  final int? validatorUserId;

  OrganisationModel({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.adminUserId,
    this.validatorUserId,
  });

  factory OrganisationModel.fromJson(Map<String, dynamic> json) {
    return OrganisationModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      image: json['image'],
      adminUserId: json['admin_user_id'],
      validatorUserId: json['validator_user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "image": image,
      "admin_user_id": adminUserId,
      "validator_user_id": validatorUserId,
    };
  }
}
