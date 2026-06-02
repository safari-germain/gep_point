import 'package:gep_point/models/m_organisation.dart';
import 'package:gep_point/models/m_specialized_profile.dart';

class UserModel {
  final int id;
  String name;
  String? prenom;
  String? email;
  String? genre;
  String? phone;
  final String role;
  final String status;
  String? profile;
  String? adresse;
  final int? organisationId;
  final OrganisationModel? organisation;
  int profileLevel;
  List<CompetenceModel> competences;
  List<ExperienceModel> experiences;
  List<PortfolioModel> portfolios;
  List<CertificationModel> certifications;

  UserModel({
    required this.id,
    required this.name,
    this.prenom,
    this.email,
    this.genre,
    this.phone,
    required this.role,
    required this.status,
    this.profile,
    this.adresse,
    this.organisationId,
    this.organisation,
    this.profileLevel = 1,
    List<CompetenceModel>? competences,
    List<ExperienceModel>? experiences,
    List<PortfolioModel>? portfolios,
    List<CertificationModel>? certifications,
  })  : this.competences = competences ?? [],
        this.experiences = experiences ?? [],
        this.portfolios = portfolios ?? [],
        this.certifications = certifications ?? [];

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      prenom: json['prenom'],
      email: json['email'],
      genre: json['genre'],
      phone: json['phone'],
      role: json['role'] ?? 'user',
      status: json['status'] ?? 'active',
      profile: json['profile'],
      adresse: json['adresse'],
      organisationId: json['organisation_id'],
      organisation: json['organisation'] != null ? OrganisationModel.fromJson(json['organisation']) : null,
      profileLevel: json['profile_level'] ?? 1,
      competences: json['competences'] != null 
          ? (json['competences'] as List).map((c) => CompetenceModel.fromJson(c)).toList() 
          : [],
      experiences: json['experiences'] != null 
          ? (json['experiences'] as List).map((e) => ExperienceModel.fromJson(e)).toList() 
          : [],
      portfolios: json['portfolios'] != null
          ? (json['portfolios'] as List).map((p) => PortfolioModel.fromJson(p)).toList()
          : [],
      certifications: json['certifications'] != null
          ? (json['certifications'] as List).map((c) => CertificationModel.fromJson(c)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "prenom": prenom,
      "email": email,
      "genre": genre,
      "phone": phone,
      "role": role,
      "status": status,
      "profile": profile,
      "adresse": adresse,
      "organisation_id": organisationId,
      "organisation": organisation?.toJson(),
      "profile_level": profileLevel,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? prenom,
    String? email,
    String? genre,
    String? phone,
    String? role,
    String? status,
    String? profile,
    String? adresse,
    int? organisationId,
    OrganisationModel? organisation,
    int? profileLevel,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      genre: genre ?? this.genre,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      profile: profile ?? this.profile,
      adresse: adresse ?? this.adresse,
      organisationId: organisationId ?? this.organisationId,
      organisation: organisation ?? this.organisation,
      profileLevel: profileLevel ?? this.profileLevel,
    );
  }
}
