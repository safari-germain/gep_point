// splash_screen.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 4), () {
      // Naviguer vers l'écran suivant
      // Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fond sombre
      body: Center(
        child: Shimmer.fromColors(
          baseColor: Colors.blue,
          highlightColor: Colors.grey.shade300,
          child: Image.asset(
            'assets/logo.png',
            width: 200,
          ),
        ),
      ),
    );
  }
}
