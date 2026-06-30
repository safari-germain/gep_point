import 'package:dio/dio.dart';
import 'package:gep_point/api_constants.dart';
import 'package:gep_point/services/s_dio/dio_service.dart';
import 'package:gep_point/models/m_configuration.dart';

class ConfigurationService {
  final Dio _dio = ApiClient().dio;

  /// Récupère toutes les configurations système
  Future<List<ConfigurationModel>> getConfigurations() async {
    try {
      final response = await _dio.get(configsURL);
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => ConfigurationModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print("Erreur ConfigurationService.getConfigurations: ${e.message}");
      return [];
    } catch (e) {
      print("Erreur ConfigurationService: $e");
      return [];
    }
  }
}
