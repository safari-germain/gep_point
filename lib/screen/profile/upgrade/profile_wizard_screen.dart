import 'package:flutter/material.dart';
import 'package:gep_point/constants.dart';
import 'package:gep_point/providers/auth_provider.dart';
import 'package:gep_point/providers/profile_upgrade_provider.dart';
import 'package:gep_point/models/m_specialized_profile.dart';
import 'package:provider/provider.dart';

class ProfileWizardScreen extends StatefulWidget {
  final int targetLevel;
  const ProfileWizardScreen({super.key, required this.targetLevel});

  @override
  State<ProfileWizardScreen> createState() => _ProfileWizardScreenState();
}

class _ProfileWizardScreenState extends State<ProfileWizardScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Data State
  final List<int> _selectedCompetenceIds = [];
  final List<ExperienceModel> _experiences = [];
  
  @override
  Widget build(BuildContext context) {
    final upgradeProvider = context.watch<ProfileUpgradeProvider>();
    int totalSteps = widget.targetLevel == 3 ? 3 : 2;
    if (widget.targetLevel == 1) totalSteps = 1;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Compléter mon Profil ${widget.targetLevel == 2 ? 'Moyen' : 'Supérieur'}'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          )
        ],
      ),
      body: Column(
        children: [
          _buildProgressBar(totalSteps),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildCompetenceStep(),
                if (widget.targetLevel >= 2) _buildExperienceStep(),
                if (widget.targetLevel >= 3) _buildPortfolioStep(),
              ],
            ),
          ),
          _buildBottomNavigation(totalSteps, upgradeProvider),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int totalSteps) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Stack(
        children: [
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 6,
            width: MediaQuery.of(context).size.width * ((_currentStep + 1) / totalSteps),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompetenceStep() {
    int maxComp = widget.targetLevel == 1 ? 1 : 5;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quelles sont vos compétences ?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Sélectionnez au plus $maxComp compétences principales.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: context.read<ProfileUpgradeProvider>().allCompetences.map((comp) {
              bool isSelected = _selectedCompetenceIds.contains(comp.id);
              return FilterChip(
                label: Text(comp.name),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      if (_selectedCompetenceIds.length < maxComp) {
                        _selectedCompetenceIds.add(comp.id);
                      }
                    } else {
                      _selectedCompetenceIds.remove(comp.id);
                    }
                  });
                },
                selectedColor: primaryColor.withOpacity(0.2),
                checkmarkColor: primaryColor,
                labelStyle: TextStyle(
                  color: isSelected ? primaryColor : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected ? primaryColor : Colors.grey.shade200,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Votre Parcours',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez vos expériences professionnelles passées.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ..._experiences.map((exp) => _buildExperienceCard(exp)),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _experiences.add(ExperienceModel(
                  companyName: 'Nouvelle Entreprise',
                  jobTitle: 'Poste occupé',
                  startDate: DateTime.now(),
                  description: '',
                ));
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une expérience'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceCard(ExperienceModel exp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.business, color: primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exp.jobTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(exp.companyName, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                Text("Depuis ${exp.startDate.year}", style: TextStyle(color: primaryColor, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _experiences.remove(exp)),
            icon: const Icon(Icons.delete_outline, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Portfolio & Preuves',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Mettez en avant vos plus belles réalisations.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          _buildUploadPlaceholder('Portfolio (Images de projets)'),
          const SizedBox(height: 24),
          _buildUploadPlaceholder('Certifications (Diplômes, Certificats)'),
        ],
      ),
    );
  }

  Widget _buildUploadPlaceholder(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300, style: BorderStyle.none),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_upload_outlined, color: Colors.grey.shade400, size: 32),
              const SizedBox(height: 8),
              Text('Parcourir les fichiers', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation(int totalSteps, ProfileUpgradeProvider upgradeProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: TextButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  setState(() => _currentStep--);
                },
                child: const Text('Précédent'),
              ),
            ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () async {
                if (_currentStep < totalSteps - 1) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  setState(() => _currentStep++);
                } else {
                  final authProvider = context.read<AuthProvider>();
                  final upgradeProvider = context.read<ProfileUpgradeProvider>();
                  
                  final success = await upgradeProvider.saveDetails(
                    competenceIds: _selectedCompetenceIds,
                    experiences: _experiences,
                    authProvider: authProvider,
                  );

                  if (success) {
                    _showSuccessDialog();
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Erreur lors de la sauvegarde du profil')),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: upgradeProvider.isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(_currentStep == totalSteps - 1 ? 'Terminer' : 'Suivant'),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Icon(Icons.check_circle, color: successColor, size: 80),
            const SizedBox(height: 16),
            const Text(
              'Profil mis à jour !',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Félicitations, votre profil est désormais plus complet et attractif.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Back from Wizard
                  Navigator.pop(context); // Back from Upgrade screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Super !'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
