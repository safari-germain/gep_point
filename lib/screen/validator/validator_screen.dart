import 'package:flutter/material.dart';
import 'package:gep_point/constants.dart';
import 'package:gep_point/models/m_organisation.dart';
import 'package:gep_point/models/m_transaction.dart';
import 'package:gep_point/services/s_organisation.dart';
import 'package:gep_point/services/s_transactions.dart';

class ValidatorScreen extends StatefulWidget {
  const ValidatorScreen({super.key, required this.id});
  final int id;
  @override
  State<ValidatorScreen> createState() => _ValidatorScreenState();
}

class _ValidatorScreenState extends State<ValidatorScreen> {
  final TransactionService _transactionService = TransactionService();
  final OrganisationService _organisationService = OrganisationService();
  List<TransactionModel> _pendingTransactions = [];
  Set<int> _selectedTransactionIds = {};
  bool _selectAll = false;
  bool _isLoading = true;
  bool isChekingValidator = true;
  OrganisationModel? org;
  @override
  void initState() {
    super.initState();
    verrifyValidator();
  }

  Future<void> verrifyValidator() async {
    final isValidator =
        await _organisationService.getVerifyValidator(widget.id);
    if (isValidator != null) {
      setState(() {
        org = isValidator;
        isChekingValidator = false;
      });
      _fetchPendingTransactions();
    }else{
      setState(() {
        isChekingValidator = false;
      });
    }
  }

  Future<void> _fetchPendingTransactions() async {
    setState(() => _isLoading = true);
    try {
      final transactions = await _transactionService.getPendingTransactions();
      setState(() {
        _pendingTransactions = transactions;
        _selectedTransactionIds.clear();
        _selectAll = false;
      });
    } catch (e) {
      print("Erreur fetching pending transactions: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectAll) {
        _selectedTransactionIds.clear();
        _selectAll = false;
      } else {
        _selectedTransactionIds =
            _pendingTransactions.map((tx) => tx.id).toSet();
        _selectAll = true;
      }
    });
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedTransactionIds.contains(id)) {
        _selectedTransactionIds.remove(id);
      } else {
        _selectedTransactionIds.add(id);
      }
      _selectAll =
          _selectedTransactionIds.length == _pendingTransactions.length;
    });
  }

  Future<void> _processSelected(bool approve) async {
    if (_selectedTransactionIds.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      bool allSuccess = true;
      for (var txId in _selectedTransactionIds) {
        final success = approve
            ? await _transactionService.validateTransaction(txId)
            : await _transactionService.cancelTransaction(txId);
        if (!success) allSuccess = false;
      }

      if (allSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "Toutes les transactions sélectionnées ont été ${approve ? 'validées' : 'annulées'}")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text("Certaines transactions n'ont pas pu être traitées")));
      }
      _fetchPendingTransactions();
    } catch (e) {
      print("Erreur traitement sélection: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
   

    return Scaffold(
      appBar: AppBar(
        title: const Text("Validateur"),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchPendingTransactions,
        child: org==null && isChekingValidator?
        SizedBox(
          child: Center(
            child: CircularProgressIndicator(
              backgroundColor: primaryColor,
            ),
          ),
        ):org==null && !isChekingValidator?
         SizedBox(
          child: Center(
            child: Text("Fonctionnalité indisponible pour vous\n tu n'est pas un validateur!!!"),
          ),):
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Organisation info
            if (org != null)
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: org!.image != null
                        ? ClipOval(
                            child: Image.network(
                              org!.image!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.business),
                            ),
                          )
                        : const Icon(Icons.business),
                  ),
                  title: Text(org!.name ),
                  subtitle:
                      const Text("Vous êtes validateur de cette organisation"),
                ),
              ),

            // Bouton Tout sélectionner
            if (_pendingTransactions.isNotEmpty)
              Row(
                children: [
                  Checkbox(
                    value: _selectAll,
                    onChanged: (value) => _toggleSelectAll(),
                  ),
                  const Text("Tout sélectionner"),
                ],
              ),

            const SizedBox(height: 16),

            // Boutons Valider / Annuler sélection
            if (_selectedTransactionIds.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _processSelected(true),
                    icon: const Icon(Icons.check),
                    label: const Text("Valider sélection"),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _processSelected(false),
                    icon: const Icon(Icons.close),
                    label: const Text("Annuler sélection"),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),

            const SizedBox(height: 16),
            const Text(
              "Transactions en attente",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_pendingTransactions.isEmpty)
              const Center(
                  child: Padding(
                padding: EdgeInsets.all(40),
                child: Text("Aucune transaction en attente"),
              ))
            else
              ..._pendingTransactions.map((tx) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: Checkbox(
                        value: _selectedTransactionIds.contains(tx.id),
                        onChanged: (value) => _toggleSelection(tx.id),
                      ),
                      title: Text("De: ${tx.receiverName}"),
                      subtitle: Text(
                          "Montant: ${tx.amount} ${tx.pointType}\nDate: ${tx.createdAt.toString().split(' ')[0]}"),
                    ),
                  ))
          ],
        ),
      ),
    );
  }
}
