import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gep_point/api_constants.dart';
import 'package:gep_point/constants.dart';
import 'package:gep_point/models/m_user.dart';
import 'package:gep_point/models/m_specialized_profile.dart';
import 'package:gep_point/providers/auth_provider.dart';
import 'package:gep_point/providers/wallet_provider.dart';
import 'package:gep_point/themes/app_colors.dart';
import 'package:gep_point/components/card/point_badget.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class DetailProfilScreen extends StatefulWidget {
  final UserModel? viewedUser; // Si présent, on affiche ce profil au lieu de celui connecté
  const DetailProfilScreen({super.key, this.viewedUser});

  @override
  State<DetailProfilScreen> createState() => _DetailProfilScreenState();
}

class _DetailProfilScreenState extends State<DetailProfilScreen> {
  final ImagePicker _picker = ImagePicker();
  
  Future<void> _pickAndUploadImage(BuildContext context) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null && context.mounted) {
      final authProvider = context.read<AuthProvider>();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload en cours...')));
      final success = await authProvider.uploadProfilePicture(File(image.path));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success ? 'Profil mis à jour avec succès' : 'Échec de la mise à jour'),
        ));
      }
    }
  }

  void _showEditProfileModal(BuildContext context, dynamic user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Modifier le profil", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nom complet"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Téléphone"),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final authProvider = context.read<AuthProvider>();
                  final success = await authProvider.updateUserInfo(
                    nameController.text,
                    emailController.text,
                    phoneController.text,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(success ? 'Informations mises à jour' : 'Erreur lors de la mise à jour'),
                    ));
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Enregistrer"),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.viewedUser != null ? 'Profil de ${widget.viewedUser!.name}' : 'Détails du Profil'),
      ),
      body: Consumer2<AuthProvider, WalletProvider>(
        builder: (context, auth, wallet, child) {
          final currentUser = auth.user;
          final user = widget.viewedUser ?? currentUser;
          
          if (user == null) return const Center(child: Text("Non connecté"));
          final isOwnProfile = widget.viewedUser == null || widget.viewedUser?.id == currentUser?.id;

          return SafeArea(
            child: ListView(
              children: [
                const SizedBox(height: 24),

                /// AVATAR
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: user.profile != null
                            ? NetworkImage(getFullImageUrl(user.profile)) as ImageProvider
                            : const AssetImage('assets/images/saf.jpg'),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _pickAndUploadImage(context),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                      // INDICATEUR NIVEAU 1
                      if (user.profileLevel == 1)
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_user, color: Colors.white, size: 12),
                                SizedBox(width: 4),
                                Text("BASIC", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${user.name} ${user.prenom ?? ''}",
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          if (isOwnProfile)
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20, color: AppColors.primary),
                              onPressed: () => _showEditProfileModal(context, user),
                            ),
                        ],
                      ),
                      Text(
                        user.email ?? '',
                        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                      if (user.phone != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          user.phone!,
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.all(defaultPadding),
                        child: const PointBadget(points: 10),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                /// INFO CARD
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      children: [
                        _balanceRow("Points Standard", wallet.getBalance('standard').toStringAsFixed(0)),
                        const Divider(height: 32, color: Colors.white10),
                        _balanceRow("Points Non standard", wallet.getBalance('non standard').toStringAsFixed(0)),
                        const Divider(height: 32, color: Colors.white10),
                        _balanceRow("Points Cash", wallet.getBalance('cash').toStringAsFixed(0)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // SECTIONS CONDITIONNELLES SELON LE NIVEAU
                if (user.profileLevel >= 2) ...[
                  _buildSectionTitle("Expériences Professionnelles"),
                  if (user.experiences.isEmpty)
                    const _EmptySection(text: "Aucune expérience renseignée")
                  else
                    ...user.experiences.map((exp) => _buildExperienceItem(exp)),
                ],

                if (user.profileLevel == 3) ...[
                  const SizedBox(height: 16),
                  _buildSectionTitle("Portfolio"),
                  const _EmptySection(text: "Le portfolio sera bientôt disponible"),
                ],
                
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildExperienceItem(ExperienceModel exp) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Card(
        child: ListTile(
          title: Text(exp.jobTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(exp.companyName),
          trailing: Text("${exp.startDate.year}"),
        ),
      ),
    );
  }

  Widget _balanceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16)),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String text;
  const _EmptySection({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(text, style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
    );
  }
}
