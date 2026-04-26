import 'package:flutter/material.dart';
import 'package:gep_point/constants.dart';
import 'package:gep_point/providers/conversion_provider.dart';
import 'package:gep_point/themes/app_colors.dart';
import 'package:provider/provider.dart';

class ConversionHistoryScreen extends StatefulWidget {
  const ConversionHistoryScreen({super.key});

  @override
  State<ConversionHistoryScreen> createState() => _ConversionHistoryScreenState();
}

class _ConversionHistoryScreenState extends State<ConversionHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConversionProvider>().fetchConversions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique des Conversions"),
        elevation: 0,
      ),
      body: Consumer<ConversionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.conversions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final conversions = provider.conversions;

          // Calcul balance total
          final totalStandard = conversions.fold<double>(0, (previousValue, element) => previousValue + element.standardAmount);
          final totalCash = conversions.fold<double>(0, (previousValue, element) => previousValue + element.cashAmount);

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                /// Balance totale
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Balance totale",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${totalStandard.toStringAsFixed(2)} pts",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                "Standard",
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${totalCash.toStringAsFixed(2)} \$",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                "Cash estimé",
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// Liste des conversions
                Expanded(
                  child: conversions.isEmpty 
                    ? const Center(child: Text("Aucune conversion"))
                    : ListView.separated(
                        itemCount: conversions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final conversion = conversions[index];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.card.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(defaultPadding),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Conversion #${conversion.id}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Date: ${conversion.createdAt.day.toString().padLeft(2, '0')}-${conversion.createdAt.month.toString().padLeft(2, '0')}-${conversion.createdAt.year}",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Standard: ${conversion.standardAmount.toStringAsFixed(2)} pts",
                                          style: const TextStyle(color: Colors.white, fontSize: 14),
                                        ),
                                        Text(
                                          "Cash: ${conversion.cashAmount.toStringAsFixed(2)} \$",
                                          style: const TextStyle(color: Colors.white, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Frais: ${conversion.fee.toStringAsFixed(2)} \$",
                                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                                        ),
                                        Text(
                                          "Taux: ${conversion.rate.toStringAsFixed(2)}",
                                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
