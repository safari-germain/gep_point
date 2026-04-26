import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gep_point/constants.dart';
import 'package:gep_point/models/m_organisation_contact.dart';
import 'package:gep_point/screen/organisation/operation_history/operations_history_marchand.dart';
import 'package:gep_point/services/s_cash_wallet.dart';
import 'package:gep_point/services/s_organisation.dart';
import 'package:gep_point/providers/auth_provider.dart';
import 'package:gep_point/providers/wallet_provider.dart';
import 'package:gep_point/api_constants.dart';
import 'package:provider/provider.dart';
import 'package:gep_point/screen/organisation/add_organisation_contact_screen.dart';
import 'package:gep_point/screen/organisation/send_points_multi_screen.dart';
import 'package:image_picker/image_picker.dart';

class OrganisationDetailScreen extends StatefulWidget {
  final int organisationId;
  const OrganisationDetailScreen({super.key, required this.organisationId});

  @override
  State<OrganisationDetailScreen> createState() =>
      _OrganisationDetailScreenState();
}

class _OrganisationDetailScreenState extends State<OrganisationDetailScreen> {
  final OrganisationService _orgService = OrganisationService();
  final TextEditingController _searchController = TextEditingController();
  List<OrganisationContactModel> _contacts = [];
  List<OrganisationContactModel> _filteredContacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _loadBalances();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final contacts = await _orgService.getContacts();
      // final wal = _walletService.getOrganisationWallets(widget.organisationId);

      setState(() {
        _contacts = contacts;

        _filteredContacts = contacts;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterContacts(String query) {
    setState(() {
      _filteredContacts = _contacts
          .where((c) =>
              (c.user?.name.toLowerCase().contains(query.toLowerCase()) ??
                  false) ||
              (c.user?.email?.toLowerCase().contains(query.toLowerCase()) ??
                  false))
          .toList();
    });
  }

  Future<void> _loadBalances() async {
    final walletProvider = context.read<WalletProvider>();
    if (widget.organisationId != 0) {
      await walletProvider.fetchBalancesForOrganisation(widget.organisationId);
    }
  }

  Future<void> _editOrganisation(dynamic org) async {
    final nameController = TextEditingController(text: org?.name);
    final descController = TextEditingController(text: org?.description);
    File? selectedImage;
    final ImagePicker picker = ImagePicker();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Modifier l'organisation",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setModalState(() {
                        selectedImage = File(image.path);
                      });
                    }
                  },
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: selectedImage != null
                        ? FileImage(selectedImage!) as ImageProvider
                        : (org?.image != null
                            ? NetworkImage("$baseURlForImages/${org!.image}")
                            : null),
                    child: selectedImage == null && org?.image == null
                        ? const Icon(Icons.camera_alt,
                            color: Colors.grey, size: 30)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration:
                      const InputDecoration(labelText: "Nom de l'organisation"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: "Description"),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    setState(() => _isLoading = true);
                    Navigator.pop(context);
                    final result = await _orgService.updateOrganisation(
                      id: widget.organisationId,
                      name: nameController.text,
                      description: descController.text,
                      imagePath: selectedImage?.path,
                    );
                    setState(() => _isLoading = false);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result['message'])));
                      if (result['success']) {
                        // Refresh auth state to pull the new org image everywhere implicitly
                        context.read<AuthProvider>().checkLoginStatus();
                        _fetchData();
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Enregistrer"),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> _sendToSelf(double availableBalance) async {
    final amountController = TextEditingController();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("S'envoyer des points"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Transférer des points vers votre compte personnel."),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Montant",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 8),
            Text("Disponible: $availableBalance PTS",
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Annuler")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Envoyer"),
          ),
        ],
      ),
    );

    if (confirmed == true && amountController.text.isNotEmpty) {
      final amount = double.tryParse(amountController.text);
      if (amount == null || amount <= 0) {
        if (mounted)
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Montant invalide")));
        return;
      }

      String selectedType = 'marchand';
      final bool? typeConfirmed = await showDialog<bool>(
        context: context,
        builder: (context) =>
            StatefulBuilder(builder: (context, setModalState) {
          return AlertDialog(
            title: const Text("Choisir le type de point"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text("Marchand -> Standard)"),
                  value: 'marchand',
                  groupValue: selectedType,
                  onChanged: (val) => setModalState(() => selectedType = val!),
                ),
                RadioListTile<String>(
                  title: const Text("Non-Standard"),
                  value: 'notoriete',
                  groupValue: selectedType,
                  onChanged: (val) => setModalState(() => selectedType = val!),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Annuler")),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Confirmer")),
            ],
          );
        }),
      );

      if (typeConfirmed != true) return;

      final currentBalance =
          context.read<WalletProvider>().getBalance(selectedType);
      if (amount > currentBalance) {
        if (mounted)
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Solde insuffisant")));
        return;
      }

      final idController = TextEditingController();
      final bool? idConfirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Saisissez votre ID"),
          content: TextField(
            controller: idController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Votre ID Utilisateur",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Annuler")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Confirmer"),
            ),
          ],
        ),
      );

      if (idConfirmed == true && idController.text.isNotEmpty) {
        final currentUserId = int.tryParse(idController.text);
        if (currentUserId == null) return;

        setState(() => _isLoading = true);
        final result = await _orgService.distributePoints(
          beneficiaryId: currentUserId,
          amount: amount,
          pointType: selectedType,
        );
        setState(() => _isLoading = false);

        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(result['message'])));
          if (result['success']) {
            context.read<WalletProvider>().fetchBalances();
            _fetchData();
          }
        }
      }
    }
  }

  Future<void> _changeValidator() async {
    final searchController = TextEditingController();
    List<Map<String, dynamic>> searchResults = [];
    bool isSearching = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(builder: (context, setModalState) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 20),
              const Text("Changer le validateur",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: "Rechercher un utilisateur",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (query) async {
                  if (query.length > 2) {
                    setModalState(() => isSearching = true);
                    final results = await _orgService.searchUsers(query);
                    setModalState(() {
                      searchResults = results;
                      isSearching = false;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              if (isSearching) const CircularProgressIndicator(),
              if (!isSearching && searchResults.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final user = searchResults[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: primaryColor.withOpacity(0.1),
                          child: Text(user['name'][0],
                              style: const TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold)),
                        ),
                        title: Text(user['name']),
                        subtitle: Text(user['email'] ?? ''),
                        onTap: () async {
                          Navigator.pop(context);
                          setState(() => _isLoading = true);
                          final result = await _orgService.updateValidator(
                              widget.organisationId, user['id']);
                          setState(() => _isLoading = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(result['message'])));
                          }
                        },
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();

    final merchantBalance = walletProvider.getBalance('marchand');
    final notorietyBalance = walletProvider.getBalance('notoriete');
    final authProvider = context.watch<AuthProvider>();
    final org = authProvider.user?.organisation;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Organisation"),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => _editOrganisation(org),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadBalances();
          _fetchData();
        },
        child: ListView(
          padding: const EdgeInsets.all(defaultPadding),
          children: [
            /// Organisation Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                      : [primaryColor.withOpacity(0.05), Colors.white],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryColor.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryColor, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: org?.image != null
                          ? NetworkImage("$baseURlForImages/${org!.image}")
                          : const AssetImage("assets/images/pharma.jpeg")
                              as ImageProvider,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          org?.name ?? "Mon Organisation",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          org?.description ?? "Gérer votre organisation",
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade500),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${_contacts.length} membre${_contacts.length > 1 ? 's' : ''}",
                            style: TextStyle(
                                fontSize: 12,
                                color: primaryColor,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Points Marchand Card — Premium
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            OperationsHistroryMarchandPointScreen(
                              organisationId: widget.organisationId,
                            )));
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667eea).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                      Icons.account_balance_wallet_rounded,
                                      color: Colors.white,
                                      size: 18),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "Points Marchand",
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "${merchantBalance.toStringAsFixed(0)} PTS",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.trending_up_rounded,
                              color: Colors.white, size: 28),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// Points Notoriété Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFf093fb).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Points Notoriété",
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${notorietyBalance.toStringAsFixed(0)} PTS",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.star_rounded, color: Colors.white, size: 32),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// Actions
            Text(
              "Actions rapides",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.person_rounded,
                    label: "S'envoyer",
                    color: const Color(0xFF2196F3),
                    onTap: () => _sendToSelf(merchantBalance),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.qr_code_scanner_rounded,
                    label: "Scanner",
                    color: const Color(0xFF009688),
                    onTap: () => _scanAction(merchantBalance),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.groups_rounded,
                    label: "Multi Envoi",
                    color: const Color(0xFFFF9800),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => SendPointsMultiScreen(
                                  contacts: _contacts,
                                  merchantBalance: merchantBalance,
                                  notorietyBalance: notorietyBalance,
                                )),
                      );
                      if (result == true) _fetchData();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.admin_panel_settings_rounded,
                    label: "Validateur",
                    color: const Color(0xFFE91E63),
                    onTap: _changeValidator,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// Répertoire de contact
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Répertoire",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.person_add_rounded, size: 18),
                  label: const Text("Ajouter"),
                  style: TextButton.styleFrom(foregroundColor: primaryColor),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => AddOrganisationContactScreen(
                                organisationId: widget.organisationId,
                              )),
                    );
                    if (result == true) _fetchData();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            /// Search bar
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.withOpacity(0.15)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterContacts,
                decoration: InputDecoration(
                  hintText: "Rechercher un membre...",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon:
                      Icon(Icons.search_rounded, color: Colors.grey.shade400),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (_isLoading)
              const Center(
                  child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ))
            else if (_filteredContacts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.people_outline_rounded,
                          size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text("Aucun contact",
                          style: TextStyle(
                              color: Colors.grey.shade400, fontSize: 15)),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredContacts.length,
                itemBuilder: (context, index) {
                  final contact = _filteredContacts[index];
                  final user = contact.user;
                  return _buildContactTile(user, merchantBalance);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? color.withOpacity(0.12) : color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactTile(dynamic user, double availableBalance) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasProfile = user?.profile != null && user!.profile!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: primaryColor.withOpacity(0.1),
          backgroundImage: hasProfile
              ? (user!.profile!.startsWith('http')
                  ? NetworkImage(user.profile!)
                  : AssetImage(user.profile!) as ImageProvider)
              : null,
          child: !hasProfile
              ? Text(
                  user?.name[0] ?? '?',
                  style: const TextStyle(
                      color: primaryColor, fontWeight: FontWeight.bold),
                )
              : null,
        ),
        title: Text(
          user?.name ?? 'Utilisateur inconnu',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          user?.email ?? 'Pas d\'email',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        trailing: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => _sendToContact(user, availableBalance),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  const Icon(Icons.send_rounded, color: primaryColor, size: 18),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendToContact(dynamic user, double availableBalance) async {
    final amountController = TextEditingController();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Envoyer à ${user?.name}"),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "Montant",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Annuler")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Envoyer"),
          ),
        ],
      ),
    );

    if (confirmed == true && amountController.text.isNotEmpty) {
      final amount = double.tryParse(amountController.text) ?? 0;
      if (amount <= 0) return;

      String selectedType = 'marchand';
      final bool? typeConfirmed = await showDialog<bool>(
        context: context,
        builder: (context) =>
            StatefulBuilder(builder: (context, setModalState) {
          return AlertDialog(
            title: const Text("Choisir le type de point"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text("Marchand (Standard)"),
                  value: 'marchand',
                  groupValue: selectedType,
                  onChanged: (val) => setModalState(() => selectedType = val!),
                ),
                RadioListTile<String>(
                  title: const Text("Notoriété (Non-Standard)"),
                  value: 'notoriete',
                  groupValue: selectedType,
                  onChanged: (val) => setModalState(() => selectedType = val!),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Annuler")),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Confirmer")),
            ],
          );
        }),
      );

      if (typeConfirmed != true) return;

      final currentBalance =
          context.read<WalletProvider>().getBalance(selectedType);
      if (amount > currentBalance) {
        if (mounted)
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Solde insuffisant")));
        return;
      }

      setState(() => _isLoading = true);
      final result = await _orgService.distributePoints(
        beneficiaryId: user!.id,
        amount: amount,
        pointType: selectedType,
      );
      setState(() => _isLoading = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(result['message'])));
        if (result['success']) {
          context.read<WalletProvider>().fetchBalances();
          _fetchData();
        }
      }
    }
  }

  Future<void> _scanAction(double availableBalance) async {
    final scannedIdStr = await _promptManualEntry(context, "ID scanné");

    if (scannedIdStr != null && context.mounted) {
      final scannedId = int.tryParse(scannedIdStr.toString());
      if (scannedId != null) {
        final amountController = TextEditingController();
        final bool? confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Envoyer via Scan"),
            content: TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Montant",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Annuler")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Envoyer"),
              ),
            ],
          ),
        );

        if (confirmed == true && amountController.text.isNotEmpty) {
          setState(() => _isLoading = true);
          final result = await _orgService.distributePoints(
            beneficiaryId: scannedId,
            amount: double.tryParse(amountController.text) ?? 0,
          );
          setState(() => _isLoading = false);
          if (context.mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(result['message'])));
            if (result['success']) {
              context.read<WalletProvider>().fetchBalances();
              _fetchData();
            }
          }
        }
      }
    }
  }

  Future<String?> _promptManualEntry(BuildContext context, String title) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Saisissez l'ID",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text("Valider"),
          ),
        ],
      ),
    );
  }
}
