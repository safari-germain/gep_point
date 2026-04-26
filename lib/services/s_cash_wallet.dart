import 'package:dio/dio.dart';
import 'package:gep_point/api_constants.dart';
import 'package:gep_point/services/s_dio/dio_service.dart';

class CashWalletService {
  final Dio _dio = ApiClient().dio;

  /// Récupère la liste de tous les portefeuilles et balances (Cash, Standard, etc.)
  Future<List<dynamic>> getWallets() async {
    try {
      final response = await _dio.get(walletsURL);
      if (response.statusCode == 200) {
        // Le backend retourne {'status': 'success', 'data': [...]}
        return response.data['data'];
      }
    } on DioException catch (e) {
      print("Erreur CashWalletService.getWallets: ${e.message}");
    }
    return [];
  }

  /// Récupère le solde pour un type spécifique
  Future<double> getBalance(String type) async {
    try {
      final response = await _dio.get('$walletsURL/$type');
      if (response.statusCode == 200) {
        return (response.data['balance'] as num).toDouble();
      }
    } catch (e) {
      print("Erreur CashWalletService.getBalance: $e");
    }
    return 0.0;
  }

  Future<Map<String, double>> getOrganisationWallets(int id) async {
  try {
    final response = await _dio.get("$walletsURL/$id/organisation");

    print('Réponse serveur: ${response.data}');
    print('Status code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final balancesData = response.data['balances'];

      if (balancesData != null && balancesData is Map) {
        // Convertit chaque valeur en double, même si c'est String
        return balancesData.map((key, value) {
          double val;
          if (value is num) {
            val = value.toDouble();
          } else if (value is String) {
            val = double.tryParse(value) ?? 0.0;
          } else {
            val = 0.0; // valeur par défaut si autre type
          }
          return MapEntry(key, val);
        });
      } else {
        print('Aucune balance trouvée ou format invalide');
      }
    } else {
      print('Erreur serveur: ${response.statusCode} - ${response.data}');
    }
  } on DioException catch (e) {
    print("Erreur Dio: ${e.response?.statusCode} - ${e.response?.data}");
  } catch (e) {
    print("Erreur inconnue: $e");
  }

  return {};
}
}
