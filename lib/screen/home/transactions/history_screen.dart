import 'package:flutter/material.dart';
import 'package:gep_point/constants.dart';
import 'package:gep_point/models/m_transaction.dart';
import 'package:gep_point/providers/auth_provider.dart';
import 'package:gep_point/providers/transaction_provider.dart';
import 'package:gep_point/screen/home/transaction_tile.dart';
import 'package:gep_point/themes/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionsHistoryScreen extends StatefulWidget {
  const TransactionsHistoryScreen({super.key});

  @override
  State<TransactionsHistoryScreen> createState() => _TransactionsHistoryScreenState();
}

class _TransactionsHistoryScreenState extends State<TransactionsHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().fetchTransactions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Historique des Transactions",
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500, fontSize: 14),
          tabs: const [
            Tab(text: "Envois"),
            Tab(text: "Reçus"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransferList(isSent: true),
          _buildTransferList(isSent: false),
        ],
      ),
    );
  }

  Widget _buildTransferList({required bool isSent}) {
    final currentUserId = context.read<AuthProvider>().user?.id;

    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.transactions.isEmpty) {
          return const Center(child: CircularProgressIndicator(backgroundColor: primaryColor));
        }

        // Filtrer les transactions (exclure conversion, purchase, purse)
        final transfers = provider.transactions.where((t) {
          final type = t.type.toLowerCase();
          // Exclure les types spécifiques
          if (type == 'conversion' || type == 'purchase' || type == 'purse') return false;

          if (isSent) {
            // Envois : je suis l'envoyeur
            return t.fromUserId == currentUserId;
          } else {
            // Reçus : je suis le destinataire
            return t.toUserId == currentUserId;
          }
        }).toList();

        if (transfers.isEmpty) {
          return Center(
            child: Text(
              isSent ? "Aucun envoi trouvé." : "Aucun reçu trouvé.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: transfers.length,
          itemBuilder: (context, index) => TransactionTile(transaction: transfers[index]),
        );
      },
    );
  }
}
