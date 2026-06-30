import 'package:flutter/material.dart';
import 'package:gep_point/providers/auth_provider.dart';
import 'package:gep_point/providers/transaction_provider.dart';
import 'package:gep_point/screen/home/transaction_tile.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(context, listen: false).fetchTransactions();
      Provider.of<TransactionProvider>(context, listen: false).fetchWithdrawals();
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
          "Historique",
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500, fontSize: 13),
          tabs: const [
            Tab(text: "Conversions"),
            Tab(text: "Retraits"),
            Tab(text: "Envois"),
            Tab(text: "Reçus"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFilteredList('conversion'),
          _buildWithdrawalList(),
          _buildTransferList(isSent: true),
          _buildTransferList(isSent: false),
        ],
      ),
    );
  }

  Widget _buildFilteredList(String type) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());
        
        final list = provider.transactions
            .where((t) => t.type.toLowerCase() == type.toLowerCase())
            .toList();

        if (list.isEmpty) return _buildEmptyState("Aucune transaction trouvée.");

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) => TransactionTile(transaction: list[index]),
        );
      },
    );
  }

  Widget _buildTransferList({required bool isSent}) {
    final currentUserId = context.read<AuthProvider>().user?.id;
    
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());
        
        // Les transferts sont de type 'transfer' ou 'receive' ou 'distribution'
        final transfers = provider.transactions.where((t) {
          final type = t.type.toLowerCase();
          if (type == 'conversion' || type == 'purchase' || type == 'purse') return false;
          
          if (isSent) {
            // Envois : je suis l'envoyeur
            return t.fromUserId == currentUserId;
          } else {
            // Reçus : je suis le destinataire
            return t.toUserId == currentUserId;
          }
        }).toList();

        if (transfers.isEmpty) return _buildEmptyState(isSent ? "Aucun envoi trouvé." : "Aucun reçu trouvé.");

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: transfers.length,
          itemBuilder: (context, index) => TransactionTile(transaction: transfers[index]),
        );
      },
    );
  }

  Widget _buildWithdrawalList() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());
        
        final withdrawals = provider.withdrawals;

        if (withdrawals.isEmpty) return _buildEmptyState("Aucun retrait trouvé.");

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: withdrawals.length,
          itemBuilder: (context, index) {
            final w = withdrawals[index];
            return _buildWithdrawalTile(context, w);
          },
        );
      },
    );
  }

  Widget _buildWithdrawalTile(BuildContext context, dynamic w) {
    final theme = Theme.of(context);
    final isConfirmed = w.status.toLowerCase() == 'confirmed';
    final color = isConfirmed ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isConfirmed ? Icons.check_circle_outline : Icons.pending_actions_rounded,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Retrait Cash",
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  DateFormat('dd MMM yyyy à HH:mm').format(w.createdAt),
                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${w.amount.toStringAsFixed(0)} pts",
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                "\$${w.usdValue.toStringAsFixed(2)}",
                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  w.status.toUpperCase(),
                  style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
