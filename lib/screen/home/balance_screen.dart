import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:gep_point/providers/wallet_provider.dart';
import 'package:gep_point/screen/profile/balance_card.dart';
import 'package:provider/provider.dart';

class VBalanceCarousel extends StatefulWidget {
  const VBalanceCarousel({super.key});

  @override
  State<VBalanceCarousel> createState() => _VBalanceCarouselState();
}

class _VBalanceCarouselState extends State<VBalanceCarousel> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WalletProvider>(context, listen: false).fetchBalances();
    });
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    
    if (walletProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final cards = [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: VBalanceCard(
          pointType: PointType.standard,
          balance: "${walletProvider.getBalance('standard')} pts",
          estimation: "≈ ${(walletProvider.getBalance('standard') * 0.02).toStringAsFixed(2)} USD", // Taux indicatif exemple
          onTap: () {},
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: VBalanceCard(
          pointType: PointType.cash,
          balance: "${walletProvider.getBalance('cash')} pts",
          estimation: "≈ ${walletProvider.getBalance('cash').toStringAsFixed(2)} USD",
          onTap: () {},
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: VBalanceCard(
          pointType: PointType.notoriete,
          balance: "${walletProvider.getBalance('notoriete')} pts",
          estimation: "Score: ${walletProvider.getBalance('notoriete')}",
          onTap: () {},
        ),
      ),
    ];

    return Column(
      children: [
        CarouselSlider(
          items: cards,
          options: CarouselOptions(
            height: 200,
            enlargeCenterPage: true,
            enlargeFactor: 0.25,
            viewportFraction: 0.85,
            autoPlay: false,
            enableInfiniteScroll: cards.length > 1,
            onPageChanged: (index, reason) {
              setState(() => _currentIndex = index);
            },
          ),
        ),

        const SizedBox(height: 12),

        /// INDICATEUR
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(cards.length, (index) {
            final isActive = _currentIndex == index;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 18 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isActive ? Colors.deepPurple : Colors.grey.shade400,
              ),
            );
          }),
        ),
      ],
    );
  }
}
