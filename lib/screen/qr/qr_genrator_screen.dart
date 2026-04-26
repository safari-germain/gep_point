import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gep_point/constants.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import 'package:gep_point/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class MyQrScreen extends StatelessWidget {
  const MyQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final String qrData = user?.id.toString() ?? "unknown";
    final String name = user?.name ?? "Nom inconnu";
    final String username = user?.email ?? "@inconnu";

    return Scaffold(
      backgroundColor: primaryColor, // Fond similaire à TikTok
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white, // Carte blanche pour le QR
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar rond
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/images/saf.jpg'), // ton image
                  ),
                  const SizedBox(height: 12),
                  // Nom
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  // Pseudo
                  Text(
                    username,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // QR Code
                  QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 220,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Colors.black,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Colors.black,
                    ),
                    embeddedImage: AssetImage('assets/images/logo.png'),
                    embeddedImageStyle: const QrEmbeddedImageStyle(
                      size: Size(40, 40),
                    ),
                    errorStateBuilder: (cxt, err) {
                      return const Center(
                        child: Text(
                          "Erreur de génération",
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Boutons copy/share
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: qrData));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Lien copié !")),
                          );
                        },
                        icon: const Icon(Icons.link),
                        label: const Text("Copy link"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Share.share(qrData);
                        },
                        icon: const Icon(Icons.share),
                        label: const Text("Share link"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
