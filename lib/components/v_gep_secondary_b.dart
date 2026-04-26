import 'package:flutter/material.dart';
import 'package:gep_point/themes/app_colors.dart';

class VGepSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const VGepSecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
