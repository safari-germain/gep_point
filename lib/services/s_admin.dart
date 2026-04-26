import 'package:dio/dio.dart';
import 'package:gep_point/api_constants.dart';
import 'package:gep_point/services/s_dio/dio_service.dart';

class AdminService {
  final Dio _dio = ApiClient().dio;

  /// Récupérer les statistiques globales du système GEP (Admin uniquement)
  Future<Map<String, dynamic>?> getAdminStats() async {
    try {
      final response = await _dio.get(adminStatsURL);
      if (response.statusCode == 200) {
        return response.data;
      }
    } on DioException catch (e) {
      print("Erreur AdminService.getAdminStats: ${e.message}");
    }
    return null;
  }
}
