import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gep_point/notification/notification_manager.dart';

import 'package:gep_point/onboarding/saut_bound.dart';
import 'package:gep_point/providers/auth_provider.dart';
import 'package:gep_point/providers/point_sale_provider.dart';
import 'package:gep_point/providers/wallet_provider.dart';
import 'package:gep_point/providers/conversion_provider.dart';
import 'package:gep_point/providers/profile_provider.dart';
import 'package:gep_point/providers/transaction_provider.dart';
import 'package:gep_point/providers/profile_upgrade_provider.dart';
import 'package:gep_point/providers/configuration_provider.dart';
import 'package:gep_point/providers/promotion_provider.dart';
import 'package:gep_point/services/s_dio/dio_service.dart';
import 'package:gep_point/themes/configs/tc_theme_mode_provider.dart';
import 'package:gep_point/themes/theme.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Pour changer la couleur du status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color.fromARGB(255, 218, 209, 253),
  ));

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialiser les notifications
  await NotificationManager.initialize();

  // Initialiser ApiClient (Dio)
  await ApiClient().init();

  // Initialiser SharedPreferences
  await SharedPreferences.getInstance();

  // Forcer l'orientation portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeModeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => ConversionProvider()),
        ChangeNotifierProvider(create: (_) => PointSaleProvider()),
        ChangeNotifierProvider(create: (_) => ProfileUpgradeProvider()),
        ChangeNotifierProvider(create: (_) => ConfigurationProvider()),
        ChangeNotifierProvider(create: (_) => PromotionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'GEP POINT',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate, // Pour les widgets Material
            GlobalWidgetsLocalizations.delegate, // Pour les fonctionnalités de base
            GlobalCupertinoLocalizations.delegate, // Pour les widgets iOS
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('fr'),
            Locale('es'),
            Locale('sw'),
          ],
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeProvider.themeMode,
          home: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: const BounceLogoSplash(),
          ),
        );
      },
    );
  }
}
