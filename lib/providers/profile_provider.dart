import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ProfileMode { user, organisation }

class ProfileProvider with ChangeNotifier {
  ProfileMode _activeMode = ProfileMode.user;
  int? _activeOrganisationId;

  ProfileMode get activeMode => _activeMode;
  int? get activeOrganisationId => _activeOrganisationId;

  static const String _modeKey = 'active_profile_mode';
  static const String _orgIdKey = 'active_organisation_id';

  ProfileProvider() {
    _loadProfileSettings();
  }

  Future<void> _loadProfileSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final String? modeStr = prefs.getString(_modeKey);
    if (modeStr != null) {
      _activeMode = modeStr == 'organisation' ? ProfileMode.organisation : ProfileMode.user;
    }
    _activeOrganisationId = prefs.getInt(_orgIdKey);
    notifyListeners();
  }

  Future<void> setProfileMode(ProfileMode mode, {int? organisationId}) async {
    _activeMode = mode;
    _activeOrganisationId = organisationId;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, mode == ProfileMode.organisation ? 'organisation' : 'user');
    if (organisationId != null) {
      await prefs.setInt(_orgIdKey, organisationId);
    } else {
      await prefs.remove(_orgIdKey);
    }
  }
}
