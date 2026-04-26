import 'package:flutter/material.dart';
import 'package:gep_point/constants.dart';
import 'package:gep_point/models/m_user.dart';
import 'package:gep_point/models/m_specialized_profile.dart';
import 'package:gep_point/providers/profile_upgrade_provider.dart';
import 'package:gep_point/services/s_user.dart';
import 'package:gep_point/screen/profile/detail_profile_screen.dart'; // We will adapt this or create UserDetailView
import 'package:provider/provider.dart';
import 'package:gep_point/api_constants.dart';
import 'package:gep_point/services/s_dio/dio_service.dart';

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
  int? _selectedCompetenceId;

  @override
  void initState() {
    super.initState();
    // Initialiser les compétences pour les filtres
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileUpgradeProvider>().init();
    });
  }

  Future<void> _performSearch() async {
    setState(() => _isSearching = true);
    
    // On simule l'appel à UserController@search via un nouveau endpoint si nécessaire
    // ou on utilise UserService avec les nouveaux paramètres
    try {
      // NOTE: Je vais simuler l'appel via Dio directement ici car UserService n'a pas encore le search exhaustif
      // Mais dans un vrai projet on l'ajouterait à UserService
      final response = await _userService.searchUsers(
        query: _searchController.text,
        competenceId: _selectedCompetenceId,
      );
      setState(() {
        _users = response;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final competences = context.watch<ProfileUpgradeProvider>().allCompetences;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Chercher un talent...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          onChanged: (val) {
             if (val.length > 2) _performSearch();
          },
          onSubmitted: (val) => _performSearch(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _performSearch,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres de compétences
          if (competences.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: competences.length,
                itemBuilder: (context, index) {
                  final comp = competences[index];
                  final isSelected = _selectedCompetenceId == comp.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(comp.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCompetenceId = selected ? comp.id : null;
                        });
                        _performSearch();
                      },
                      selectedColor: primaryColor.withOpacity(0.2),
                      checkmarkColor: primaryColor,
                    ),
                  );
                },
              ),
            ),
          
          Expanded(
            child: _isSearching 
              ? const Center(child: CircularProgressIndicator())
              : _users.isEmpty 
                ? const Center(child: Text("Aucun utilisateur trouvé"))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      return _buildUserCard(user);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onTap: () {
          // Navigation vers les détails (on passera l'utilisateur sélectionné)
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailProfilScreen(viewedUser: user)),
          );
        },
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: user.profile != null 
                ? NetworkImage(getFullImageUrl(user.profile)) as ImageProvider
                : const AssetImage('assets/images/saf.jpg') as ImageProvider,
            ),
            // ICÔNE SPÉCIALE NIVEAU 1
            if (user.profileLevel == 1)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_user, color: Colors.blue, size: 14),
                ),
              ),
          ],
        ),
        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user.competences.isNotEmpty)
              Text(user.competences.first.name, style: const TextStyle(color: primaryColor)),
            Text(user.adresse ?? 'Aucune adresse', style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }
}

// Extension pour UserService pour inclure la recherche complexe
extension UserSearchExtension on UserService {
  Future<List<UserModel>> searchUsers({String? query, int? competenceId}) async {
    try {
      final dio = ApiClient().dio;
      final response = await dio.get('$baseURL/users/search', queryParameters: {
        if (query != null && query.isNotEmpty) 'query': query,
        if (competenceId != null) 'competence_id': competenceId,
      });
      
      if (response.statusCode == 200) {
        // Laravel paginate retourne les données dans 'data'
        final List data = response.data['data'] ?? [];
        return data.map((u) => UserModel.fromJson(u)).toList();
      }
    } catch (e) {
      print("Erreur recherche: $e");
    }
    return [];
  }
}
