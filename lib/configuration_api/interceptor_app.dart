import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppInterceptors extends Interceptor {
  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';

      if (token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        print('Le token est: $token');
      }
      
      options.headers['Accept'] = 'application/json';

      // Continue la requête après avoir ajouté les en-têtes
      handler.next(options);
    } catch (e) {
      print('Erreur lors de la récupération du token: $e');
      // Passe l'option sans modifier en cas d'erreur
      handler.next(options);
    }
  }

  @override
  Future<void> onResponse(Response response, ResponseInterceptorHandler handler) async {
    // Logique supplémentaire si nécessaire
    print('Réponse reçue: ${response.statusCode}');
    handler.next(response);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    try {
      final statusCode = err.response?.statusCode;
      final prefs = await SharedPreferences.getInstance();

      if (statusCode != null) {
        final errorMsg = err.response?.data?.toString() ?? 'Erreur inconnue';
        print('Erreur détectée: $errorMsg');

        switch (statusCode) {
          case 401:
            await prefs.setString('ErrorMessage', 'Non autorisé: $errorMsg');
            // Exemple: Déconnexion ou redirection
            break;
          case 500:
            await prefs.setString('ErrorMessage', 'Erreur serveur: $errorMsg');
            // Exemple: Notification utilisateur
            break;
          default:
            // Autres codes d'erreur
            await prefs.setString('ErrorMessage', errorMsg);
            break;
        }
      }
    } catch (e) {
      print('Erreur lors de la gestion des erreurs: $e');
    }

    // Continue toujours avec l'erreur
    handler.next(err);
  }
}
