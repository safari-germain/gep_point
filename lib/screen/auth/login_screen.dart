import 'package:flutter/material.dart';
import 'package:gep_point/constants.dart';
import 'package:gep_point/navigation/bottom_navigation.dart';
import 'package:gep_point/screen/auth/signup_screen.dart';
import 'package:gep_point/providers/auth_provider.dart';
import 'package:gep_point/screen/auth/forgot_password_screen.dart';
import 'package:gep_point/screen/auth/google_auth/google_sign_in_service.dart';
import 'package:provider/provider.dart';

import 'components/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? email;
  String? password;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    GoogleSignInService.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Image.asset(
                                        "assets/images/logo.png",
                                        height: 100,
                                      ),
                      ),
                      Center(
                        child: Text(
                          "GEP POINT !",
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: primaryColor),
                        ),
                      ),
                      const SizedBox(height: defaultPadding / 4),
                      Center(
                        child: const Text(
                          "Connectez vous à votre compte.",
                        ),
                      ),
                      const SizedBox(height: defaultPadding),
                      LogInForm(
                        formKey: _formKey,
                        onEmailSaved: (value) => email = value,
                        onPasswordSaved: (value) => password = value,
                      ),
                      Align(
                        child: TextButton(
                          child: const Text("Mot de passe oublier?"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: double.maxFinite,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              
                              final authProvider = Provider.of<AuthProvider>(context, listen: false);
                              final success = await authProvider.login(email!, password!);
                              
                              if (success) {
                                Navigator.pushReplacement(
                                  context, 
                                  MaterialPageRoute(builder: (_) => const MainNavigation())
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(authProvider.error ?? "Erreur de connexion")),
                                );
                              }
                            }
                          },
                          child: context.watch<AuthProvider>().isLoading 
                            ? const CircularProgressIndicator(color: Colors.white) 
                            : const Text("Log in"),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Je n'ai pas de compte?"),
                          TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen()));
                            },
                            child: const Text("Créer"),
                          )
                        ],
                      ),
                      SizedBox(
                        height: defaultPadding,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                            icon: Image.asset(
                              "assets/images/google.png",
                              height: 22,
                            ),
                            label: Text(
                              "Se connecter avec Google",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: primaryColor, fontSize: 14),
                            ),
                            onPressed: () async {
                              try {
                                final googleUser = await GoogleSignInService.instance.signIn();
                                if (googleUser != null) {
                                  final email = googleUser.email;
                                  final googleId = googleUser.id;
                                  
                                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                  final success = await authProvider.login(email, googleId);
                                  
                                  if (success && mounted) {
                                    Navigator.pushReplacement(
                                      context, 
                                      MaterialPageRoute(builder: (_) => const MainNavigation())
                                    );
                                  } else if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(authProvider.error ?? "Erreur de connexion Google")),
                                    );
                                  }
                                }
                              } catch (error) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Échec de la connexion avec Google")),
                                  );
                                }
                              }
                            }),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
