import 'package:gep_point/constants.dart';
import 'package:flutter/material.dart';

class TextButtonThemes {
  TextButtonThemes._();

  static TextButtonThemeData lightTextButtonThemeData = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: primaryColor,
      textStyle: const TextStyle(fontFamily: 'Plus Jakarta', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
    ),
  );
  static TextButtonThemeData darkTextButtonThemeData = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: primaryColor,
      textStyle: const TextStyle(fontFamily: 'Plus Jakarta', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
    ),
  );
}
