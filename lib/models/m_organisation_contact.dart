class OrganisationContactModel {
  final int id;
  final int organisationId;
  final int userId;
  final String? role;
  final ContactUser? user;

  OrganisationContactModel({
    required this.id,
    required this.organisationId,
    required this.userId,
    this.role,
    this.user,
  });

  factory OrganisationContactModel.fromJson(Map<String, dynamic> json) {
    return OrganisationContactModel(
      id: json['id'],
      organisationId: json['organisation_id'],
      userId: json['user_id'],
      role: json['role'],
      user: json['user'] != null ? ContactUser.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "organisation_id": organisationId,
      "user_id": userId,
      "role": role,
      "user": user?.toJson(),
    };
  }
}

class ContactUser {
  final int id;
  final String name;
  final String? email;
  final String? profile;

  ContactUser({
    required this.id,
    required this.name,
    this.email,
    this.profile,
  });

  factory ContactUser.fromJson(Map<String, dynamic> json) {
    return ContactUser(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'],
      profile: json['profile'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "profile": profile,
    };
  }
}
