import 'package:flutter/material.dart';
import 'package:gep_point/constants.dart';
import 'package:gep_point/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String? email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mot de passe oublié"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Entrez votre adresse email pour recevoir un lien de réinitialisation.",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: defaultPadding * 2),
                TextFormField(
                  validator: emaildValidator.call,
                  onSaved: (value) => email = value,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: "Email",
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: defaultPadding * 2),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        final success = await authProvider.resetPassword(email!);
                        
                        if (success) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Un email de réinitialisation a été envoyé."),
                                backgroundColor: successColor,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(authProvider.error ?? "Erreur de réinitialisation"),
                                backgroundColor: errorColor,
                              ),
                            );
                          }
                        }
                      }
                    },
                    child: context.watch<AuthProvider>().isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text("Envoyer le lien"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
