import 'dart:io';
import 'package:dio/dio.dart';
import 'package:gep_point/api_constants.dart';
import 'package:gep_point/models/m_specialized_profile.dart';
import 'package:gep_point/services/s_dio/dio_service.dart';

class CertificationService {
  final Dio _dio = ApiClient().dio;

  /// Récupère les certifications de l'utilisateur connecté
  Future<List<CertificationModel>> fetchMyCertifications() async {
    try {
      final response = await _dio.get(certificationURL);
      if (response.statusCode == 200) {
        final List data = response.data as List? ?? [];
        return data.map((c) => CertificationModel.fromJson(c)).toList();
      }
    } catch (e) {
      print('CertificationService.fetchMyCertifications: $e');
    }
    return [];
  }

  /// Récupère les certifications d'un utilisateur par son ID (public)
  Future<List<CertificationModel>> fetchUserCertifications(int userId) async {
    try {
      final response = await _dio.get(userCertificationURL(userId));
      if (response.statusCode == 200) {
        final List data = response.data as List? ?? [];
        return data.map((c) => CertificationModel.fromJson(c)).toList();
      }
    } catch (e) {
      print('CertificationService.fetchUserCertifications: $e');
    }
    return [];
  }

  /// Crée une nouvelle certification
  Future<CertificationModel?> createCertification({
    required String title,
    required String institution,
    String? description,
    DateTime? grantedAt,
    File? image,
  }) async {
    try {
      final formData = FormData.fromMap({
        'title': title,
        'institution': institution,
        if (description != null && description.isNotEmpty) 'description': description,
        if (grantedAt != null) 'granted_at': grantedAt.toIso8601String().split('T').first,
        if (image != null)
          'image': await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          ),
      });

      final response = await _dio.post(certificationURL, data: formData);
      if (response.statusCode == 201) {
        return CertificationModel.fromJson(response.data);
      }
    } catch (e) {
      print('CertificationService.createCertification: $e');
    }
    return null;
  }

  /// Met à jour une certification
  Future<CertificationModel?> updateCertification({
    required int id,
    String? title,
    String? institution,
    String? description,
    DateTime? grantedAt,
    File? image,
  }) async {
    try {
      final formData = FormData.fromMap({
        if (title != null) 'title': title,
        if (institution != null) 'institution': institution,
        if (description != null) 'description': description,
        if (grantedAt != null) 'granted_at': grantedAt.toIso8601String().split('T').first,
        if (image != null)
          'image': await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          ),
      });

      final response = await _dio.post('$certificationURL/$id', data: formData);
      if (response.statusCode == 200) {
        return CertificationModel.fromJson(response.data);
      }
    } catch (e) {
      print('CertificationService.updateCertification: $e');
    }
    return null;
  }

  /// Supprime une certification
  Future<bool> deleteCertification(int id) async {
    try {
      final response = await _dio.delete('$certificationURL/$id');
      return response.statusCode == 200;
    } catch (e) {
      print('CertificationService.deleteCertification: $e');
      return false;
    }
  }
}
