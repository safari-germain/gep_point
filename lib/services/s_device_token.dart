import 'dart:io';
import 'package:dio/dio.dart';
import 'package:gep_point/api_constants.dart';
import 'package:gep_point/services/s_dio/dio_service.dart';
import 'package:gep_point/notification/notification_manager.dart';

class DeviceTokenService {
  final Dio _dio = ApiClient().dio;

  /// Enregistre le token FCM de l'utilisateur actuel sur le backend
  Future<void> registerDeviceToken() async {
    try {
      final token = await NotificationManager.getToken();
      if (token == null) return;

      final response = await _dio.post('$baseURL/device-token', data: {
        'token': token,
        'device_type': Platform.isAndroid ? 'android' : 'ios',
      });

      if (response.statusCode == 200) {
        print('DeviceTokenService: Token enregistré avec succès');
      }
    } catch (e) {
      print('DeviceTokenService Error: $e');
    }
  }
}
