import 'package:gep_point/constants.dart';
import 'package:flutter/material.dart';

class CardThemesData {
  CardThemesData._();

  static CardThemeData lightCardtheme = CardThemeData(
    elevation: 4,
    color: Colors.white,
    margin: EdgeInsets.all(5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(defaultBorderRadious),
    ),
    surfaceTintColor: Colors.white,
  );
  static CardThemeData darkCardtheme = CardThemeData(
    elevation: 6,
    color: const Color.fromARGB(255, 41, 41, 44),
    margin: EdgeInsets.all(5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(defaultBorderRadious),
    ),
  );
}
