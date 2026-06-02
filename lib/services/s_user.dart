import 'package:dio/dio.dart';
import 'package:gep_point/api_constants.dart';
import 'package:gep_point/models/m_user.dart';
import 'package:gep_point/services/s_dio/dio_service.dart';

class UserService {
  final Dio _dio = ApiClient().dio;

  /// Récupère les informations du profil de l'utilisateur connecté
  Future<UserModel?> getUserProfile() async {
    try {
      final response = await _dio.get(userURL);
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['user']);
      }
    } on DioException catch (e) {
      print("Erreur UserService.getUserProfile: ${e.message}");
    }
    return null;
  }

  /// Récupère les informations d'un utilisateur par son ID
  Future<UserModel?> getUserById(int id) async {
    try {
      final response = await _dio.get('$baseURL/users/$id');
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['user'] ?? response.data);
      }
    } on DioException catch (e) {
      print("Erreur UserService.getUserById: ${e.message}");
    }
    return null;
  }

  /// Met à jour les informations de profil (général)
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(profileURL, data: data);
      return response.statusCode == 200;
    } on DioException catch (e) {
      print("Erreur UserService.updateProfile: ${e.message}");
      return false;
    }
  }

  /// Mettre à jour la photo de profil
  Future<bool> updateProfileImage(String imagePath, int userId) async {
    try {
      String fileName = imagePath.split('/').last;
      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(imagePath, filename: fileName),
      });
      final response = await _dio.post('$baseURL/updateUserProfil/$userId', data: formData);
      return response.statusCode == 200;
    } catch (e) {
      print("Erreur UserService.updateProfileImage: $e");
      return false;
    }
  }

  /// Met à jour les informations de profil
  Future<bool> updateUserInfo(int userId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('$baseURL/updateUserInfo/$userId', data: data);
      return response.statusCode == 200;
    } on DioException catch (e) {
      print("Erreur UserService.updateUserInfo: ${e.message}");
      return false;
    }
  }
}
