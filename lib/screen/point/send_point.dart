import 'package:flutter/material.dart';
import 'package:gep_point/components/v_gep_amout_text_field.dart';
import 'package:gep_point/components/v_gep_primary_b.dart';
import 'package:gep_point/themes/app_colors.dart';

class SendPointScreen extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  SendPointScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              /// User preview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(radius: 28),
                    SizedBox(width: 16),
                    Text(
                      "John Doe",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 40),

              VGepAmountField(controller: controller),

              const SizedBox(height: 20),

              const Text(
                "Frais : 2%",
                style: TextStyle(color: AppColors.textSecondary),
              ),

              const Spacer(),

              VGepPrimaryButton(
                text: "Confirmer l'envoi",
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
