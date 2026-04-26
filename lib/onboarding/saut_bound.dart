import 'package:flutter/material.dart';
import 'package:gep_point/constants.dart';
import 'package:gep_point/navigation/bottom_navigation.dart';
import 'package:gep_point/onboarding/onboarding_screen.dart';
import 'package:gep_point/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BounceLogoSplash extends StatefulWidget {
  const BounceLogoSplash({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BounceLogoSplashState createState() => _BounceLogoSplashState();
}

class _BounceLogoSplashState extends State<BounceLogoSplash> with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _circleController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _circleScaleAnimation;

  bool _showCircle = false;
  bool _isFirstTime = true;

  @override
  void initState() {
    super.initState();

    _checkFirstTime();

    // Bounce animation
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _bounceAnimation = CurvedAnimation(
      parent: _bounceController,
      curve: Curves.bounceOut,
    );

    _bounceController.forward().whenComplete(() {
      if (_isFirstTime) {
        // Show circle after bounce
        setState(() => _showCircle = true);
        _circleController.forward();
      } else {
        // Skip to navigation
        _navigateAfterSplash();
      }
    });

    // Circle animation
    _circleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _circleScaleAnimation = Tween<double>(begin: 0.0, end: 12.0).animate(
      CurvedAnimation(parent: _circleController, curve: Curves.easeInOut),
    );

    _circleController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        await _setSplashSeen();
        _navigateAfterSplash();
      }
    });
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    _isFirstTime = prefs.getBool('splash_seen') ?? true;
  }

  Future<void> _setSplashSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('splash_seen', false);
  }

  void _navigateAfterSplash() async {
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // On force la vérification du token et des infos utilisateur
    await authProvider.checkLoginStatus();

    if (mounted) {
      if (authProvider.user != null) {
        // Utilisateur connecté -> Accueil
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      } else {
        // Non connecté -> Vérifier si Onboarding déjà vu
        final prefs = await SharedPreferences.getInstance();
        bool seenOnboarding = prefs.getBool('onboarding_seen') ?? false;
        
        if (seenOnboarding) {
           // Déjà vu onboarding -> Login (supposant que OnboardingScreen gère le login ou qu'il y a un LoginScreen)
           // Ici on suit la logique existante ou on redirige vers Onboarding qui contient le bouton Login
           Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _circleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Logo bounce
          Center(
            child: ScaleTransition(
              scale: _bounceAnimation,
              child: Image.asset('assets/images/logo.png', width: 200),
            ),
          ),

          // Expanding circle (only if first time)
          if (_showCircle)
            AnimatedBuilder(
              animation: _circleScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _circleScaleAnimation.value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

// Exemple de LoginPage
