import 'package:flutter/material.dart';
import 'package:gep_point/components/card/common_card.dart';
import 'package:gep_point/constants.dart';
import 'package:gep_point/models/m_transaction.dart';
import 'package:intl/intl.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionTile({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    // Déterminer si c'est une entrée ou sortie (ex: si receiverId est l'utilisateur actuel)
    // Pour l'instant on se base sur le type ou on pourrait passer l'ID de l'utilisateur
    final bool isIncome = transaction.type == 'receive' || transaction.type == 'distribution';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding / 2, vertical: defaultPadding / 2),
      child: CommonCard(
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: isIncome ? primaryColor : Colors.red[600],
                child: Icon(
                  isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.type.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isIncome ? "De: ID ${transaction.receiverName}" : "Vers: ID ${transaction.receiverName}",
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ref: TX-${transaction.id}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(transaction.createdAt),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${isIncome ? '+' : '-'}${transaction.amount.toStringAsFixed(2)} pts",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isIncome ? primaryColor : Colors.red[400],
                    ),
                  ),
                  if (transaction.fee > 0)
                    Text(
                      "Frais: ${transaction.fee}",
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
