import 'package:flutter/material.dart';
import 'package:gep_point/constants.dart';
import 'package:gep_point/providers/auth_provider.dart';
import 'package:gep_point/providers/profile_upgrade_provider.dart';
import 'package:gep_point/models/m_specialized_profile.dart';
import 'package:gep_point/services/s_portfolio.dart';
import 'package:gep_point/services/s_certification.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';

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
  final List<ProjectDraft> _portfolioDrafts = [];
  final List<CertificationDraft> _certificationDrafts = [];
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
            onPressed: () => _showExperienceDialog(),
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
            onPressed: () => _showExperienceDialog(experience: exp),
            icon: const Icon(Icons.edit_outlined, color: primaryColor, size: 20),
          ),
          IconButton(
            onPressed: () => setState(() => _experiences.remove(exp)),
            icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
          ),
        ],
      ),
    );
  }

  void _showExperienceDialog({ExperienceModel? experience}) {
    final companyCtrl = TextEditingController(text: experience?.companyName);
    final titleCtrl = TextEditingController(text: experience?.jobTitle);
    final descCtrl = TextEditingController(text: experience?.description);
    DateTime selectedDate = experience?.startDate ?? DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialog) {
        return AlertDialog(
          title: Text(experience == null ? 'Ajouter une expérience' : 'Modifier l\'expérience'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: companyCtrl, decoration: const InputDecoration(labelText: 'Entreprise')),
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Poste')),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Début: '),
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(1980),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) setDialog(() => selectedDate = date);
                      },
                      child: Text("${selectedDate.year}"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () {
                if (companyCtrl.text.isEmpty || titleCtrl.text.isEmpty) return;
                setState(() {
                  final newExp = ExperienceModel(
                    companyName: companyCtrl.text,
                    jobTitle: titleCtrl.text,
                    startDate: selectedDate,
                    description: descCtrl.text,
                  );
                  if (experience != null) {
                    int index = _experiences.indexOf(experience);
                    _experiences[index] = newExp;
                  } else {
                    _experiences.add(newExp);
                  }
                });
                Navigator.pop(ctx);
              },
              child: const Text('Valider'),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPortfolioStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Portfolio & Réalisations', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Mettez en avant vos plus belles réalisations.', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          ..._portfolioDrafts.map((draft) => _buildProjectDraftCard(draft)),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _showProjectDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un projet au portfolio'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 32),
          const Text('Diplômes & Certifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Ajoutez vos titres académiques ou certifications professionnelles.', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 16),
          ..._certificationDrafts.map((draft) => _buildCertificationDraftCard(draft)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _showCertificationDialog(),
            icon: const Icon(Icons.school_outlined),
            label: const Text('Ajouter une certification'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationDraftCard(CertificationDraft draft) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Row(children: [
        Icon(Icons.verified_outlined, color: Colors.blue.shade600, size: 24),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(draft.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(draft.institution, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ])),
        IconButton(onPressed: () => _showCertificationDialog(draft: draft), icon: const Icon(Icons.edit_outlined, size: 20, color: primaryColor)),
        IconButton(onPressed: () => setState(() => _certificationDrafts.remove(draft)), icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent)),
      ]),
    );
  }

  Widget _buildProjectDraftCard(ProjectDraft draft) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Row(children: [
        if (draft.images.isNotEmpty)
          Stack(children: [
            ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(draft.images.first, width: 50, height: 50, fit: BoxFit.cover)),
            if (draft.images.length > 1)
              Positioned(
                bottom: 2, right: 2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(4)),
                  child: Text('+${draft.images.length - 1}', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
              ),
          ])
        else
          Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.image, color: Colors.grey)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(draft.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          if (draft.description != null) Text(draft.description!, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
        IconButton(onPressed: () => _showProjectDialog(draft: draft), icon: const Icon(Icons.edit_outlined, size: 20, color: primaryColor)),
        IconButton(onPressed: () => setState(() => _portfolioDrafts.remove(draft)), icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent)),
      ]),
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
                    // Enregistrer les projets du portfolio un par un
                    final portfolioService = PortfolioService();
                    for (var draft in _portfolioDrafts) {
                      await portfolioService.createProject(
                        title: draft.title,
                        description: draft.description,
                        images: draft.images,
                      );
                    }
                    // Enregistrer les certifications un par un
                    final certService = CertificationService();
                    for (var draft in _certificationDrafts) {
                      await certService.createCertification(
                        title: draft.title,
                        institution: draft.institution,
                        description: draft.description,
                        image: draft.image,
                      );
                    }
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
                  Navigator.pop(context); // Back from profile
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

  void _showCertificationDialog({CertificationDraft? draft}) {
    final titleCtrl = TextEditingController(text: draft?.title);
    final instCtrl = TextEditingController(text: draft?.institution);
    final descCtrl = TextEditingController(text: draft?.description);
    File? selectedFile = draft?.image;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialog) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(draft == null ? 'Nouvelle certification' : 'Modifier certification'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Titre/Diplôme *')),
                TextField(controller: instCtrl, decoration: const InputDecoration(labelText: 'Institution *')),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final img = await picker.pickImage(source: ImageSource.gallery);
                    if (img != null) setDialog(() => selectedFile = File(img.path));
                  },
                  child: Container(
                    height: 100, width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                    child: selectedFile != null
                        ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(selectedFile!, fit: BoxFit.cover))
                        : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_outlined, color: primaryColor), Text('Preuve (Photo)', style: TextStyle(fontSize: 12))]),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isEmpty || instCtrl.text.isEmpty) return;
                setState(() {
                  final newDraft = CertificationDraft(title: titleCtrl.text, institution: instCtrl.text, description: descCtrl.text, image: selectedFile);
                  if (draft != null) {
                    int idx = _certificationDrafts.indexOf(draft);
                    _certificationDrafts[idx] = newDraft;
                  } else {
                    _certificationDrafts.add(newDraft);
                  }
                });
                Navigator.pop(ctx);
              },
              child: const Text('Valider'),
            ),
          ],
        );
      }),
    );
  }

  void _showProjectDialog({ProjectDraft? draft}) {
    final titleCtrl = TextEditingController(text: draft?.title);
    final descCtrl = TextEditingController(text: draft?.description);
    List<File> selectedFiles = draft?.images ?? [];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialog) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(draft == null ? 'Ajouter un projet' : 'Modifier le projet'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Titre du projet *')),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
                const SizedBox(height: 16),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Images (max 4)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    if (selectedFiles.length < 4)
                      TextButton.icon(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final imgs = await picker.pickMultiImage(imageQuality: 80);
                          if (imgs.isNotEmpty) {
                            setDialog(() {
                              final remaining = 4 - selectedFiles.length;
                              selectedFiles.addAll(imgs.take(remaining).map((x) => File(x.path)));
                            });
                          }
                        },
                        icon: const Icon(Icons.add_a_photo_outlined, size: 16),
                        label: const Text('Ajouter', style: TextStyle(fontSize: 12)),
                      ),
                  ]),
                  const SizedBox(height: 8),
                  if (selectedFiles.isNotEmpty)
                    SizedBox(
                      height: 60,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedFiles.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (ctx, i) => Stack(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(selectedFiles[i], width: 60, height: 60, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 0, right: 0,
                            child: GestureDetector(
                              onTap: () => setDialog(() => selectedFiles.removeAt(i)),
                              child: Container(
                                decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
                                padding: const EdgeInsets.all(2),
                                child: const Icon(Icons.close, size: 10, color: Colors.white),
                              ),
                            ),
                          ),
                        ]),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final imgs = await picker.pickMultiImage(imageQuality: 80);
                        if (imgs.isNotEmpty) {
                          setDialog(() {
                            selectedFiles = imgs.take(4).map((x) => File(x.path)).toList();
                          });
                        }
                      },
                      child: Container(
                        height: 80, width: double.infinity,
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                        child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_outlined, color: primaryColor), Text('Ajouter des images', style: TextStyle(fontSize: 12))]),
                      ),
                    ),
                ]),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isEmpty) return;
                setState(() {
                  final newDraft = ProjectDraft(title: titleCtrl.text, description: descCtrl.text, images: selectedFiles);
                  if (draft != null) {
                    int idx = _portfolioDrafts.indexOf(draft);
                    _portfolioDrafts[idx] = newDraft;
                  } else {
                    _portfolioDrafts.add(newDraft);
                  }
                });
                Navigator.pop(ctx);
              },
              child: const Text('Valider'),
            ),
          ],
        );
      }),
    );
  }
}

class CertificationDraft {
  final String title;
  final String institution;
  final String? description;
  final File? image;
  CertificationDraft({required this.title, required this.institution, this.description, this.image});
}

class ProjectDraft {
  final String title;
  final String? description;
  final List<File> images;
  ProjectDraft({required this.title, this.description, this.images = const []});
}
