import 'package:flutter/material.dart';
import 'package:gep_point/constants.dart';
import 'package:gep_point/providers/auth_provider.dart';
import 'package:gep_point/providers/profile_upgrade_provider.dart';
import 'package:gep_point/providers/wallet_provider.dart';
import 'package:gep_point/screen/profile/upgrade/components/upgrade_card_plan.dart';
import 'package:gep_point/screen/profile/upgrade/profile_wizard_screen.dart';
import 'package:provider/provider.dart';

class ProfileUpgradeScreen extends StatefulWidget {
  const ProfileUpgradeScreen({super.key});

  @override
  State<ProfileUpgradeScreen> createState() => _ProfileUpgradeScreenState();
}

class _ProfileUpgradeScreenState extends State<ProfileUpgradeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileUpgradeProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final wallet = context.watch<WalletProvider>();
    final upgradeProvider = context.watch<ProfileUpgradeProvider>();
    final currentLevel = user?.profileLevel ?? 1;

    if (upgradeProvider.isLoading && upgradeProvider.allCompetences.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final plans = [
      {
        'level': 1,
        'title': 'Profil Basic',
        'price': 'Gratuit',
        'color': greyColor,
        'features': [
          'Informations de base (nom, adresse)',
          '1 seule compétence affichée',
          'Visibilité standard',
        ],
      },
      {
        'level': 2,
        'title': 'Profil Moyen',
        'price': '${upgradeProvider.getUpgradePrice(2)} pts',
        'color': primaryColor,
        'features': [
          'Tout du profil Basic',
          'Jusqu\'à 5 compétences',
          'Ajout d\'expériences professionnelles',
          'Badge de certification basique',
        ],
      },
      {
        'level': 3,
        'title': 'Profil Supérieur',
        'price': '${upgradeProvider.getUpgradePrice(3)} pts',
        'color': Colors.amber.shade700,
        'features': [
          'Tout du profil Moyen',
          'Compétences illimitées',
          'Portfolio avec photos de projets',
          'Certifications avec justificatifs',
          'Priorité dans les recherches',
        ],
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Améliorer mon Profil'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Text(
                  'Débloquez votre potentiel',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Choisissez le niveau qui correspond à vos ambitions professionnelles.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                final level = plan['level'] as int;
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _currentPage == index ? 1.0 : 0.5,
                  child: UpgradeCardPlan(
                    title: plan['title'] as String,
                    price: plan['price'] as String,
                    features: List<String>.from(plan['features'] as List),
                    isCurrent: currentLevel == level,
                    accentColor: plan['color'] as Color,
                    onUpgrade: () => _showConfirmUpgrade(context, level, plan['price'] as String),
                  ),
                );
              },
            ),
          ),
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              plans.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index ? primaryColor : Colors.grey.shade300,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.info_outline, color: Colors.blue.shade700),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Solde actuel',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          'Points Standards disponibles',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${wallet.getBalance('standard').toStringAsFixed(0)} pts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showConfirmUpgrade(BuildContext context, int level, String price) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 24),
            const Icon(Icons.rocket_launch_outlined, size: 64, color: primaryColor),
            const SizedBox(height: 16),
            const Text(
              'Confirmer l\'amélioration',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Vous êtes sur le point de passer au niveau $level pour $price. Cette action est irréversible.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () async {
                  final authProvider = context.read<AuthProvider>();
                  final upgradeProvider = context.read<ProfileUpgradeProvider>();

                  final result = await upgradeProvider.upgradeUser(level, authProvider);

                  if (context.mounted) {
                    Navigator.pop(context); // Close modal
                    if (result['success']) {
                      // Synchroniser les balances
                      context.read<WalletProvider>().fetchBalances();
                      
                      // Navigation vers le Wizard
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileWizardScreen(targetLevel: level),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result['message'])),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  
                ),
                child: const Text('Confirmer et Payer'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}
