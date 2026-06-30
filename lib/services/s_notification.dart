import 'package:dio/dio.dart';
import 'package:gep_point/services/s_dio/dio_service.dart';

class NotificationModel {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.data,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      type: json['type'],
      data: json['data'] ?? {},
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  bool get isRead => readAt != null;
}

class NotificationService {
  final Dio _dio = ApiClient().dio;

  Future<List<NotificationModel>> fetchNotifications({int page = 1, int perPage = 15}) async {
    try {
      final response = await _dio.get(
        '/notifications',
        queryParameters: {'page': page, 'per_page': perPage},
      );

      final data = response.data['data'] as List;
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } catch (e) {
      print('Erreur lors de la récupération des notifications: $e');
      return [];
    }
  }

  Future<bool> markAsRead(String id) async {
    try {
      final response = await _dio.put('/notifications/$id/read');
      return response.statusCode == 200;
    } catch (e) {
      print('Erreur lors du marquage de la notification: $e');
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final response = await _dio.put('/notifications/read-all');
      return response.statusCode == 200;
    } catch (e) {
      print('Erreur lors du marquage de toutes les notifications: $e');
      return false;
    }
  }
}
