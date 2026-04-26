import 'package:flutter/material.dart';
import 'package:gep_point/themes/app_colors.dart';

class VUGepStatusBadge extends StatelessWidget {
  final String status;

  const VUGepStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case "completed":
        color = AppColors.success;
        break;
      case "pending":
        color = AppColors.warning;
        break;
      default:
        color = AppColors.danger;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
