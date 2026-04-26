import 'package:flutter/material.dart';
import 'package:gep_point/navigation/bottom_navigation.dart';
import 'package:gep_point/providers/auth_provider.dart';
import 'package:gep_point/screen/auth/components/sign_up_form.dart';
import 'package:gep_point/screen/auth/components/step_3_profile.dart';
import 'package:gep_point/screen/auth/google_auth/google_sign_in_service.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  int _currentStep = 1;

  final _formKey = GlobalKey<FormState>();
  String? email;
  String? pass;
  String? phone;
  String? confirm;
  String? name;
  String? agentCode;
  bool conditionPolitionContranct = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    GoogleSignInService.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Image.asset("assets/images/logo.png", height: _currentStep == 1 ? 140 : 80),
                ),
                Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: _buildCurrentStep(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context) {
    if (_currentStep == 1) {
      return _buildRegistrationForm(context);
    } else {
      return Step3Profile(
        onComplete: (file) async {
          if (file != null) {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            await authProvider.uploadProfilePicture(file);
          }
          if (mounted) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const MainNavigation()));
          }
        },
      );
    }
  }

  Widget _buildRegistrationForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Créer un compte", style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: defaultPadding),
        SignUpForm(
          formKey: _formKey,
          onNameSaved: (value) => name = value,
          onPhoneSaved: (value) => phone = value,
          onEmailSaved: (value) => email = value,
          onPasswordSaved: (value) => pass = value,
          onAgentCodeSaved: (value) => agentCode = value,
          onConfirmSaved: (value) => confirm = value,
        ),
        const SizedBox(height: defaultPadding),
        Row(
          children: [
            Checkbox(
              onChanged: (value) => setState(() => conditionPolitionContranct = value!),
              value: conditionPolitionContranct,
            ),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: "J'accepte la",
                  children: [
                    TextSpan(
                      text: " politique de confidentialité",
                      style: const TextStyle(color: primaryColor, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: defaultPadding),
        SizedBox(
          width: double.maxFinite,
          child: ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                if (pass != confirm) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mots de passe non identiques')));
                  return;
                }
                if (!conditionPolitionContranct) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez accepter la politique")));
                  return;
                }
                await _register(pass!);
              }
            },
            child: context.watch<AuthProvider>().isLoading 
                ? const CircularProgressIndicator(color: Colors.white) 
                : const Text("S'inscrire"),
          ),
        ),
        const SizedBox(height: defaultPadding),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: Image.asset("assets/images/google.png", height: 22),
            label: Text("S'inscrire avec Google", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: primaryColor)),
            onPressed: () async {
              try {
                final googleUser = await GoogleSignInService.instance.signIn();
                if (googleUser != null) {
                  email = googleUser.email;
                  name = googleUser.displayName ?? "Utilisateur Google";
                  final googleId = googleUser.id;
                  
                  await _register(googleId);
                }
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur de connexion Google")));
              }
            },
          ),
        ),
      ],
    );
  }

  Future<void> _register(String password) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      name: name ?? "Utilisateur",
      email: email ?? "",
      password: password,
      phone: phone ?? "",
      agentCode: agentCode,
    );

    if (success && mounted) {
      setState(() {
        _currentStep = 2;
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authProvider.error ?? "Erreur d'inscription")));
    }
  }
}
