import 'package:dio/dio.dart';
import 'package:gep_point/api_constants.dart';
import 'package:gep_point/services/s_dio/dio_service.dart';

class ConversionService {
  final Dio _dio = ApiClient().dio;

  /// Récupère les taux de conversion actuels (ex: Standard vers Cash)
  Future<List<dynamic>> getConversionRates() async {
    try {
      final response = await _dio.get(pointRatesURL);
      if (response.statusCode == 200) {
        return response.data as List? ?? [];
      }
    } on DioException catch (e) {
      print("Erreur ConversionService.getConversionRates: ${e.message}");
    }
    return [];
  }

  /// Effectue une conversion de points
  /// ex: from='standard', to='cash'
  Future<bool> convertPoints({
    required double amount,
    required String from,
    required String to,
  }) async {
    try {
      final response = await _dio.post('$baseURL/convert', data: {
        'amount': amount,
        'from_type': from,
        'to_type': to,
      });
      return response.statusCode == 200;
    } on DioException catch (e) {
      print("Erreur ConversionService.convertPoints: ${e.message}");
      return false;
    }
  }

  /// Historique des conversions effectuées
  Future<List<dynamic>> getConversionHistory() async {
    try {
      final response = await _dio.get('$baseURL/conversions');
      if (response.statusCode == 200) {
        return response.data['conversions'];
      }
    } catch (e) {
      print("Erreur ConversionService.getConversionHistory: $e");
    }
    return [];
  }
}
