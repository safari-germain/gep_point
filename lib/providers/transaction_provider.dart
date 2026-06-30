import 'package:flutter/material.dart';
import 'package:gep_point/models/m_transaction.dart';
import 'package:gep_point/models/m_withdrawal.dart';
import 'package:gep_point/services/s_transactions.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _service = TransactionService();

  List<TransactionModel> _transactions = [];
  List<WithdrawalModel> _withdrawals = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _lastPage = 1;
  String? _error;

  List<TransactionModel> get transactions => _transactions;
  List<WithdrawalModel> get withdrawals => _withdrawals;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  String? get error => _error;

  /// ---------------------- Retraits ---------------------- ///
  Future<void> fetchWithdrawals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _withdrawals = await _service.getWithdrawals();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ---------------------- Transactions globales ---------------------- ///
  Future<void> fetchTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await _service.getTransactions();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ---------------------- Transfert de points ---------------------- ///
  Future<bool> transfer(int toUserId, double amount,
      {String feePayer = 'receiver'}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.transferPoints(
        toUserId: toUserId,
        amount: amount,
        feePayer: feePayer,
      );

      if (result['success'] == true) {
        await fetchTransactions();
        return true;
      } else {
        _error = result['message'];
        return false;
      }
    } catch (e) {
      _error = "Une erreur est survenue lors du transfert";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ---------------------- Conversion ---------------------- ///
  Future<bool> convert(double amount) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.convertPoints(amount: amount);
      if (result['success'] == true) {
        return true;
      } else {
        _error = result['message'];
        return false;
      }
    } catch (e) {
      _error = "Une erreur est survenue lors de la conversion";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ---------------------- Transactions de l'utilisateur ---------------------- ///
  Future<void> fetchUserTransfers(int userId) async {
    _isLoading = true;
    _currentPage = 1;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.getUserTransfers(userId, page: 1);

      final List<TransactionModel> data = result['transactions'] ?? [];
      _transactions = data;

      _currentPage = result['current_page'] ?? 1;
      _lastPage = result['last_page'] ?? 1;
    } catch (e) {
      _error = "Erreur fetchUserTransfers: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreUserTransfers(int userId) async {
    if (_currentPage >= _lastPage) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final result = await _service.getUserTransfers(userId, page: nextPage);

      final List<TransactionModel> data = result['transactions'] ?? [];

      _transactions.addAll(data);
      _currentPage = result['current_page'] ?? nextPage;
      _lastPage = result['last_page'] ?? _lastPage;
    } catch (e) {
      _error = "Erreur loadMoreUserTransfers: $e";
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// ---------------------- Réceptions de l'utilisateur ---------------------- ///
  Future<void> fetchUserReceipts(int userId) async {
    _isLoading = true;
    _currentPage = 1;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.getUserReceipts(userId, page: 1);

      final List<TransactionModel> data = result['transactions'] ?? [];
      _transactions = data;

      _currentPage = result['current_page'] ?? 1;
      _lastPage = result['last_page'] ?? 1;
    } catch (e) {
      _error = "Erreur fetchUserReceipts: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ---------------------- Transactions de l'organisation ---------------------- ///
  Future<void> fetchOrganisationTransfers(int orgId, {bool loadMore = false}) async {
  if (_isLoading) return;

  if (loadMore && _currentPage >= _lastPage) return;

  if (loadMore) {
    _isLoadingMore = true;
    notifyListeners();
  } else {
    _isLoading = true;
    _currentPage = 1;
    _transactions.clear();
    _error = null;
    notifyListeners();
  }

  try {
    final nextPage = loadMore ? _currentPage + 1 : 1;
    final result = await _service.getOrganisationTransfers(orgId, page: nextPage);

    final List<TransactionModel> newTransactions = result['transactions'] ?? [];

    if (loadMore) {
      _transactions.addAll(newTransactions);
    } else {
      _transactions = newTransactions;
    }

    _currentPage = result['current_page'] ?? nextPage;
    _lastPage = result['last_page'] ?? _lastPage;
  } catch (e) {
    _error = "Erreur fetchOrganisationTransfers: $e";
  } finally {
    _isLoading = false;
    _isLoadingMore = false;
    notifyListeners();
  }
}
}
