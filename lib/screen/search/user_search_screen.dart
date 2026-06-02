import 'package:flutter/material.dart';
import 'package:gep_point/constants.dart';
import 'package:gep_point/models/m_user.dart';
import 'package:gep_point/providers/profile_upgrade_provider.dart';
import 'package:gep_point/services/s_user.dart';
import 'package:gep_point/screen/search/talent_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:gep_point/api_constants.dart';
import 'package:gep_point/services/s_dio/dio_service.dart';
import 'package:google_fonts/google_fonts.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});
  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final UserService _userService = UserService();

  List<UserModel> _users = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  int? _selectedCompetenceId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileUpgradeProvider>().init();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });
    try {
      final dio = ApiClient().dio;
      final response = await dio.get('$baseURL/users/search', queryParameters: {
        if (_searchController.text.isNotEmpty) 'query': _searchController.text,
        if (_selectedCompetenceId != null) 'competence_id': _selectedCompetenceId,
        'per_page': 20,
      });
      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        setState(() {
          _users = data.map((u) => UserModel.fromJson(u)).toList();
        });
      }
    } catch (e) {
      debugPrint('Search error: $e');
    }
    setState(() => _isSearching = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final competences = context.watch<ProfileUpgradeProvider>().allCompetences;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            _buildFilterBar(theme, competences),
            Expanded(child: _buildBody(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Marché de Talents',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Trouvez les meilleurs profils',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Hero(
            tag: 'search_bar',
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _searchController.text.isNotEmpty
                        ? theme.colorScheme.primary.withOpacity(0.4)
                        : theme.colorScheme.outlineVariant.withOpacity(0.3),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Nom, email, compétence...',
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded),
                            color: theme.colorScheme.onSurfaceVariant,
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _users = [];
                                _hasSearched = false;
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (v) {
                    setState(() {});
                    if (v.length > 2) _performSearch();
                  },
                  onSubmitted: (_) => _performSearch(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(ThemeData theme, competences) {
    if (competences.isEmpty) return const SizedBox.shrink();
    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          const SizedBox(height: 10),
          SizedBox(
            height: 38,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: competences.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final c = competences[i];
                final sel = _selectedCompetenceId == c.id;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedCompetenceId = sel ? null : c.id);
                    _performSearch();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant.withOpacity(0.4),
                      ),
                    ),
                    child: Text(
                      c.name,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: sel
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isSearching) return _buildShimmer(theme);
    if (!_hasSearched) return _buildEmptyState(theme);
    if (_users.isEmpty) return _buildNoResult(theme);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: _users.length,
      itemBuilder: (_, i) => _SearchResultCard(user: _users[i]),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_search_rounded,
              size: 56,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Recherchez un talent',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tapez un nom, email ou sélectionnez\nune compétence pour commencer',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResult(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 56,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun talent trouvé',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Essayez avec d'autres mots-clés",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        height: 88,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CARTE DE RÉSULTAT — Adapts to theme
// ─────────────────────────────────────────────────────────────────────────────
class _SearchResultCard extends StatelessWidget {
  final UserModel user;
  const _SearchResultCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isExpert = user.profileLevel == 3;
    final bool isConfirmed = user.profileLevel >= 2;

    final badgeColor = isExpert
        ? theme.colorScheme.primary
        : isConfirmed
            ? const Color(0xFFF59E0B)
            : theme.colorScheme.outline;

    final badgeLabel = isExpert
        ? 'EXPERT ✦'
        : isConfirmed
            ? 'CONFIRMÉ'
            : 'BASIQUE';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TalentDetailScreen(user: user, readOnly: true),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isExpert
                ? theme.colorScheme.primary.withOpacity(0.25)
                : theme.colorScheme.outlineVariant.withOpacity(0.4),
            width: isExpert ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            _buildAvatar(theme, isExpert, isConfirmed),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildBadge(theme, badgeLabel, badgeColor),
                    ],
                  ),
                  if (user.competences.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      user.competences.map((c) => c.name).take(3).join(' · '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isExpert
                            ? theme.colorScheme.primary
                            : const Color(0xFFF59E0B),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                  if (user.email != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            user.email!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (user.experiences.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.work_outline_rounded,
                          size: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${user.experiences.first.jobTitle} · ${user.experiences.first.companyName}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme, bool isExpert, bool isConfirmed) {
    final initials = _initials();
    return Container(
      decoration: isExpert
          ? BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            )
          : null,
      child: CircleAvatar(
        radius: 26,
        backgroundColor: theme.colorScheme.primaryContainer,
        backgroundImage: user.profile != null
            ? getImageProvider(user.profile)
            : null,
        child: user.profile == null
            ? Text(
                initials,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildBadge(ThemeData theme, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _initials() {
    final parts = user.name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';
  }
}

// Extension pour la recherche
extension UserSearchExtension on UserService {
  Future<List<UserModel>> searchUsers({String? query, int? competenceId}) async {
    try {
      final dio = ApiClient().dio;
      final response = await dio.get('$baseURL/users/search', queryParameters: {
        if (query != null && query.isNotEmpty) 'query': query,
        if (competenceId != null) 'competence_id': competenceId,
      });
      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        return data.map((u) => UserModel.fromJson(u)).toList();
      }
    } catch (e) {
      debugPrint("Erreur recherche: $e");
    }
    return [];
  }
}
