import 'package:flutter/material.dart';
import 'package:gep_point/components/v_gep_text_field.dart';
import 'package:gep_point/constants.dart';
import 'package:gep_point/services/s_organisation.dart';

class AddOrganisationContactScreen extends StatefulWidget {
  const AddOrganisationContactScreen({super.key, required this.organisationId});
  final int organisationId;
  @override
  State<AddOrganisationContactScreen> createState() =>
      _AddOrganisationContactScreenState();
}

class _AddOrganisationContactScreenState
    extends State<AddOrganisationContactScreen> {
  final _searchController = TextEditingController();
  final OrganisationService _orgService = OrganisationService();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  Future<void> _searchUsers(String query) async {
    if (query.length < 2) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isLoading = true);
    final results = await _orgService.searchUsers(query);
    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  Future<void> _addContact(Map<String, dynamic> user) async {
    setState(() => _isLoading = true);
    final result = await _orgService.addContact(user['id'],organizationId: widget.organisationId);
    setState(() => _isLoading = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
      Navigator.pop(context, true); // true to indicate success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter un Contact")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: VUGepTextField(
              controller: _searchController,
              onChanged: _searchUsers,
              hintText: "Rechercher par nom ou email",
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(defaultPadding),
              child: CircularProgressIndicator(),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final user = _searchResults[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(user['name'][0]),
                  ),
                  title: Text(user['name']),
                  subtitle: Text(user['email'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.person_add, color: primaryColor),
                    onPressed: () => _addContact(user),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
