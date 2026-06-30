import 'package:flutter/material.dart';
import 'package:gep_point/api_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PromotionProvider extends ChangeNotifier {
  double? _activeDiscountPercentage;
  String? _activePromotionName;
  bool _isLoading = false;

  double? get activeDiscountPercentage => _activeDiscountPercentage;
  String? get activePromotionName => _activePromotionName;
  bool get isLoading => _isLoading;
  bool get hasPromotion => _activeDiscountPercentage != null && _activeDiscountPercentage! > 0;

  Future<void> fetchActiveTransferPromotion() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$baseURL/promotions/active/transfer'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final promotion = data['promotion'];
        if (promotion != null) {
          _activeDiscountPercentage = (promotion['discount_percentage'] as num?)?.toDouble();
          _activePromotionName = promotion['name'] as String?;
        } else {
          _activeDiscountPercentage = null;
          _activePromotionName = null;
        }
      }
    } catch (_) {
      _activeDiscountPercentage = null;
      _activePromotionName = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
