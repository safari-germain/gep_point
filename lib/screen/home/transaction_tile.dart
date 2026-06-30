import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gep_point/models/m_transaction.dart';
import 'package:gep_point/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionTile({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final theme = Theme.of(context);
        final currentUserId = authProvider.user?.id;

        // Déterminer isIncome en se basant sur les IDs
        final bool isIncome = currentUserId == transaction.toUserId;

        // Icone et couleur
        final iconData = isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
        final color = isIncome ? theme.colorScheme.primary : theme.colorScheme.error;
        final bgColor = isIncome ? theme.colorScheme.primaryContainer : theme.colorScheme.errorContainer;
        final iconColor = isIncome ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onErrorContainer;

        // Couleur du statut
        final statusColor = _getStatusColor(theme);

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
                    _getDisplayName(transaction, currentUserId),
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
                    Row(
                      children: [
                        Text(
                          _getTypeLabel(transaction),
                          style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(theme, statusColor),
                      ],
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
      },
    );
  }

  Widget _buildStatusBadge(ThemeData theme, Color statusColor) {
    final statusText = _getStatusText(transaction.status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        statusText,
        style: theme.textTheme.labelSmall?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor(ThemeData theme) {
    switch (transaction.status.toLowerCase()) {
      case 'completed':
        return theme.colorScheme.primary;
      case 'pending':
        return theme.colorScheme.tertiary;
      case 'failed':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return '✓ Réussi';
      case 'pending':
        return '⏳ En attente';
      case 'failed':
        return '✗ Échoué';
      default:
        return status;
    }
  }

  String _getDisplayName(TransactionModel transaction, int? currentUserId) {
    final type = transaction.type.toLowerCase();

    // Activation de compte
    if (type == 'purchase' || type == 'purse') {
      return 'Activation compte';
    }

    // Déterminer la direction de la transaction
    final isSent = currentUserId == transaction.fromUserId;
    final isReceived = currentUserId == transaction.toUserId;

    if (isSent) {
      // L'utilisateur a envoyé la transaction
      return 'Envoyé à ${transaction.receiverName ?? 'Destinataire inconnu'}';
    } else if (isReceived) {
      // L'utilisateur a reçu la transaction
      return 'Reçu de ${transaction.senderName ?? 'Système'}';
    } else {
      // Cas par défaut
      return '${transaction.senderName ?? 'Système'} → ${transaction.receiverName ?? 'Inconnu'}';
    }
  }

  String _getTypeLabel(TransactionModel transaction) {
    final type = transaction.type.toLowerCase();
    if (type == 'purchase' || type == 'purse') {
      return 'ACTIVATION COMPTE';
    }
    return transaction.type.toUpperCase();
  }
}
