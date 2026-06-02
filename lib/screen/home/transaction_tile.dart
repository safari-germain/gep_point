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
    final theme = Theme.of(context);
    final bool isIncome = transaction.type == 'receive' || transaction.type == 'distribution';
    
    // Icone et couleur
    final iconData = isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final color = isIncome ? theme.colorScheme.primary : theme.colorScheme.error;
    final bgColor = isIncome ? theme.colorScheme.primaryContainer : theme.colorScheme.errorContainer;
    final iconColor = isIncome ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onErrorContainer;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(iconData, color: iconColor, size: 24),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _getDisplayName(transaction, isIncome),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              "${isIncome ? '+' : '-'}${transaction.amount.toStringAsFixed(0)} pts",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getTypeLabel(transaction),
                  style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                Text(
                  DateFormat('dd MMM HH:mm').format(transaction.createdAt),
                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            if (transaction.fee > 0) ...[
              const SizedBox(height: 2),
              Text(
                "Frais: ${transaction.fee}",
                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.error),
              ),
            ]
          ],
        ),
      ),
    );
  }

  String _getDisplayName(TransactionModel transaction, bool isIncome) {
    if (transaction.type.toLowerCase() == 'purchase' || transaction.type.toLowerCase() == 'purse') {
      return 'Activation compte';
    }
    return isIncome ? (transaction.senderName ?? 'Système') : (transaction.receiverName ?? 'Activation compte');
  }

  String _getTypeLabel(TransactionModel transaction) {
    final type = transaction.type.toLowerCase();
    if (type == 'purchase' || type == 'purse') {
      return 'ACTIVATION COMPTE';
    }
    return transaction.type.toUpperCase();
  }
}
