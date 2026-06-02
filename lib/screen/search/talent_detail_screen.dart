import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gep_point/api_constants.dart';
import 'package:gep_point/models/m_user.dart';
import 'package:gep_point/models/m_specialized_profile.dart';
import 'package:gep_point/providers/auth_provider.dart';
import 'package:gep_point/services/s_portfolio.dart';
import 'package:gep_point/services/s_certification.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gep_point/providers/profile_upgrade_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gep_point/screen/point/send_point.dart';

class TalentDetailScreen extends StatefulWidget {
  final UserModel user;
  final bool readOnly;
  const TalentDetailScreen(
      {super.key, required this.user, this.readOnly = false});

  @override
  State<TalentDetailScreen> createState() => _TalentDetailScreenState();
}

class _TalentDetailScreenState extends State<TalentDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PortfolioService _portfolioService = PortfolioService();
  final CertificationService _certificationService = CertificationService();
  List<PortfolioModel> _portfolios = [];
  List<CertificationModel> _certifications = [];
  bool _loadingPortfolio = false;
  bool _loadingCertifications = false;

  static const _amber = Color(0xFFF59E0B);

  bool get _isExpert => widget.user.profileLevel == 3;
  bool get _isConfirmed => widget.user.profileLevel >= 2;

  int get _tabCount => _isExpert
      ? 4
      : _isConfirmed
          ? 2
          : 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCount, vsync: this);
    if (_isExpert) {
      _loadPortfolio();
      _loadCertifications();
    }
  }

  Future<void> _loadPortfolio() async {
    setState(() => _loadingPortfolio = true);
    _portfolios = await _portfolioService.fetchUserPortfolio(widget.user.id);
    setState(() => _loadingPortfolio = false);
  }

  Future<void> _loadCertifications() async {
    setState(() => _loadingCertifications = true);
    _certifications =
        await _certificationService.fetchUserCertifications(widget.user.id);
    setState(() => _loadingCertifications = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOwnProfile = !widget.readOnly &&
        context.read<AuthProvider>().user?.id == widget.user.id;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          _buildSliverHeader(
              theme,
              !widget.readOnly &&
                  context.read<AuthProvider>().user?.id == widget.user.id)
        ],
        body: Column(children: [
          _buildTabBar(theme),
          Expanded(
              child: TabBarView(
            controller: _tabController,
            children: [
              _buildInfoTab(isOwnProfile),
              if (_isConfirmed) _buildExperiencesTab(),
              if (_isExpert) ...[
                _buildPortfolioTab(isOwnProfile),
                _buildCertificationsTab(isOwnProfile),
              ],
            ],
          )),
        ]),
      ),
    );
  }

  Widget _buildSliverHeader(ThemeData theme, bool isOwn) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: theme.colorScheme.surface,
      foregroundColor: theme.colorScheme.onSurface,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primaryContainer.withOpacity(0.6),
                theme.colorScheme.surface,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              child: Column(children: [
                Stack(alignment: Alignment.center, children: [
                  if (_isExpert)
                    Container(
                      width: 80,
                      height: 80,
                      decoration:
                          BoxDecoration(shape: BoxShape.circle, boxShadow: [
                        BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.35),
                            blurRadius: 24,
                            spreadRadius: 4)
                      ]),
                    ),
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    backgroundImage: widget.user.profile != null
                        ? getImageProvider(widget.user.profile)
                        : null,
                    child: widget.user.profile == null
                        ? Text(_initials(),
                            style: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontSize: 28,
                                fontWeight: FontWeight.w800))
                        : null,
                  ),
                ]),
                const SizedBox(height: 12),
                Text('${widget.user.name} ${widget.user.prenom ?? ''}',
                    style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                const SizedBox(height: 4),
                _levelBadgeLarge(theme),
                if (_isConfirmed && widget.user.competences.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                      widget.user.competences
                          .map((c) => c.name)
                          .take(3)
                          .join(' · '),
                      style: TextStyle(
                          color: _isExpert ? theme.colorScheme.primary : _amber,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                ],
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    final tabs = [
      const Tab(text: 'Infos'),
      if (_isConfirmed) const Tab(text: 'Expériences'),
      if (_isExpert) ...[
        const Tab(text: 'Portfolio'),
        const Tab(text: 'Certifications'),
      ],
    ];
    return Container(
      color: theme.colorScheme.surfaceContainerLow,
      child: TabBar(
        controller: _tabController,
        tabs: tabs,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        indicatorColor: theme.colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
      ),
    );
  }

  Widget _buildInfoTab(bool isOwn) {
    final theme = Theme.of(context);
    return ListView(padding: const EdgeInsets.all(20), children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _sectionLabel('Coordonnées'),
          if (isOwn)
            IconButton(
              onPressed: () => _showEditInfoModal(context),
              icon: const Icon(Icons.edit_outlined, size: 18),
            ),
        ],
      ),
      const SizedBox(height: 8),
      _infoCard('', [
        if (widget.user.email != null)
          _infoRow(Icons.email_outlined, widget.user.email!),
        if (widget.user.phone != null)
          _infoRow(Icons.phone_outlined, widget.user.phone!),
        if (widget.user.adresse != null)
          _infoRow(Icons.location_on_outlined, widget.user.adresse!),
      ]),
      if (_isConfirmed) ...[
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionLabel('Compétences'),
            if (!widget.readOnly &&
                context.read<AuthProvider>().user?.id == widget.user.id)
              IconButton(
                onPressed: () => _showEditCompetencesModal(context),
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 18,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (widget.user.competences.isEmpty)
          const Text('Aucune compétence renseignée',
              style: TextStyle(
                  color: Colors.white38,
                  fontSize: 13,
                  fontStyle: FontStyle.italic))
        else
          Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.user.competences
                  .map((c) => _competenceChip(c.name))
                  .toList()),
      ],
      const SizedBox(height: 32),
      if (widget.readOnly &&
          context.read<AuthProvider>().user?.id != widget.user.id)
        _buildSendPointsButton(theme),
      const SizedBox(height: 32),
    ]);
  }

  Widget _buildSendPointsButton(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => SendPointScreen(recipient: widget.user)),
        ),
        icon: const Icon(Icons.send_rounded, color: Colors.white),
        label: const Text(
          "ENVOYER DES POINTS",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            letterSpacing: 1.2,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildExperiencesTab() {
    final isOwn = !widget.readOnly &&
        context.read<AuthProvider>().user?.id == widget.user.id;
    return Column(children: [
      if (isOwn)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showEditExperienceModal(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Ajouter une expérience'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _amber,
                side: BorderSide(color: _amber.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: widget.user.experiences.length,
          itemBuilder: (_, i) {
            final exp = widget.user.experiences[i];
            final duration = exp.endDate != null
                ? '${exp.startDate.year} – ${exp.endDate!.year}'
                : '${exp.startDate.year} – Présent';
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withOpacity(0.3)),
              ),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: _amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.work_rounded,
                      color: Color(0xFFF59E0B), size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Text(exp.jobTitle,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.w700))),
                            if (isOwn) ...[
                              GestureDetector(
                                onTap: () => _showEditExperienceModal(context,
                                    experience: exp),
                                child: const Icon(Icons.edit_outlined,
                                    color: _amber, size: 16),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () =>
                                    _showDeleteExperienceConfirm(context, exp),
                                child: const Icon(Icons.delete_outline,
                                    color: Colors.redAccent, size: 16),
                              ),
                            ],
                          ]),
                      Text(exp.companyName,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant)),
                      const SizedBox(height: 4),
                      Text(duration,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant)),
                      if (exp.description != null &&
                          exp.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(exp.description!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    height: 1.5,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant)),
                      ],
                    ])),
              ]),
            );
          },
        ),
      ),
    ]);
  }

  Widget _buildPortfolioTab(bool isOwn) {
    return Column(children: [
      if (isOwn)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAddProjectModal(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Ajouter un projet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      Expanded(
        child: _loadingPortfolio
            ? const Center(child: CircularProgressIndicator())
            : _portfolios.isEmpty
                ? Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        Icon(Icons.folder_open_rounded,
                            size: 48,
                            color:
                                Theme.of(context).colorScheme.outlineVariant),
                        const SizedBox(height: 12),
                        Text('Aucun projet pour l\'instant',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontSize: 14)),
                      ]))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _portfolios.length,
                    itemBuilder: (_, i) =>
                        _buildPortfolioCard(_portfolios[i], isOwn),
                  ),
      ),
    ]);
  }

  Widget _buildCertificationsTab(bool isOwn) {
    return Column(children: [
      if (isOwn)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAddCertificationModal(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Ajouter une certification'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _amber,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      Expanded(
        child: _loadingCertifications
            ? const Center(child: CircularProgressIndicator())
            : _certifications.isEmpty
                ? Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        Icon(Icons.verified_outlined,
                            size: 48,
                            color:
                                Theme.of(context).colorScheme.outlineVariant),
                        const SizedBox(height: 12),
                        Text('Aucune certification renseignée',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontSize: 14)),
                      ]))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _certifications.length,
                    itemBuilder: (_, i) =>
                        _buildCertificationCard(_certifications[i], isOwn),
                  ),
      ),
    ]);
  }

  Widget _buildCertificationCard(CertificationModel c, bool isOwn) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _amber.withOpacity(0.2)),
      ),
      child: Row(children: [
        if (c.imageUrl != null || c.imagePath != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image(
              image: getImageProvider(c.imageUrl ?? c.imagePath),
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          )
        else
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                color: _amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.workspace_premium_rounded,
                color: _amber, size: 24),
          ),
        const SizedBox(width: 14),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(c.title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          Text(c.institution,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ])),
        if (isOwn) ...[
          IconButton(
            onPressed: () =>
                _showAddCertificationModal(context, certification: c),
            icon: const Icon(Icons.edit_outlined, color: _amber, size: 20),
          ),
          IconButton(
            onPressed: () => _showDeleteCertificationConfirm(context, c),
            icon: const Icon(Icons.delete_outline,
                color: Colors.redAccent, size: 20),
          ),
        ],
      ]),
    );
  }

  Widget _buildPortfolioCard(PortfolioModel p, bool isOwn) {
    return GestureDetector(
      onLongPress: isOwn ? () => _showDeleteConfirm(context, p) : null,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                blurRadius: 10)
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Stack(children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: (p.imageUrl != null || p.imagePath != null)
                    ? Image(
                        image: getImageProvider(p.imageUrl ?? p.imagePath),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => _placeholderImage(),
                      )
                    : _placeholderImage(),
              ),
              if (p.imageUrls.length > 1)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.collections_rounded,
                          color: Colors.white, size: 10),
                      const SizedBox(width: 4),
                      Text('${p.imageUrls.length}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ]),
                  ),
                ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.title,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              if (p.description != null && p.description!.isNotEmpty)
                Text(p.description!,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              if (p.url != null && p.url!.isNotEmpty) ...[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => _launchUrl(p.url!),
                  child: Row(children: [
                    Icon(Icons.link_rounded,
                        size: 12, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 4),
                    Text('Voir le projet',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ]),
                ),
              ],
            ]),
          ),
          if (isOwn)
            Positioned(
              top: 8,
              left: 8,
              child: GestureDetector(
                onTap: () => _showAddProjectModal(context, project: p),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.edit_rounded,
                      color: Colors.white, size: 14),
                ),
              ),
            ),
        ]),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
      child: Center(
          child: Icon(Icons.image_rounded,
              size: 36, color: Theme.of(context).colorScheme.outlineVariant)),
    );
  }

  void _showAddProjectModal(BuildContext context, {PortfolioModel? project}) {
    final titleCtrl = TextEditingController(text: project?.title);
    final descCtrl = TextEditingController(text: project?.description);
    final urlCtrl = TextEditingController(text: project?.url);
    List<File> selectedImages = [];
    bool loading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setModal) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          project == null
                              ? 'Nouveau projet'
                              : 'Modifier le projet',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                      IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: Icon(Icons.close_rounded,
                              color:
                                  Theme.of(ctx).colorScheme.onSurfaceVariant)),
                    ]),
                const SizedBox(height: 16),
                _modalField('Titre du projet *', titleCtrl,
                    hint: 'Ex: Application mobile GEP'),
                const SizedBox(height: 12),
                _modalField('Description', descCtrl,
                    hint: 'Décrivez votre projet...', maxLines: 3),
                const SizedBox(height: 12),
                _modalField('Lien (URL)', urlCtrl, hint: 'https://...'),
                const SizedBox(height: 12),
                // Image picker
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Images (max 4)',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant)),
                        if (selectedImages.length < 4)
                          TextButton.icon(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final imgs =
                                  await picker.pickMultiImage(imageQuality: 80);
                              if (imgs.isNotEmpty) {
                                setModal(() {
                                  final remaining = 4 - selectedImages.length;
                                  selectedImages.addAll(imgs
                                      .take(remaining)
                                      .map((x) => File(x.path)));
                                });
                              }
                            },
                            icon: const Icon(Icons.add_photo_alternate_rounded,
                                size: 18),
                            label: const Text('Ajouter'),
                          ),
                      ]),
                  const SizedBox(height: 8),
                  if (selectedImages.isNotEmpty)
                    SizedBox(
                      height: 80,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedImages.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (ctx, i) => Stack(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(selectedImages[i],
                                width: 80, height: 80, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: () =>
                                  setModal(() => selectedImages.removeAt(i)),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    shape: BoxShape.circle),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(Icons.close,
                                    size: 12, color: Colors.white),
                              ),
                            ),
                          ),
                        ]),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outlineVariant
                                .withOpacity(0.3),
                            strokeAlign: BorderSide.strokeAlignOutside),
                      ),
                      child: Column(children: [
                        Icon(Icons.add_a_photo_outlined,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withOpacity(0.5)),
                        const SizedBox(height: 8),
                        Text('Aucune image sélectionnée',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withOpacity(0.6),
                                fontSize: 12)),
                      ]),
                    ),
                ]),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading
                        ? null
                        : () async {
                            if (titleCtrl.text.trim().isEmpty) return;
                            setModal(() => loading = true);
                            final PortfolioModel? result;
                            if (project == null) {
                              result = await _portfolioService.createProject(
                                title: titleCtrl.text.trim(),
                                description: descCtrl.text.trim().isNotEmpty
                                    ? descCtrl.text.trim()
                                    : null,
                                url: urlCtrl.text.trim().isNotEmpty
                                    ? urlCtrl.text.trim()
                                    : null,
                                images: selectedImages,
                              );
                            } else {
                              result = await _portfolioService.updateProject(
                                id: project.id,
                                title: titleCtrl.text.trim(),
                                description: descCtrl.text.trim().isNotEmpty
                                    ? descCtrl.text.trim()
                                    : null,
                                url: urlCtrl.text.trim().isNotEmpty
                                    ? urlCtrl.text.trim()
                                    : null,
                                images: selectedImages,
                              );
                            }
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (result != null) {
                              setState(() {
                                if (project == null) {
                                  _portfolios.insert(0, result!);
                                } else {
                                  int index = _portfolios
                                      .indexWhere((p) => p.id == project.id);
                                  if (index != -1) _portfolios[index] = result!;
                                }
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(ctx).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(
                            project == null
                                ? 'Publier le projet'
                                : 'Enregistrer les modifications',
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 20),
              ]),
        );
      }),
    );
  }

  void _showDeleteConfirm(BuildContext context, PortfolioModel p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Supprimer',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Text('Supprimer "${p.title}" ?',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final ok = await _portfolioService.deleteProject(p.id);
              if (ok)
                setState(() => _portfolios.removeWhere((x) => x.id == p.id));
            },
            child: const Text('Supprimer',
                style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }

  Widget _modalField(String label, TextEditingController ctrl,
      {String? hint, int maxLines = 1}) {
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant)),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.primary)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    ]);
  }

  Widget _infoCard(String title, List<Widget> rows) {
    final theme = Theme.of(context);
    if (rows.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel(title),
        const SizedBox(height: 12),
        ...rows,
      ]),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurface))),
      ]),
    );
  }

  Widget _sectionLabel(String label) {
    final theme = Theme.of(context);
    return Text(label,
        style: theme.textTheme.titleSmall
            ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.3));
  }

  Widget _competenceChip(String name) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.25)),
      ),
      child: Text(name,
          style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600)),
    );
  }

  Widget _levelBadgeLarge(ThemeData theme) {
    if (widget.user.profileLevel == 1) {
      return Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.4)),
        ),
        child: Text('PROFIL BASIQUE',
            style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1)),
      );
    }
    if (widget.user.profileLevel == 2) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
            color: _amber.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _amber.withOpacity(0.5))),
        child: const Text('PROFIL CONFIRMÉ',
            style: TextStyle(
                color: Color(0xFFF59E0B),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1)),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          theme.colorScheme.primary.withOpacity(0.25),
          theme.colorScheme.primary.withOpacity(0.1)
        ]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5)),
      ),
      child: Text('PROFIL EXPERT ✶',
          style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1)),
    );
  }

  String _initials() {
    final parts = widget.user.name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return widget.user.name.isNotEmpty
        ? widget.user.name[0].toUpperCase()
        : '?';
  }

  void _showEditCompetencesModal(BuildContext context) async {
    final upgradeProvider = context.read<ProfileUpgradeProvider>();
    final authProvider = context.read<AuthProvider>();

    // Charger les compétences si besoin
    if (upgradeProvider.allCompetences.isEmpty) await upgradeProvider.init();

    List<int> selectedIds = widget.user.competences.map((c) => c.id).toList();
    int limit = (widget.user.profileLevel == 1)
        ? 1
        : ((widget.user.profileLevel == 2) ? 5 : 999);

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setModal) {
        final modalTheme = Theme.of(ctx);
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Modifier mes compétences',
                    style: TextStyle(
                        color: modalTheme.colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('Choisissez jusqu\'à $limit compétences.',
                    style: TextStyle(
                        color: modalTheme.colorScheme.onSurfaceVariant,
                        fontSize: 12)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 400,
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: upgradeProvider.allCompetences.map((comp) {
                        bool isSelected = selectedIds.contains(comp.id);
                        return FilterChip(
                          label: Text(comp.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            setModal(() {
                              if (selected) {
                                if (selectedIds.length < limit)
                                  selectedIds.add(comp.id);
                              } else {
                                selectedIds.remove(comp.id);
                              }
                            });
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final success = await upgradeProvider.saveDetails(
                        competenceIds: selectedIds,
                        experiences: widget.user.experiences,
                        authProvider: authProvider,
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (success) {
                        setState(() {
                          widget.user.competences.clear();
                          widget.user.competences.addAll(upgradeProvider
                              .allCompetences
                              .where((c) => selectedIds.contains(c.id)));
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: modalTheme.colorScheme.primary,
                        foregroundColor: Colors.white),
                    child: const Text('Enregistrer'),
                  ),
                ),
                const SizedBox(height: 20),
              ]),
        );
      }),
    );
  }

  void _showEditExperienceModal(BuildContext context,
      {ExperienceModel? experience}) {
    final companyCtrl = TextEditingController(text: experience?.companyName);
    final titleCtrl = TextEditingController(text: experience?.jobTitle);
    final descCtrl = TextEditingController(text: experience?.description);
    DateTime selectedDate = experience?.startDate ?? DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialog) {
        return AlertDialog(
          backgroundColor: Theme.of(ctx).colorScheme.surfaceContainerHigh,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(experience == null ? 'Ajouter' : 'Modifier'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: companyCtrl,
                    decoration: const InputDecoration(labelText: 'Entreprise')),
                TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Poste')),
                TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3),
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
                      child: Text("${selectedDate.year}",
                          style: TextStyle(color: _amber)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () async {
                if (companyCtrl.text.isEmpty || titleCtrl.text.isEmpty) return;
                final upgradeProvider = context.read<ProfileUpgradeProvider>();
                final authProvider = context.read<AuthProvider>();
                List<ExperienceModel> newExps =
                    List.from(widget.user.experiences);
                final updatedExp = ExperienceModel(
                  companyName: companyCtrl.text,
                  jobTitle: titleCtrl.text,
                  startDate: selectedDate,
                  description: descCtrl.text,
                );
                if (experience != null) {
                  int index = newExps.indexOf(experience);
                  newExps[index] = updatedExp;
                } else {
                  newExps.add(updatedExp);
                }
                final success = await upgradeProvider.saveDetails(
                  competenceIds:
                      widget.user.competences.map((c) => c.id).toList(),
                  experiences: newExps,
                  authProvider: authProvider,
                );
                if (ctx.mounted) Navigator.pop(ctx);
                if (success) {
                  setState(() {
                    widget.user.experiences.clear();
                    widget.user.experiences.addAll(newExps);
                  });
                }
              },
              child: const Text('Valider'),
            ),
          ],
        );
      }),
    );
  }

  void _showDeleteExperienceConfirm(BuildContext context, ExperienceModel exp) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).colorScheme.surfaceContainerHigh,
        title: const Text('Supprimer'),
        content: const Text('Supprimer cette expérience ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              final upgradeProvider = context.read<ProfileUpgradeProvider>();
              final authProvider = context.read<AuthProvider>();
              List<ExperienceModel> newExps =
                  List.from(widget.user.experiences);
              newExps.remove(exp);
              final success = await upgradeProvider.saveDetails(
                competenceIds:
                    widget.user.competences.map((c) => c.id).toList(),
                experiences: newExps,
                authProvider: authProvider,
              );
              if (ctx.mounted) Navigator.pop(ctx);
              if (success) {
                setState(() {
                  widget.user.experiences.clear();
                  widget.user.experiences.addAll(newExps);
                });
              }
            },
            child: const Text('Supprimer',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showAddCertificationModal(BuildContext context,
      {CertificationModel? certification}) {
    final titleCtrl = TextEditingController(text: certification?.title);
    final instCtrl = TextEditingController(text: certification?.institution);
    final descCtrl = TextEditingController(text: certification?.description);
    File? selectedImage;
    bool loading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setModal) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          certification == null
                              ? 'Nouvelle certification'
                              : 'Modifier la certification',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                      IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: Icon(Icons.close_rounded,
                              color:
                                  Theme.of(ctx).colorScheme.onSurfaceVariant)),
                    ]),
                const SizedBox(height: 16),
                _modalField('Titre de la certification *', titleCtrl,
                    hint: 'Ex: Google Data Analytics'),
                const SizedBox(height: 12),
                _modalField('Institution *', instCtrl,
                    hint: 'Ex: Coursera / Google'),
                const SizedBox(height: 12),
                _modalField('Description', descCtrl,
                    hint: 'Optionnel', maxLines: 2),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final img =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (img != null)
                      setModal(() => selectedImage = File(img.path));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Theme.of(ctx).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Theme.of(ctx)
                                .colorScheme
                                .outlineVariant
                                .withOpacity(0.4))),
                    child: Row(children: [
                      Icon(Icons.image_rounded,
                          color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                          size: 20),
                      const SizedBox(width: 10),
                      Text(
                          selectedImage != null
                              ? 'Certificat sélectionné ✓'
                              : 'Ajouter une preuve (Image)',
                          style: TextStyle(
                              color: selectedImage != null
                                  ? Colors.green
                                  : Theme.of(ctx).colorScheme.onSurfaceVariant,
                              fontSize: 14)),
                    ]),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading
                        ? null
                        : () async {
                            if (titleCtrl.text.trim().isEmpty ||
                                instCtrl.text.trim().isEmpty) return;
                            setModal(() => loading = true);
                            final CertificationModel? result;
                            if (certification == null) {
                              result = await _certificationService
                                  .createCertification(
                                title: titleCtrl.text.trim(),
                                institution: instCtrl.text.trim(),
                                description: descCtrl.text.trim().isNotEmpty
                                    ? descCtrl.text.trim()
                                    : null,
                                image: selectedImage,
                              );
                            } else {
                              result = await _certificationService
                                  .updateCertification(
                                id: certification.id,
                                title: titleCtrl.text.trim(),
                                institution: instCtrl.text.trim(),
                                description: descCtrl.text.trim().isNotEmpty
                                    ? descCtrl.text.trim()
                                    : null,
                                image: selectedImage,
                              );
                            }
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (result != null) {
                              setState(() {
                                if (certification == null) {
                                  _certifications.insert(0, result!);
                                } else {
                                  int index = _certifications.indexWhere(
                                      (c) => c.id == certification.id);
                                  if (index != -1)
                                    _certifications[index] = result!;
                                }
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _amber,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(
                            certification == null ? 'Enregistrer' : 'Modifier',
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 20),
              ]),
        );
      }),
    );
  }

  void _showDeleteCertificationConfirm(
      BuildContext context, CertificationModel c) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer'),
        content: Text('Supprimer "${c.title}" ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final ok = await _certificationService.deleteCertification(c.id);
              if (ok)
                setState(
                    () => _certifications.removeWhere((x) => x.id == c.id));
            },
            child: const Text('Supprimer',
                style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }

  void _showEditInfoModal(BuildContext context) {
    final nameCtrl = TextEditingController(text: widget.user.name);
    final emailCtrl = TextEditingController(text: widget.user.email);
    final phoneCtrl = TextEditingController(text: widget.user.phone);
    bool loading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setModal) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Modifier mes informations',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                _modalField('Nom complet', nameCtrl),
                const SizedBox(height: 12),
                _modalField('Email', emailCtrl),
                const SizedBox(height: 12),
                _modalField('Téléphone', phoneCtrl),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading
                        ? null
                        : () async {
                            setModal(() => loading = true);
                            final authProvider = context.read<AuthProvider>();
                            final success = await authProvider.updateUserInfo(
                              nameCtrl.text.trim(),
                              emailCtrl.text.trim(),
                              phoneCtrl.text.trim(),
                            );
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (success) {
                              setState(() {
                                widget.user.name = nameCtrl.text.trim();
                                widget.user.email = emailCtrl.text.trim();
                                widget.user.phone = phoneCtrl.text.trim();
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(ctx).colorScheme.primary,
                        foregroundColor: Colors.white),
                    child: loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Enregistrer'),
                  ),
                ),
                const SizedBox(height: 20),
              ]),
        );
      }),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri))
      await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
