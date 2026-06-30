import 'package:flutter/material.dart';
import 'package:gep_point/api_constants.dart';
import 'package:gep_point/components/indication_action_card.dart';
import 'package:gep_point/constants.dart';
import 'package:gep_point/screen/home/balance_screen.dart';
import 'package:gep_point/screen/home/coponents/point_chart.dart';
import 'package:gep_point/screen/home/recent_transaction.dart';
import 'package:gep_point/screen/qr/scan_screen.dart';
import 'package:gep_point/screen/qr/qr_genrator_screen.dart';
import 'package:gep_point/screen/point/send_point.dart';
import 'package:provider/provider.dart';
import 'package:gep_point/providers/conversion_provider.dart';
import 'package:gep_point/providers/auth_provider.dart';
import 'package:gep_point/providers/configuration_provider.dart';
import 'package:gep_point/screen/search/user_search_screen.dart';
import 'package:gep_point/components/withdrawal_cta_banner.dart';
import 'package:gep_point/screen/home/withdrawal_request_screen.dart';
import 'package:gep_point/screen/home/transactions/history_page.dart';
import 'package:gep_point/screen/notifications_screen.dart';
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
      Provider.of<ConfigurationProvider>(context, listen: false).fetchConfigurations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversionProvider = context.watch<ConversionProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final rates = conversionProvider.rates;
    final rateString = rates.isNotEmpty ? '1 point = ${rates['standard_to_cash'] ?? 'N/A'} USD' : '1 point = 2 450 USD';
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar Personnalisée
            SliverAppBar(
              expandedHeight: 80.0,
              floating: true,
              pinned: true,
              backgroundColor: theme.colorScheme.surface,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: 12),
                  child: Row(
                    children: [
                      ClipOval(
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: user?.profile != null
                              ? Image.network(
                                  '$baseURlForImages/${user!.profile!}',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return CircleAvatar(
                                      radius: 24,
                                      backgroundColor: theme.colorScheme.primaryContainer,
                                      child: Icon(Icons.person, color: theme.colorScheme.primary),
                                    );
                                  },
                                )
                              : CircleAvatar(
                                  radius: 24,
                                  backgroundColor: theme.colorScheme.primaryContainer,
                                  child: Icon(Icons.person, color: theme.colorScheme.primary),
                                ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Bonjour,",
                              style: theme.textTheme.labelLarge?.copyWith(color: Colors.grey.shade600),
                            ),
                            Text(
                              user?.name ?? "Membre",
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                        },
                        color: theme.colorScheme.onSurface,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Barre de recherche MD3
                    const SizedBox(height: 8),
                    Hero(
                      tag: 'search_bar',
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserSearchScreen())),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
                                const SizedBox(width: 12),
                                Text(
                                  "Rechercher un talent...",
                                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // CTA Retrait (si activé)
                    Consumer<ConfigurationProvider>(
                      builder: (context, config, child) {
                        if (config.isEnabled('withdrawal_enabled')) {
                          return WithdrawalCtaBanner(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const WithdrawalRequestScreen()),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    const SizedBox(height: 24),

                    // Soldes
                    Text("Vos Portefeuilles", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const VBalanceCarousel(),

                    const SizedBox(height: 24),

                    // Actions Rapides
                    Text("Actions Rapides", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickAction(context, Icons.qr_code_scanner, "Scanner",
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanScreen()))),
                        _buildQuickAction(context, Icons.qr_code_rounded, "Recevoir",
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => MyQrScreen()))),
                        _buildQuickAction(context, Icons.currency_exchange_rounded, "Convertir", () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Fonctionnalité 'Convertir' bientôt disponible.")),
                          );
                        }),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Indicateur de taux
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: VIndicationCard(
                        icon: Icons.trending_up,
                        typepoint: "Taux Standard",
                        rate: rateString,
                        label: "Estimation actuelle",
                        gradientColors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.8),
                        ],
                        onTap: () {},
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Graphique
                    PointsChart(),

                    const SizedBox(height: 32),

                    // Transactions récentes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Transactions récentes",
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const HistoryPage()),
                          ),
                          child: const Text("Voir tout"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const RecentTransaction(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: theme.colorScheme.primaryContainer,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Icon(icon, color: theme.colorScheme.onPrimaryContainer, size: 28),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
