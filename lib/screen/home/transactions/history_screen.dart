import 'package:flutter/material.dart';
import 'package:gep_point/constants.dart';
import 'package:gep_point/models/m_transaction.dart';
import 'package:gep_point/providers/transaction_provider.dart';
import 'package:gep_point/themes/app_colors.dart';
import 'package:provider/provider.dart';

class TransactionsHistoryScreen extends StatefulWidget {
  const TransactionsHistoryScreen({super.key});

  @override
  State<TransactionsHistoryScreen> createState() => _TransactionsHistoryScreenState();
}

class _TransactionsHistoryScreenState extends State<TransactionsHistoryScreen> {
  PageController pageController = PageController();

  int selectedPage = 0; // 0 = Envoi, 1 = Réception

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique des Transactions"),
        elevation: 0,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator(backgroundColor: primaryColor,));
          }

          final sentTransactions = provider.transactions.where((t) => t.type == 'transfer' || t.type == 'convert').toList();
          final receivedTransactions = provider.transactions.where((t) => t.type == 'receive' || t.type == 'distribution').toList();

          return Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              children: [
                /// Carte actions Envoyer / Recevoir
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ActionButton(
                        label: "Envoyer",
                        icon: Icons.send,
                        isSelected: selectedPage == 0,
                        onTap: () {
                          pageController.animateToPage(0, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                        },
                      ),
                      _ActionButton(
                        label: "Recevoir",
                        icon: Icons.download,
                        isSelected: selectedPage == 1,
                        onTap: () {
                          pageController.animateToPage(1, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                /// PageView des transactions
                Expanded(
                  child: provider.transactions.isEmpty 
                    ? const Center(child: Text("Aucune transaction"))
                    : PageView(
                        controller: pageController,
                        onPageChanged: (index) {
                          setState(() {
                            selectedPage = index;
                          });
                        },
                        children: [
                          /// Transactions envoyées
                          _TransactionsList(
                            transactions: sentTransactions,
                            isIncome: false,
                          ),

                          /// Transactions reçues
                          _TransactionsList(
                            transactions: receivedTransactions,
                            isIncome: true,
                          ),
                        ],
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

/// Widget pour le bouton d'action Envoyer / Recevoir
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.white30),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.white70),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Liste des transactions
class _TransactionsList extends StatelessWidget {
  final List<TransactionModel> transactions;
  final bool isIncome;

  const _TransactionsList({
    required this.transactions,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(child: Text("Aucune transaction dans cette catégorie"));
    }
    return ListView.separated(
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: primaryColor.withOpacity(0.1),
                child: const Icon(Icons.compare_arrows, color: primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.type.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tx.createdAt.toString().split(' ')[0],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "${isIncome ? '+' : '-'}${tx.amount.toStringAsFixed(2)}pts",
                style: TextStyle(
                  color: isIncome ? primaryColor : Colors.red[400],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
