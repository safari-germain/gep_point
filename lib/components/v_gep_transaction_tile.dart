import 'package:flutter/material.dart';
import 'package:gep_point/themes/app_colors.dart';

class VGepTransactionTile extends StatelessWidget {
  final String title;
  final double amount;
  final bool isIncoming;
  final String date;

  const VGepTransactionTile({
    super.key,
    required this.title,
    required this.amount,
    required this.isIncoming,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      leading: CircleAvatar(
        backgroundColor: isIncoming ? AppColors.success.withOpacity(0.2) : AppColors.danger.withOpacity(0.2),
        child: Icon(
          isIncoming ? Icons.arrow_downward : Icons.arrow_upward,
          color: isIncoming ? AppColors.success : AppColors.danger,
        ),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(date, style: const TextStyle(color: AppColors.textSecondary)),
      trailing: Text(
        "${isIncoming ? "+" : "-"}${amount.toStringAsFixed(2)}",
        style: TextStyle(
          color: isIncoming ? AppColors.success : AppColors.danger,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
