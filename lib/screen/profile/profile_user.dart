import 'package:flutter/material.dart';
import 'package:gep_point/components/card/common_card.dart';
import 'package:gep_point/components/card_point/brush_metal_card.dart';
import 'package:gep_point/components/card_point/holographique_card.dart';
import 'package:gep_point/components/list_tile/divider_list_tile.dart';
import 'package:gep_point/constants.dart';
import 'package:gep_point/screen/profile/bottom_select_count.dart';
import 'package:gep_point/screen/profile/components/main_profile_card.dart';
import 'package:gep_point/screen/profile/components/profile_menu_item_list_tile.dart';
import 'package:gep_point/screen/profile/components/sub_profile_card.dart';
import 'package:gep_point/screen/profile/detail_profile_screen.dart';
import 'package:gep_point/screen/qr/qr_genrator_screen.dart';
import 'package:gep_point/screen/validator/validator_screen.dart';
import 'package:gep_point/screen/profile/language_screen.dart';
import 'package:gep_point/themes/configs/tc_theme_mode_provider.dart';
import 'package:gep_point/providers/auth_provider.dart';
import 'package:gep_point/providers/wallet_provider.dart';
import 'package:gep_point/providers/profile_provider.dart';
import 'package:gep_point/api_constants.dart';
import 'package:gep_point/screen/profile/upgrade/profile_upgrade_screen.dart';
import 'package:gep_point/screen/search/talent_detail_screen.dart';
import 'package:gep_point/screen/auth/login_screen.dart';
import 'package:provider/provider.dart';

class ProfileUserScren extends StatefulWidget {
  const ProfileUserScren({super.key});

  @override
  State<ProfileUserScren> createState() => _ProfileUserScrenState();
}

class _ProfileUserScrenState extends State<ProfileUserScren> {
  @override
  void initState() {
    super.initState();
    _loadBalances();
  }

  int id = 0;
  Future<void> _loadBalances() async {
    final walletProvider = context.read<WalletProvider>();
    final userProvider = context.read<AuthProvider>();
    final user = userProvider.user;
    if (user != null && user.id != 0) {
      setState(() {
        id = user.id;
      });
      await walletProvider.fetchBalances();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile utilisateur'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: [
              Consumer2<AuthProvider, ProfileProvider>(
                builder: (context, authProvider, profileProvider, child) {
                  final user = authProvider.user;

                  if (user == null) return const SizedBox();

                  String activeName = "${user.name} ${user.prenom ?? ''}";
                  String activeImage = getFullImageUrl('$baseURlForImages/${user.profile}');
                  String? inactiveImage;

                  if (profileProvider.activeMode == ProfileMode.organisation && user.organisation != null) {
                    activeName = user.organisation!.name;
                    activeImage = getFullImageUrl("$baseURlForImages/${user.organisation!.image}",
                        defaultImage: "assets/images/pharma.jpeg");
                    inactiveImage = getFullImageUrl('$baseURlForImages/${user.profile}');
                  }

                  return MainProfileCard(
                    name: activeName,
                    role: user.role,
                    email: user.email ?? '',
                    imageSrc: activeImage,
                    orgName: user.organisation?.name,
                    orgImageSrc: inactiveImage,
                    hasOrganisation: user.organisation != null,
                    press: () {
                      showRoleBottomSheet(context);
                    },
                  );
                },
              ),
              SizedBox(
                height: defaultPadding,
              ),
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final user = authProvider.user;
                  return SubProfileCard(
                    name: user?.name ?? 'Utilisateur',
                    imageSrc: getFullImageUrl("$baseURlForImages/${user?.profile}"),
                    press: () {
                      if (user != null && user.profileLevel >= 2) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => TalentDetailScreen(user: user)));
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailProfilScreen()));
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: defaultPadding),
              // Bannière Premium / Spécialisation
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileUpgradeScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [primaryColor, Color(0xFF6C56DD)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.stars, color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Devenir Premium',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Débloquez votre portfolio et vos expériences',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: defaultPadding),
              Consumer<WalletProvider>(
                builder: (context, walletProvider, child) {
                  return BrushedMetalCard(
                    child: HolographicCreditCard(
                      amount: walletProvider.getBalance('standard').toStringAsFixed(2), // renvoie "10"
                      baseGradient: [Color(0xFF141E30), Color(0xFF243B55)],
                      icon: Icons.cast_sharp,
                      subtitle: 'Total Point',
                      title: 'Point Standard',
                      onTap: () {},
                    ),
                  );
                },
              ),
              const SizedBox(height: defaultPadding),
              ProfileMenuListTile(
                text: "Mon Code QR",
                svgSrc: "assets/icons/Preferences.svg",
                press: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => MyQrScreen()));
                },
              ),
              const SizedBox(height: defaultPadding),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: defaultPadding / 2),
                child: Text(
                  "Tâches",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              ProfileMenuListTile(
                text: "Validateur",
                svgSrc: "assets/icons/diamond.svg",
                isShowDivider: true,
                trailing: Icon(
                  Icons.library_add_check,
                  color: primaryColor,
                ),
                press: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ValidatorScreen(
                                id: id,
                              )));
                },
              ),
              const SizedBox(height: defaultPadding),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: defaultPadding / 2),
                child: Text(
                  "Personalistation",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              DividerListTileWithTrilingText(
                svgSrc: "assets/icons/Notification.svg",
                title: "Notification",
                trilingText: "On",
                press: () {},
              ),
              ProfileMenuListTile(
                text: "Mode Sombre",
                svgSrc: "assets/icons/Preferences.svg",
                press: () {
                  Provider.of<ThemeModeProvider>(context, listen: false).toggleTheme();
                },
                trailing: Switch(
                  value: Theme.of(context).brightness == Brightness.dark,
                  onChanged: (value) {
                    Provider.of<ThemeModeProvider>(context, listen: false).toggleTheme();
                  },
                ),
              ),
              const SizedBox(height: defaultPadding),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: defaultPadding / 2),
                child: Text(
                  "Parametre",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              ProfileMenuListTile(
                text: "Langue",
                svgSrc: "assets/icons/Language.svg",
                press: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguageScreen()));
                },
              ),
              ProfileMenuListTile(
                text: "Obtenir de l'aide?",
                svgSrc: "assets/icons/Language.svg",
                isShowDivider: false,
                press: () {
                  //Navigator.pushNamed(context, selectLanguageScreenRoute);
                },
              ),
              SizedBox(
                height: defaultPadding,
              ),
              GestureDetector(
                onTap: () {
                  context.read<AuthProvider>().logout();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                child: CommonCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: defaultPadding / 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Se déconnecter',
                          style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w400),
                        ),
                        Icon(
                          Icons.logout,
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
