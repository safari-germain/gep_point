import 'package:flutter/material.dart';

class CheckBoxTheme {
  CheckBoxTheme._();

  static CheckboxThemeData lightCheckBoxThemeData = CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    checkColor: WidgetStateProperty.resolveWith(
      (states) {
        if (states.contains(WidgetState.selected)) {
          return const Color.fromARGB(255, 59, 129, 252);
        }
        return Colors.black;
      },
    ),
  );
}
