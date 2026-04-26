import 'package:dio/dio.dart';
import 'package:gep_point/api_constants.dart';
import 'package:gep_point/models/m_transaction.dart';
import 'package:gep_point/services/s_dio/dio_service.dart';

class TransactionService {
  final Dio _dio = ApiClient().dio;

  /// Récupère l'historique des transactions de l'utilisateur
  Future<List<TransactionModel>> getTransactions() async {
    try {
      final response = await _dio.get(transactionsURL);
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => TransactionModel.fromJson(json)).toList();
      }
    } on DioException catch (e) {
      print("Erreur TransactionService.getTransactions: ${e.message}");
    }
    return [];
  }

  /// Effectue un transfert de points Standard à un autre utilisateur
  Future<Map<String, dynamic>> transferPoints({
    required int toUserId,
    required double amount,
    String feePayer = 'receiver', // 'sender' or 'receiver'
  }) async {
    try {
      final response = await _dio.post(transferURL, data: {
        'to_user_id': toUserId,
        'amount': amount,
        'fee_payer': feePayer,
      });
      return {
        'success': response.statusCode == 200,
        'message': response.data['message'] ?? 'Transfert réussi',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Erreur lors du transfert',
      };
    }
  }

  /// Effectue une conversion de points Standard en Cash
  Future<Map<String, dynamic>> convertPoints({
    required double amount,
  }) async {
    try {
      final response = await _dio.post(convertURL, data: {
        'amount': amount,
      });
      return {
        'success': response.statusCode == 200,
        'message': response.data['message'] ?? 'Conversion réussie',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message':
            e.response?.data['message'] ?? 'Erreur lors de la conversion',
      };
    }
  }

  Future<Map<String, dynamic>> getUserTransfers(
    int id, {
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '$baseURL/user/$id/transfers?page=$page',
      );

      if (response.statusCode == 200) {
        final data = response.data;

        List<TransactionModel> transactions = (data['data'] as List)
            .map((json) => TransactionModel.fromJson(json))
            .toList();

        return {
          "transactions": transactions,
          "current_page": data['current_page'],
          "last_page": data['last_page'],
        };
      }
    } catch (e) {
      print("Erreur getUserTransfers: $e");
    }

    return {
      "transactions": [],
      "current_page": 1,
      "last_page": 1,
    };
  }

  Future<Map<String, dynamic>> getUserReceipts(
    int id, {
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '$baseURL/user/$id/receipts?page=$page',
      );

      if (response.statusCode == 200) {
        final data = response.data;

        List<TransactionModel> transactions = (data['data'] as List)
            .map((json) => TransactionModel.fromJson(json))
            .toList();

        return {
          "transactions": transactions,
          "current_page": data['current_page'],
          "last_page": data['last_page'],
        };
      }
    } catch (e) {
      print("Erreur getUserReceipts: $e");
    }

    return {
      "transactions": [],
      "current_page": 1,
      "last_page": 1,
    };
  }

  Future<Map<String, dynamic>> getOrganisationTransfers(
    int id, {
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '$baseURL/organisation/$id/transfers?page=$page',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        //print(data);
        List<TransactionModel> transactions = (data['data'] as List)
            .map((json) => TransactionModel.fromJson(json))
            .toList();

        return {
          "transactions": transactions,
          "current_page": data['current_page'],
          "last_page": data['last_page'],
        };
      }
    } catch (e) {
      print("Erreur getOrganisationTransfers: $e");
    }

    return {
      "transactions": [],
      "current_page": 1,
      "last_page": 1,
    };
  }

  final String pendingTransactionsURL = "/transactions/pending";
  final String validateTransactionURL = "/transactions"; // /{id}/validate
  final String cancelTransactionURL = "/transactions"; // /{id}/cancel

  // 1️⃣ Récupérer les transactions en attente
  Future<List<TransactionModel>> getPendingTransactions() async {
    try {
      final response = await _dio.get("$baseURL$pendingTransactionsURL");
      if (response.statusCode == 200) {
        List<dynamic> data = response.data['transactions'];
        print('le données:$data');
        return data.map((json) => TransactionModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print(
          "TransactionService getPendingTransactions Dio Error: ${e.message}");
      throw "Erreur lors de la récupération des transactions";
    } catch (e) {
      print("TransactionService getPendingTransactions Unexpected Error: $e");
      throw "Erreur inattendue lors de la récupération des transactions";
    }
  }

  // 2️⃣ Valider une transaction
  Future<bool> validateTransaction(int id) async {
    try {
      final response =
          await _dio.post("$baseURL$validateTransactionURL/$id/validate");
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      print("TransactionService validateTransaction Dio Error: ${e.message}");
      throw "Erreur lors de la validation de la transaction";
    } catch (e) {
      print("TransactionService validateTransaction Unexpected Error: $e");
      throw "Erreur inattendue lors de la validation";
    }
  }

  // 3️⃣ Annuler une transaction
  Future<bool> cancelTransaction(int id) async {
    try {
      final response =
          await _dio.post("$baseURL$cancelTransactionURL/$id/cancel");
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      print("TransactionService cancelTransaction Dio Error: ${e.message}");
      throw "Erreur lors de l'annulation de la transaction";
    } catch (e) {
      print("TransactionService cancelTransaction Unexpected Error: $e");
      throw "Erreur inattendue lors de l'annulation";
    }
  }
}
