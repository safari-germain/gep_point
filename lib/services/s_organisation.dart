import 'package:dio/dio.dart';
import 'package:gep_point/api_constants.dart';
import 'package:gep_point/models/m_organisation.dart';
import 'package:gep_point/models/m_organisation_contact.dart';
import 'package:gep_point/models/m_point_sale.dart';
import 'package:gep_point/services/s_dio/dio_service.dart';

class OrganisationService {
  final Dio _dio = ApiClient().dio;

  /// Liste des organisations disponibles
  Future<List<OrganisationModel>> getOrganisations() async {
    try {
      final response = await _dio.get(organisationsURL);
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => OrganisationModel.fromJson(json)).toList();
      }
    } catch (e) {
      print("Erreur OrganisationService.getOrganisations: $e");
    }
    return [];
  }
  Future<Map<String, dynamic>> getOrganisationSalesHistory(
  int id, {
  int page = 1,
}) async {
  try {
    final response = await _dio.get(
      '$baseURL/organisation-sale/$id?page=$page',
    );

    if (response.statusCode == 200) {
      final data = response.data;

    List<PointSaleModel> sales = (data['data'] as List<dynamic>)
    .map<PointSaleModel>((json) => PointSaleModel.fromJson(json))
    .toList();

      return {
        "sales": sales,
        "current_page": data['current_page'],
        "last_page": data['last_page'],
      };
    }
  } catch (e) {
    print("Erreur getOrganisationSalesHistory: $e");
  }

  return {
    "sales": [],
    "current_page": 1,
    "last_page": 1,
  };
}

  /// Créer une organisation
  Future<Map<String, dynamic>> createOrganisation({
    required String name,
    required String description,
    required int validatorUserId,
    String? marketeurCode,
    String? imagePath,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'name': name,
        'description': description,
        'validator_user_id': validatorUserId,
        if (marketeurCode != null) 'marketeur_code': marketeurCode,
        if (imagePath != null)
          'image': await MultipartFile.fromFile(imagePath, filename: imagePath.split('/').last),
      });

      final response = await _dio.post(organisationCreateURL, data: formData);
      return {
        'success': response.statusCode == 201 || response.statusCode == 200,
        'message': (response.data is Map) ? (response.data['message'] ?? 'Organisation créée avec succès') : 'Organisation créée avec succès',
        'organisation': (response.data is Map) ? response.data['organisation'] : null,
      };
    } on DioException catch (e) {
      String errorMessage = 'Erreur lors de la création de l\'organisation';
      if (e.response?.data is Map) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      } else if (e.response?.data is String && e.response!.data.toString().contains('<!DOCTYPE html>')) {
        errorMessage = 'Le serveur a renvoyé une erreur HTML. Vérifiez les logs du backend.';
      }

      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Une erreur inattendue est survenue: $e',
      };
    }
  }

  /// Mettre à jour une organisation
  Future<Map<String, dynamic>> updateOrganisation({
    required int id,
    String? name,
    String? description,
    String? imagePath,
  }) async {
    try {
      Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (imagePath != null) {
        data['image'] = await MultipartFile.fromFile(imagePath, filename: imagePath.split('/').last);
      }
      
      FormData formData = FormData.fromMap(data);

      final response = await _dio.post('$organisationsURL/$id/update', data: formData);
      return {
        'success': response.statusCode == 200,
        'message': (response.data is Map) ? (response.data['message'] ?? 'Organisation mise à jour') : 'Organisation mise à jour',
        'organisation': (response.data is Map) ? response.data['organisation'] : null,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Erreur lors de la mise à jour',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur inattendue: $e',
      };
    }
  }

  /// Rechercher des utilisateurs (pour le validateur)
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final response = await _dio.get('$baseURL/users/search', queryParameters: {'query': query});
      if (response.statusCode == 200) {
        if (response.data is Map && response.data['data'] != null) {
          return List<Map<String, dynamic>>.from(response.data['data']);
        }
        return List<Map<String, dynamic>>.from(response.data);
      }
    } catch (e) {
      print("Erreur OrganisationService.searchUsers: $e");
    }
    return [];
  }

  /// Distribuer des points Merchant aux membres
  Future<Map<String, dynamic>> distributePoints({
    required int beneficiaryId,
    required double amount,
    String pointType = 'marchand',
  }) async {
    try {
      final response = await _dio.post(distributeURL, data: {
        'beneficiary_id': beneficiaryId,
        'amount': amount,
        'point_type': pointType,
      });
      return {
        'success': response.statusCode == 200,
        'message': response.data['message'] ?? 'Distribution réussie',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Erreur lors de la distribution',
      };
    }
  }

  /// Distribuer des points Merchant à plusieurs membres
  Future<Map<String, dynamic>> distributePointsMultiple({
    required List<int> beneficiaryIds,
    required double amountPerUser,
    String pointType = 'marchand',
  }) async {
    try {
      final response = await _dio.post('$organisationsURL/distribute-multiple', data: {
        'beneficiary_ids': beneficiaryIds,
        'amount_per_user': amountPerUser,
        'point_type': pointType,
      });
      return {
        'success': response.statusCode == 200,
        'message': response.data['message'] ?? 'Distribution multiple réussie',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Erreur lors de la distribution multiple',
      };
    }
  }

  /// Changer le validateur de l'organisation
  Future<Map<String, dynamic>> updateValidator(int organisationId, int validatorUserId) async {
    try {
      final response = await _dio.put('$organisationsURL/$organisationId/validator', data: {
        'validator_user_id': validatorUserId,
      });
      return {
        'success': response.statusCode == 200,
        'message': response.data['message'] ?? 'Validateur mis à jour avec succès',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Erreur lors de la mise à jour du validateur',
      };
    }
  }

  // ==================== GESTION DES CONTACTS (MEMBRES) ====================

  /// Lister les contacts/membres de l'organisation
  Future<List<OrganisationContactModel>> getContacts() async {
    try {
      final response = await _dio.get(orgContactsURL);
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => OrganisationContactModel.fromJson(json)).toList();
      }
    } catch (e) {
      print("Erreur OrganisationService.getContacts: $e");
    }
    return [];
  }

  Future<OrganisationModel?> getVerifyValidator(int id) async {
  try {
    final response = await _dio.get('$baseURL/organisation/$id/validateur');
    if (response.statusCode == 200) {
      // Supposons que response.data est une liste, on prend juste le premier élément
      final data = response.data;
      if (data != null && data is List && data.isNotEmpty) {
        return OrganisationModel.fromJson(data[0]);
      }
    }
  } catch (e) {
    print("Erreur OrganisationService.getContact: $e");
  }
  return null; // si aucun contact trouvé ou erreur
}

  /// Ajouter un membre à l'organisation
  Future<Map<String, dynamic>> addContact(int userId, {int? organizationId}) async {
    try {
      final response = await _dio.post(orgContactsURL, data: {
        'user_id': userId,
        if (organizationId != null) 'organisation_id': organizationId,
      });
      return {
        'success': response.statusCode == 201,
        'message': response.data['message'] ?? 'Membre ajouté',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Erreur lors de l\'ajout',
      };
    }
  }

  /// Supprimer un membre
  Future<bool> deleteContact(int contactId) async {
    try {
      final response = await _dio.delete('$orgContactsURL/$contactId');
      return response.statusCode == 200;
    } catch (e) {
      print("Erreur OrganisationService.deleteContact: $e");
      return false;
    }
  }
}
