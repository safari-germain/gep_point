import 'package:flutter/material.dart';
import 'package:gep_point/constants.dart';
import 'package:gep_point/providers/transaction_provider.dart';
import 'package:gep_point/screen/home/transaction_tile.dart';
import 'package:provider/provider.dart';

class RecentTransaction extends StatefulWidget {
  const RecentTransaction({super.key});

  @override
  State<RecentTransaction> createState() => _RecentTransactionState();
}

class _RecentTransactionState extends State<RecentTransaction> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(context, listen: false).fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();

    if (transactionProvider.isLoading) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.all(defaultPadding),
        child: CircularProgressIndicator(),
      ));
    }

    final transactions = transactionProvider.transactions.take(10).toList();

    if (transactions.isEmpty) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.all(defaultPadding),
        child: Text("Aucune transaction récente"),
      ));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: defaultPadding / 5),
      itemBuilder: (context, index) {
        return TransactionTile(
          transaction: transactions[index],
        );
      },
    );
  }
}
