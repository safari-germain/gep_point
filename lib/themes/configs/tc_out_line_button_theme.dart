import 'package:gep_point/constants.dart';
import 'package:flutter/material.dart';

class OutLineButtonThemes {
  OutLineButtonThemes._();

  static OutlinedButtonThemeData lightOutLineButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      backgroundColor: Colors.transparent,
      side: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      textStyle: const TextStyle(fontFamily: 'Plus Jakarta', fontSize: 11, color: Colors.black),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadious),
      ),
    ),
  );
  static OutlinedButtonThemeData darkOutLineButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      backgroundColor: Colors.transparent,
      side: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultPadding),
      ),
      textStyle: const TextStyle(fontFamily: 'Plus Jakarta', fontSize: 11, color: Colors.white),
    ),
  );
}
