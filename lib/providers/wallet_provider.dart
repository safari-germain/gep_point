import 'package:flutter/material.dart';
import 'package:gep_point/services/s_cash_wallet.dart';

class WalletProvider extends ChangeNotifier {
  final CashWalletService _service = CashWalletService();

  Map<String, dynamic> _balances = {};
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic> get balances => _balances;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Récupérer tous les soldes
  Future<void> fetchBalances() async {
    _isLoading = true;
    _error = null; // Clear previous errors
    notifyListeners();

    try {
      final wallets = await _service.getWallets();

      _balances = {
  for (var item in wallets)
    item['point_type'] as String: double.tryParse(item['balance'].toString()) ?? 0.0
};
      print("balance utilisateur est:$_balances");
    } catch (e) {
      _error = e.toString();
      // Optionally, you might want to log the error
      // print('Error fetching balances: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBalancesForOrganisation(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final balances = await _service.getOrganisationWallets(id);
      print('balance est deee:$balances');
      // Ici balances est déjà un Map<String, double>
      _balances = balances;
    } catch (e) {
      _error = e.toString();
      print("Erreur fetchBalancesForOrganisation: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtenir le solde par type
  double getBalance(String type) {
    return (_balances[type] ?? 0).toDouble();
  }
  //// Dans ton WalletProvider
double getUserBalance(String pointType) {
  return _balances[pointType] ?? 0.0;
}
}
