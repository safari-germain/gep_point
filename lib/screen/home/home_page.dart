import 'package:flutter/material.dart';
import 'package:gep_point/components/indication_action_card.dart';
import 'package:gep_point/constants.dart';
import 'package:gep_point/screen/home/balance_screen.dart';
import 'package:gep_point/screen/home/coponents/point_chart.dart';
import 'package:gep_point/screen/home/recent_transaction.dart';
import 'package:gep_point/screen/qr/scan_screen.dart';
import 'package:provider/provider.dart';
import 'package:gep_point/providers/conversion_provider.dart';
import 'package:gep_point/screen/search/user_search_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ConversionProvider>(context, listen: false).fetchRates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversionProvider = context.watch<ConversionProvider>();
    final rates = conversionProvider.rates;
    final rateString = rates.isNotEmpty ? '1 point = ${rates['standard_to_cash'] ?? 'N/A'} USD' : '1point = 2 450 USD';

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ScanScreen())),
        child: const Icon(
          Icons.qr_code_scanner,
          size: 28,
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          physics: BouncingScrollPhysics(),
          children: [
            const SizedBox(height: defaultPadding),
            // Barre de recherche
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserSearchScreen())),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 12),
                    Text("Rechercher un membre, une compétence...", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: defaultPadding),
            // Taux indicatif
            SizedBox(
              height: defaultPadding,
            ),
            VIndicationCard(
              icon: Icons.trending_up,
              typepoint: "Point Standard",
              rate: rateString,
              label: "Estimation du taux actuel",
              gradientColors: [
                Color(0xFF141E30),
                Color(0xFF243B55),
              ],
              onTap: () {},
            ),

            SizedBox(
              height: defaultPadding,
            ),
            const SizedBox(height: defaultPadding),
            PointsChart(),
            VBalanceCarousel(),
            const SizedBox(height: 16),
            const Text(
              "Transactions récentes",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            /// Liste des transactions
            RecentTransaction(),
          ],
        ),
      ),
    );
  }
}
