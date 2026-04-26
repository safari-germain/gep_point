import 'package:flutter/material.dart';
import 'package:gep_point/models/m_specialized_profile.dart';
import 'package:gep_point/services/s_profile_upgrade.dart';
import 'package:gep_point/providers/auth_provider.dart';

class ProfileUpgradeProvider with ChangeNotifier {
  final ProfileUpgradeService _service = ProfileUpgradeService();

  List<CompetenceModel> _allCompetences = [];
  List<ConfigurationModel> _configs = [];
  bool _isLoading = false;

  List<CompetenceModel> get allCompetences => _allCompetences;
  List<ConfigurationModel> get configs => _configs;
  bool get isLoading => _isLoading;

  /// Récupère le coût pour un niveau donné depuis les configurations
  int getUpgradePrice(int level) {
    String key = (level == 2) ? 'upgrade_profile_moyen_points' : 'upgrade_profile_superieur_points';
    var config = _configs.where((c) => c.key == key).firstOrNull;
    return config != null ? int.parse(config.value) : 0;
  }

  /// Initialisation des données (Compétences et Configs)
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _allCompetences = await _service.fetchCompetences();
    _configs = await _service.fetchConfigs();

    _isLoading = false;
    notifyListeners();
  }

  /// Exécute l'upgrade du profil
  Future<Map<String, dynamic>> upgradeUser(int targetLevel, AuthProvider authProvider) async {
    _isLoading = true;
    notifyListeners();

    final result = await _service.upgradeProfile(targetLevel);

    if (result['success']) {
      // Si succès, on force le reload de l'utilisateur dans l'AuthProvider
      await authProvider.checkLoginStatus();
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  /// Sauvegarde les détails spécialisés
  Future<bool> saveDetails({
    required List<int> competenceIds,
    required List<ExperienceModel> experiences,
    required AuthProvider authProvider,
  }) async {
    _isLoading = true;
    notifyListeners();

    final success = await _service.saveSpecializedDetails(
      competenceIds: competenceIds,
      experiences: experiences,
    );

    if (success) {
      await authProvider.checkLoginStatus();
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }
}
