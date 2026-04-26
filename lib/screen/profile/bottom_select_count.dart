import 'package:flutter/material.dart';
import 'package:gep_point/api_constants.dart';
import 'package:gep_point/constants.dart';
import 'package:gep_point/providers/auth_provider.dart';
import 'package:gep_point/providers/profile_provider.dart';
import 'package:gep_point/screen/organisation/create_organisation_screen.dart';
import 'package:gep_point/screen/organisation/organisation_detail_screen.dart';
import 'package:provider/provider.dart';

void showRoleBottomSheet(BuildContext context) {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
  final user = authProvider.user;

  if (user == null) return;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Drag Indicator
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Icon(Icons.swap_horiz_rounded, color: primaryColor, size: 22),
                const SizedBox(width: 10),
                Text(
                  "Changer de profil",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Basculez entre votre compte personnel et votre organisation",
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ),

            const SizedBox(height: 20),

            /// CARD COMPTE PERSONNEL
            _roleCard(
              context: context,
              name: "${user.name} ${user.prenom ?? ''}",
              role: "Compte Personnel",
              imageUrl: user.profile != null
                  ? "$baseURlForImages/${user.profile}"
                  : "assets/images/saf.jpg",
              isActive: profileProvider.activeMode == ProfileMode.user,
              icon: Icons.person_rounded,
              onTap: () {
                profileProvider.setProfileMode(ProfileMode.user);
                Navigator.pop(context);
              },
            ),

            const SizedBox(height: 12),

            /// CARD ORGANISATION
            if (user.organisation != null)
              _roleCard(
                context: context,
                name: user.organisation!.name,
                role: "Profil Organisation",
                imageUrl: user.organisation!.image != null
                    ? "$baseURlForImages/${user.organisation!.image}"
                    : "assets/images/pharma.jpeg",
                isActive: profileProvider.activeMode == ProfileMode.organisation,
                icon: Icons.business_rounded,
                onTap: () {
                  profileProvider.setProfileMode(ProfileMode.organisation, organisationId: user.organisation!.id);
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => OrganisationDetailScreen(organisationId:user.organisation!.id,)));
                },
              )
            else
              _addOrgCard(
                context: context,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateOrganisationScreen(currentUserId: user.id)),
                  );
                },
              ),

            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

Widget _roleCard({
  required BuildContext context,
  required String name,
  required String role,
  required String imageUrl,
  required bool isActive,
  required IconData icon,
  required VoidCallback onTap,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return AnimatedContainer(
    duration: const Duration(milliseconds: 250),
    curve: Curves.easeInOut,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isActive
                ? primaryColor.withOpacity(isDark ? 0.15 : 0.06)
                : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? primaryColor.withOpacity(0.6) : Colors.grey.withOpacity(0.15),
              width: isActive ? 1.8 : 1,
            ),
          ),
          child: Row(
            children: [
              /// Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? primaryColor : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 26,
                  backgroundImage: imageUrl.startsWith('http')
                      ? NetworkImage(imageUrl) as ImageProvider
                      : AssetImage(imageUrl),
                ),
              ),

              const SizedBox(width: 14),

              /// Name & Role
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(icon, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          role,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (isActive)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: successColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: successColor,
                    size: 20,
                  ),
                )
              else
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _addOrgCard({
  required BuildContext context,
  required VoidCallback onTap,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: primaryColor.withOpacity(0.3),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_business_rounded, size: 26, color: primaryColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Créer une organisation",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Gérer une équipe et distribuer des points",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: primaryColor, size: 22),
          ],
        ),
      ),
    ),
  );
}
