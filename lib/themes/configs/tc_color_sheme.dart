import 'package:gep_point/constants.dart';
import 'package:flutter/material.dart';

class ColorShemee {
  ColorShemee._();

  static ColorScheme primaryColorSheme = ColorScheme.fromSeed(seedColor: primaryColor, brightness: Brightness.light);
  static ColorScheme darkColorSheme = ColorScheme.fromSeed(seedColor: primaryColor, brightness: Brightness.dark);
  static ColorScheme secondaryColorSheme = ColorScheme.fromSeed(seedColor: primaryColor, brightness: Brightness.light);
}
