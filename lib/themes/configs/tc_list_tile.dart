import 'package:gep_point/constants.dart';
import 'package:flutter/material.dart';

class ListTileThemes {
  ListTileThemes._();

  static ListTileThemeData lightListTileTheme = ListTileThemeData(
    iconColor: primaryColor,
    textColor: Colors.black.withOpacity(0.5),
    tileColor: Colors.transparent,
  );

  //dark mode
  static ListTileThemeData darkListTileTheme =
      ListTileThemeData(iconColor: primaryColor, textColor: Colors.grey.shade300, tileColor: Colors.transparent);
}
