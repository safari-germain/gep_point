import 'package:flutter/material.dart';
import 'package:gep_point/themes/app_colors.dart';

class VGepPointBalanceCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  const VGepPointBalanceCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppColors.textSecondary)),
              Text(
                amount.toStringAsFixed(2),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary),
              ),
            ],
          )
        ],
      ),
    );
  }
}
