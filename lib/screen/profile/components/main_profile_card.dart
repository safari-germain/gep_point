import 'package:flutter/material.dart';
import 'package:gep_point/components/card/common_card.dart';
import 'package:gep_point/providers/profile_provider.dart';
import 'package:provider/provider.dart';
import '../../../../constants.dart';

class MainProfileCard extends StatelessWidget {
  const MainProfileCard({
    super.key,
    required this.name,
    required this.role,
    required this.email,
    required this.imageSrc,
    this.orgName,
    this.orgImageSrc,
    this.hasOrganisation = false,
    this.press,
  });

  final String name, role, email, imageSrc;
  final String? orgName, orgImageSrc;
  final bool hasOrganisation;
  final VoidCallback? press;

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final bool isOrgMode = profileProvider.activeMode == ProfileMode.organisation;

    // L'actif est à gauche (grand), l'inactif à droite (petit)
    final String leadingImage = isOrgMode ? (orgImageSrc ?? 'assets/images/pharma.jpeg') : imageSrc;
    final String? trailingImage = hasOrganisation
        ? (isOrgMode ? imageSrc : (orgImageSrc ?? 'assets/images/pharma.jpeg'))
        : null;

    return CommonCard(
      child: ListTile(
        onTap: press,
        leading: CircleAvatar(
          radius: 28,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: leadingImage.startsWith('http') 
              ? Image.network(leadingImage, fit: BoxFit.cover, width: 56, height: 56)
              : Image.asset(leadingImage, fit: BoxFit.cover, width: 56, height: 56),
          ),
        ),
        title: Text(
          isOrgMode ? (orgName ?? name) : name,
          style: const TextStyle(fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(email),
        trailing: trailingImage != null
            ? CircleAvatar(
                radius: 20,
                backgroundColor: primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(1.7),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: trailingImage.startsWith('http')
                      ? Image.network(trailingImage, fit: BoxFit.cover, width: 40, height: 40)
                      : Image.asset(trailingImage, fit: BoxFit.cover, width: 40, height: 40),
                  ),
                ),
              )
            : Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.swap_horiz_rounded, color: primaryColor, size: 20),
              ),
      ),
    );
  }
}
