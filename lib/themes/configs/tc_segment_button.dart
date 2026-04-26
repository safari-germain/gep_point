import 'package:flutter/material.dart';

class SegmentButton {
  SegmentButton._();

  static SegmentedButtonThemeData lightSegmentButtontheme = SegmentedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(Colors.grey.shade100),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return Colors.teal;
      }),
      side: WidgetStateProperty.all(
        BorderSide(color: Colors.teal, width: 1),
      ),
    ),
  );
  static SegmentedButtonThemeData darkSegmentButtontheme = SegmentedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(Colors.grey.shade100),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return const Color.fromARGB(255, 51, 125, 253);
      }),
      side: WidgetStateProperty.all(
        BorderSide(color: Color.fromARGB(255, 51, 125, 253), width: 1),
      ),
    ),
  );
}
