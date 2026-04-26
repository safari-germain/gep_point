import 'package:flutter/material.dart';

class SwitchThemes {
  SwitchThemes._();

  static SwitchThemeData lightSwichThemeData = SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color.fromARGB(255, 59, 129, 252);
      }
      return Colors.black;
    }),
    trackOutlineColor: WidgetStatePropertyAll(
      Colors.grey.withOpacity(0.3),
    ),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.blueAccent.withOpacity(0.5);
      }
      return Colors.white;
    }),
  );
  static SwitchThemeData darkSwichThemeData = SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.teal;
      }
      return Colors.white;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.teal.withOpacity(0.5);
      }
      return Colors.black;
    }),
  );
}
