import 'package:flutter/material.dart';

class IconThemes {
  IconThemes._();

  static IconThemeData lightIconTheme = IconThemeData(
    color: Colors.black.withOpacity(0.5),
    size: 24,
  );
  //dark Mode
  static IconThemeData darkIconTheme = IconThemeData(
    color: Colors.white.withOpacity(0.6),
    size: 24,
  );
}
