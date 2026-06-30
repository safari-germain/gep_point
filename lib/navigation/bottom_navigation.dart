import 'package:flutter/material.dart';
import 'package:gep_point/constants.dart';
import 'package:gep_point/screen/home/conversion/history_conversion.dart';
import 'package:gep_point/screen/home/home_page.dart';
import 'package:gep_point/screen/home/transactions/history_page.dart';
import 'package:gep_point/screen/home/transactions/history_screen.dart';
import 'package:gep_point/screen/profile/profile_user.dart';
import 'package:iconsax/iconsax.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  final pages = const [
    HomePage(),
    HistoryPage(),
    TransactionsHistoryScreen(),
    ProfileUserScren(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 8, left: 2, right: 2),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey.withOpacity(0.5),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(
              icon: Iconsax.home,
              label: 'Accueil',
              index: 0,
            ),
            _navItem(
              icon: Iconsax.tick_circle,
              label: 'Historique',
              index: 1,
            ),
            _navItem(
              icon: Iconsax.arrow_swap_horizontal,
              label: 'Transfert',
              index: 2,
            ),
            _navItem(
              icon: Iconsax.user,
              label: 'Profil',
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _index == index;
    final primary = primaryColor;

    return GestureDetector(
      onTap: () => setState(() => _index = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔹 Barre au-dessus
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 3,
            width: isSelected ? 30 : 0,
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 6),

          Icon(
            icon,
            color: isSelected ? primary : Colors.grey,
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: TextStyle(
              color: isSelected ? primary : Colors.grey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
