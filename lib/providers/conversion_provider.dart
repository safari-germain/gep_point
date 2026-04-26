import 'package:flutter/material.dart';
import 'package:gep_point/models/m_conversion.dart';
import 'package:gep_point/services/s_convertion.dart';

class ConversionProvider extends ChangeNotifier {
  final ConversionService _service = ConversionService();
  
  List<ConversionModel> _conversions = [];
  bool _isLoading = false;
  Map<String, dynamic> _rates = {};

  List<ConversionModel> get conversions => _conversions;
  bool get isLoading => _isLoading;
  Map<String, dynamic> get rates => _rates;

  Future<void> fetchConversions() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _service.getConversionHistory();
      _conversions = data.map((json) => ConversionModel.fromJson(json)).toList();
    } catch (e) {
      print("Erreur ConversionProvider.fetchConversions: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRates() async {
    try {
      _rates = await _service.getConversionRates();
      notifyListeners();
    } catch (e) {
      print("Erreur ConversionProvider.fetchRates: $e");
    }
  }

  Future<bool> convert(double amount, String from, String to) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _service.convertPoints(amount: amount, from: from, to: to);
      if (success) {
        await fetchConversions();
        return true;
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
