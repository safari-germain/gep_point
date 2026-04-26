import 'package:flutter/material.dart';
import 'package:gep_point/screen/auth/login_screen.dart';
import 'package:gep_point/screen/auth/signup_screen.dart';

class AuthMenu {
  static void show(BuildContext context, {bool fromBottom = false}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showMenu<String>(
      context: context,
      position: fromBottom
          ? RelativeRect.fromLTRB(
              screenWidth - 200, // Position horizontale
              screenHeight - 200, // Position verticale (en bas)
              0,
              0,
            )
          : RelativeRect.fromLTRB(
              screenWidth - 200,
              kToolbarHeight + 20,
              0,
              0,
            ),
      items: [
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            'Vous n\'êtes pas connecté',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
              fontSize: 12,
            ),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'login',
          child: Row(
            children: [
              Icon(Icons.login, size: 20, color: Colors.blue),
              SizedBox(width: 8),
              Text('Se connecter'),
            ],
          ),
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
            });
          },
        ),
        PopupMenuItem<String>(
          value: 'signup',
          child: Row(
            children: [
              Icon(Icons.person_add, size: 20, color: Colors.green),
              SizedBox(width: 8),
              Text('Créer un compte'),
            ],
          ),
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
            });
          },
        ),
      ],
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
