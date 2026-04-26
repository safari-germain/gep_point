import 'package:dio/dio.dart';
import 'package:gep_point/configuration_api/interceptor_app.dart';

class ApiClient {
  late Dio dio;

  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal();

  Future<void> init() async {
    print("Initialisation de Dio...");
    dio = Dio();
    dio.interceptors.add(AppInterceptors());
  }
}
