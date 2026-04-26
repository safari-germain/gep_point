import 'package:dio/dio.dart';
import 'package:gep_point/api_constants.dart';
import 'package:gep_point/models/m_specialized_profile.dart';
import 'package:gep_point/services/s_dio/dio_service.dart';

class ProfileUpgradeService {
  final Dio _dio = ApiClient().dio;

  /// Récupère toutes les compétences disponibles au backend
  Future<List<CompetenceModel>> fetchCompetences() async {
    try {
      final response = await _dio.get(competencesURL);
      if (response.statusCode == 200) {
        return (response.data as List).map((c) => CompetenceModel.fromJson(c)).toList();
      }
    } catch (e) {
      print("Erreur fetchCompetences: $e");
    }
    return [];
  }

  /// Récupère la configuration des prix pour les upgrades
  Future<List<ConfigurationModel>> fetchConfigs() async {
    try {
      final response = await _dio.get(configsURL);
      if (response.statusCode == 200) {
        return (response.data as List).map((c) => ConfigurationModel.fromJson(c)).toList();
      }
    } catch (e) {
      print("Erreur fetchConfigs: $e");
    }
    return [];
  }

  /// Demande une montée de niveau
  Future<Map<String, dynamic>> upgradeProfile(int targetLevel) async {
    try {
      final response = await _dio.post(upgradeProfileURL, data: {
        'target_level': targetLevel,
      });
      return {
        'success': response.statusCode == 200,
        'data': response.data,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Erreur lors de la mise à niveau',
      };
    }
  }

  /// Sauvegarde les détails spécialisés (Compétences, Expériences)
  Future<bool> saveSpecializedDetails({
    required List<int> competenceIds,
    required List<ExperienceModel> experiences,
  }) async {
    try {
      final response = await _dio.post(specializedDetailsURL, data: {
        'competences': competenceIds,
        'experiences': experiences.map((e) => e.toJson()).toList(),
      });
      return response.statusCode == 200;
    } catch (e) {
      print("Erreur saveSpecializedDetails: $e");
      return false;
    }
  }
}
