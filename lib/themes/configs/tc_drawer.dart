import 'package:flutter/material.dart';

class DrowerThemeData {
  DrowerThemeData._();

  static DrawerThemeData lightDrawerThemeData = DrawerThemeData(
      backgroundColor: Colors.white,
      shadowColor: Colors.black.withOpacity(0.5),
      elevation: 0,
      width: 230,
      surfaceTintColor: Colors.blue.withOpacity(0.4));

//mode dark
  static DrawerThemeData darkDrawerThemeData = DrawerThemeData(
      backgroundColor: const Color.fromARGB(255, 31, 30, 30),
      shadowColor: Colors.black.withOpacity(0.5),
      elevation: 0,
      width: 230,
      surfaceTintColor: Colors.blue.withOpacity(0.4));
}
