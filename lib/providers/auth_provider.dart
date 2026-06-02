import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:gep_point/api_constants.dart';
import 'package:gep_point/models/m_user.dart';
import 'package:gep_point/services/s_dio/dio_service.dart';
import 'package:gep_point/services/s_device_token.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final Dio _dio = ApiClient().dio;

  /// Connexion
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.post(loginURL, data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);

        _user = UserModel.fromJson(response.data['user']);
        
        // Enregistrer le token de notification
        DeviceTokenService().registerDeviceToken();
        
        return true;
      }
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? "Erreur de connexion $e";
    print('erreur:$e');
    } catch (e) {
      _error = "Une erreur inattendue est survenue";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  /// Inscription
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? agentCode,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.post(registerURL, data: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        if (agentCode != null) 'agent_code': agentCode,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (response.data['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', response.data['token']);
          _user = UserModel.fromJson(response.data['user']);
          
          // Enregistrer le token de notification
          DeviceTokenService().registerDeviceToken();
        }
        return true;
      }
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? "Erreur d'inscription";
    } catch (e) {
      _error = "Une erreur inattendue est survenue";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  /// Déconnexion
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    _user = null;
    notifyListeners();
  }

  /// Vérifier si l'utilisateur est déjà connecté au démarrage
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token != null && token.isNotEmpty) {
      try {
        final response = await _dio.get(userURL);
        if (response.statusCode == 200) {
          _user = UserModel.fromJson(response.data['user']);
          
          // Mettre à jour le token de notification au cas où
          DeviceTokenService().registerDeviceToken();
        }
      } catch (e) {
        // Token invalide ou expiré
        await logout();
      }
    }
    notifyListeners();
  }

  /// Réinitialisation du mot de passe
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.post('$baseURL/forgot-password', data: {
        'email': email,
      });

      if (response.statusCode == 200) {
        return true;
      }
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? "Erreur de réinitialisation";
    } catch (e) {
      _error = "Une erreur inattendue est survenue";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  /// Upload de la photo de profil
  Future<bool> uploadProfilePicture(File imageFile) async {
    if (_user == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      // L'API est updateUserProfil dans le backend
      final response = await _dio.post('$baseURL/updateUserProfil/${_user!.id}', data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _user = UserModel.fromJson(response.data['user']);
        return true;
      }
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? "Erreur lors de l'upload";
    } catch (e) {
      _error = "Une erreur inattendue est survenue";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  /// Update user info
  Future<bool> updateUserInfo(String name, String email, String phone) async {
    if (_user == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.put('$baseURL/updateUserInfo/${_user!.id}', data: {
        'name': name,
        'email': email,
        'phone': phone,
        'genre': _user!.genre ?? 'Non spécifié',
      });

      if (response.statusCode == 200) {
        _user = UserModel.fromJson(response.data['user']);
        return true;
      }
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? "Erreur lors de la mise à jour";
    } catch (e) {
      _error = "Une erreur inattendue est survenue";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }
}
