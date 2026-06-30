import 'package:flutter/material.dart';
import 'package:gep_point/themes/app_colors.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Langues'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildLanguageItem(
            context,
            title: "Français",
            subtitle: "Langue par défaut",
            isActive: true,
            flag: "🇫🇷",
          ),
          _buildLanguageItem(
            context,
            title: "English",
            subtitle: "Bientôt disponible",
            isActive: false,
            flag: "🇬🇧",
          ),
          _buildLanguageItem(
            context,
            title: "Español",
            subtitle: "Bientôt disponible",
            isActive: false,
            flag: "🇪🇸",
          ),
          _buildLanguageItem(
            context,
            title: "Swahili",
            subtitle: "Bientôt disponible",
            isActive: false,
            flag: "🇹🇿",
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageItem(BuildContext context, {
    required String title,
    required String subtitle,
    required bool isActive,
    required String flag,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: isActive ? Border.all(color: AppColors.primary, width: 2) : null,
      ),
      child: ListTile(
        leading: Text(flag, style: const TextStyle(fontSize: 24)),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.white : Colors.grey,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isActive ? Colors.white70 : Colors.grey.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
        trailing: isActive
            ? const Icon(Icons.check_circle, color: AppColors.primary)
            : const Icon(Icons.lock_outline, color: Colors.grey),
        onTap: isActive ? () {} : null, // Ne rien faire ou afficher un message
      ),
    );
  }
}
