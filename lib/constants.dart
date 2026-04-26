import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';

const grandisExtendedFont = "Grandis Extended";

// On color 80, 60.... those means opacity

const Color primaryColor = Color(0XFF896CFE);
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
const MaterialColor primaryMaterialColor = MaterialColor(0XFF896CFE, <int, Color>{
  50: Color(0xFFEFECFF),
  100: Color(0xFFD7D0FF),
  200: Color(0xFFBDB0FF),
  300: Color(0xFFA390FF),
  400: Color(0xFF8F79FF),
  500: Color(0xFF7B61FF),
  600: Color(0xFF7359FF),
  700: Color(0xFF684FFF),
  800: Color(0xFF5E45FF),
  900: Color(0xFF6C56DD),
});
const LinearGradient primaryLinearGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF16161E),
    Color(0xFF1F1F2E),
    Color(0xFF0F0F17),
  ],
);
const Color blackColor = Color(0xFF16161E);
const Color blackColor80 = Color(0xFF45454B);
const Color blackColor60 = Color(0xFF737378);
const Color blackColor40 = Color(0xFFA2A2A5);
const Color blackColor20 = Color(0xFFD0D0D2);
const Color blackColor10 = Color(0xFFE8E8E9);
const Color blackColor5 = Color(0xFFF3F3F4);

const Color whiteColor = Colors.white;
const Color whileColor80 = Color(0xFFCCCCCC);
const Color whileColor60 = Color(0xFF999999);
const Color whileColor40 = Color(0xFF666666);
const Color whileColor20 = Color(0xFF333333);
const Color whileColor10 = Color(0xFF191919);
const Color whileColor5 = Color(0xFF0D0D0D);

const Color greyColor = Color(0xFFB8B5C3);
const Color lightGreyColor = Color(0xFFF8F8F9);
const Color darkGreyColor = Color(0xFF1C1C25);
// const Color greyColor80 = Color(0xFFC6C4CF);
// const Color greyColor60 = Color(0xFFD4D3DB);
// const Color greyColor40 = Color(0xFFE3E1E7);
// const Color greyColor20 = Color(0xFFF1F0F3);
// const Color greyColor10 = Color(0xFFF8F8F9);
// const Color greyColor5 = Color(0xFFFBFBFC);

const Color purpleColor = Color(0XFF216588);
const Color successColor = Color(0xFF2ED573);
const Color warningColor = Color(0xFFFFBE21);
const Color errorColor = Color(0xFFEA5B5B);

const double defaultPadding = 16.0;
const double defaultBorderRadious = 6.0;
const double defaultSpacing = 10.0;
const Duration defaultDuration = Duration(milliseconds: 300);

final passwordValidator = MultiValidator([
  RequiredValidator(errorText: 'Mot de passe requis'),
  MinLengthValidator(8, errorText: 'le mot de passe doit etre au moin 8 caractères'),
  PatternValidator(r'(?=.*?[#?!@$%^&*-])', errorText: 'le mot de passe doit avoir aumoins un caractère special'),
]);

final emaildValidator = MultiValidator([
  RequiredValidator(errorText: 'Email requis'),
  EmailValidator(errorText: "Entrez  email address valide"),
]);
final namedValidator = MultiValidator([RequiredValidator(errorText: 'Noms Complet requis')]);
final inputValidator = MultiValidator([RequiredValidator(errorText: 'Ce champs est requis')]);
final genredValidator = MultiValidator([RequiredValidator(errorText: 'Genre requis')]);

const pasNotMatchErrorText = "confirmation mot de passe incorrect";
//les données pour cherche par commande,
List<String> lesgenres = ["Feminin", "Masculin"];
List<String> etatBiens = ["Neuf", "Occasion"];
List<String> typeOperations = ["Vente", "Location"];
List<String> typeVentes = ["Normale", "Solde"];
List<String> devise = ["CFD", "USD"];
List<String> contratTransport = ["Aucun", "Totalement inclus", "partage 50/50", "À charge de l'acheteur"];
//publication de bien

// common widget

Widget buildTextField({
  required TextEditingController controller,
  required String label,
  required String hintText,
  required IconData icon,
  void Function(String?)? onChanged,
  int maxLines = 1,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (label.isNotEmpty) ...[
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
      ],
      Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: maxLines > 1 ? 16 : 14),
            prefixIcon: Icon(icon, color: Colors.grey.shade600),
          ),
        ),
      ),
    ],
  );
}

Widget buildDropdown({
  required String? value,
  required List<String> items,
  required String label,
  required Function(String?) onChanged,
  String? Function(String?)? validator,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black87),
      ),
      const SizedBox(height: 4),
      DropdownButtonFormField<String>(
        value: value,
        items: items.map((String item) {
          return DropdownMenuItem<String>(value: item, child: Text(item));
        }).toList(),
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    ],
  );
}

String stocktypefromBd(String stocktype) {
  if (stocktype == 'en_stock') return 'Stock';
  if (stocktype == 'sur_commande') return 'Commande';
  if (stocktype == 'groupage') return 'Groupage';
  return 'Stock';
}

String formatDateTime(String createdAt) {
  // Convertir la chaîne Laravel en DateTime
  DateTime date = DateTime.parse(createdAt).toLocal(); // Convertit en heure locale

  // Formatter la date
  String formattedDate = DateFormat('dd MMM yyyy').format(date);
  String formattedTime = DateFormat('HH:mm').format(date);

  return "$formattedDate à $formattedTime";
}

Future<String?> cacheNameUser() async {
  final prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString('user_name');
  return username;
}

Future<String?> shopName() async {
  final prefs = await SharedPreferences.getInstance();
  String? shopname = prefs.getString('shop_name');
  return shopname;
}

// set datas
Future setCacheNameUser(String nom) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('user_name', nom);
}

Future setShopName(String nom) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('shop_name', nom);
}
