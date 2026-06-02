import 'package:flutter/material.dart';
import 'package:gep_point/constants.dart';
import 'package:gep_point/models/m_transaction.dart';
import 'package:gep_point/models/m_point_sale.dart';
import 'package:gep_point/providers/transaction_provider.dart';
import 'package:gep_point/providers/point_sale_provider.dart';
import 'package:gep_point/themes/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OperationsHistroryMarchandPointScreen extends StatefulWidget {
  const OperationsHistroryMarchandPointScreen({super.key, required this.organisationId});
  final int organisationId;

  @override
  State<OperationsHistroryMarchandPointScreen> createState() => _OperationsHistroryMarchandPointScreenState();
}

class _OperationsHistroryMarchandPointScreenState extends State<OperationsHistroryMarchandPointScreen> {
  PageController pageController = PageController();
  int selectedPage = 0; // 0 = Envoi, 1 = Réception

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().fetchOrganisationTransfers(widget.organisationId);
      context.read<PointSaleProvider>().fetchSales(widget.organisationId);
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique de transfert et réception"),
        elevation: 0,
      ),
      body: Consumer2<TransactionProvider, PointSaleProvider>(
        builder: (context, txProvider, saleProvider, child) {
          final sentTransactions = txProvider.transactions;
          final receivedSales = saleProvider.sales;

          final isLoading = txProvider.isLoading && sentTransactions.isEmpty || saleProvider.isLoading && receivedSales.isEmpty;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              children: [
                // Carte actions Envoyé / Reçu
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
                        label: "Envoyés",
                        icon: Icons.send,
                        isSelected: selectedPage == 0,
                        onTap: () {
                          if (pageController.hasClients) {
                            pageController.animateToPage(0, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                          }
                        },
                      ),
                      _ActionButton(
                        label: "Reçu",
                        icon: Icons.download,
                        isSelected: selectedPage == 1,
                        onTap: () {
                          if (pageController.hasClients) {
                            pageController.animateToPage(1, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // PageView
                Expanded(
                  child: PageView(
                    controller: pageController,
                    onPageChanged: (index) {
                      setState(() {
                        selectedPage = index;
                      });
                    },
                    children: [
                      // Envois
                      _TransactionsList(
                        transactions: sentTransactions,
                        isIncome: false,
                        loadMore: () => txProvider.fetchOrganisationTransfers(widget.organisationId, loadMore: true),
                        hasMore: txProvider.currentPage < txProvider.lastPage,
                      ),
                      // Réceptions
                      _SalesList(
                        sales: receivedSales,
                        loadMore: () => saleProvider.fetchSales(widget.organisationId, loadMore: true),
                        hasMore: saleProvider.currentPage < saleProvider.lastPage,
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

// --------------------- WIDGETS --------------------- //

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

// --------------------- Transactions --------------------- //
class _TransactionsList extends StatelessWidget {
  final List<TransactionModel> transactions;
  final bool isIncome;
  final VoidCallback loadMore;
  final bool hasMore;

  const _TransactionsList({
    required this.transactions,
    required this.isIncome,
    required this.loadMore,
    required this.hasMore,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(child: Text("Aucune transaction"));
    }

    return ListView.separated(
      itemCount: transactions.length + (hasMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        if (index == transactions.length && hasMore) {
          loadMore();
          return const Center(child: CircularProgressIndicator());
        }

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
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(Icons.compare_arrows, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.type.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
  'Effectué le ${DateFormat('dd/MM/yyyy à HH:mm').format(tx.createdAt)}',
  style: const TextStyle(fontSize: 12, color: Colors.grey),
),
                    const SizedBox(height: 4),
                    Text(
                      "Envoyé à : ${tx.receiverName ?? 'Inconnu'} \nType de point: ${tx.pointType}  \nFrais de transaction: ${tx.fee.toStringAsFixed(2)} pts \nStatut de transfert: ${tx.status}",
                      style: const TextStyle(fontSize: 12,),
                    ),
                  ],
                ),
              ),
              Text(
                "${isIncome ? '+' : '-'}${tx.amount.toStringAsFixed(2)} pts",
                style: TextStyle(
                  color: isIncome ? AppColors.primary : Colors.red[400],
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
// --------------------- Sales --------------------- //
class _SalesList extends StatelessWidget {
  final List<PointSaleModel> sales;
  final VoidCallback loadMore;
  final bool hasMore;

  const _SalesList({
    required this.sales,
    required this.loadMore,
    required this.hasMore,
  });

  @override
  Widget build(BuildContext context) {
    if (sales.isEmpty) {
      return const Center(child: Text("Aucune réception"));
    }

    return ListView.separated(
      itemCount: sales.length + (hasMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        if (index == sales.length && hasMore) {
          loadMore();
          return const Center(child: CircularProgressIndicator());
        }

        final sale = sales[index];

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
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(Icons.download, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "RÉCEPTION",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sale.createdAt.toString().split(' ')[0],
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Text(
                "+${sale.quantity.toStringAsFixed(2)} pts",
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}