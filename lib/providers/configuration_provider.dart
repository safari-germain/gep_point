import 'package:flutter/material.dart';
import 'package:gep_point/models/m_configuration.dart';
import 'package:gep_point/services/s_configuration.dart';

class ConfigurationProvider extends ChangeNotifier {
  final ConfigurationService _service = ConfigurationService();
  
  List<ConfigurationModel> _configurations = [];
  bool _isLoading = false;

  List<ConfigurationModel> get configurations => _configurations;
  bool get isLoading => _isLoading;

  /// Récupérer une valeur par sa clé
  String getValue(String key, {String defaultValue = ''}) {
    try {
      return _configurations.firstWhere((c) => c.key == key).value;
    } catch (_) {
      return defaultValue;
    }
  }

  /// Vérifier si une option booléenne est activée
  bool isEnabled(String key) {
    try {
      final config = _configurations.firstWhere((c) => c.key == key);
      return config.asBool;
    } catch (_) {
      return false;
    }
  }

  Future<void> fetchConfigurations() async {
    _isLoading = true;
    notifyListeners();

    try {
      _configurations = await _service.getConfigurations();
    } catch (e) {
      print("Erreur fetchConfigurations: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
