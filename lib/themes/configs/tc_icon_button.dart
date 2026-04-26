import 'package:flutter/material.dart';

class IconButtonTheme {
  IconButtonTheme._();
  static final lightIconButton = IconButtonThemeData(
    style: IconButton.styleFrom(
      elevation: 0,
      disabledBackgroundColor: Colors.grey,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 30),
      iconSize: 30,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
  static final darkIconButton = IconButtonThemeData(
    style: IconButton.styleFrom(
      elevation: 0,
      disabledBackgroundColor: Colors.grey,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 30),
      iconSize: 30,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
  //dark mode
}
