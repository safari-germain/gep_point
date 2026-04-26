import 'package:flutter/material.dart';
import 'package:gep_point/components/v_gep_primary_b.dart';
import 'package:gep_point/constants.dart';
import 'package:gep_point/models/m_organisation_contact.dart';
import 'package:gep_point/services/s_organisation.dart';

class SendPointsMultiScreen extends StatefulWidget {
  final List<OrganisationContactModel> contacts;
  final double merchantBalance;
  final double notorietyBalance;

  const SendPointsMultiScreen({
    super.key,
    required this.contacts,
    required this.merchantBalance,
    required this.notorietyBalance,
  });

  @override
  State<SendPointsMultiScreen> createState() => _SendPointsMultiScreenState();
}

class _SendPointsMultiScreenState extends State<SendPointsMultiScreen> {
  final OrganisationService _orgService = OrganisationService();
  final TextEditingController _amountController = TextEditingController();
  
  List<OrganisationContactModel> _filteredContacts = [];
  final Set<int> _selectedUserIds = {};
  bool _isLoading = false;
  String _selectedPointType = 'marchand'; // 'marchand' or 'notoriete'

  @override
  void initState() {
    super.initState();
    _filteredContacts = widget.contacts;
  }

  void _filterContacts(String query) {
    setState(() {
      _filteredContacts = widget.contacts
          .where((c) => 
            (c.user?.name.toLowerCase().contains(query.toLowerCase()) ?? false) || 
            (c.user?.email?.toLowerCase().contains(query.toLowerCase()) ?? false))
          .toList();
    });
  }

  void _toggleSelection(int userId) {
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
      } else {
        _selectedUserIds.add(userId);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedUserIds.length == widget.contacts.length) {
        _selectedUserIds.clear();
      } else {
        _selectedUserIds.addAll(widget.contacts.map((c) => c.user!.id));
      }
    });
  }

  Future<void> _sendPoints() async {
    if (_selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sélectionnez au moins un contact")),
      );
      return;
    }

    final amountPerUser = double.tryParse(_amountController.text);
    if (amountPerUser == null || amountPerUser <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Montant invalide")),
      );
      return;
    }

    final totalAmountNeeded = amountPerUser * _selectedUserIds.length;
    final availableBalance = _selectedPointType == 'marchand' ? widget.merchantBalance : widget.notorietyBalance;

    if (totalAmountNeeded > availableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Solde insuffisant. Requis: $totalAmountNeeded, Disponible: $availableBalance")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _orgService.distributePointsMultiple(
        beneficiaryIds: _selectedUserIds.toList(),
        amountPerUser: amountPerUser,
        pointType: _selectedPointType,
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableBalance = _selectedPointType == 'marchand' ? widget.merchantBalance : widget.notorietyBalance;
    final double totalAmount = (_selectedUserIds.length * (double.tryParse(_amountController.text) ?? 0));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Envoi Multiple"),
        actions: [
          TextButton(
            onPressed: _selectAll,
            child: Text(
              _selectedUserIds.length == widget.contacts.length ? "Désélectionner" : "Tout",
              style: const TextStyle(color: primaryColor),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              children: [
                // Point Type Selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPointType,
                      dropdownColor: Colors.grey.shade900,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'marchand', child: Text("Points Marchand (Standard)", style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'notoriete', child: Text("Points Notoriété (Non-Standard)", style: TextStyle(color: Colors.white))),
                      ],
                      onChanged: (val) => setState(() => _selectedPointType = val!),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    hintText: "Montant par personne",
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryColor)),
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (v) => setState(() {}),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total: $totalAmount PTS",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: totalAmount > availableBalance ? Colors.red : Colors.green,
                      ),
                    ),
                    Text(
                      "Disponible: $availableBalance PTS",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                
                const SizedBox(height: defaultPadding),
                
                TextField(
                  onChanged: _filterContacts,
                  decoration: InputDecoration(
                    hintText: "Rechercher un contact...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              itemCount: _filteredContacts.length,
              itemBuilder: (context, index) {
                final contact = _filteredContacts[index];
                final user = contact.user;
                if (user == null) return const SizedBox.shrink();
                
                final isSelected = _selectedUserIds.contains(user.id);
                
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(user.name[0]),
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.email ?? ''),
                  trailing: Checkbox(
                    value: isSelected,
                    activeColor: primaryColor,
                    onChanged: (bool? value) => _toggleSelection(user.id),
                  ),
                  onTap: () => _toggleSelection(user.id),
                );
              },
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: VGepPrimaryButton(
              text: "Envoyer à ${_selectedUserIds.length} contact(s)",
              loading: _isLoading,
              onPressed: (_isLoading || _selectedUserIds.isEmpty) 
                  ? () {} 
                  : _sendPoints,
            ),
          ),
        ],
      ),
    );
  }
}
