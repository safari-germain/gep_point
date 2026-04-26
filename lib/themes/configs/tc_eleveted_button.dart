import 'package:gep_point/constants.dart';
import 'package:flutter/material.dart';

class ElevationButtonTheme {
  ElevationButtonTheme._();
  static final lightElevetedButton = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.white,
      backgroundColor: primaryColor,
      disabledBackgroundColor: Colors.grey,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 30),
      textStyle: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w300),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadious),
      ),
    ),
  );
  //dark mode

  static final darkElevetedButton = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.white,
      backgroundColor: primaryColor,
      disabledBackgroundColor: Colors.grey,
      side: const BorderSide(color: Colors.grey),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 30),
      textStyle: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w800),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadious),
      ),
    ),
  );
}
