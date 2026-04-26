import 'package:flutter/material.dart';
import 'package:gep_point/themes/app_colors.dart';

class VGepAmountField extends StatelessWidget {
  final TextEditingController controller;

  const VGepAmountField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      decoration: const InputDecoration(
        hintText: "0.00",
        hintStyle: TextStyle(color: AppColors.textSecondary),
        border: InputBorder.none,
      ),
    );
  }
}
