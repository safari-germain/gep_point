import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gep_point/components/v_gep_primary_b.dart';
import 'package:gep_point/constants.dart';

class Step1Otp extends StatefulWidget {
  final Function(String) onVerified;

  const Step1Otp({super.key, required this.onVerified});

  @override
  State<Step1Otp> createState() => _Step1OtpState();
}

class _Step1OtpState extends State<Step1Otp> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String? _verificationId;
  bool _codeSent = false;

  void _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-resolution (rarely happens automatically except on some Android devices)
          setState(() => _isLoading = false);
          widget.onVerified(phone);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _isLoading = false);
          debugPrint("Firebase Phone Auth Error: ${e.code} - ${e.message}");
          String errorMessage = "Erreur d'envoi OTP";
          if (e.code == 'configuration-not-found') {
            errorMessage = "Configuration Firebase manquante (Console).";
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _isLoading = false;
            _verificationId = verificationId;
            _codeSent = true;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _verifyOtp() async {
    final code = _codeController.text.trim();
    if (code.isEmpty || _verificationId == null) return;

    setState(() => _isLoading = true);
    
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );

      // We just need to verify it's valid. We might not need to sign in permanently if we use our own backend
      // But we must sign in to credential to prove ownership.
      await FirebaseAuth.instance.signInWithCredential(credential);
      
      setState(() => _isLoading = false);
      widget.onVerified(_phoneController.text.trim());
      
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Code OTP invalide")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Vérification du numéro",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: defaultPadding),
        if (!_codeSent) ...[
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: "Numéro de téléphone (+243...)",
              hintText: "+243812345678",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: defaultPadding),
          SizedBox(
            width: double.infinity,
            child: VGepPrimaryButton(
              onPressed: _isLoading ? () {} : _sendOtp,
              text: "Suivant",
              loading: _isLoading,
            ),
          ),
        ] else ...[
          TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Code de vérification",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: defaultPadding),
          SizedBox(
            width: double.infinity,
            child: VGepPrimaryButton(
              onPressed: _isLoading ? () {} : _verifyOtp,
              text: "Vérifier",
              loading: _isLoading,
            ),
          ),
          TextButton(
             onPressed: () {
               setState(() {
                 _codeSent = false;
               });
             }, 
             child: const Text("Changer de numéro"),
          ),
        ],
      ],
    );
  }
}
