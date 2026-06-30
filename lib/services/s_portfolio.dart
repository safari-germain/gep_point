import 'dart:io';
import 'package:dio/dio.dart';
import 'package:gep_point/api_constants.dart';
import 'package:gep_point/models/m_specialized_profile.dart';
import 'package:gep_point/services/s_dio/dio_service.dart';

class PortfolioService {
  final Dio _dio = ApiClient().dio;

  /// Récupère les projets portfolio de l'utilisateur connecté
  Future<List<PortfolioModel>> fetchMyPortfolio() async {
    try {
      final response = await _dio.get(portfolioURL);
      if (response.statusCode == 200) {
        final List data = response.data as List? ?? [];
        return data.map((p) => PortfolioModel.fromJson(p)).toList();
      }
    } catch (e) {
      print('PortfolioService.fetchMyPortfolio: $e');
    }
    return [];
  }

  /// Récupère les projets portfolio d'un utilisateur par son ID (public)
  Future<List<PortfolioModel>> fetchUserPortfolio(int userId) async {
    try {
      final response = await _dio.get(userPortfolioURL(userId));
      if (response.statusCode == 200) {
        final List data = response.data as List? ?? [];
        return data.map((p) => PortfolioModel.fromJson(p)).toList();
      }
    } catch (e) {
      print('PortfolioService.fetchUserPortfolio: $e');
    }
    return [];
  }

  /// Crée un nouveau projet portfolio
  Future<PortfolioModel?> createProject({
    required String title,
    String? description,
    String? url,
    List<File>? images,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'title': title,
        if (description != null && description.isNotEmpty) 'description': description,
        if (url != null && url.isNotEmpty) 'url': url,
      };

      if (images != null && images.isNotEmpty) {
        List<MultipartFile> files = [];
        for (var img in images) {
          files.add(await MultipartFile.fromFile(
            img.path,
            filename: img.path.split('/').last,
          ));
        }
        data['images[]'] = files;
      }

      final formData = FormData.fromMap(data);
      final response = await _dio.post(portfolioURL, data: formData);
      if (response.statusCode == 201) {
        return PortfolioModel.fromJson(response.data);
      }
    } catch (e) {
      print('PortfolioService.createProject: $e');
    }
    return null;
  }

  /// Met à jour un projet portfolio existant
  Future<PortfolioModel?> updateProject({
    required int id,
    String? title,
    String? description,
    String? url,
    List<File>? images,
  }) async {
    try {
      final Map<String, dynamic> data = {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (url != null) 'url': url,
      };

      if (images != null && images.isNotEmpty) {
        List<MultipartFile> files = [];
        for (var img in images) {
          files.add(await MultipartFile.fromFile(
            img.path,
            filename: img.path.split('/').last,
          ));
        }
        data['images[]'] = files;
      }

      final formData = FormData.fromMap(data);
      final response = await _dio.post('$portfolioURL/$id', data: formData);
      if (response.statusCode == 200) {
        return PortfolioModel.fromJson(response.data);
      }
    } catch (e) {
      print('PortfolioService.updateProject: $e');
    }
    return null;
  }

  /// Supprime un projet portfolio
  Future<bool> deleteProject(int id) async {
    try {
      final response = await _dio.delete('$portfolioURL/$id');
      return response.statusCode == 200;
    } catch (e) {
      print('PortfolioService.deleteProject: $e');
      return false;
    }
  }
}
