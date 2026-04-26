import 'package:gep_point/constants.dart';
import 'package:flutter/material.dart';

class DropDownButtonThemeDatas {
  DropDownButtonThemeDatas._();

  static DropdownMenuThemeData lightDropDownButontheme = DropdownMenuThemeData(
    // Style du DropdownButton
    menuStyle: MenuStyle(
      backgroundColor: WidgetStatePropertyAll(Colors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        borderSide: BorderSide(color: primaryColor),
      ),
    ),
  );
  static DropdownMenuThemeData darkDropDownButontheme = DropdownMenuThemeData(
    // Style du DropdownButton
    menuStyle: MenuStyle(backgroundColor: WidgetStatePropertyAll(const Color.fromARGB(255, 39, 39, 39))),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        borderSide: BorderSide(color: primaryColor),
      ),
    ),
  );
}
