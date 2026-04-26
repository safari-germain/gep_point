import 'package:gep_point/constants.dart';
import 'package:flutter/material.dart';

class DialogThemesData {
  DialogThemesData._();
  static final lightDialogTheme = DialogThemeData(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  );
  //dark mode
  static final darkDialogTheme = DialogThemeData(
    backgroundColor: const Color.fromARGB(255, 44, 43, 43),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(defaultBorderRadious),
    ),
  );
}
