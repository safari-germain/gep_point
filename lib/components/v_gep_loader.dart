import 'package:flutter/material.dart';
import 'package:gep_point/themes/app_colors.dart';

class VUGepLoader extends StatelessWidget {
  const VUGepLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }
}
