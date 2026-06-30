import 'package:flutter/material.dart';
import 'package:gep_point/components/v_gep_primary_b.dart';
import 'package:gep_point/components/v_gep_text_field.dart';
import 'package:gep_point/constants.dart';
import 'package:gep_point/services/s_organisation.dart';

class CreateOrganisationScreen extends StatefulWidget {
  const CreateOrganisationScreen({super.key,required this.currentUserId});
  final int currentUserId;
  @override
  State<CreateOrganisationScreen> createState() => _CreateOrganisationScreenState();
}

class _CreateOrganisationScreenState extends State<CreateOrganisationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _marketeurCodeController = TextEditingController();
  
  bool _isLoading = false;

  
  
  final OrganisationService _orgService = OrganisationService();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
   

    setState(() => _isLoading = true);

    try {
      final result = await _orgService.createOrganisation(
        name: _nameController.text,
        description: _descriptionController.text,
        validatorUserId: widget.currentUserId,
        marketeurCode: _marketeurCodeController.text.isNotEmpty ? _marketeurCodeController.text : null,
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
        Navigator.pop(context);
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
    return Scaffold(
      appBar: AppBar(title: const Text("Créer une Organisation")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(defaultPadding),
          children: [
            VUGepTextField(
              controller: _nameController,
              hintText: "Nom de l'organisation",
              validator: (v) => v!.isEmpty ? "Champ requis" : null,
            ),
            const SizedBox(height: defaultPadding),
            VUGepTextField(
              controller: _descriptionController,
              hintText: "Description",
              maxLines: 3,
            ),
            const SizedBox(height: defaultPadding),
            VUGepTextField(
              controller: _marketeurCodeController,
              hintText: "Code marketeur (Optionnel)",
            ),
            const SizedBox(height: defaultPadding),
            
            Text("Choisir un validateur (Optionnel, par défaut vous-même)", style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            
            

            const SizedBox(height: defaultPadding * 2),
            VGepPrimaryButton(
              text: "Créer l'organisation",
              loading: _isLoading,
              onPressed: _isLoading ? () {} : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
